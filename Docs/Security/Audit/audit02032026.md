# Teltonika RUTOS Multi-Router Security Audit — Analysis
**Date:** 2026-03-02  
**Scope:** Review of collected on-device audit reports and the audit launcher script.
## What the audit script does
The launcher script connects to each router via SSH, executes a read-only inventory/audit shell script on the router, writes the report to `/tmp/rut_audit.txt`, then copies that report back to the Mac using SCP.
### Security considerations of the launcher design
- Uses `sshpass` and a plaintext password (environment variable / `.env` file). This increases the risk of credential disclosure via shell history, process list, or accidental sharing.
- Uses `StrictHostKeyChecking=accept-new`. This is convenient but can silently trust a first-seen host key (riskier if run on untrusted networks).
- Pulls configuration excerpts (`uci show ...`) into local files; treat the resulting audit outputs as secrets.
## High-level findings
### 1) Password-based SSH enabled (all reviewed devices)
Across the reviewed audit outputs, Dropbear SSH configuration shows `PasswordAuth='on'` and `RootPasswordAuth='1'`, while WAN SSH access is disabled via `_sshWanAccess='0'`.

**Impact:** LAN compromise becomes more valuable, brute-force and credential reuse risks remain, and root password auth increases blast radius.

**Recommendation:** Switch to SSH keys and disable root password authentication (or root login entirely), keeping WAN SSH disabled.
### 2) RUTX10-2House has materially larger exposed surface
RUTX10-2House shows additional services listening beyond the typical web UI/DNS/SSH baseline:
- MQTT broker (mosquitto) listening on `0.0.0.0:1883` (all interfaces)
- Samba (smbd) listening on 139/445
- An unusual listener: `uhttpd` bound to port 3306 (port normally associated with MySQL)

**Recommendation:** If MQTT/Samba are not required on the router, disable them. If they are required, bind to LAN-only interfaces and restrict access.
### 3) MQTT appears allowed from WAN on RUTX10-2House
Firewall rules on RUTX10-2House include an explicit WAN INPUT ACCEPT for TCP/1883 with comment `Enable_MQTT_WAN`.

**Impact:** If WAN is internet-facing, TCP/1883 exposure is a high-risk ingress point unless protected by strong authentication, IP allowlisting, and (preferably) TLS.

**Recommendation:** Remove this WAN allow rule, or restrict it to VPN-only / allowlisted IPs, and migrate to MQTT over TLS (8883) if remote access is required.
## Per-device summary (from provided audit outputs)
| Device | SSH auth posture | Notable listeners | Notable WAN findings | RMS/telemetry |
|---|---|---|---|---|
| RUTX10-2House | PasswordAuth=on; RootPasswordAuth=1; _sshWanAccess=0 | 1883 (mosquitto on 0.0.0.0 / ::), 139/445 (smbd), 3306 (uhttpd - unusual), 22 (dropbear), 80/443 (uhttpd), 53 (dnsmasq) | Firewall contains explicit ACCEPT for WAN input tcp/1883 with comment '!fw3: Enable_MQTT_WAN'. | Outbound rms_mqtt connection to RMS endpoint (port 15010) observed. |
| RUTX10-3Riihi | PasswordAuth=on; RootPasswordAuth=1; _sshWanAccess=0 | 22 (dropbear), 80/443 (uhttpd), 53 (dnsmasq) [no MQTT/Samba listeners observed in audit excerpt] | No explicit WAN accept for 1883 observed in provided audit output. | Outbound rms_mqtt connection to RMS endpoint (port 15010) observed. |
| RUTX12-5Powerplant | PasswordAuth=on; RootPasswordAuth=1; _sshWanAccess=0 | 22 (dropbear), 80/443 (uhttpd), 53 (dnsmasq) [no MQTT/Samba listeners observed in audit excerpt] | No explicit WAN accept for 1883 observed in provided audit output. | Outbound rms_mqtt connection to RMS endpoint (port 15010) observed. |
| RUTX10-6Powerplant | PasswordAuth=on; RootPasswordAuth=1; _sshWanAccess=0 | 22 (dropbear), 80/443 (uhttpd), 53 (dnsmasq) [no MQTT/Samba listeners observed in audit excerpt] | No explicit WAN accept for 1883 observed in provided audit output. | Outbound rms_mqtt connection to RMS endpoint (port 15010) observed. |

## Evidence excerpts (sanitized)
> Note: excerpts are intentionally short and omit any secrets/tokens.

