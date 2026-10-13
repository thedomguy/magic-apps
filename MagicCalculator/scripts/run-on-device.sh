#!/usr/bin/env bash
# Regenerate, build, install and launch MagicCalculator on a connected iPhone.
# Usage: scripts/run-on-device.sh            (first reachable paired iPhone)
#        DEVICE_ID=<coredevice id> scripts/run-on-device.sh
set -euo pipefail

cd "$(dirname "$0")/.."
BUNDLE_ID=com.rahulbhatt.MagicCalculator
DERIVED=build/device

# Resolve "<coredevice id> <udid>" for DEVICE_ID, or the first reachable paired iPhone.
json=$(mktemp)
xcrun devicectl list devices --json-output "$json" >/dev/null
read -r DEVICE_ID UDID < <(python3 - "$json" "${DEVICE_ID:-}" <<'PY'
import json, sys
wanted = sys.argv[2]
for d in json.load(open(sys.argv[1]))["result"]["devices"]:
    hw, conn = d["hardwareProperties"], d["connectionProperties"]
    if wanted:
        ok = d["identifier"] == wanted
    else:
        # The tunnel reads "disconnected" until devicectl opens it on demand; "unavailable" is unreachable.
        ok = hw.get("deviceType") == "iPhone" and conn.get("pairingState") == "paired" \
            and conn.get("tunnelState") != "unavailable"
    if ok:
        print(d["identifier"], hw["udid"])
        break
PY
) || true
rm -f "$json"
[[ -n "${UDID:-}" ]] || { echo "No reachable paired iPhone. Unlock it / connect it and retry." >&2; exit 1; }

xcodegen generate --quiet
xcodebuild -scheme MagicCalculator -destination "id=$UDID" -derivedDataPath "$DERIVED" \
  -allowProvisioningUpdates -quiet build

APP="$DERIVED/Build/Products/Debug-iphoneos/MagicCalculator.app"
xcrun devicectl device install app --device "$DEVICE_ID" "$APP" >/dev/null
xcrun devicectl device process launch --device "$DEVICE_ID" --terminate-existing "$BUNDLE_ID" >/dev/null
echo "Launched $BUNDLE_ID on $DEVICE_ID"
