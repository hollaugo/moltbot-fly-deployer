# Changelog

All notable improvements to the Moltbot Fly.io Deployer skill.

## [2.0.0] - 2026-01-29

### 🎉 Major Update - Production-Tested Deployment

Complete rewrite based on real-world deployment experience and lessons learned.

### ✨ Added

- **CRITICAL:** `CLAWDBOT_STATE_DIR=/data` configuration
- **NEW:** Proper `http_service` format (replaces `[[services]]`)
- **NEW:** Token configuration in both env var AND config file
- **NEW:** Device pairing workflow with approval script
- **NEW:** DNS propagation troubleshooting
- **NEW:** Config file creation guide at `/data/moltbot.json`
- **NEW:** Helper scripts:
  - `approve-device.sh` - One-liner device approval
  - `setup-trusted-proxies.sh` - Optional proxy configuration
- **NEW:** `CHECKLIST.md` - Step-by-step deployment checklist
- **NEW:** Comprehensive troubleshooting section

### 🔧 Fixed

- Token mismatch errors (now documented: must be in both places)
- Gateway not listening (proper `--bind lan` configuration)
- State persistence issues (`CLAWDBOT_STATE_DIR` was missing)
- Memory issues (documented 2GB minimum)
- DNS resolution delays (added cache flush instructions)
- Config validation errors (documented invalid `auth.mode` values)

### 📚 Improved

- Detailed troubleshooting for every common error
- Step-by-step device pairing process
- DNS propagation wait times and solutions
- Nuclear option (destroy & redeploy) when debugging fails
- Quick reference commands section
- Templates updated with correct configurations

### 🔑 Key Lessons Incorporated

1. **`CLAWDBOT_STATE_DIR=/data`** - Without this, config location is wrong
2. **Token in BOTH places** - Env var for server, config for validation
3. **Use `http_service`** - Newer Fly format, more reliable
4. **Device pairing required** - Even with token authentication
5. **DNS takes time** - 2-5 minutes is normal
6. **Fresh deploy often faster** - Than debugging corrupted state
7. **2GB RAM minimum** - 512MB OOMs, 1GB marginal, 2GB safe

### 🗑️ Removed

- Old `[[services]]` configuration format
- Incomplete proxy configuration steps
- Misleading "optional" labels on critical settings

### 📖 Documentation

- Complete rewrite of `skill.md` with production experience
- Added `CHECKLIST.md` for systematic deployment
- Enhanced `README.md` with troubleshooting index
- Added inline comments to templates
- Created `CHANGELOG.md` (this file)

## [1.0.0] - Initial Release

### Added

- Basic Fly.io deployment guide
- Template configurations
- Basic troubleshooting

### Known Issues

- Missing `CLAWDBOT_STATE_DIR` configuration
- Incomplete token setup (only env var)
- Using deprecated `[[services]]` format
- No device pairing documentation
- Limited troubleshooting coverage

---

## Migration from 1.0.0 to 2.0.0

If you deployed with version 1.0.0:

### Critical Updates Needed

1. **Add to fly.toml `[env]` section:**
   ```toml
   CLAWDBOT_STATE_DIR = '/data'
   ```

2. **Change `[[services]]` to `[http_service]`:**
   ```toml
   [http_service]
     internal_port = 3000
     force_https = true
     auto_stop_machines = false
     auto_start_machines = true
     min_machines_running = 1
     processes = ["app"]
   ```

3. **Create `/data/moltbot.json`:**
   ```bash
   fly ssh console -a your-app
   # Create config with same token as env var
   ```

4. **Approve device pairing:**
   ```bash
   ./scripts/approve-device.sh your-app
   ```

### Redeploy

```bash
fly deploy -a your-app
```

Or for clean slate:

```bash
fly apps destroy your-app -y
# Follow 2.0.0 guide from scratch
```

---

## Testing

Version 2.0.0 was tested with:
- Moltbot/Clawdbot `2026.1.29`
- Fly.io CLI `v0.4.6`
- macOS (arm64) and Linux deployment
- Successful production deployment on `2026-01-29`

## Credits

Thanks to the Moltbot community and real-world deployment experience that informed these improvements.

## Support

Issues? Check the troubleshooting section in `skill.md` or open an issue at:
https://github.com/hollaugo/moltbot-fly-deployer
