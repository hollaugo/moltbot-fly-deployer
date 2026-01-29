---
name: deploy-moltbot-to-fly
description: Deploy Moltbot (Clawdbot) to Fly.io with proper proxy configuration, trusted proxies setup, and device pairing
---

# Deploy Moltbot to Fly.io

You are helping the user deploy Moltbot (also known as Clawdbot) to Fly.io. This is a comprehensive guide that handles all the tricky configuration including trusted proxies for Fly's internal network and device pairing approval.

## Overview

Deploying Moltbot to Fly.io requires:
1. Setting up the Fly app with a persistent volume
2. Configuring environment secrets (API keys, gateway token)
3. Setting up `trustedProxies` to allow Fly's internal proxy network
4. Approving device pairing for web UI access

## Prerequisites

Before starting:
- [ ] Fly.io CLI installed (`brew install flyctl` or `curl -L https://fly.io/install.sh | sh`)
- [ ] Fly.io account and logged in (`fly auth login`)
- [ ] Anthropic API key (and optionally OpenAI API key)
- [ ] Git installed

## Phase 1: Clone and Setup

### 1.1 Clone the Moltbot Repository

```bash
git clone https://github.com/moltbot/moltbot.git
cd moltbot
```

### 1.2 Create .env.example

Create a `.env.example` file in the project root with the required environment variables:

```bash
cat > .env.example << 'EOF'
# Required: Your Anthropic API key
ANTHROPIC_API_KEY=sk-ant-xxxxx

# Optional: OpenAI API key for fallback models
OPENAI_API_KEY=sk-xxxxx

# Required: Gateway token for authentication (generate with: openssl rand -hex 32)
CLAWDBOT_GATEWAY_TOKEN=your-64-char-hex-token

# Optional: Slack Bot Token (if using Slack)
SLACK_BOT_TOKEN=xoxb-xxxxx

# Optional: Discord Bot Token (if using Discord)
DISCORD_BOT_TOKEN=your-discord-bot-token
EOF
```

**Tell the user:**
"Please copy `.env.example` to `.env` and fill in your API keys. At minimum, you need:
- `ANTHROPIC_API_KEY`: Your Anthropic API key
- `CLAWDBOT_GATEWAY_TOKEN`: Generate with `openssl rand -hex 32`"

### 1.3 Generate Gateway Token

```bash
openssl rand -hex 32
```

Save this token - you'll need it for Fly secrets and for web UI authentication.

## Phase 2: Fly.io Configuration

### 2.1 Create fly.toml

Create or update `fly.toml` in the project root:

```toml
app = 'your-app-name'
primary_region = 'iad'

[build]
  dockerfile = 'Dockerfile'

[env]
  NODE_ENV = 'production'
  TZ = 'UTC'

[processes]
  app = "node dist/index.js gateway --allow-unconfigured --port 3000 --bind lan"

[[mounts]]
  source = 'moltbot_data'
  destination = '/data'

[[vm]]
  size = 'shared-cpu-2x'
  memory = '2gb'

[[services]]
  internal_port = 3000
  protocol = 'tcp'

  [[services.ports]]
    handlers = ['http']
    port = 80
    force_https = true

  [[services.ports]]
    handlers = ['tls', 'http']
    port = 443
```

**CRITICAL:** The `--bind lan` flag is essential. It tells the gateway to bind to the LAN interface which maps to `0.0.0.0` inside the Fly VM.

### 2.2 Create the Fly App

```bash
fly apps create your-app-name
```

### 2.3 Create Persistent Volume

```bash
fly volumes create moltbot_data --region iad --size 1
```

### 2.4 Set Fly Secrets

```bash
# Required secrets
fly secrets set ANTHROPIC_API_KEY="sk-ant-xxxxx" -a your-app-name
fly secrets set CLAWDBOT_GATEWAY_TOKEN="$(openssl rand -hex 32)" -a your-app-name

# Optional secrets
fly secrets set OPENAI_API_KEY="sk-xxxxx" -a your-app-name
fly secrets set SLACK_BOT_TOKEN="xoxb-xxxxx" -a your-app-name
fly secrets set DISCORD_BOT_TOKEN="your-token" -a your-app-name
```

