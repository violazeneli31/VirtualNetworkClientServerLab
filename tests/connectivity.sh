#!/bin/bash
# Tests the network and the client-server apps (report sections 4 and 5).
# Run on EITHER machine:
#
#   bash tests/connectivity.sh               after static-ip.sh (uses 222.22.22.10 / .11 and names)
#   bash tests/connectivity.sh <other-IP>    while still on DHCP (give the other machine's IP)

if [ "$(hostname)" = "group22-02" ]; then
  ME=Server;  OTHER=${1:-group22-01}
else
  ME=Desktop; OTHER=${1:-group22-02}
fi
echo "Testing from the $ME, other machine: $OTHER"

echo; echo "===== 1. My IP address ====="
ip -4 -brief addr show enp0s3

echo; echo "===== 2. Ping the other machine ====="
ping -c 4 "$OTHER"

echo; echo "===== 3. Ping a public website (Internet works) ====="
ping -c 4 www.google.com

echo; echo "===== 4. Traceroute (first hop = gateway 222.22.22.1) ====="
traceroute -m 5 www.google.com

echo; echo "===== 5. DNS lookup with Google DNS ====="
nslookup www.google.com 8.8.8.8

if [ "$ME" = "Server" ]; then
  echo; echo "===== 6. Nginx is running and serves its page ====="
  systemctl is-active nginx
  curl -s http://localhost | grep -o "<title>.*</title>"
else
  echo; echo "===== 6. Get the web page from the server with curl ====="
  curl -s "http://$OTHER" | grep -o "<title>.*</title>"

  echo; echo "===== 7. SSH into the server (type 'yes' the first time, then the password) ====="
  ssh "group22@$OTHER" "echo; echo Logged in to \$(hostname) over SSH; uptime"

  echo; echo "===== 8. Opening the server's page in Firefox ====="
  firefox "http://$OTHER" >/dev/null 2>&1 &
fi

echo; echo "Connectivity tests finished."
