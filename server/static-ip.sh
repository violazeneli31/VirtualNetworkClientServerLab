#!/bin/bash
# Step 2 on the SERVER: switch to the static IP 222.22.22.10
# and let it find the desktop by name.
# Run from the repository folder:   sudo bash server/static-ip.sh

cp server/netplan-static.yaml /etc/netplan/50-cloud-init.yaml
chmod 600 /etc/netplan/50-cloud-init.yaml
netplan apply
sleep 3

# Local "DNS": the name group22-01 means 222.22.22.11
grep -q "group22-01" /etc/hosts || echo "222.22.22.11 group22-01" >> /etc/hosts

echo
echo "=== Server now uses ==="
ip -4 -brief addr show enp0s3
grep group22-01 /etc/hosts