**Important:** Save the `CLAWDBOT_GATEWAY_TOKEN` value - you'll need it later for device pairing.

To retrieve the token later:
```bash
fly ssh console -a your-app-name -C "printenv CLAWDBOT_GATEWAY_TOKEN"
```

## Phase 3: Deploy

### 3.1 Deploy to Fly.io

```bash
fly deploy -a your-app-name
```

The first deploy may take a few minutes. Watch for the "listening on ws://0.0.0.0:3000" message in the logs.

### 3.2 Verify Deployment

```bash
fly logs -a your-app-name --no-tail | tail -30
```

Look for:
- `[gateway] listening on ws://0.0.0.0:3000`
- `[slack] socket mode connected` (if using Slack)

## Phase 4: Configure Trusted Proxies

**CRITICAL STEP:** Fly.io routes traffic through internal proxies (172.16.x.x). Without configuring `trustedProxies`, all connections will fail with "Proxy headers detected from untrusted address".

### 4.1 SSH into the Fly Machine

```bash
fly ssh console -a your-app-name
```

### 4.2 Update moltbot.json with trustedProxies

```bash
node -e "
const fs = require('fs');
const configPath = '/data/moltbot.json';
let config = {};
try { config = JSON.parse(fs.readFileSync(configPath)); } catch {}

// Ensure gateway config exists
config.gateway = config.gateway || {};

// Add trusted proxies - MUST include the exact Fly proxy IP
// Check your logs for the actual proxy IP (e.g., 172.16.3.162)
config.gateway.trustedProxies = [
  '172.16.0.0/12',
  '10.0.0.0/8',
  '172.16.3.162'  // Add the specific IP from your logs
];

config.gateway.mode = 'local';
config.gateway.bind = 'lan';

fs.writeFileSync(configPath, JSON.stringify(config, null, 2));
console.log('Config updated with trustedProxies');
"
```

### 4.3 Verify Config

```bash
cat /data/moltbot.json | grep -A5 trustedProxies
```

### 4.4 Exit and Restart

```bash
exit
fly machines restart -a your-app-name
```

Wait ~60 seconds for the gateway to fully start.

## Phase 5: Device Pairing

When you first access the web UI, you'll see "pairing required" errors. This is because Moltbot requires device authentication for security.

### 5.1 Access the Web UI

Open: `https://your-app-name.fly.dev/`

You'll see connection errors - this is expected before pairing.

### 5.2 Check Pending Pairings

```bash
fly ssh console -a your-app-name -C "cat /data/devices/pending.json"
```

You should see a pending pairing request with a `requestId` and `deviceId`.

### 5.3 Approve the Pairing

```bash
fly ssh console -a your-app-name -C 'node -e "
const fs = require(\"fs\");
const pending = JSON.parse(fs.readFileSync(\"/data/devices/pending.json\"));
const paired = JSON.parse(fs.readFileSync(\"/data/devices/paired.json\") || \"{}\");
const requestId = Object.keys(pending)[0];
if (requestId) {
  const device = pending[requestId];
  paired[device.deviceId] = {
    deviceId: device.deviceId,
    publicKey: device.publicKey,
    platform: device.platform,
    clientId: device.clientId,
    role: device.role,
    roles: device.roles,
    scopes: device.scopes,
    approvedAt: Date.now(),
    approvedBy: \"cli\"
  };
  delete pending[requestId];
  fs.writeFileSync(\"/data/devices/pending.json\", JSON.stringify(pending, null, 2));
  fs.writeFileSync(\"/data/devices/paired.json\", JSON.stringify(paired, null, 2));
  console.log(\"Approved device:\", device.deviceId);
} else {
  console.log(\"No pending devices\");
}
"'
```

### 5.4 Verify Connection

Refresh the browser. Check the logs:

