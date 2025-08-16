# Raspberry Pi Networking — Disable Wi‑Fi & Set Static IP (Bookworm & Legacy)

Target:
- Static IP: **000.000.000.151/24**
- Gateway: **000.000.000.1**
- DNS: **000.000.000.1**

Use **NetworkManager** (Bookworm default) or **dhcpcd** (legacy).

## Detect stack
```bash
systemctl is-active NetworkManager
systemctl is-active dhcpcd
ip -4 addr show dev eth0
ip route
```

## A) NetworkManager (recommended)
```bash
CON_NAME="Wired connection 1"
sudo nmcli con mod "$CON_NAME" ipv4.method manual   ipv4.addresses 000.000.000.151/24   ipv4.gateway 000.000.000.1   ipv4.dns "000.000.000.1"   ipv6.method ignore
sudo nmcli con down "$CON_NAME" || true
sudo nmcli con up "$CON_NAME"
```

**Back to DHCP**
```bash
sudo nmcli con mod "$CON_NAME" ipv4.method auto ipv4.addresses "" ipv4.gateway "" ipv4.dns "" ipv6.method auto
sudo nmcli con up "$CON_NAME"
```

### Keyfile alternative
`/etc/NetworkManager/system-connections/eth0-static.nmconnection`
```ini
[connection]
id=eth0-static
type=ethernet
interface-name=eth0
[ipv4]
address1=000.000.000.151/24,000.000.000.1
dns=000.000.000.1;
method=manual
[ipv6]
method=ignore
```
Then `chmod 600` + `nmcli con reload && nmcli con up eth0-static`.

## B) dhcpcd (legacy)
`/etc/dhcpcd.conf`:
```ini
interface eth0
static ip_address=000.000.000.151/24
static routers=000.000.000.1
static domain_name_servers=000.000.000.1
```
Then `sudo systemctl restart dhcpcd`.

## Disable Wi‑Fi (permanent)
Append to `/boot/firmware/config.txt` (or `/boot/config.txt` on older):
```
dtoverlay=disable-wifi
```
Reboot.

## Verify
```bash
ip -4 addr show dev eth0
ip route
nmcli dev show eth0 | grep -E 'IP4.DNS|IP4.ADDRESS'
```

## Rescue (if link lost)
```bash
sudo ip addr add 000.000.000.151/24 dev eth0
sudo ip route add default via 000.000.000.1
sudo systemctl restart NetworkManager || sudo systemctl restart dhcpcd
```