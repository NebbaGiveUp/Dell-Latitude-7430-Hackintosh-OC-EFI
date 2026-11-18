# Dell-Latitude-7430-Hackintosh-OpenCore-EFI

An OpenCore EFI configuration providing hardware acceleration and macOS support for the **Dell Latitude 7430** laptop.

---

## Tested macOS Version

- macOS Tahoe 26.7.3 (`25G342`)

---

## System Configuration

| Component | Specification |
| :--- | :--- |
| Model | Dell Latitude 7430 |
| Processor | 12th Gen Intel Core i7-1270P (Alder Lake-P, 12 Cores / 16 Threads, up to 4.80 GHz) |
| Graphics | Intel Iris Xe Graphics (`8086:46A6`, Revision `0x0C`, Subsystem `1028:0B09`, 1536 MB Dynamic VRAM, Metal 2) |
| Memory | 32 GB LPDDR5 4800 MHz dual-channel |
| Storage | 256 GB NVMe SSD (Samsung SM981/PM981/PM983 controller, supported via NVMeFix) |
| Display | 14.0-inch Full High Definition (1920x1080) 60Hz internal eDP panel |
| Sound Card | Intel Alder Lake-P cAVS (`8086:51c8`) + Realtek ALC3281 / ALC711 Codec |
| Wireless | Intel Wi-Fi 6E AX211 (802.11ax, 2x2, 160MHz) |
| Bluetooth | Intel Bluetooth 5.3 Controller |
| Ethernet | USB-C / Thunderbolt Gigabit Adapter |
| Touchpad | Dell I2C HID Multitouch Touchpad + Physical Buttons |
| Keyboard | Dell Backlit Keyboard with ambient brightness control |
| Web Camera | Integrated FHD 1080p RGB WebCam with privacy shutter |
| Battery | Dell 4-cell 58Wh ExpressCharge Battery |
| Ports | 2x Thunderbolt 4 (Power Delivery & DisplayPort), 1x USB-A 3.2 Gen 1 (PowerShare), 1x HDMI 2.0, 1x 3.5mm Universal Audio Jack, 1x MicroSD Card Reader |

---

---

## BIOS Settings

The following Dell BIOS configurations (accessible via `F2` during boot) are recommended:

### General
- Boot Mode: **UEFI**
- Advanced Boot Options: **Enable UEFI Network Stack: Disabled**

### System Configuration
- SATA Operation: **AHCI / NVMe** (Do not use RAID On)
- Integrated NIC: **Enabled**
- USB Configuration: **Enable USB Boot Support**, **Enable External USB Ports**
- Audio: **Enabled**

### Security
- TPM 2.0 Security: **TPM On**
- Absolute / Computrace: **Disabled**

### Secure Boot
- Secure Boot: **Disabled**

### Performance
- Intel SpeedStep: **Enabled**
- C-States Control: **Enabled**
- Intel TurboBoost: **Enabled**
- HyperThreading: **Enabled** (Untested)

### Virtualization
- Intel Virtualization Technology: **Enabled**
- VT for Direct I/O (VT-d): **Enabled**

### Power Management
- Intel Speed Shift Technology: **Enabled**
- Wake on AC: **Disabled**
- Block Sleep: **Disabled**

### POST Behavior
- Fastboot: **Thorough**

---

## What Works

