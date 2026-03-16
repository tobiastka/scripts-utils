# scripts-utils

Collection of utility scripts for development workflows.

## chrome-devtools-devices

Adds custom devices to Chrome DevTools responsive mode. Useful for syncing device presets across machines since Chrome doesn't sync this setting.

### Usage

1. **Close Chrome completely**
2. Run the script:

```bash
cd chrome-devtools-devices
./add-devices.sh
```

3. Open Chrome and check DevTools (F12) > Device Toolbar

### Customize

Edit `chrome-devtools-devices/devices.json` to add/remove devices. The script will skip devices that already exist (matched by title).

### Included devices

**Project breakpoints (FIL):**
- FIL - Mobile (375x812, 3x)
- FIL - Tablet (450x900, 2x)
- FIL - Desktop SM (1280x800, 1x)
- FIL - Desktop LG (1920x1080, 1x)

**Popular devices:**
- iPhone 15 (393x852, 3x)
- iPhone 15 Pro Max (430x932, 3x)
- Samsung Galaxy S24 (360x780, 3x)
- Google Pixel 8 (412x915, 2.625x)
- iPad 10th Gen (820x1180, 2x)
- MacBook Air 13" (1440x900, 2x)
- Monitor 2K (2560x1440, 1x)

### Requirements

- macOS (uses Chrome's default profile path)
- python3 (included with macOS)