### RUTX10-2House
**dropbear:**
```text
dropbear.@dropbear[0].PasswordAuth='on'
dropbear.@dropbear[0].RootPasswordAuth='1'
dropbear.@dropbear[0]._sshWanAccess='0'
```
**mosq:**
```text
tcp 0 0 0.0.0.0:1883 ... LISTEN mosquitto
```
**mqtt_wan:**
```text
-A zone_wan_input -p tcp --dport 1883 ... "!fw3: Enable_MQTT_WAN" -j ACCEPT
```
**samba:**
```text
tcp ... :445 LISTEN smbd (plus :139)
```
**uhttpd3306:**
```text
tcp 0 0 0.0.0.0:3306 ... LISTEN uhttpd
```

### RUTX10-3Riihi
**dropbear:**
```text
dropbear.@dropbear[0].PasswordAuth='on'
dropbear.@dropbear[0].RootPasswordAuth='1'
dropbear.@dropbear[0]._sshWanAccess='0'
```

### RUTX12-5Powerplant
**dropbear:**
```text
dropbear.@dropbear[0].PasswordAuth='on'
dropbear.@dropbear[0].RootPasswordAuth='1'
dropbear.@dropbear[0]._sshWanAccess='0'
```

### RUTX10-6Powerplant
**dropbear:**
```text
dropbear.@dropbear[0].PasswordAuth='on'
dropbear.@dropbear[0].RootPasswordAuth='1'
dropbear.@dropbear[0]._sshWanAccess='0'
```
## Recommended remediation plan (prioritized)
1. **RUTX10-2House:** Remove WAN accept for TCP/1883 (MQTT), or restrict to VPN/allowlist + TLS.
2. **RUTX10-2House:** Bind mosquitto to LAN-only interface(s); require authentication; disable anonymous access.
3. **RUTX10-2House:** Disable Samba unless explicitly needed; if needed, ensure LAN-only and hardened config.
4. **All devices:** Move SSH to key-based authentication; disable root password auth; consider disabling root login.
5. **RUTX10-2House:** Investigate why `uhttpd` listens on port 3306; confirm it is an intended service binding.
6. **Audit tooling:** Replace `sshpass` with SSH keys and pin host keys (`StrictHostKeyChecking=yes`).
## Appendix A — Full audit launcher script (reference)
```bash
#!/usr/bin/env bash
# Teltonika RUTOS multi-router security audit (Mac launcher)
# Runs a full on-device audit via SSH and pulls reports back to Mac
# usage: in terminal...
# export RUTOS_USER="admin"
# export RUTOS_PASS="PallolaRul3z%"

source .rutosaudit.env
USERNAME="$RUTOS_USER"
PASSWORD="$RUTOS_PASS"
set -euo pipefail

# ====== ROUTER LIST ======
ROUTERS=(
  "192.168.123.2 RUTX10-2House"
  "192.168.123.3 RUTX10-3Riihi"
  "192.168.123.5 RUTX12-5Powerplant"
  "192.168.123.6 RUTX10-6Powerplant"
  "192.168.123.4 TSW212main"
  "192.168.123.7 TSW202-house"
)

# ====== CREDENTIALS ======
# Option A: export RUTOS_USER and RUTOS_PASS before running
# Option B: script will prompt if missing

USERNAME="${RUTOS_USER:-}"
PASSWORD="${RUTOS_PASS:-}"

if [ -z "$USERNAME" ]; then
  read -rp "Router username: " USERNAME
fi

if [ -z "$PASSWORD" ]; then
  read -rsp "Router password: " PASSWORD
  echo
fi

# ====== SSH SETTINGS ======
SSH_PORT=22
SSH_OPTS=(
  -p "$SSH_PORT"
  -o ConnectTimeout=10
  -o ServerAliveInterval=15
  -o ServerAliveCountMax=4
  -o StrictHostKeyChecking=accept-new
)

TS="$(date +%Y%m%d_%H%M%S)"

echo "==> Starting multi-router audit at $TS"
echo

for entry in "${ROUTERS[@]}"; do
  IP=$(echo "$entry" | awk '{print $1}')
  NAME=$(echo "$entry" | awk '{print $2}')
  LOCAL_OUT="audit_${NAME}_${TS}.txt"
  REMOTE_OUT="/tmp/rut_audit.txt"

  echo "==> Auditing $NAME ($IP)..."

  # Run remote audit
  sshpass -p "$PASSWORD" ssh "${SSH_OPTS[@]}" "$USERNAME@$IP" 'sh -s' <<'REMOTE_EOF'
#!/bin/sh
OUT="/tmp/rut_audit.txt"
echo "=== Teltonika RUTOS Security Audit ($(date)) ===" | tee "$OUT"

echo "\n[System]" | tee -a "$OUT"
uname -a | tee -a "$OUT"
[ -f /etc/openwrt_release ] && cat /etc/openwrt_release | tee -a "$OUT"
echo "Uptime: $(uptime)" | tee -a "$OUT"

echo "\n[Firmware version]" | tee -a "$OUT"
ubus call system board 2>/dev/null | tee -a "$OUT"

echo "\n[User accounts]" | tee -a "$OUT"
cat /etc/passwd | tee -a "$OUT"

echo "\n[SSH configuration]" | tee -a "$OUT"
uci show dropbear 2>/dev/null | tee -a "$OUT"

echo "\n[Installed packages count]" | tee -a "$OUT"
opkg list-installed | wc -l | tee -a "$OUT"

echo "\n[Recent package installs (top 50)]" | tee -a "$OUT"
for p in $(opkg list-installed | awk '{print $1}'); do
  t=$(opkg status "$p" 2>/dev/null | awk -F': ' '/^Installed-Time:/{print $2}')
  if [ -n "$t" ]; then
    d="$(date -d @"$t" 2>/dev/null || date -r "$t" 2>/dev/null || echo "$t")"
    echo "$d  $p"
  fi
done | sort -r | head -50 | tee -a "$OUT"

echo "\n[Running processes]" | tee -a "$OUT"
ps w | tee -a "$OUT"

echo "\n[Listening sockets]" | tee -a "$OUT"
netstat -ntulp 2>/dev/null | tee -a "$OUT" || ss -lntup 2>/dev/null | tee -a "$OUT"

echo "\n[Outbound connections]" | tee -a "$OUT"
netstat -ntup 2>/dev/null | grep ESTABLISHED | tee -a "$OUT" || ss -ntup 2>/dev/null | grep ESTAB | tee -a "$OUT"

echo "\n[Firewall rules]" | tee -a "$OUT"
iptables -S 2>/dev/null | tee -a "$OUT"
ip6tables -S 2>/dev/null | tee -a "$OUT"

echo "\n[Port forwards]" | tee -a "$OUT"
uci show firewall 2>/dev/null | grep redirect | tee -a "$OUT"

echo "\n[Autostart services]" | tee -a "$OUT"
ls -l /etc/rc.d/ 2>/dev/null | tee -a "$OUT"

echo "\n[Cron jobs]" | tee -a "$OUT"
crontab -l 2>/dev/null | tee -a "$OUT"
[ -f /etc/crontabs/root ] && cat /etc/crontabs/root | tee -a "$OUT"

echo "\n[Configs changed in last 14 days]" | tee -a "$OUT"
find /etc -type f -mtime -14 -printf "%TY-%Tm-%Td %TH:%TM %p\n" 2>/dev/null | sort -r | tee -a "$OUT"

echo "\n[RMS status]" | tee -a "$OUT"
pgrep -fl rms 2>/dev/null | tee -a "$OUT"
uci show 2>/dev/null | grep -i rms | tee -a "$OUT"

echo "\n[Data Sender]" | tee -a "$OUT"
pgrep -fl 'data[-_]?sender' 2>/dev/null | tee -a "$OUT"
uci show 2>/dev/null | grep -i data_sender | tee -a "$OUT"

echo "\n[Telemetry: MQTT, Azure IoT, SNMP, GPS]" | tee -a "$OUT"
pgrep -fl 'mosquitto|snmp|gpsd|azure|iothub' 2>/dev/null | tee -a "$OUT"
uci show 2>/dev/null | egrep -i 'mqtt|azure|iothub|snmp|gps' | tee -a "$OUT"

echo "\n[VPN services]" | tee -a "$OUT"
pgrep -fl 'openvpn|wg|strongswan|charon|xl2tp|pptp|sstp' 2>/dev/null | tee -a "$OUT"
uci show 2>/dev/null | egrep -i 'openvpn|wireguard|ipsec|l2tp|pptp|sstp' | tee -a "$OUT"

echo "\n[Writable dirs suspicious files]" | tee -a "$OUT"
find /tmp /var -type f -size +50k -printf "%p (%k KB)\n" 2>/dev/null | tee -a "$OUT"

echo "\n[Executable files in writable dirs]" | tee -a "$OUT"
find /tmp /var -type f -perm -111 -printf "%p\n" 2>/dev/null | tee -a "$OUT"

echo "\n[Binary integrity checks]" | tee -a "$OUT"
for b in /bin/busybox /usr/sbin/dropbear /usr/sbin/uhttpd /usr/sbin/dnsmasq /usr/sbin/hostapd /usr/sbin/pppd; do
  if [ -x "$b" ]; then
    if command -v sha256sum >/dev/null 2>&1; then
      sha256sum "$b" | tee -a "$OUT"
    elif command -v md5sum >/dev/null 2>&1; then
      md5sum "$b" | tee -a "$OUT"
    fi
  fi
done

echo "\n[Done] Full report saved to $OUT"
REMOTE_EOF

  # Pull report back to Mac
  sshpass -p "$PASSWORD" scp -P "$SSH_PORT" "$USERNAME@$IP:$REMOTE_OUT" "./$LOCAL_OUT"

  echo "    Saved: $LOCAL_OUT"
  echo
done

echo "==> All audits complete."
```
