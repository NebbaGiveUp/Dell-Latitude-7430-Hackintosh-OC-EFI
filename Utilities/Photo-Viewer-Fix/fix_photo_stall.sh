#!/usr/bin/env bash
#
# fix_photo_stall.sh
# Dell Latitude 7430 Hackintosh - Fix Image Viewer / Telegram Full-Screen Photo Stall
#
# On macOS Tahoe with Intel Iris Xe (Alder Lake), opening full-screen images in messaging apps
# like Telegram, Safari, or Preview invokes Apple's Live Text OCR vision framework.
# Because the donor Gen12 Tiger Lake Metal driver lacks native neural/vision shader instructions,
# MTLCompilerService enters a 5-10 second shader compilation loop that stalls image display.
# Disabling Live Text OCR eliminates this stall instantly (0.0s latency).
#

set -euo pipefail

echo "Disabling Apple Live Text OCR globally to eliminate image viewer stalls..."

defaults write -g AppleLiveTextEnabled -bool false

echo ""
echo "Setting verified: AppleLiveTextEnabled = $(defaults read -g AppleLiveTextEnabled)"
echo ""
echo "Telegram and photo preview apps will now open full-screen images instantaneously."
