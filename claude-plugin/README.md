# Moltbot Fly.io Deployer - Claude Code Plugin

A Claude Code plugin to deploy Moltbot (Clawdbot) to Fly.io with proper proxy configuration, trusted proxies setup, and device pairing.

## Installation

Add this plugin to your Claude Code project:

```bash
# Clone to your plugins directory
git clone https://github.com/hollaugo/moltbot-fly-deployer.git ~/.claude/plugins/moltbot-fly-deployer
```

Or copy the `claude-plugin` folder contents to your project's `.claude-plugin` directory.

## Usage

In Claude Code, run:

```
/deploy-moltbot-to-fly
```

Or ask Claude to help you deploy Moltbot to Fly.io.

## What's Included

- `.claude-plugin/plugin.json` - Plugin manifest
- `skills/deploy-moltbot-to-fly/SKILL.md` - Comprehensive deployment guide
- `templates/` - Configuration templates (fly.toml, moltbot.json)
- `scripts/` - Helper scripts for trusted proxies and device approval

## Plugin Structure

```
claude-plugin/
├── .claude-plugin/
│   └── plugin.json
├── skills/
│   └── deploy-moltbot-to-fly/
│       └── SKILL.md
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
