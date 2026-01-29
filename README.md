# Moltbot Fly.io Deployer

A Claude Code skill for deploying [Moltbot](https://github.com/moltbot/moltbot) (also known as Clawdbot) to Fly.io.

## What This Skill Does

Deploying Moltbot to Fly.io has several non-obvious configuration requirements:

1. **Trusted Proxies** - Fly.io routes traffic through internal proxies (172.16.x.x). Without configuring `trustedProxies`, all web connections fail.

2. **Device Pairing** - Moltbot requires device authentication for security. New browser sessions need to be approved.

3. **Gateway Binding** - The `--bind lan` flag is required (not `--bind 0.0.0.0`).

4. **Startup Time** - The gateway takes ~60 seconds to fully start.

This skill guides you through all these steps with the exact commands needed.

## Quick Start

1. Install the skill in Claude Code
2. Run `/deploy-moltbot-to-fly`
3. Follow the guided deployment process

## Prerequisites

- [Fly.io CLI](https://fly.io/docs/hands-on/install-flyctl/) installed
- Fly.io account (free tier works)
- Anthropic API key
- Git

## Key Configuration

### fly.toml

```toml
[processes]
  app = "node dist/index.js gateway --allow-unconfigured --port 3000 --bind lan"

[[mounts]]
  source = 'moltbot_data'
  destination = '/data'
```

### Trusted Proxies (moltbot.json)

```json
{
  "gateway": {
    "trustedProxies": ["172.16.0.0/12", "10.0.0.0/8", "172.16.3.162"],
    "mode": "local",
    "bind": "lan"
  }
}
```

### Required Secrets

```bash
fly secrets set ANTHROPIC_API_KEY="sk-ant-xxxxx"
fly secrets set CLAWDBOT_GATEWAY_TOKEN="$(openssl rand -hex 32)"
```

## Troubleshooting

| Error | Cause | Fix |
|-------|-------|-----|
| "Proxy headers detected from untrusted address" | trustedProxies not configured | Add Fly proxy IP to trustedProxies |
| "pairing required" | Device not paired | Run device approval script |
| Gateway not listening | Startup takes ~60s | Wait and check logs |

## License

MIT
