# Moltbot Fly.io Deployer - Moltbot Skill

A comprehensive Moltbot/Clawdbot skill for deploying Moltbot to Fly.io with proper configuration, persistent storage, authentication, and device pairing.

## What This Skill Covers

- ✅ Complete Fly.io deployment from scratch
- ✅ Proper `fly.toml` configuration with critical settings
- ✅ Token-based authentication setup
- ✅ Device pairing approval
- ✅ Troubleshooting common issues
- ✅ DNS resolution and cache management
- ✅ Config file creation at correct location

## Installation

Install as a Moltbot plugin:

```bash
moltbot plugin install github:hollaugo/moltbot-fly-deployer
```

Or manually copy the `moltbot-skill` folder to your Moltbot plugins directory.

## Usage

Ask Moltbot to help you deploy to Fly.io:

```
"Help me deploy Moltbot to Fly.io"
```

Or use the skill directly:

```
/deploy-moltbot-to-fly
```

## What's Included

```
moltbot-skill/
├── clawdbot.plugin.json       # Plugin manifest
├── skills/
│   └── deploy-moltbot-to-fly/
│       └── skill.md           # Complete deployment guide
├── templates/
│   ├── fly.toml              # Correct Fly configuration
│   └── moltbot.json          # Sample config file
├── scripts/
│   ├── setup-trusted-proxies.sh  # Optional proxy config
│   └── approve-device.sh         # Device approval helper
└── README.md
```

## Key Features

### Critical Configurations

The skill ensures you set up:

1. **`CLAWDBOT_STATE_DIR=/data`** - For proper config persistence
2. **`http_service`** format - Newer Fly.io configuration
3. **Token in both places** - Env var AND config file
4. **Proper memory allocation** - 2GB recommended
5. **Device pairing workflow** - Complete approval process

### Common Issues Solved

- ✅ Token mismatch errors
- ✅ DNS propagation delays
- ✅ Config validation failures  
- ✅ Gateway not listening
- ✅ Device pairing required errors
- ✅ State persistence issues

### Troubleshooting Guide

The skill includes fixes for:

- Connection refused errors
- Proxy header warnings
- OOM/memory issues
- Gateway lock files
- DNS resolution problems
- Config corruption recovery

## Quick Start

1. **Clone Moltbot repo**
2. **Generate token**: `openssl rand -hex 32`
3. **Create `fly.toml`** with proper settings
4. **Deploy**: `fly deploy -a your-app-name`
5. **Create config file** at `/data/moltbot.json`
6. **Approve device pairing**
7. **Access**: `https://your-app-name.fly.dev/?token=YOUR-TOKEN`

Full details in the skill documentation!

## Requirements

- Fly.io CLI installed
- Fly.io account (free tier works)
- Anthropic API key
- Git installed

## Templates

### fly.toml

Includes all critical settings:
- `CLAWDBOT_STATE_DIR=/data`
- `http_service` configuration
- Proper process binding
- Memory and VM sizing

### moltbot.json

Sample config with:
- Token authentication
- Gateway settings
- Agent configuration
- Provider profiles

## Scripts

### approve-device.sh

One-liner to approve pending device pairing:

```bash
./scripts/approve-device.sh your-app-name
```

### setup-trusted-proxies.sh

Optional script to configure Fly proxy network trust.

## Known Issues & Solutions

### Issue: Token Mismatch

**Solution:** Ensure token in `/data/moltbot.json` matches `CLAWDBOT_GATEWAY_TOKEN` env var.

### Issue: DNS Not Resolving

**Solution:** Wait 2-5 minutes, use Google DNS (8.8.8.8), flush local cache.

### Issue: Gateway Won't Start

**Solution:** Check logs for validation errors, ensure `CLAWDBOT_STATE_DIR=/data` is set.

### Issue: Deployment Stuck

**Nuclear option:** Destroy app and redeploy fresh - often faster than debugging.

## Updates

The skill is tested with Moltbot version `2026.1.29` and Fly.io as of January 2026.

Key lessons incorporated:
1. `CLAWDBOT_STATE_DIR` is critical
2. Token must be in both env and config
3. Use `http_service` format
4. Device pairing is required
5. DNS propagation takes time
6. Fresh deploys > debugging corruption

## Contributing

Found an issue or improvement? Open a PR at:
https://github.com/hollaugo/moltbot-fly-deployer

## License

MIT

## Credits

Created by Prompt Circle for the Moltbot/Clawdbot community.

Based on real-world deployment experience and official Moltbot docs at https://docs.molt.bot/platforms/fly
