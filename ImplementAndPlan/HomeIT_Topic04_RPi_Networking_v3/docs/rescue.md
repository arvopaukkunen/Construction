# Network Rescue
If you lost network connectivity:
```bash
sudo ip addr add 000.000.000.151/24 dev eth0
sudo ip route add default via 000.000.000.1
sudo systemctl restart NetworkManager || sudo systemctl restart dhcpcd
```
Reapply permanent configuration as per main guide.