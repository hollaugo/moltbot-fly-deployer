# Moltbot Fly.io Deployer - Moltbot Skill

A Moltbot/Clawdbot skill to deploy Moltbot to Fly.io with proper proxy configuration, trusted proxies setup, and device pairing.

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

- `clawdbot.plugin.json` - Plugin manifest for Moltbot
- `skills/deploy-moltbot-to-fly/skill.md` - Comprehensive deployment guide
- `templates/` - Configuration templates (fly.toml, moltbot.json)
- `scripts/` - Helper scripts for trusted proxies and device approval

## Plugin Structure

```
moltbot-skill/
├── clawdbot.plugin.json
├── skills/
│   └── deploy-moltbot-to-fly/
│       └── skill.md
├── templates/
│   ├── fly.toml
│   └── moltbot.json
├── scripts/
│   ├── setup-trusted-proxies.sh
│   └── approve-device.sh
└── README.md
```

## Key Features

- Step-by-step Fly.io deployment guidance
- Trusted proxies configuration (required for Fly's internal proxy network)
- Device pairing approval for web UI access
- Helper scripts for common operations

## License

MIT
