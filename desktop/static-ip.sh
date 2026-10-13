#!/bin/bash
# Step 2 on the DESKTOP: switch to the static IP 222.22.22.11
# and let it find the server by name.
# Run from the repository folder:   sudo bash desktop/static-ip.sh

cp desktop/netplan-static.yaml /etc/netplan/01-network-manager-all.yaml
chmod 600 /etc/netplan/01-network-manager-all.yaml
netplan apply
sleep 3

# Local "DNS": the name group22-02 means 222.22.22.10
grep -q "group22-02" /etc/hosts || echo "222.22.22.10 group22-02" >> /etc/hosts

echo
echo "=== Desktop now uses ==="
ip -4 -brief addr show enp0s3
grep group22-02 /etc/hosts
