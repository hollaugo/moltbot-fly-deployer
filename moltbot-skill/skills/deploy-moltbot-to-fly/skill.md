# Deploy Moltbot to Fly.io

Deploy Moltbot (Clawdbot) to Fly.io with proper proxy configuration, trusted proxies setup, and device pairing.

## Overview

Deploying Moltbot to Fly.io requires:
1. Setting up the Fly app with a persistent volume
2. Configuring environment secrets (API keys, gateway token)
3. Setting up `trustedProxies` to allow Fly's internal proxy network
4. Approving device pairing for web UI access

## Prerequisites

Before starting:
- Fly.io CLI installed (`brew install flyctl` or `curl -L https://fly.io/install.sh | sh`)
- Fly.io account and logged in (`fly auth login`)
- Anthropic API key (and optionally OpenAI API key)
- Git installed

## Phase 1: Clone and Setup

### 1.1 Clone the Moltbot Repository

```bash
git clone https://github.com/moltbot/moltbot.git
cd moltbot
```

### 1.2 Create .env File

Create a `.env` file with the required environment variables:

```bash
# Required: Your Anthropic API key
ANTHROPIC_API_KEY=sk-ant-xxxxx

# Optional: OpenAI API key for fallback models
OPENAI_API_KEY=sk-xxxxx

# Required: Gateway token for authentication (generate with: openssl rand -hex 32)
CLAWDBOT_GATEWAY_TOKEN=your-64-char-hex-token
```

**Important:** Generate the gateway token with:
```bash
openssl rand -hex 32
```

Save this token - you'll need it for Fly secrets and web UI authentication.

## Phase 2: Fly.io Configuration

### 2.1 Create fly.toml

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

**CRITICAL:** Use `--bind lan`, not `--bind 0.0.0.0`.

### 2.2 Create App and Volume

```bash
fly apps create your-app-name
fly volumes create moltbot_data --region iad --size 1
```

### 2.3 Set Fly Secrets

```bash
fly secrets set ANTHROPIC_API_KEY="sk-ant-xxxxx" -a your-app-name
fly secrets set CLAWDBOT_GATEWAY_TOKEN="$(openssl rand -hex 32)" -a your-app-name
```

To retrieve the token later:
```bash
fly ssh console -a your-app-name -C "printenv CLAWDBOT_GATEWAY_TOKEN"
```

## Phase 3: Deploy

```bash
fly deploy -a your-app-name
```

Wait for "listening on ws://0.0.0.0:3000" in logs:
```bash
fly logs -a your-app-name --no-tail | tail -30
```

## Phase 4: Configure Trusted Proxies

**CRITICAL:** Without `trustedProxies`, all connections fail with "Proxy headers detected from untrusted address".

### 4.1 SSH and Update Config

```bash
fly ssh console -a your-app-name
```

```bash
node -e "
const fs = require('fs');
const configPath = '/data/moltbot.json';
let config = {};
try { config = JSON.parse(fs.readFileSync(configPath)); } catch {}

config.gateway = config.gateway || {};
config.gateway.trustedProxies = [
  '172.16.0.0/12',
  '10.0.0.0/8',
  '172.16.3.162'
];
config.gateway.mode = 'local';
config.gateway.bind = 'lan';

fs.writeFileSync(configPath, JSON.stringify(config, null, 2));
console.log('Config updated');
"
```

### 4.2 Restart

```bash
exit
fly machines restart -a your-app-name
```

## Phase 5: Device Pairing

### 5.1 Access Web UI

Open: `https://your-app-name.fly.dev/`

### 5.2 Approve Pairing

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
}
"'
```

### 5.3 Verify

Refresh browser and check logs:
```bash
fly logs -a your-app-name --no-tail | grep "webchat connected"
```

## Troubleshooting

| Error | Fix |
|-------|-----|
| "Proxy headers detected from untrusted address" | Add Fly proxy IP to trustedProxies |
| "pairing required" | Run device approval script |
| Gateway not listening | Wait ~60 seconds |

## Quick Reference

```bash
fly deploy -a APP
fly logs -a APP --no-tail | tail -50
fly ssh console -a APP
fly machines restart -a APP
fly secrets list -a APP
```
