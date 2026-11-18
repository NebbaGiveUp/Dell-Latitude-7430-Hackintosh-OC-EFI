#!/usr/bin/env bash
#
# install_hdmi_rgb_fix.sh
# Dell Latitude 7430 Hackintosh - HDMI Full Range RGB EDID Override Installer
#
# This script installs an EDID override for external HDMI monitors (specifically MSI PRO MP251 E14L)
# that forces macOS CoreDisplay to output Full Range RGB (0-255) instead of Limited Range YCbCr (16-235).
#

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TARGET_ROOT="/Library/Displays/Contents/Resources/Overrides"
VENDOR_DIR="DisplayVendorID-dc4"
VENDOR_ALIAS="DisplayVendorID-0dc4"
PRODUCT_FILE="DisplayProductID-60d2"

if [[ $EUID -ne 0 ]]; then
    echo "Error: This script must be run as root. Please run with sudo:"
    echo "  sudo $0"
    exit 1
fi

ACTION="${1:---install}"

case "$ACTION" in
    --install|-i)
        echo "Installing HDMI Full Range RGB EDID override..."

        mkdir -p "${TARGET_ROOT}/${VENDOR_DIR}"

        cp "${SCRIPT_DIR}/${VENDOR_DIR}/${PRODUCT_FILE}" "${TARGET_ROOT}/${VENDOR_DIR}/${PRODUCT_FILE}"
        chmod 644 "${TARGET_ROOT}/${VENDOR_DIR}/${PRODUCT_FILE}"
        chown root:wheel "${TARGET_ROOT}/${VENDOR_DIR}/${PRODUCT_FILE}"

        # Create 4-character hex vendor alias for compatibility across all macOS display resolvers
        ln -snf "${VENDOR_DIR}" "${TARGET_ROOT}/${VENDOR_ALIAS}"

        chown -R root:wheel "${TARGET_ROOT}/${VENDOR_DIR}"
        chmod 755 "${TARGET_ROOT}/${VENDOR_DIR}"

        echo ""
        echo "Successfully installed EDID override:"
        echo "  - File:  ${TARGET_ROOT}/${VENDOR_DIR}/${PRODUCT_FILE}"
        echo "  - Alias: ${TARGET_ROOT}/${VENDOR_ALIAS} -> ${VENDOR_DIR}"
        echo ""
        echo "Please reconnect your HDMI display or restart your Mac for changes to take effect."
        ;;

    --uninstall|-u)
        echo "Uninstalling HDMI Full Range RGB EDID override..."

        if [[ -L "${TARGET_ROOT}/${VENDOR_ALIAS}" ]]; then
            rm -f "${TARGET_ROOT}/${VENDOR_ALIAS}"
            echo "Removed alias: ${TARGET_ROOT}/${VENDOR_ALIAS}"
        fi

        if [[ -d "${TARGET_ROOT}/${VENDOR_DIR}" ]]; then
            rm -rf "${TARGET_ROOT}/${VENDOR_DIR}"
            echo "Removed directory: ${TARGET_ROOT}/${VENDOR_DIR}"
        fi

        echo ""
        echo "Successfully uninstalled EDID override."
        echo "Please reconnect your HDMI display or restart your Mac to revert to default EDID handling."
        ;;

    --help|-h)
        echo "Usage: sudo $0 [--install | --uninstall]"
        echo ""
        echo "Options:"
        echo "  --install, -i     Install the Full Range RGB EDID override (default)"
        echo "  --uninstall, -u   Remove the EDID override and restore default display behavior"
        echo "  --help, -h        Show this help message"
        ;;

    *)
        echo "Unknown option: $ACTION"
        echo "Usage: sudo $0 [--install | --uninstall]"
        exit 1
        ;;
esac
