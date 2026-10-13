# Virtual Networking & Client–Server Deployment

A Computer Networks lab where two Ubuntu virtual machines share a private network in VirtualBox:

* a **server** (`group22-02`) that runs a website (Nginx), remote login (SSH) and a speed-test service (iperf3);
* a **desktop** (`group22-01`) that uses them through Firefox, SSH, curl and Wireshark.

We set up the network, tested it layer by layer, measured its speed, and looked at the actual packets.

> Course project for **CEN 307 – Computer Networks**, Epoka University (Group 22, January 2026).

---

## What's in this repository

| File / folder | What it is |
|---|---|
| `Computer Networks Project Group 22.pdf` / `.docx` | The full report with screenshots |
| [`host/`](host/) | `create-lab.sh` (Mac/Linux) and `create-lab.bat` (Windows): create the network and both VMs |
| [`server/`](server/) | `setup.sh` and `static-ip.sh` for the server, plus the network settings they use |
| [`desktop/`](desktop/) | `setup.sh` and `static-ip.sh` for the desktop, plus the network settings they use |
| [`tests/`](tests/) | `connectivity.sh`, `performance.sh`, `wireshark.sh`: all the tests |
| [`packet-tracer/`](packet-tracer/) | The topology in Cisco Packet Tracer (`.pkt`) and how to open it |

---

## How we did it

1. **Created a NAT Network** in VirtualBox called `group22_nat` (`222.22.22.0/24`, DHCP on).
2. **Installed Ubuntu Server and Ubuntu Desktop** as VMs on that network.
3. **Installed the programs:** Nginx, SSH and iperf3 on the server; Firefox, curl, speedtest-cli and Wireshark on the desktop.
4. **Tested on DHCP:** ping, traceroute, nslookup and SSH.
5. **Switched to static IPs** (server `222.22.22.10`, desktop `222.22.22.11`) and mapped names in `/etc/hosts`.
6. **Tested again:** pinged by name, opened the website in Firefox, and ran curl and SSH.
7. **Measured** speed (iperf3, speedtest) and delay (ping), and **captured** HTTP, DNS and the TCP handshake in Wireshark.
8. **Drew the topology** in Cisco Packet Tracer.

---

## Do it yourself, step by step

### Before you start

* Install **VirtualBox**.
* Download the **Ubuntu Server 24.04** and **Ubuntu Desktop 24.04** ISO files from ubuntu.com.
* Download this repository to your computer: green **Code** button → **Download ZIP**, then unzip it.

### Step 1: Create the network and the two VMs (your computer)

Open a terminal **inside the repository folder** and run the script with the paths to your two ISO files:

| Your computer | Command |
|---|---|
| Mac / Linux | `bash host/create-lab.sh ~/Downloads/ubuntu-24.04.3-live-server-amd64.iso ~/Downloads/ubuntu-24.04.3-desktop-amd64.iso` |
| Windows (Command Prompt) | `host\create-lab.bat C:\Users\you\Downloads\ubuntu-24.04.3-live-server-amd64.iso C:\Users\you\Downloads\ubuntu-24.04.3-desktop-amd64.iso` |

It creates `group22_nat`, builds both VMs (4096 MB RAM, 2 CPUs, 25 GB disk) and starts them.

### Step 2: Install Ubuntu in both windows

Follow the installer and type these values when it asks:

| VM | Name / computer name | Username |
|---|---|---|
| UbuntuServer | `group22-02` | `group22` |
| UbuntuDesktop | `group22-01` | `group22` |

When it finishes, press **Enter** to reboot and log in.

### Step 3: Get this repository inside each VM

**Server**
```bash
git clone <this repository's URL>
cd <repository folder>
```
**Desktop**: open *Terminal*, then:
```bash
sudo apt install -y git
git clone <this repository's URL>
cd <repository folder>
```
The URL is under the green **Code** button on GitHub. All the following commands are run from inside this folder.

### Step 4: Install everything

| Machine | Command | What it does |
|---|---|---|
| Server | `sudo bash server/setup.sh` | Installs Nginx, SSH, iperf3 and net-tools, and sets DHCP with Google DNS |
| Desktop | `sudo bash desktop/setup.sh` | Installs Firefox, SSH client, curl, speedtest-cli and Wireshark |

Each script prints the machine's IP at the end. **Write both IPs down**, because you need them in the next step.

### Step 5: Test the network on DHCP

Give each machine the **other** machine's IP from step 4:

| Machine | Command (example IPs) |
|---|---|
| Server | `bash tests/connectivity.sh 222.22.22.6` |
| Desktop | `bash tests/connectivity.sh 222.22.22.5` |

It runs ping, a ping to google.com, traceroute and nslookup. On the desktop it also fetches the web page and logs in with SSH (type `yes`, then the password).

### Step 6: Switch to static IPs

| Machine | Command | Result |
|---|---|---|
| Server | `sudo bash server/static-ip.sh` | IP `222.22.22.10`; knows `group22-01` by name |
| Desktop | `sudo bash desktop/static-ip.sh` | IP `222.22.22.11`; knows `group22-02` by name |

### Step 7: Test again with static IPs and names

On **both** machines:
```bash
bash tests/connectivity.sh
```
This time it uses the names (`group22-01` / `group22-02`). On the desktop it also opens **http://group22-02** in Firefox, which should show "Welcome to nginx!".

### Step 8: Measure speed and delay (desktop)

```bash
bash tests/performance.sh
```
It measures Internet speed, speed in both directions between the VMs, and delay to the server and to google.com.

### Step 9: Capture packets with Wireshark (desktop)

```bash
sudo bash tests/wireshark.sh
```
It captures for 15 seconds while making web and DNS traffic, then shows the **TCP handshake**, the **HTTP request/response** and the **DNS query/response**. The capture is saved as `lab-capture.pcap`. Open it with `wireshark lab-capture.pcap` to explore it in the Wireshark window.

### Step 10: See the topology in Packet Tracer

See [`packet-tracer/README.md`](packet-tracer/README.md).

---

## Our results

| Measurement | Result |
|---|---|
| Speed desktop → server (iperf3) | **3.03 Gbit/s** |
| Speed server → desktop (iperf3) | **2.65 Gbit/s** |
| Internet download / upload (speedtest) | **51.48 / 18.99 Mbit/s** |
| Delay desktop ↔ server (ping) | **1.24 ms** |
| Delay desktop → google.com | **23.55 ms** |
| Delay server → google.com | **15.09 ms** |
| Packet loss in all tests | **0%** |

**What it means:** traffic between the two VMs never leaves the computer, so it's about 60× faster and 20× quicker to respond than traffic to the Internet. Traceroute shows only the first hop (the gateway `222.22.22.1`), because the routers after it don't answer traceroute.

**In Wireshark we saw:**
* **TCP handshake:** SYN → SYN-ACK → ACK on port 80, then the HTTP request, then FIN to close the connection.
* **HTTP:** `GET /` answered with `200 OK`. The browser also asked for `/favicon.ico` and got `404 Not Found`.
* **DNS:** the desktop asked `8.8.8.8` for `www.google.com` and got its IP address back.

---

## Team

Group 22: Sidrit Rrustemi, Viola Zeneli, Arsildo Veliu, Megi Almadhi, Artemisa Hasalami

Instructor: Shkumbin Fida
