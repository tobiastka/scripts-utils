#!/bin/bash
#
# Adds custom devices to Chrome DevTools responsive mode.
# Chrome MUST be closed before running this script.
#

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
DEVICES_FILE="$SCRIPT_DIR/devices.json"
PREFS_FILE="$HOME/Library/Application Support/Google/Chrome/Default/Preferences"

# Check Chrome is not running
if pgrep -x "Google Chrome" > /dev/null 2>&1; then
  echo "ERROR: Chrome is running. Close it first, then re-run this script."
  exit 1
fi

# Check Preferences file exists
if [ ! -f "$PREFS_FILE" ]; then
  echo "ERROR: Chrome Preferences file not found at:"
  echo "  $PREFS_FILE"
  echo "Make sure Chrome has been opened at least once."
  exit 1
fi

# Check devices.json exists
if [ ! -f "$DEVICES_FILE" ]; then
  echo "ERROR: devices.json not found at:"
  echo "  $DEVICES_FILE"
  exit 1
fi

# Backup
cp "$PREFS_FILE" "$PREFS_FILE.backup"
echo "Backup created at: $PREFS_FILE.backup"

# Inject devices using python3
DEVICES_FILE="$DEVICES_FILE" python3 << 'PYEOF'
import json
import os

prefs_file = os.path.expanduser("~/Library/Application Support/Google/Chrome/Default/Preferences")
devices_file = os.environ["DEVICES_FILE"]

with open(prefs_file, "r") as f:
    prefs = json.load(f)

with open(devices_file, "r") as f:
    new_devices = json.load(f)

# Navigate to devtools.preferences.customEmulatedDeviceList
devtools = prefs.setdefault("devtools", {})
devtools_prefs = devtools.setdefault("preferences", {})

# customEmulatedDeviceList is stored as a JSON string inside preferences
raw = devtools_prefs.get("customEmulatedDeviceList", "[]")
existing = json.loads(raw)

# Build set of existing device titles
existing_titles = set()
for device in existing:
    existing_titles.add(device.get("title", ""))

added = 0
for dev in new_devices:
    title = dev["title"]
    if title in existing_titles:
        print(f"  SKIP (already exists): {title}")
        continue

    # Build Chrome DevTools emulated device format
    chrome_device = {
        "title": title,
        "type": dev.get("type", "phone"),
        "user-agent": "",
        "capabilities": ["touch", "mobile"] if dev.get("mobile", True) else [],
        "screen": {
            "device-pixel-ratio": dev["deviceScaleFactor"],
            "vertical": {
                "width": dev["width"],
                "height": dev["height"]
            },
            "horizontal": {
                "width": dev["height"],
                "height": dev["width"]
            }
        },
        "modes": [
            {
                "title": "default",
                "orientation": "vertical",
                "insets": {"left": 0, "top": 0, "right": 0, "bottom": 0}
            },
            {
                "title": "default",
                "orientation": "horizontal",
                "insets": {"left": 0, "top": 0, "right": 0, "bottom": 0}
            }
        ],
        "show-by-default": True,
        "show": "Always"
    }

    existing.append(chrome_device)
    existing_titles.add(title)
    added += 1
    print(f"  ADDED: {title}")

# Save back as JSON string
devtools_prefs["customEmulatedDeviceList"] = json.dumps(existing)

with open(prefs_file, "w") as f:
    json.dump(prefs, f, separators=(",", ":"))

print(f"\nDone! {added} device(s) added, {len(new_devices) - added} skipped.")
PYEOF

echo ""
echo "Open Chrome and check DevTools > Device Toolbar to see your new devices."
