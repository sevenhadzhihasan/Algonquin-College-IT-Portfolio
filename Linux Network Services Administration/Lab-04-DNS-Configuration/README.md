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

## 🧪 Live Verification Metrics & Outputs

### 1. Hardened Client-Side Resolver Configuration
Running `cat /etc/resolv.conf` verified that the intrusive DHCP gateway (`192.168.70.2`) was successfully stripped. Both cluster nodes are permanently locked onto the local loopback socket interface:
```text
search localdomain example130.lab
nameserver 127.0.0.1
```

### 2. Verified Authoritative Forward Mapping
Querying `ftp.example130.lab` yields a seamless response from the local deployment engine with an active **`aa` (Authoritative Answer)** header flag:
```text
;; ->>HEADER<<- opcode: QUERY, status: NOERROR, id: 3600
;; flags: qr aa rd ra; QUERY: 1, ANSWER: 1, AUTHORITY: 2, ADDITIONAL: 3

;; ANSWER SECTION:
ftp.example130.lab.	86400	IN	A	172.16.32.130

;; SERVER: 127.0.0.1#53(127.0.0.1)
```

### 3. External Cache Proxy Forwarding Execution
Querying a public web interface like `google.ca` passes directly through the internal system daemon cache block rather than dropping or hitting the network sandbox path directly:
```text
;; ->>HEADER<<- opcode: QUERY, status: NOERROR, id: 7164
;; flags: qr rd ra; QUERY: 1, ANSWER: 1, AUTHORITY: 0, ADDITIONAL: 1

;; ANSWER SECTION:
google.ca.		5	IN	A	142.250.69.67

;; SERVER: 127.0.0.1#53(127.0.0.1)
```

### 4. Slave Node Replication & System Logs Audit
Tracing the system initialization metrics shows the secondary node dynamically fetching the active zone data fields across subnets via notifications from the primary engine:
```text
Oct  9 19:50:52 hadz0024-CLT named[3226]: zone example130.lab/IN: loaded serial 2026100901
Oct  9 19:50:52 hadz0024-CLT named[3226]: zone 16.172.in-addr.arpa/IN: loaded serial 2026100901
Oct  9 19:50:52 hadz0024-CLT named[3226]: zone example130.lab/IN: sending notifies (serial 2026100901)
```
