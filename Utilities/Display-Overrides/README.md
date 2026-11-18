# HDMI Full Range RGB EDID Overrides

This directory provides EDID overrides and installation scripts to fix washed-out colors and lifted black levels on external monitors connected via HDMI under macOS.

---

## Background & Root Cause

When connecting an external monitor over HDMI, macOS frequently classifies the display as a television receiver (CEA-861 compliant) if the monitor's EDID advertises YCbCr color capabilities.

When this occurs:
- macOS forces **Limited Range YCbCr (16–235)** instead of **Full Range RGB (0–255)**.
- Blacks appear elevated and gray instead of deep black.
- Colors appear washed out and desaturated.
- Text rendering clarity is reduced due to chroma subsampling.

### The Fix

The included override modifies the monitor's EDID before it reaches macOS `CoreDisplay`:
1. **Base EDID Byte 24:** Patched from `0x2A` to `0x22` (digital display, RGB 4:4:4 color encoding).
2. **CEA-861 Extension Block Byte 131:** Patched from `0xB2` to `0x82` (strips YCbCr 4:4:4 and YCbCr 4:2:2 advertising).
3. **Checksums:** Block 0 checksum (`0x93`) and Block 1 checksum (`0x07`) recalculated to ensure EDID validity.

With YCbCr support removed from the advertised capabilities, macOS is forced to output native **Full Range RGB (0–255)** at full refresh rate.

---

## Included Monitors

| Vendor | Model | Vendor ID | Product ID | Directory |
| :--- | :--- | :--- | :--- | :--- |
| MSI | PRO MP251 E14L | `0x0DC4` (`3524`) | `0x60D2` (`24786`) | `DisplayVendorID-dc4/DisplayProductID-60d2` |

---

## Installation

Open Terminal and run:

```bash
cd Utilities/Display-Overrides
sudo ./install_hdmi_rgb_fix.sh
```

After installation, unplug and reconnect your HDMI cable or restart your Mac. The display will immediately output deep blacks and accurate Full Range RGB color.

---

## Uninstallation

To remove the override and restore default macOS display behavior:

```bash
cd Utilities/Display-Overrides
sudo ./install_hdmi_rgb_fix.sh --uninstall
```

---

## Adapting for Other Monitors

If you have a different monitor showing washed-out colors over HDMI:
1. Determine your monitor's Vendor ID and Product ID in hex (e.g., from Hackintool or IORegistryExplorer under `AppleDisplay`).
2. Convert the IDs to decimal for the plist keys `DisplayVendorID` and `DisplayProductID`.
3. Extract your monitor's EDID, patch byte 24 and the CEA extension byte to disable YCbCr flags, recalculate checksums, and base64-encode the resulting binary into `<key>IODisplayEDID</key>`.
4. Place the resulting plist in `/Library/Displays/Contents/Resources/Overrides/DisplayVendorID-<vendor_hex>/DisplayProductID-<product_hex>`.
