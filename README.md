# Dell Latitude 7430 Hackintosh OpenCore EFI

OpenCore configuration providing full hardware acceleration and macOS support for the **Dell Latitude 7430** laptop.

Tested on **macOS Tahoe 26.7.3 (`25G342`)** and **macOS Sequoia 15.x**.

---

## Hardware Specifications

| Component | Specification |
| :--- | :--- |
| Model | Dell Latitude 7430 |
| Processor | Intel Core i7-1270P (Alder Lake-P, 4P + 8E cores, 16 threads, up to 4.80 GHz) |
| Graphics | Intel Iris Xe Graphics (`8086:46A6`, Rev `0x0C`, Subsystem `1028:0B09`, 1536 MB Dynamic VRAM, Metal 2) |
| Memory | 32 GB LPDDR5 4800 MHz dual-channel |
| Storage | 256 GB NVMe SSD (Samsung PM991a / PM981 via NVMeFix) |
| Display | 14.0" FHD (1920x1080) 60Hz internal eDP panel |
| Audio | Realtek ALC3281 / ALC711 (Alder Lake-P cAVS `8086:51c8`, layout-id `11`) |
| Wireless | Intel Wi-Fi 6E AX211 (802.11ax, 2x2, 160MHz) |
| Bluetooth | Intel Bluetooth 5.3 Controller |
| Trackpad | Dell I2C HID Multitouch Touchpad + physical buttons |
| Keyboard | Dell Backlit Keyboard with ambient brightness control |
| Camera | 1080p FHD RGB WebCam with privacy shutter |
| Battery | Dell 4-cell 58Wh ExpressCharge Battery |
| Ports | 2x Thunderbolt 4 (Power Delivery & DP), 1x USB-A 3.2 Gen 1 (PowerShare), 1x HDMI 2.0, 3.5mm Audio, MicroSD |

---

## BIOS Configuration

Press `F2` at boot to enter BIOS setup and configure the following options:

- **SATA Operation:** AHCI / NVMe (do not use RAID On)
- **Secure Boot:** Disabled
- **Absolute / Computrace:** Disabled
- **TPM 2.0:** Enabled
- **Intel Virtualization Technology & VT-d:** Enabled
- **Intel SpeedStep & Speed Shift:** Enabled
- **C-States Control & TurboBoost:** Enabled
- **Fastboot:** Thorough
- **Enable UEFI Network Stack:** Disabled
- **Wake on AC / Block Sleep:** Disabled

---

## Status

