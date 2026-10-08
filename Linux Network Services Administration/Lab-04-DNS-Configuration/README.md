# Lab 04: DNS - Master, Slave, Caching, and Authoritative Name Server Configuration

## 📌 Project Overview
This repository contains the blueprints and automation engine used to design and deploy a complete DNS infrastructure within a Red Hat Enterprise Linux 8 (RHEL 8) multi-subnet sandbox. The project implements a **Master Authoritative Server**, a **Slave Replication Node**, and cross-subnet data propagation blocks designed to prevent lookup loop errors.

## 🗺️ Architectural Mapping
* **Domain Context Name:** `example130.lab`
* **Master Server VM (`Server3_SRV`):** `172.16.30.130` (Host: `hadz0024-SRV`)
* **Slave Client VM (`Linux3_CLT`):** `172.16.31.130` (Host: `hadz0024-CLT`)
* **Isolated Virtual Network Segment:** `172.16.32.130` (Target: `ftp.example130.lab`)

---

## 🛠️ Main Infrastructure Configurations

### 🖥️ Master Configuration Block (`/etc/named.conf`)
```named
options {
    listen-on port 53 { 127.0.0.1; any; };
    directory       "/var/named";
    dump-file       "/var/named/data/cache_dump.db";
    allow-query     { any; };
    allow-recursion { 127.0.0.1; 172.16.30.0/24; 172.16.31.0/24; };
    recursion yes;
    dnssec-validation no;
};

zone "example130.lab" IN {
    type master;
    file "/etc/named/fwd.example130.lab";
    allow-transfer { 172.16.31.130; };
};

zone "16.172.in-addr.arpa" IN {
    type master;
    file "named.16.172";
    allow-transfer { 172.16.31.130; };
};
```
---

## 🧪 Verification Diagnostics

### 1. Configuration & Zone File Validation
```bash
# Verify Master forward zone configuration syntax
sudo named-checkzone "example130.lab" "/etc/named/fwd.example130.lab"
# Expected Output: zone example130.lab/IN: loaded serial 2026100803 OK
```

### 2. Master Server Resolution Tests (`172.16.30.130`)
Run from the Master node or any host in the allowed subnet to verify record mapping:

```bash
# 1. Verify Master Server Forward Host Record
dig @172.16.30.130 hadz0024-SRV.example130.lab +short
# Expected: 172.16.30.130

# 2. Verify Client Forward Host Record via Master
dig @172.16.30.130 hadz0024-CLT.example130.lab +short
# Expected: 172.16.31.130

# 3. Verify Lab Required FTP Alias / Host Record
dig @172.16.30.130 ftp.example130.lab +short
# Expected: 172.16.32.130

# 4. Verify Reverse Lookup Mappings (PTR Record)
dig @172.16.30.130 -x 172.16.30.130 +short
# Expected: hadz0024-SRV.example130.lab.

# 5. Verify External Recursive Caching Layer
dig @172.16.30.130 www.google.ca +short
```

### 3. Slave Node Replication & Resolution Tests (`172.16.31.130`)
Run directly on the Client/Slave VM:

```bash
# 1. Prove zone transfer files exist locally in storage
sudo ls -l /var/named/slaves/
# Expected: fwd.example130.lab.db and named.16.172.db populated

# 2. Query the Slave server directly for local nameserver resolution
dig @172.16.31.130 ns2.example130.lab +short
# Expected: 172.16.31.130

# 3. Query the Slave server for Master nameserver information
dig @172.16.31.130 ns1.example130.lab +short
# Expected: 172.16.30.130
```
