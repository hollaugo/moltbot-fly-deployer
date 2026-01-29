# How to Use This Skill

## Quick Install

If you want to install this skill in your Clawdbot instance:

\`\`\`bash
cd /Users/uosuji/clawd/skills/
cp -r /Users/uosuji/prompt-circle-phoenix/moltbot-fly-deployer/moltbot-skill moltbot-fly-deployer
clawdbot gateway restart
\`\`\`

Then ask Clawdbot:
\`\`\`
Help me deploy Moltbot to Fly.io
\`\`\`

## Manual Usage

Read the comprehensive guide:
\`\`\`bash
cat /Users/uosuji/prompt-circle-phoenix/moltbot-fly-deployer/moltbot-skill/skills/deploy-moltbot-to-fly/skill.md
\`\`\`

Or follow the checklist:
\`\`\`bash
cat /Users/uosuji/prompt-circle-phoenix/moltbot-fly-deployer/moltbot-skill/CHECKLIST.md
\`\`\`

## Helper Scripts

Approve device pairing:
\`\`\`bash
./scripts/approve-device.sh your-app-name
\`\`\`

Setup trusted proxies (optional):
\`\`\`bash
./scripts/setup-trusted-proxies.sh your-app-name
\`\`\`

## What's New in v2.0.0

See \`CHANGELOG.md\` and \`UPDATE_SUMMARY.md\` for complete details.

Key improvements:
- ✅ CLAWDBOT_STATE_DIR configuration
- ✅ http_service format
- ✅ Token in both places documented
- ✅ Device pairing workflow
- ✅ DNS propagation solutions
- ✅ Complete troubleshooting
- ✅ Automated helper scripts
- ✅ Production-tested & verified

## Success Story

This skill successfully deployed:
- **App:** molty-personal-assitant.fly.dev
- **Date:** 2026-01-29
- **Status:** ✅ Running and accessible
- **All issues encountered and solved**

## Support

Issues? Check:
1. \`CHECKLIST.md\` - Verify you didn't miss steps
2. \`skill.md\` Troubleshooting section - Common errors & fixes
3. \`CHANGELOG.md\` - Known issues and solutions

## Files Overview

- \`skill.md\` - Complete deployment guide (403 lines)
- \`CHECKLIST.md\` - Step-by-step checklist
- \`CHANGELOG.md\` - Version history & migration guide
- \`UPDATE_SUMMARY.md\` - What changed and why
- \`README.md\` - Skill overview
- \`scripts/\` - Automation helpers
- \`templates/\` - Correct configurations
- \`INSTALLATION.md\` - This file

Everything you need for a successful Fly.io deployment! 🚀