```bash
fly logs -a your-app-name --no-tail | tail -10
```

Look for: `webchat connected conn=... client=moltbot-control-ui`

## Phase 6: Verification Checklist

Run through this checklist to verify everything works:

```
## Deployment Verification

- [ ] Gateway listening: `fly logs -a APP | grep "listening on ws"`
- [ ] No proxy warnings: `fly logs -a APP | grep -v "untrusted address"`
- [ ] Web UI connected: `fly logs -a APP | grep "webchat connected"`
- [ ] Health check: `curl https://APP.fly.dev/__health`
```

## Troubleshooting

### "Proxy headers detected from untrusted address"

**Cause:** `trustedProxies` not configured or doesn't include the Fly proxy IP.

**Fix:**
1. Check logs for the actual proxy IP: `fly logs -a APP | grep "remote="`
2. Add that IP to `trustedProxies` in `/data/moltbot.json`
3. Restart: `fly machines restart -a APP`

### "pairing required"

**Cause:** Device not paired.

**Fix:**
1. Check pending: `fly ssh console -a APP -C "cat /data/devices/pending.json"`
2. Run the approval script from Phase 5.3
3. Refresh the browser

### Gateway not listening on port 3000

**Cause:** Gateway taking too long to start (~60 seconds is normal).

**Fix:**
1. Wait 60-90 seconds after deploy/restart
2. Check logs: `fly logs -a APP --no-tail | grep "listening"`
3. Verify process: `fly ssh console -a APP -C "ps -e | grep moltbot"`

### Invalid --bind error

**Cause:** Using invalid bind value (e.g., `0.0.0.0`).

**Fix:** Use `--bind lan` in fly.toml, not `--bind 0.0.0.0`.

Valid bind values: `loopback`, `lan`, `tailnet`, `auto`, `custom`

## Complete moltbot.json Example

```json
{
  "meta": {
    "lastTouchedVersion": "2026.1.27-beta.1"
  },
  "auth": {
    "profiles": {
      "anthropic:default": { "provider": "anthropic", "mode": "token" },
      "openai:default": { "provider": "openai", "mode": "token" }
    }
  },
  "agents": {
    "defaults": {
      "model": {
        "primary": "anthropic/claude-sonnet-4-5",
        "fallbacks": ["anthropic/claude-sonnet-4-5", "openai/gpt-4o"]
      },
      "maxConcurrent": 4
    },
    "list": [{ "id": "main", "default": true }]
  },
  "bindings": [{ "agentId": "main", "match": { "channel": "discord" } }],
  "channels": {
    "discord": {
      "enabled": true,
      "groupPolicy": "allowlist",
      "guilds": {
        "YOUR_GUILD_ID": {
          "requireMention": false,
          "channels": { "general": { "allow": true } }
        }
      }
    }
  },
  "gateway": {
    "mode": "local",
    "bind": "lan",
    "trustedProxies": ["172.16.0.0/12", "10.0.0.0/8", "172.16.3.162"]
  },
  "plugins": {
    "entries": {
      "discord": { "enabled": true },
      "slack": { "enabled": true }
    }
  }
}
```

## Quick Reference Commands

```bash
# Deploy
fly deploy -a APP

# Logs
fly logs -a APP --no-tail | tail -50

# SSH
fly ssh console -a APP

# Restart
fly machines restart -a APP

# List secrets
fly secrets list -a APP

# Get gateway token
fly ssh console -a APP -C "printenv CLAWDBOT_GATEWAY_TOKEN"

# Check pending devices
fly ssh console -a APP -C "cat /data/devices/pending.json"

# Check paired devices
fly ssh console -a APP -C "cat /data/devices/paired.json"

# Check config
fly ssh console -a APP -C "cat /data/moltbot.json"
```

## Resources

- Moltbot Docs: https://docs.molt.bot/
- Fly.io Docs: https://fly.io/docs/
- Moltbot Fly Deployment Guide: https://docs.molt.bot/platforms/fly
