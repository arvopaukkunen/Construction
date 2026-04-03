# RUTM52 WireGuard Golden Config (Public / Sanitized)

## Purpose
Stable remote-work access from a Mac laptop to a Windows workstation over WireGuard, with multiple WAN uplinks enabled, while keeping WireGuard return traffic pinned to the intended mobile interface.

RUTM52 multiwan loadbalancer is with One Starlink std + Telia 5g + Telia 4g. Starlink is in router's WAN port physically and Telia sim cards are used on RUTM52 mob1xxx & mob2xxx.

---

## Target Outcome
- Mac on an external network connects to the RUTM52 WireGuard server
- Mac reaches only company LAN resources through a split tunnel
- Mac can RDP to a Windows workstation inside the company network
- Multiple WAN uplinks may stay enabled
- WireGuard reply traffic must use the intended mobile interface, not an arbitrary load-balanced path

---

## Architecture Summary
### WireGuard server (RUTM52)
- Interface: `wgserver`
- Tunnel subnet: `10.5.0.0/24` *(example only)*
- Listen port: `55321` *(example only)*
- Public endpoint: `<PUBLIC_WAN_IP_OR_DDNS>:55321`

### Mac WireGuard client
- Tunnel IP: `10.5.0.2/32` *(example only)*
- Split tunnel routes:
  - `<COMPANY_LAN_SUBNET>`
  - `<WIREGUARD_TUNNEL_SUBNET>`
- PersistentKeepalive: `25`

### Windows workstation
- Target host: `<WINDOWS_WORKSTATION_LAN_IP>`
- RDP port: `3389`

---

## Key Design Principle
When the router hosts the WireGuard server and multiple WAN uplinks are active, **the reply path must remain symmetric**.

That means:
- the Mac connects to one specific public endpoint
- the router must reply using the same intended WAN path/source IP
- generic multi-WAN load balancing can break the WireGuard handshake if replies leave through the wrong uplink

---

## Required Router Configuration

### 1. Main WAN Priority
In `Network → WAN`, ensure the intended mobile interface is above other uplinks in the main priority order.

Example:
1. `<PRIMARY_MOBILE_INTERFACE>`
2. `<STARLINK_OR_WAN_INTERFACE>`
3. `<SECONDARY_MOBILE_INTERFACE>`

This is critical for router-originated WireGuard reply traffic.

### 2. Multiwan / Load Balancer
Keep all required uplinks enabled:
- `<PRIMARY_MOBILE_INTERFACE>`
- `<STARLINK_OR_WAN_INTERFACE>`
- `<SECONDARY_MOBILE_INTERFACE>`

### 3. Multiwan Policy
Create a dedicated policy for WireGuard return traffic.

Policy name example:
- `wg_primary_mobile_only`

That policy must contain only:
- the member corresponding to `<PRIMARY_MOBILE_INTERFACE>`

Do **not** include the general WAN or backup WANs in this special WireGuard policy.

### 4. WireGuard Peer
Peer name example:
- `MacRemote`

Peer settings:
- Public key = current Mac public key
- Allowed IPs = `<MAC_WG_IP>/32`
- `Route allowed IPs` = `off`

### 5. Firewall Rule for WireGuard Listener
Keep exactly one active rule:

- Protocol: `UDP`
- Source zone: `wan`
- Destination zone: `Device (input)`
- Destination port: `<WG_LISTEN_PORT>`
- Action: `Accept`
- Address family: `IPv4`

### 6. No Port Forward
There must be **no port forward** for WireGuard to the Windows workstation.

The router itself is the WireGuard server.

---

## Mac Client Reference Config (Sanitized)
```ini
[Interface]
PrivateKey = <MAC_PRIVATE_KEY>
Address = <MAC_WG_IP>/32
DNS = <OPTIONAL_DNS_SERVER>

[Peer]
PublicKey = <ROUTER_WG_PUBLIC_KEY>
AllowedIPs = <COMPANY_LAN_SUBNET>, <WIREGUARD_TUNNEL_SUBNET>
Endpoint = <PUBLIC_WAN_IP_OR_DDNS>:<WG_LISTEN_PORT>
PersistentKeepalive = 25
```

---

## Validation Commands

### On Mac
```bash
ping -c 4 <ROUTER_WG_IP>
ping -c 4 <WINDOWS_WORKSTATION_LAN_IP>
nc -vz <WINDOWS_WORKSTATION_LAN_IP> 3389
```

Expected:
- all succeed

### On RUTM52
```sh
ip route get <MAC_PUBLIC_IP>
wg show
wg show wgserver latest-handshakes
wg show wgserver transfer
```

Expected:
- route uses the intended mobile interface and source public IP
- handshake is non-zero
- transfer counters increase

Example good route shape:
```text
<MAC_PUBLIC_IP> dev <PRIMARY_MOBILE_DEVICE> src <PRIMARY_MOBILE_PUBLIC_IP>
```

---

## Security Hardening Checklist
- Keep **RDP behind WireGuard only**
- Do **not** expose RDP directly to the internet
- Restrict Windows firewall inbound RDP to the WireGuard subnet if possible
- Keep **Network Level Authentication** enabled on Windows
- Use a strong password for the Windows RDP account
- Do not expose router admin UI or SSH from WAN unless absolutely required
- Keep only one WireGuard firewall listener rule
- Remove obsolete test rules and old port forwards
- Keep router, Windows, and WireGuard client updated

---

## Operational Notes

### Normal Office Mode
- WireGuard off on Mac
- local LAN works normally

### Remote-Work Mode
- Mac on hotspot / external network
- WireGuard on
- RDP to the Windows workstation over its LAN IP

### Other VPN Client in Use
- turn WireGuard off while using another organization's VPN client

---

## Troubleshooting Summary

### Symptom
WireGuard on the Mac shows the tunnel as connected locally, but:
- handshake does not complete
- router tunnel IP does not respond
- LAN resources are unreachable

### Likely Cause
The router is replying through the wrong WAN interface because of multi-WAN routing or load balancing.

### Most Important Check
```sh
ip route get <MAC_PUBLIC_IP>
```

If the route does **not** use the intended mobile interface and source public IP, the WireGuard handshake can fail.

### Stable Fix Pattern
- keep the intended mobile WAN first in main WAN priority
- use a dedicated Multiwan policy for WireGuard return traffic
- avoid generic balancing for router-hosted WireGuard server replies

---

## Backup Practice
Keep at least two router backups:
1. `known-good-working-wireguard`
2. `post-cleanup-production`

---

## Notes for Public Documentation
This document intentionally masks:
- public IP addresses
- private LAN addressing
- WireGuard public/private keys
- workstation identifiers
- organization-specific names
