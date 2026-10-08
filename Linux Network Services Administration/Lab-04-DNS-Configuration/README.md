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

### 1. Forward Zone Structural Integrity Check
```bash
sudo named-checkzone "example130.lab" "/etc/named/fwd.example130.lab"
# Expected Output: zone example130.lab/IN: loaded serial 2026100803 OK
```

### 2. Live Replication Validation Audit (Executed on Slave)
```bash
sudo ls -l /var/named/slaves/
# Expected Output:
# -rw-r--r-- 1 named named 480 Oct 8 12:33 fwd.example130.lab.db
# -rw-r--r-- 1 named named 514 Oct 8 12:33 named.16.172.db
```

### 3. Network Lookup Query Resolution
```bash
dig @172.16.30.130 ftp.example130.lab +short
# Returns: 172.16.32.130

dig @172.16.30.130 www.google.ca +short
# Status: NOERROR (Recursive caching layer success)
```

## 🚀 Lab Outcomes
* Successfully automated cross-subnet BIND package deployments.
* Eliminated DNS resolution loops by implementing glue records for custom authoritative nameservers.
* Set up strict access control recursion matrices, allowing local segments while securing port 53 bindings.
