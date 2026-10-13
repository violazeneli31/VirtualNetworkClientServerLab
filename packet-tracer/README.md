# Packet Tracer topology

[`group22-topology.pkt`](group22-topology.pkt) is our lab network built in **Cisco Packet Tracer**, a network simulator from Cisco.

It shows the same network we built in VirtualBox, but with Cisco devices, so you can see each device's role. **The picture of this topology is in section 8.3 of the PDF report (page 36).**

---

## How to open it

1. Install **Cisco Packet Tracer 9.0 or newer** on your computer.
2. Download the file: on GitHub, click `group22-topology.pkt`, then the **Download** button (↓).
3. Double-click the file, or in Packet Tracer go to **File → Open** and choose it.

---

## What it means

| Device | Model | Role in our network | IP address |
|---|---|---|---|
| **group22-01** | PC-PT | The **client**, our Ubuntu Desktop | 222.22.22.11 |
| **group22-02** | Server-PT | The **server**, our Ubuntu Server (website + SSH) | 222.22.22.10 |
| **Switch-group22** | 2960-24TT | Connects the devices inside the network (Layer 2) | none |
| **Router-group22** | 2911 | The **gateway** that leads out of the network | 222.22.22.1 |

* All devices are in network `222.22.22.0/24`.
* The PC and the server use `222.22.22.1` as their gateway and `8.8.8.8` as DNS.
* The PC and the server are cabled to the switch, and the switch is cabled to the router.
* **Green triangles** on the cables mean the link is up. Hover over a device to see its IP.

---

## Try it

* **Ping:** click **group22-01 → Desktop → Command Prompt**, then type `ping 222.22.22.10` (the server) and `ping 222.22.22.1` (the router).
* **See a device's settings:** click **group22-01 → Desktop → IP Configuration**.
* **See the router's configuration:** click **Router-group22 → CLI**, then type `enable`, then `show running-config`.
* **Watch packets move:** click **Simulation** (bottom right), send a ping, and press **Play**. The packet travels PC → switch → server and back.

---

## Build it yourself from scratch

1. **Add the devices** from the bottom-left panel: End Devices → **PC** and **Server**, Switches → **2960**, Routers → **2911**.
2. **Cable them** with *Connections (lightning icon) → Copper Straight-Through*: PC → switch, server → switch, switch → router port **GigabitEthernet0/0**.
3. **Rename them:** click each device → **Config** → *Display Name*: `group22-01`, `group22-02`, `Switch-group22`, `Router-group22`.
4. **Set the PC and server IPs:** click the device → **Desktop → IP Configuration → Static**.

   | Device | IP Address | Subnet Mask | Default Gateway | DNS Server |
   |---|---|---|---|---|
   | group22-01 | 222.22.22.11 | 255.255.255.0 | 222.22.22.1 | 8.8.8.8 |
   | group22-02 | 222.22.22.10 | 255.255.255.0 | 222.22.22.1 | 8.8.8.8 |

5. **Set the router:** click the router → **CLI** and type:
   ```
   enable
   configure terminal
   hostname Router-group22
   interface GigabitEthernet0/0
   ip address 222.22.22.1 255.255.255.0
   no shutdown
   end
   write memory
   ```
6. When all the cable lights are green, test with `ping` as shown in **Try it**.
