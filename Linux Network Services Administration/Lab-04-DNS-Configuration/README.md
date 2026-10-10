# Lab 04: DNS - Master, Slave, Caching, and Authoritative Name Server Configuration

## 📌 Project Overview
This repository contains the blueprints and automation engines used to design, deploy, and harden a complete DNS infrastructure within a Red Hat Enterprise Linux 8 (RHEL 8) multi-subnet sandbox. The project implements a Master Authoritative Server, a Slave Replication Node, and precise client-side resolver isolation configurations to eliminate DHCP interface override bugs.

## 🗺️ Architectural Mapping
* **Domain Context Name:** `example130.lab`
* **Master Server VM (Server3_SRV):** `172.16.30.130` (Host: `hadz0024-SRV` / Name Server: `ns1`)
* **Slave Client VM (Linux3_CLT):** `172.16.31.130` (Host: `hadz0024-CLT` / Name Server: `ns2`)
* **Isolated Virtual Network Target:** `172.16.32.130` (Host: `ftp.example130.lab`)

---

## 🛠️ Main Infrastructure Configurations

### 🖥️ Master Configuration Block (`/etc/named.conf`)
```named
options {
    listen-on port 53 { 127.0.0.1; any; };
    directory       "/var/named";
    dump-file       "/var/named/data/cache_dump.db";
    statistics-file "/var/named/data/named_stats.txt";
    memstatistics-file "/var/named/data/named_mem_stats.txt";
    allow-query     { any; };
    
    # Secure recursion metrics for authorized subnets
    allow-recursion { 127.0.0.1; 172.16.30.0/24; 172.16.31.0/24; };
    recursion yes;
    
    # Global forwarders to handle external recursive resolution
    forwarders { 8.8.8.8; 8.8.4.4; };
    dnssec-validation no;
};

zone "." IN { type hint; file "named.ca"; };
include "/etc/named.rfc1912.zones";
include "/etc/named.root.key";

zone "example130.lab" IN {
    type master;
    file "/var/named/fwd.example130.lab";
    allow-transfer { 172.16.31.130; };
    also-notify { 172.16.31.130; };
};

zone "16.172.in-addr.arpa" IN {
    type master;
    file "/var/named/named.16.172";
    allow-transfer { 172.16.31.130; };
    also-notify { 172.16.31.130; };
};
```

---

## 🧪 Verification Diagnostics

### 1. Configuration & Zone File Validation
```bash
# Verify Master configuration syntax profile
sudo named-checkconf

# Verify Master forward zone integrity
cd /var/named
sudo named-checkzone "example130.lab" "fwd.example130.lab"
# Expected Output: zone example130.lab/IN: loaded serial 2026100901 OK

# Verify Master reverse zone integrity
sudo named-checkzone "16.172.in-addr.arpa" "named.16.172"
# Expected Output: zone 16.172.in-addr.arpa/IN: loaded serial 2026100901 OK
```

### 2. Client-Side Resolver Verification (`/etc/resolv.conf`)
Run on **both** cluster nodes to guarantee that NetworkManager/DHCP gateway overrides (`192.168.70.2`) have been completely stripped:
```bash
cat /etc/resolv.conf
# Expected Output:
# search localdomain example130.lab
# nameserver 127.0.0.1
```

### 3. Integrated Resolution Matrix Tests
Execute these native queries directly on either server node terminal window to demonstrate active resolution through your local infrastructure:

```bash
# A. Verify Master Forward Host Resolution
dig hadz0024-SRV.example130.lab +short
# Expected Output: 172.16.30.130
# Verification: Note the responding line ends with ";; SERVER: 127.0.0.1#53"

# B. Verify Lab Required FTP Target Alias Map
dig ftp.example130.lab +short
# Expected Output: 172.16.32.130

# C. Verify Reverse Subnet Pointers (Canonical Absolute PTR Check)
dig -x 172.16.30.130 +short
# Expected Output: 
# hadz0024-SRV.example130.lab.
# ns1.example130.lab.

# D. Verify External Caching Layer (Proxy Forwarders)
dig google.ca +short | head -n 1
# Expected Output: Active public web IP address
# Verification: Must route cleanly through local BIND engine (;; SERVER: 127.0.0.1#53)
```

### 4. Slave Replication Synchronization Audit
Run directly on the **Slave Node (`hadz0024-CLT`)** to prove AXFR dynamic zone distribution succeeded:
```bash
sudo ls -l /var/named/slaves/
# Expected Output: non-zero byte sizing files for fwd.example130.lab.db and named.16.172.db

# Query local replicated data directly via slave loopback socket
dig @127.0.0.1 ns1.example130.lab +short
# Expected Output: 172.16.30.130
```
