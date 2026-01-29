#!/bin/bash
# Approve pending device pairing for Moltbot on Fly.io

set -e

if [ -z "$1" ]; then
  echo "Usage: $0 <app-name>"
  echo "Example: $0 my-moltbot"
  exit 1
fi

APP_NAME="$1"

echo "Approving pending device for $APP_NAME..."

flyctl ssh console -a "$APP_NAME" -C 'node -e "
const fs = require(\"fs\");
const pending = JSON.parse(fs.readFileSync(\"/data/devices/pending.json\"));
const paired = JSON.parse(fs.readFileSync(\"/data/devices/paired.json\") || \"{}\");
const requestId = Object.keys(pending)[0];
if (requestId) {
  const device = pending[requestId];
  paired[device.deviceId] = {
    deviceId: device.deviceId,
    publicKey: device.publicKey,
    platform: device.platform,
    clientId: device.clientId,
    role: device.role,
    roles: device.roles,
    scopes: device.scopes,
    approvedAt: Date.now(),
    approvedBy: \"cli\"
  };
  delete pending[requestId];
  fs.writeFileSync(\"/data/devices/pending.json\", JSON.stringify(pending, null, 2));
  fs.writeFileSync(\"/data/devices/paired.json\", JSON.stringify(paired, null, 2));
  console.log(\"✅ Approved device:\", device.deviceId);
} else {
  console.log(\"❌ No pending devices found\");
}
"'

echo ""
echo "Done! Refresh your browser to connect."
