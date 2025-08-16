#!/usr/bin/env bash
set -euo pipefail
IP="${1:-000.000.000.151/24}"; GW="${2:-000.000.000.1}"; DNS="${3:-000.000.000.1}"
CON_NAME="$(nmcli -t -f NAME,TYPE con show | awk -F: '$2=="ethernet"{print $1; exit}')"
[ -z "$CON_NAME" ] && { echo "No ethernet connection found"; exit 1; }
sudo nmcli con mod "$CON_NAME" ipv4.method manual ipv4.addresses "$IP" ipv4.gateway "$GW" ipv4.dns "$DNS" ipv6.method ignore
sudo nmcli con down "$CON_NAME" || true
sudo nmcli con up "$CON_NAME"
nmcli -f GENERAL.STATE,IP4.ADDRESS dev show eth0 | sed -n '1,20p'