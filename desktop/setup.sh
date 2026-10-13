#!/bin/bash
# Step 1 on the DESKTOP: install the client programs (the desktop uses DHCP by default).
# Run from the repository folder:   sudo bash desktop/setup.sh

# Answer "yes" in advance to Wireshark's "let normal users capture?" question
echo "wireshark-common wireshark-common/install-setuid boolean true" | debconf-set-selections

# Install: browser, SSH client, curl, speed tests, traceroute, Wireshark (+ tshark for scripts)
apt update
apt install -y firefox openssh-client curl speedtest-cli iperf3 traceroute wireshark tshark

# Let your user capture packets (takes effect after logging out and in)
usermod -aG wireshark "$SUDO_USER"

echo
echo "=== Desktop ready ==="
ip -4 -brief addr show enp0s3
firefox --version
ssh -V
