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
| Memory | 16 GB LPDDR4x 4267 MHz dual-channel |
| Storage | 512 GB M.2 NVMe PCIe Gen 4 Solid State Drive |
| Display | 14.0-inch Full High Definition (1920x1080) 60Hz internal eDP panel |
| Sound Card | Intel Alder Lake-P cAVS (`8086:51c8`) + Realtek ALC3281 / ALC711 Codec |
| Wireless | Intel Wi-Fi 6E AX211 (802.11ax, 2x2, 160MHz) |
| Bluetooth | Intel Bluetooth 5.3 Controller |
| Ethernet | USB-C / Thunderbolt Gigabit Adapter |
| Touchpad | Dell I2C HID Multitouch Touchpad + Physical Buttons |
| Keyboard | Dell Backlit Keyboard with ambient brightness control |
| Web Camera | Integrated HD 720p / RGB WebCam with privacy shutter |
| Battery | Dell 4-cell 58Wh ExpressCharge Battery |
| Ports | 2x Thunderbolt 4 (Power Delivery & DisplayPort), 1x USB-A 3.2 Gen 1 (PowerShare), 1x HDMI 2.0, 1x 3.5mm Universal Audio Jack, 1x MicroSD Card Reader |

---

### Bootloader and SMBIOS

- **Bootloader:** OpenCore 1.0.x
- **SMBIOS Model:** `MacBookPro16,2`
- **PlatformInfo Notice:** All serial numbers and unique hardware identifiers have been cleared from this public repository. **You must generate your own serials using [GenSMBIOS](https://github.com/corpnewt/GenSMBIOS) before booting.**

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
- HyperThreading: **Enabled**

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

- [x] **Full Graphics Acceleration (Metal 2):** Powered by the patched [WhateverXe-AlderLake](https://github.com/NebbaGiveUp/WhateverXe-AlderLake) driver, running Apple's Gen12 Tiger Lake userspace stack with 1536 MB Dynamic VRAM.
- [x] **Internal Display Backlight Control:** Native brightness adjustments via Fn keys (`BrightnessKeys.kext`) and the macOS Control Center slider.
- [x] **Internal Audio Output & Input:** Speakers, headphone jack, and microphone arrays function natively via `AppleALC.kext` and `SimpleHDA.kext` (layout-id `11`).
- [x] **Display Idle Sleep & Wake:** Inactivity display blanking and keyboard/trackpad wake function cleanly without GPU blitter ring hangs.
- [x] **System Sleep & Wake:** Reliable sleep and wake via closing the lid or selecting Sleep from the Apple menu.
- [x] **Wi-Fi Networking:** 2.4 GHz and 5 GHz wireless connections via `AirportItlwm.kext`.
- [x] **Bluetooth:** Native pairing and wireless audio transmission via `IntelBluetoothFirmware.kext` and `BlueToolFixup.kext`.
- [x] **Multitouch Trackpad:** Full macOS multi-finger gestures, tap-to-click, and tracking via `VoodooI2C.kext` and `VoodooI2CHID.kext`.
- [x] **Battery & Thermal Management:** Accurate battery percentage, discharge rates, and power state readout via `VirtualSMC.kext` and `SMCBatteryManager.kext`.
- [x] **Web Camera:** Internal HD webcam recognized and operational in FaceTime, Photo Booth, and web conferencing tools.
- [x] **USB-C & Thunderbolt Ports:** Power Delivery charging, data transfer, and external device connectivity.
- [x] **USB-A 3.2 Ports:** High-speed USB 3.0/3.1 bus data transfer with PowerShare functionality.

---

## What Does Not Work

- **Safari Video Streaming (YouTube and DRM Video):**  
  YouTube videos and specific DRM-wrapped web media fail to play in Safari due to macOS Tahoe WebKit MediaSource engine and FairPlay pipeline changes that are incompatible with the unreleased Tiger Lake GVA driver stack.  
  *Workaround:* Use an alternative web browser (Google Chrome, Brave, Microsoft Edge, or Mozilla Firefox) for smooth, hardware-accelerated video streaming.
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

- **[b00t0x](https://github.com/b00t0x):** Creator of the WhateverXe project and WhateverXe-Graphics userspace bundle framework.
- **[NebbaGiveUp](https://github.com/NebbaGiveUp/WhateverXe-AlderLake):** WhateverXe Alder Lake-P eDP port mode 0 and display pipeline patchset.
- **Thatisjigen & renedis:** Crucial reverse-engineering and commits for Alder Lake eDP port hand-off, single-output CDCLK routing, and Display Engine master parking.
- **[laobamac](https://github.com/laobamac/SimpleHDA):** Creator of SimpleHDA for restoring the AppleHDA audio stack on macOS Tahoe without root patches.
- **[Acidanthera](https://github.com/acidanthera):** Authors and maintainers of OpenCore, Lilu, AppleALC, VirtualSMC, RestrictEvents, and MacKernelSDK.
- **[TAT-Hins](https://github.com/TAT-Hins/Dell-Latitude-7490-Hackintosh-OC-EFI):** Reference layout for documentation structure and system configuration.
