# Moltbot Fly.io Deployer

Deploy Moltbot (Clawdbot) to Fly.io with proper proxy configuration, trusted proxies setup, and device pairing.

## Overview

Deploying Moltbot to Fly.io requires specific configuration that isn't immediately obvious:

1. **Trusted Proxies** - Fly.io routes traffic through internal proxies. Without proper `trustedProxies` configuration, all connections fail with "Proxy headers detected from untrusted address".

2. **Binding Configuration** - Must use `--bind lan`, not `--bind 0.0.0.0`.

3. **Device Pairing** - Web UI access requires approving device pairing via SSH.

This repository provides skills/plugins that guide you through the entire deployment process.

## Choose Your Format

### Claude Code Plugin

For use with Claude Code (Anthropic's CLI tool):

```
claude-plugin/
├── .claude-plugin/plugin.json
├── skills/deploy-moltbot-to-fly/SKILL.md
├── templates/
└── scripts/
```

See [claude-plugin/README.md](claude-plugin/README.md) for installation.

### Moltbot Skill

For use as a Moltbot/Clawdbot plugin:

```
moltbot-skill/
├── clawdbot.plugin.json
├── skills/deploy-moltbot-to-fly/skill.md
├── templates/
└── scripts/
```

See [moltbot-skill/README.md](moltbot-skill/README.md) for installation.

## Quick Reference

### Key Commands

```bash
# Deploy
fly deploy -a APP_NAME

# Check logs
fly logs -a APP_NAME --no-tail | tail -50

# SSH into container
fly ssh console -a APP_NAME

# Restart after config changes
fly machines restart -a APP_NAME

# Get gateway token
fly ssh console -a APP_NAME -C "printenv CLAWDBOT_GATEWAY_TOKEN"
```

### Critical Configuration

**fly.toml** - Use `--bind lan`:
```toml
[processes]
  app = "node dist/index.js gateway --allow-unconfigured --port 3000 --bind lan"
```

**moltbot.json** - Configure trustedProxies:
```json
{
  "gateway": {
    "trustedProxies": ["172.16.0.0/12", "10.0.0.0/8"],
    "mode": "local",
    "bind": "lan"
  }
}
```

## Common Issues

| Error | Solution |
|-------|----------|
| "Proxy headers detected from untrusted address" | Add Fly proxy IP to `trustedProxies` |
| "pairing required" | Run device approval script |
| Gateway not listening | Wait ~60 seconds after restart |

## License

MIT

## Author

Prompt Circle - https://promptcircle.ai
