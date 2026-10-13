#!/bin/bash
# Measures speed and delay (report section 7.1 and 7.2).
# Run on the DESKTOP after static-ip.sh on both machines:   bash tests/performance.sh

echo "===== 1. Internet speed (speedtest-cli) ====="
speedtest-cli --simple

echo; echo "===== 2. Speed desktop -> server (iperf3) ====="
iperf3 -c 222.22.22.10

echo; echo "===== 3. Speed server -> desktop (iperf3, reverse) ====="
iperf3 -c 222.22.22.10 -R

echo; echo "===== 4. Delay desktop <-> server (look at 'avg') ====="
ping -c 5 222.22.22.10

echo; echo "===== 5. Delay desktop -> google.com (look at 'avg') ====="
ping -c 5 www.google.com

echo; echo "===== 6. Delay server -> google.com (runs on the server over SSH, asks for its password) ====="
ssh group22@group22-02 "ping -c 5 www.google.com"

echo; echo "Performance tests finished."
