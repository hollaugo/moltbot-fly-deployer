# Moltbot Fly.io Deployment Checklist

Use this checklist to ensure you don't miss any critical steps.

## Pre-Deployment

- [ ] Fly.io CLI installed (`fly version`)
- [ ] Logged into Fly.io (`fly auth whoami`)
- [ ] Anthropic API key ready
- [ ] Generated gateway token (`openssl rand -hex 32`)
- [ ] Saved token somewhere safe

## Setup

- [ ] Cloned Moltbot repo
- [ ] Created `fly.toml` with:
  - [ ] `CLAWDBOT_STATE_DIR = '/data'`
  - [ ] `http_service` (not `[[services]]`)
  - [ ] `memory = '2048mb'`
  - [ ] `--bind lan`
- [ ] Created Fly app (`fly apps create`)
- [ ] Created volume (`fly volumes create moltbot_data`)
- [ ] Set secrets:
  - [ ] `CLAWDBOT_GATEWAY_TOKEN`
  - [ ] `ANTHROPIC_API_KEY`
  - [ ] `OPENAI_API_KEY` (optional)

## Deployment

- [ ] Deployed app (`fly deploy`)
- [ ] Verified gateway started (`fly logs | grep "listening on"`)
- [ ] Created `/data/moltbot.json` with:
  - [ ] Same token as env var
  - [ ] `gateway.auth.mode = "token"`
  - [ ] `gateway.mode = "local"`
  - [ ] `gateway.bind = "lan"`
- [ ] Restarted machine after config creation

## Access & Pairing

- [ ] DNS resolving (`nslookup app-name.fly.dev 8.8.8.8`)
- [ ] Flushed local DNS cache if needed
- [ ] Accessed tokenized URL: `https://app-name.fly.dev/?token=YOUR-TOKEN`
- [ ] Approved device pairing via SSH
- [ ] Refreshed browser
- [ ] Successfully connected! 🎉

## Verification

- [ ] Can access Control UI
- [ ] Can send a test message
- [ ] Logs look healthy (`fly logs`)
- [ ] No errors in gateway logs

## Troubleshooting (If Issues)

- [ ] Token in config matches env var
- [ ] Gateway actually listening (`fly logs | grep "listening"`)
- [ ] DNS propagated (wait 2-5 min)
- [ ] Tried fresh browser/incognito
- [ ] Checked machine status (`fly status`)

## Nuclear Option (Last Resort)

If all else fails:
```bash
fly apps destroy your-app-name -y
# Start over from Setup phase
```

## Post-Deployment

- [ ] Bookmark tokenized URL
- [ ] Document token location
- [ ] Configure any channels (Discord, Telegram, etc.)
- [ ] Test deployment works as expected

## Common Gotchas

- ✅ Token must be in **BOTH** env var and config file
- ✅ `CLAWDBOT_STATE_DIR=/data` is **critical**
- ✅ Use `http_service` not `[[services]]`
- ✅ Wait for DNS propagation (2-5 min)
- ✅ Device pairing is required even with token
- ✅ 2GB RAM minimum
- ✅ `--bind lan` not `0.0.0.0`

## Quick Commands

```bash
# Status check
fly status -a APP

# Logs
fly logs -a APP

# SSH
fly ssh console -a APP

# Restart
fly machines list -a APP
fly machine restart <id> -a APP

# Get token
fly ssh console -a APP -C "printenv CLAWDBOT_GATEWAY_TOKEN"

# Approve device
./scripts/approve-device.sh APP
```

---

✅ = Required
⚠️ = Important
💡 = Helpful
