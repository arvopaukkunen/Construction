# Network Rescue
If you lost network connectivity:
```bash
sudo ip addr add 192.168.123.151/24 dev eth0
sudo ip route add default via 192.168.123.1
sudo systemctl restart NetworkManager || sudo systemctl restart dhcpcd
```
Reapply permanent configuration as per main guide.