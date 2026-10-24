#!/usr/bin/env bash
# Generate, build, install (and optionally launch) one native Swift app on a connected iPhone.
# Usage: scripts/load-app.sh <dir> <scheme> <bundle id> [launch: ON|OFF]
#        DEVICE_ID=<coredevice id> overrides the first reachable paired iPhone.
set -euo pipefail

DIR=$1 SCHEME=$2 BUNDLE_ID=$3 LAUNCH=${4:-OFF}
cd "$(dirname "$0")/../$DIR"
DERIVED=build/device

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
        ok = hw.get("deviceType") == "iPhone" and conn.get("pairingState") == "paired" \
            and conn.get("tunnelState") != "unavailable"
    if ok:
        print(d["identifier"], hw["udid"])
        break
PY
) || true
rm -f "$json"
[[ -n "${UDID:-}" ]] || { echo "No reachable paired iPhone. Unlock it / connect it and retry." >&2; exit 1; }

[[ -f project.yml ]] && xcodegen generate --quiet
xcodebuild -scheme "$SCHEME" -destination "id=$UDID" -derivedDataPath "$DERIVED" \
  -allowProvisioningUpdates -quiet build

xcrun devicectl device install app --device "$DEVICE_ID" \
  "$DERIVED/Build/Products/Debug-iphoneos/$SCHEME.app" >/dev/null
echo "Installed $BUNDLE_ID on $DEVICE_ID"
if [[ $LAUNCH == ON ]]; then
  xcrun devicectl device process launch --device "$DEVICE_ID" --terminate-existing "$BUNDLE_ID" >/dev/null
  echo "Launched $BUNDLE_ID"
fi
