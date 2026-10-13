#!/bin/bash
# Captures HTTP, DNS and the TCP three-way handshake (report section 7.3 and 7.4).
# Run on the DESKTOP after static-ip.sh on both machines:   sudo bash tests/wireshark.sh
# The capture is saved as lab-capture.pcap so you can also open it in Wireshark.

FILE=lab-capture.pcap

echo "Capturing on enp0s3 for 15 seconds..."
tshark -i enp0s3 -a duration:15 -w "$FILE" -q 2>/dev/null &
sleep 3

# Make the traffic we want to see
curl -s http://222.22.22.10 > /dev/null          # TCP handshake + HTTP GET / 200 OK
nslookup www.google.com 8.8.8.8 > /dev/null      # DNS query + response
wait
chmod 644 "$FILE"

echo; echo "===== 1. TCP three-way handshake: SYN, SYN-ACK, ACK (port 80) ====="
tshark -r "$FILE" -Y "tcp.port == 80 && tcp.len == 0" 2>/dev/null | head -3

echo; echo "===== 2. HTTP request and response ====="
tshark -r "$FILE" -Y "http" 2>/dev/null

echo; echo "===== 3. DNS query and response (to 8.8.8.8) ====="
tshark -r "$FILE" -Y "dns" 2>/dev/null

echo; echo "===== 4. HTTP GET with curl (full page) ====="
curl http://222.22.22.10

echo; echo "Saved: $FILE  ->  open it with:  wireshark $FILE"
