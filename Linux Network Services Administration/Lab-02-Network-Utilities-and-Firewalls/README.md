# Lab 02 - Network Utilities and Netfilter Firewall Configuration

This directory contains the production shell script and evaluation diagnostics mapping out system access control matrix routines. The objective of this lab is to utilize netfilter firewall management (`iptables`), raw frame monitoring engines (`tcpdump`), and raw socket streaming tools (`netcat`) to map out subnet boundaries.

## Key Implemented Milestones

* **Security Policy Rule Matrices** — Constructed a modular `iptables` configuration utility that systematically purges runtime table spaces, authorizes inbound TCP traffic states originating exclusively from trusted client network paths (`172.16.31.0/24`), and rejects traffic from sibling server nodes (`172.16.30.0/24`) on production port `49999`.
* **Network Diagnostic Interceptions** — Managed deep packet inspection layers utilizing `tcpdump` tracking on the `ens224` network interface layer, collecting precise transactional payload dumps formatting in multi-byte ASCII hexadecimal notation fields.
* **Socket Bound Infrastructure** — Configured generic daemon bindings using continuous Netcat standard loops (`nc -vkl`) to securely evaluate and test inbound connectivity channels.

---

## File Layout

```text
Lab-02-Network-Utilities-and-Firewalls/
├── README.md        # Lab documentation and validation guide
└── firewall.sh      # Core firewall manipulation shell script
```

---

## Environment Verification Guide

To review or run evaluations on this implementation structure across testing nodes:

### 1. Apply Infrastructure Control Rules
Execute the shell utility as an administrative user (`root`/`sudo`) on the Server node:
```bash
chmod +x firewall.sh
sudo ./firewall.sh
```

### 2. Stand Up the Multi-Interface Socket Listener
Bind the network tracking process across active endpoints to catch multi-subnet data transfers:
```bash
nc -vkl 49999
```

### 3. Initialize Packet Inspector
In an alternate server console layout workspace, attach the logging utility to monitor the target hardware interface link:
```bash
sudo tcpdump -i ens224 -qnX -tttt port 49999
```

### 4. Execute Matrix Validation Routine
* **Client Accept Test:** Fire an endpoint probe from a Client node (`172.16.31.x`). Traffic drops cleanly into the listener array and logs to the screen.
  ```bash
  nc -v [SERVER_IP] 49999
  ```
* **Server Reject Test:** Fire an endpoint query loop directly from an internal Server node system interface environment (`172.16.30.x`). The target router blocks the communication path immediately with a connection rejection error message.
  ```bash
  nc -v [SERVER_IP] 49999
  ```
