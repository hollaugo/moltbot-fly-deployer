#!/bin/bash
# Approve pending device pairing for Moltbot on Fly.io
# Usage: ./approve-device.sh <app-name>

set -euo pipefail

APP_NAME="${1:-}"

if [ -z "$APP_NAME" ]; then
  echo "Usage: $0 <app-name>"
  echo "Example: $0 my-moltbot-app"
  exit 1
fi

echo "Checking pending devices for $APP_NAME..."

# Check if there are pending devices
PENDING=$(fly ssh console -a "$APP_NAME" -C "cat /data/devices/pending.json" 2>/dev/null || echo "{}")

if [ "$PENDING" = "{}" ]; then
  echo "No pending devices to approve."
  exit 0
fi

echo "Found pending device(s). Approving..."

# Approve the device
fly ssh console -a "$APP_NAME" -C 'node -e "
const fs = require(\"fs\");
const pendingPath = \"/data/devices/pending.json\";
const pairedPath = \"/data/devices/paired.json\";

let pending = {};
let paired = {};

try { pending = JSON.parse(fs.readFileSync(pendingPath)); } catch {}
try { paired = JSON.parse(fs.readFileSync(pairedPath)); } catch {}

const requestIds = Object.keys(pending);
if (requestIds.length === 0) {
  console.log(\"No pending devices\");
  process.exit(0);
}

for (const requestId of requestIds) {
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
    approvedBy: \"approve-device-script\"
  };
  delete pending[requestId];
  console.log(\"Approved device:\", device.deviceId.substring(0, 16) + \"...\");
}

fs.writeFileSync(pendingPath, JSON.stringify(pending, null, 2));
fs.writeFileSync(pairedPath, JSON.stringify(paired, null, 2));
console.log(\"All pending devices approved.\");
"'

echo ""
echo "Done! Refresh your browser to connect."
