#!/usr/bin/env bash
set -euo pipefail
CFG="/boot/firmware/config.txt"; [ -f "/boot/config.txt" ] && CFG="/boot/config.txt"
grep -q "^dtoverlay=disable-wifi" "$CFG" || echo "dtoverlay=disable-wifi" | sudo tee -a "$CFG" >/dev/null
echo "Added disable-wifi overlay to $CFG (reboot to apply)."