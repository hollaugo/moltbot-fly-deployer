#!/bin/bash
# Configure trusted proxies for Moltbot on Fly.io
# Usage: ./setup-trusted-proxies.sh <app-name> [additional-ip]

set -euo pipefail

APP_NAME="${1:-}"
ADDITIONAL_IP="${2:-}"

if [ -z "$APP_NAME" ]; then
  echo "Usage: $0 <app-name> [additional-ip]"
  echo "Example: $0 my-moltbot-app"
  echo "Example: $0 my-moltbot-app 172.16.3.162"
  exit 1
fi

echo "Setting up trusted proxies for $APP_NAME..."

# Build the node command
if [ -n "$ADDITIONAL_IP" ]; then
  EXTRA_IP=", \"$ADDITIONAL_IP\""
else
  EXTRA_IP=""
fi

fly ssh console -a "$APP_NAME" -C "node -e \"
const fs = require('fs');
const configPath = '/data/moltbot.json';
let config = {};

try {
  config = JSON.parse(fs.readFileSync(configPath));
} catch (e) {
  console.log('Creating new config...');
}

config.gateway = config.gateway || {};
config.gateway.trustedProxies = [
  '172.16.0.0/12',
  '10.0.0.0/8'$EXTRA_IP
];
config.gateway.mode = 'local';
config.gateway.bind = 'lan';

fs.writeFileSync(configPath, JSON.stringify(config, null, 2));
console.log('Trusted proxies configured:');
console.log(JSON.stringify(config.gateway.trustedProxies, null, 2));
\""

echo ""
echo "Restarting machine to apply changes..."
fly machines restart -a "$APP_NAME"

echo ""
echo "Done! Wait ~60 seconds for the gateway to start."
echo "Check logs with: fly logs -a $APP_NAME --no-tail | tail -30"
