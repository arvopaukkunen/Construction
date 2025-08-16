#!/usr/bin/env bash
set -euo pipefail
CON_NAME="$(nmcli -t -f NAME,TYPE con show | awk -F: '$2=="ethernet"{print $1; exit}')"
[ -z "$CON_NAME" ] && { echo "No ethernet connection found"; exit 1; }
sudo nmcli con mod "$CON_NAME" ipv4.method auto ipv4.addresses "" ipv4.gateway "" ipv4.dns "" ipv6.method auto
sudo nmcli con up "$CON_NAME"
nmcli -f GENERAL.STATE,IP4.ADDRESS dev show eth0 | sed -n '1,20p'