#!/bin/bash
# Step 1 on the SERVER: install the programs and use DHCP with Google DNS.
# Run from the repository folder:   sudo bash server/setup.sh

# Answer "yes" in advance to iperf3's "start as a service?" question
echo "iperf3 iperf3/start_daemon boolean true" | debconf-set-selections

# Install: web server, SSH server, speed-test server and network tools
apt update
apt install -y nginx openssh-server iperf3 net-tools traceroute

# Start them now and at every boot
systemctl enable --now nginx ssh iperf3

# Network: DHCP address, DNS 8.8.8.8 / 8.8.4.4
cp server/netplan-dhcp.yaml /etc/netplan/50-cloud-init.yaml
chmod 600 /etc/netplan/50-cloud-init.yaml
netplan apply
sleep 3

echo
echo "=== Server ready ==="
ip -4 -brief addr show enp0s3
systemctl is-active nginx ssh iperf3