- [x] **CPU Core Topology and Power Scheduling:** Alder Lake hybrid architecture (4 Performance cores + 8 Efficient cores, 16 logical threads) correctly mapped and scheduled using `CpuTopologyRebuild.kext`. High-priority tasks are prioritized onto Performance cores, Hyper-Threading is recognized, and all 16 execution units remain fully utilized.
- [x] **Full Graphics Acceleration (Metal 2) & Media Decoding:** Powered by the patched [WhateverXe-AlderLake](https://github.com/NebbaGiveUp/WhateverXe-AlderLake) driver, running Apple's Gen12 Tiger Lake userspace stack with 1536 MB Dynamic VRAM. Includes `-wexgvadrop=IOGVAScaler,IOGVABGRAEnc,IOGVAHEVCEncodeCapabilities,IOGVACodec` in `boot-args`. This selective GVA configuration eliminates the donor VA driver's hardware Multi-Format Codec (`VCS0`) GPU reset on Telegram animated GIFs/stickers and eliminates the 9.2-second `VPHAL` unsupported resolution stall on fullscreen photo previews, while preserving full GPU hardware HEVC decoding and 60Hz butter-smooth desktop compositing.
- [x] **Internal Display Backlight Control:** Native brightness adjustments via Fn keys (`BrightnessKeys.kext`) and the macOS Control Center slider.
- [x] **Internal Audio Output & Input:** Speakers, and microphone arrays function natively via `AppleALC.kext` and `SimpleHDA.kext` (layout-id `11`).
- [x] **Display Idle Sleep & Wake:** Inactivity display blanking and keyboard/trackpad wake function cleanly without GPU blitter ring hangs.
- [x] **System Sleep & Wake:** Reliable sleep and wake via closing the lid or selecting Sleep from the Apple menu.
- [x] **Wi-Fi Networking:** 2.4 GHz and 5 GHz wireless connections via `AirportItlwm.kext`.
- [x] **Bluetooth:** Native pairing and wireless audio transmission via `IntelBluetoothFirmware.kext` and `BlueToolFixup.kext`.
- [x] **Multitouch Trackpad:** Full macOS multi-finger gestures, tap-to-click, and tracking via `VoodooI2C.kext` and `VoodooI2CHID.kext`.
- [x] **Battery & Thermal Management:** Accurate battery percentage, discharge rates, and power state readout via `VirtualSMC.kext` and `SMCBatteryManager.kext`.
- [x] **Web Camera:** Internal 1080p FHD webcam recognized and operational in FaceTime, Photo Booth, and web conferencing tools.
- [x] **USB-C Ports:** Power Delivery charging, data transfer, and external device connectivity.
- [x] **USB-A 3.2 Ports:** High-speed USB 3.0/3.1 bus data transfer with PowerShare functionality.
---

## What Does Not Work

- **Safari 4K Video Streaming:**  
  Safari web video playback operates smoothly up to 1080p60. 4K streams utilizing VP9 or AV1 codecs rely on CPU software decoding or may drop frames. For 4K 60fps streaming, Chromium-based browsers (Google Chrome, Brave, Edge) or Firefox are recommended.
- **Apple-Native AirDrop & Sidecar:**  
  AirDrop and Sidecar rely on Apple-proprietary Broadcom Wi-Fi/Bluetooth hardware features that are unsupported on Intel wireless cards.

---

## Required Post-Installation Steps

After placing this EFI into your system's EFI partition, the following software components are required on macOS Tahoe to finalize graphics and audio functionality:

### 1. Generate Your Own Serial Numbers (Mandatory)
Before your first boot, open `EFI/OC/config.plist` using ProperTree or OpenCore Auxiliary Tools:
1. Run [GenSMBIOS](https://github.com/corpnewt/GenSMBIOS) and generate a `MacBookPro16,2` profile.
2. Fill in:
   - `PlatformInfo -> Generic -> SystemSerialNumber`
   - `PlatformInfo -> Generic -> MLB`
   - `PlatformInfo -> Generic -> SystemUUID`
   - `PlatformInfo -> Generic -> ROM` (Use your primary network adapter MAC address without colons)

### 2. Install Userspace Graphics Drivers
This EFI utilizes [WhateverXe-AlderLake](https://github.com/NebbaGiveUp/WhateverXe-AlderLake) for Intel Iris Xe acceleration:
1. Download **`WhateverXe-Graphics-0.4.4.pkg`** from the [WhateverXe-Graphics Releases](https://github.com/b00t0x/WhateverXe-Graphics/releases/tag/v0.4.4).
2. Run the package installer and reboot. This installs the required Metal, OpenGL, and Video Acceleration driver bundles into `/Library/Extensions` and `/Library/GPUBundles`.

### 3. Install CoreAudio HAL Plug-in
macOS Tahoe removed the native `AppleHDA.kext` driver stack. This EFI restores it using [SimpleHDA](https://github.com/laobamac/SimpleHDA):
1. Download and run the **`SimpleHDA-HAL-1.0.1.pkg`** installer from the [SimpleHDA Releases](https://github.com/laobamac/SimpleHDA/releases).
2. This installs `AppleHDAHALPlugIn.bundle` to `/Library/Audio/Plug-Ins/SimpleHDA/` for native volume control and device node discovery.

---

## Special Credits

- **[b00t0x](https://github.com/b00t0x):** Creator of the CpuTopologyRebuild plugin, WhateverXe project, and WhateverXe-Graphics userspace bundle framework.
- **Thatisjigen & renedis:** Crucial reverse-engineering and commits for Alder Lake eDP port hand-off, single-output CDCLK routing, and Display Engine master parking.
- **[laobamac](https://github.com/laobamac/SimpleHDA):** Creator of SimpleHDA for restoring the AppleHDA audio stack on macOS Tahoe without root patches.
- **[Acidanthera](https://github.com/acidanthera):** Authors and maintainers of OpenCore, Lilu, AppleALC, VirtualSMC, RestrictEvents, and MacKernelSDK.
- **[TAT-Hins](https://github.com/TAT-Hins/Dell-Latitude-7490-Hackintosh-OC-EFI):** Reference layout for documentation structure and system configuration.
