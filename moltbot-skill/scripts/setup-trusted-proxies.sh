#!/bin/bash
# Configure trusted proxies for Fly.io internal network

set -e

if [ -z "$1" ]; then
  echo "Usage: $0 <app-name>"
  echo "Example: $0 my-moltbot"
  exit 1
fi

APP_NAME="$1"

echo "Configuring trusted proxies for $APP_NAME..."

flyctl ssh console -a "$APP_NAME" -C 'node -e "
const fs = require(\"fs\");
const configPath = \"/data/moltbot.json\";
let config = {};

try {
  config = JSON.parse(fs.readFileSync(configPath));
} catch (e) {
  console.log(\"⚠️  Config file not found, creating new one\");
}

config.gateway = config.gateway || {};
config.gateway.trustedProxies = [
  \"172.16.0.0/12\",
  \"10.0.0.0/8\"
];

fs.writeFileSync(configPath, JSON.stringify(config, null, 2));
console.log(\"✅ Trusted proxies configured\");
console.log(\"   - 172.16.0.0/12 (Fly internal)\");
console.log(\"   - 10.0.0.0/8 (Private networks)\");
"'

echo ""
echo "Done! Restart the machine to apply changes:"
echo "  fly machines list -a $APP_NAME"
echo "  fly machine restart <machine-id> -a $APP_NAME"
