# 1. Physically connect Starlink

There are two main connection methods:

    a. Ethernet adapter (recommended).If you have Starlink with the official Ethernet adapter, plug that into one of RUTM52’s LAN/WAN ports, e.g. LAN4, and then:
    
    - Go to Network → Interfaces → Add.
    Choose WAN type: DHCP client.
    Assign to the physical port (e.g., eth1 or lan4).
    Rename it something like wan3_starlink.

    b. Wi-Fi as WAN (optional backup). If you can’t use the Ethernet adapter:
    Go to Network → Wireless → Scan.
    Join your Starlink Wi-Fi as a WAN client.
    Create a new interface (e.g. wan3_starlink_wifi).
    Mode: DHCP client.

Ethernet is always preferred for stability and throughput.

# 2. Configure Load Balancing

    Once Starlink interface is up:
    Navigate to Network → Load Balancing.
    Click Add or edit existing policy.
    
    You’ll now see all WANs:
        wan1_telia5g
        wan2_telia4g
        wan3_starlink

Set “Weight” for each according to your desired balance:

Example setup:

| Connection | Role      | Weight |
| ---------- | --------- | ------ |
| Telia 5G   | Primary   | 3      |
| Starlink   | Secondary | 2      |
| Telia LTE  | Backup    | 1      |
The higher the weight → the more traffic it handles.

# Ensure “Health Check” is enabled for each WAN (ping to e.g. 1.1.1.1 or 8.8.8.8) — this lets RUTM52 auto-disable a link if it fails.

Optional: Connection priorities (Failover + Balance hybrid)

If you want Starlink mainly as backup, not simultaneous load-balance:

Change mode to “Failover” for Starlink.

Keep Telia 5G and LTE for balance.
→ Then Starlink kicks in only when both mobile WANs fail.

# Verify
Go to:
- Status → Load Balancing
- You should see 3 WAN interfaces, their status, IPs, and traffic distribution.
- You can test by disconnecting one link — the router should seamlessly rebalance or fail over.

# Starlink considerations

Starlink has CGNAT — you’ll get a non-public IP (no inbound access).
If you need inbound connections (VPN, servers), consider:

Starlink Business (public IP)

Or use RUTM52’s VPN tunnel via your Telia WAN for inbound traffic.

Check MTU; Starlink often prefers MTU 1500, while mobile links might use 1420–1460.
You can adjust per interface if needed.

# Summary
You do not need much more than plugging it in, but:
- Create a separate WAN interface (DHCP).
- Add it to the Load Balancer policy.
- Set weights and health checks.
- Verify failover behavior and MTU compatibility.