### What Works
- **CPU Scheduling:** Alder Lake hybrid architecture (4P + 8E cores, 16 threads) scheduled via `CpuTopologyRebuild.kext`.
- **Graphics Acceleration:** Full Metal 2 3D acceleration and WindowServer compositing via [WhateverXe-AlderLake](https://github.com/NebbaGiveUp/WhateverXe-AlderLake).
- **GPU Hang Recovery:** Recovers within seconds from unsupported Metal shader or video faults without crashing (`-wex-reset-restore` & `-wex-no-multicontext`).
- **Media Decoding:** 4K HEVC hardware decode via GPU; H.264 handled via CPU software decode (`-wexgvadrop`) to bypass donor VA driver ring faults.
- **Display & Backlight:** Native 1080p 60Hz panel timing with Fn key brightness controls and Control Center slider.
- **External Video:** HDMI output supported. Full Range RGB (0–255) forced via EDID override in `Utilities/Display-Overrides/`.
- **Audio:** Internal speakers, 3.5mm combo jack, and microphone via `AppleALC.kext` and `SimpleHDA.kext`.
- **Sleep & Wake:** Display idle sleep and full ACPI S3 system sleep/wake operate reliably.
- **Wireless & Bluetooth:** 2.4/5 GHz Wi-Fi via `AirportItlwm.kext`; Bluetooth pairing and audio via `IntelBluetoothFirmware.kext` and `BlueToolFixup.kext`.
- **Trackpad:** Full macOS multi-touch gestures via `VoodooI2C.kext` and `VoodooI2CHID.kext`.
- **Power & Battery:** Real-time battery status, percentage, and discharge rate via `VirtualSMC.kext` and `SMCBatteryManager.kext`.
- **Peripherals:** 1080p Webcam, Thunderbolt 4 (charging and data), USB-A 3.2 Gen 1 with PowerShare.

### Limitations
- **Safari 4K VP9/AV1:** High-resolution VP9/AV1 streams in Safari fall back to CPU decode or drop frames. Use Chrome or Firefox for 4K60.
- **AirDrop / Sidecar / Universal Control:** Requires native Apple Broadcom wireless hardware; unsupported on Intel AX211.

---

## Post-Installation Setup

### 1. Generate SMBIOS Serials (Mandatory)
Open `EFI/OC/config.plist` and inject unique serials generated with [GenSMBIOS](https://github.com/corpnewt/GenSMBIOS) using the **`MacBookPro16,2`** model:
- `PlatformInfo -> Generic -> SystemSerialNumber`
- `PlatformInfo -> Generic -> MLB`
- `PlatformInfo -> Generic -> SystemUUID`
- `PlatformInfo -> Generic -> ROM` (primary network adapter MAC address without colons)

### 2. Install Userspace Graphics Drivers
1. Download **`WhateverXe-Graphics-0.4.4.pkg`** from [WhateverXe-Graphics Releases](https://github.com/b00t0x/WhateverXe-Graphics/releases/tag/v0.4.4).
2. Run the installer and reboot. This deploys the Gen12 Metal, OpenGL, and Video Acceleration driver bundles into `/Library/Extensions` and `/Library/GPUBundles`.

### 3. Install CoreAudio HAL Plug-in (macOS Tahoe)
macOS Tahoe removed native legacy `AppleHDA.kext`. SimpleHDA restores audio without root patches:
1. Download and run **`SimpleHDA-HAL-1.0.1.pkg`** from [SimpleHDA Releases](https://github.com/laobamac/SimpleHDA/releases).
2. Reboot to activate native volume controls and output routing.

### 4. Enable HDMI Full Range RGB (Optional - External Monitors)
macOS often treats external HDMI monitors as televisions, forcing Limited Range YCbCr (16–235) with washed-out colors:
1. Run the included EDID override installer:
   ```bash
   cd Utilities/Display-Overrides
   sudo ./install_hdmi_rgb_fix.sh
   ```
2. Reconnect the HDMI cable. (Pre-configured for MSI PRO MP251 E14L; see [`Utilities/Display-Overrides/README.md`](Utilities/Display-Overrides/README.md) for other displays).

### 5. Configure Sleep / Power Management (Recommended)
Set stable S3 RAM sleep parameters and disable hibernatemode / network wake:
```bash
cd Utilities/Power-Management
sudo ./fix_sleep.sh
```

### 6. Disable Live Text Image Stalls (Recommended)
On Alder Lake, viewing images full-screen can trigger Apple's Live Text OCR shader compilation loops on the donor Tiger Lake driver:
```bash
cd Utilities/Photo-Viewer-Fix
./fix_photo_stall.sh
```

---

## Credits

- **[b00t0x](https://github.com/b00t0x):** WhateverXe, WhateverXe-Graphics, and CpuTopologyRebuild.
- **Thatisjigen & renedis:** Alder Lake eDP port hand-off, single-output CDCLK routing, and DE master sleep/wake logic.
- **[retropineaple](https://github.com/retropineaple):** GPU hardware reset recovery and RCS state restoration.
- **[laobamac](https://github.com/laobamac/SimpleHDA):** SimpleHDA audio restoration for macOS Tahoe.
- **[Acidanthera](https://github.com/acidanthera):** OpenCore, Lilu, AppleALC, VirtualSMC, and MacKernelSDK.
- **[TAT-Hins](https://github.com/TAT-Hins/Dell-Latitude-7490-Hackintosh-OC-EFI):** Reference documentation structure.
