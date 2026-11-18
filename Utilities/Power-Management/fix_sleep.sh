#!/usr/bin/env bash
#
# fix_sleep.sh
# Dell Latitude 7430 Hackintosh - Optimal Sleep & Power Management Configuration
#
# Configures macOS power management for pure S3 RAM sleep, prevents sleepimage disk writes,
# and disables network wake events that cause black screens or stuck transcoders on wake.
#

set -euo pipefail

if [[ $EUID -ne 0 ]]; then
    echo "Error: This script must be run as root. Please run with sudo:"
    echo "  sudo $0"
    exit 1
fi

echo "Configuring power management parameters for Dell Latitude 7430..."

# Global stability flags: Pure S3 RAM sleep, no standby delay, no background network wake
pmset -a hibernatemode 0
pmset -a standby 0
pmset -a powernap 0
pmset -a proximitywake 0
pmset -a tcpkeepalive 0
pmset -a womp 0

# Battery profile: 5 min display idle sleep, 10 min system sleep
pmset -b displaysleep 5
pmset -b sleep 10
pmset -b disksleep 10

# AC / Charger profile: 15 min display idle sleep, 30 min system sleep
pmset -c displaysleep 15
pmset -c sleep 30
pmset -c disksleep 10

echo "Locking sleepimage to 0 bytes to prevent disk hibernation writes..."
if [[ -f /var/vm/sleepimage ]]; then
    chflags nouchg /var/vm/sleepimage 2>/dev/null || true
    rm -f /var/vm/sleepimage
fi
touch /var/vm/sleepimage
chflags uchg /var/vm/sleepimage

echo ""
echo "Power management configured successfully:"
pmset -g custom
echo ""
echo "Sleep and wake are now configured for reliable S3 operation."
