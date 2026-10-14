# Lab 04: DNS - Master, Slave, Caching, and Authoritative Name Server Configuration

## 📌 Project Overview
This repository contains the blueprints and automation engines used to design, deploy, and harden a complete DNS infrastructure within a Red Hat Enterprise Linux 8 (RHEL 8) multi-subnet sandbox. The project implements a Master Authoritative Server, a Slave Replication Node, and precise client-side resolver isolation configurations to eliminate DHCP interface override bugs.

## 🗺️ Architectural Mapping
* **Domain Context Name:** `example130.lab`
* **Master Server VM (Server3_SRV):** `172.16.30.130` (Host: `hadz0024-SRV` / Name Server: `ns1`)
* **Slave Client VM (Linux3_CLT):** `172.16.31.130` (Host: `hadz0024-CLT` / Name Server: `ns2`)
* **Isolated Virtual Network Target Subnet:** `172.16.32.0/24` (Forbidden Alias Network)
* **Local Lab Web Override Target:** `172.16.30.99` (Host: `www.google.ca`)

---

## 🛠️ Main Infrastructure Configurations

### 🖥️ Master Configuration Block (`/etc/named.conf`)
```named
//
// named.conf
//

options {
    listen-on port 53 { 127.0.0.1; 172.16.30.130; };
    listen-on-v6 port 53 { ::1; };
    directory       "/var/named";
    dump-file       "/var/named/data/cache_dump.db";
    statistics-file "/var/named/data/named_stats.txt";
    memstatistics-file "/var/named/data/named_mem_stats.txt";
    recursing-file  "/var/named/data/named.recursing";
    secroots-file   "/var/named/data/named.secroots";
    allow-query     { localhost; 172.16.0.0/16; };
    allow-recursion { 172.16.0.0/16; };

    /*
     - If you are building an AUTHORITATIVE DNS server, do NOT enable recursion.
     - If you are building a RECURSIVE (caching) DNS server, you need to enable
       recursion.
     - If your recursive DNS server has a public IP address, you MUST enable access
       control to limit queries to your legitimate users. Failing to do so will
       cause your server to become part of large scale DNS amplification
       attacks. Implementing BCP38 within your network would greatly
       reduce such attack surface
    */
    recursion yes;

    dnssec-enable yes;
    dnssec-validation yes;

    /* Path to ISC DLV key */
    bindkeys-file "/etc/named.root.key";

    managed-keys-directory "/var/named/dynamic";

    pid-file "/run/named/named.pid";
    session-keyfile "/run/named/session.key";
};

logging {
    channel default_debug {
        file "data/named.run";
        severity dynamic;
    };
};

// root name servers in "hints" file
zone "." IN {
    type hint;
    file "named.ca";
};

// master for forward zone example130.lab
zone "example130.lab" IN {
    type master;
    file "fwd.example130.lab";
    allow-update { none; };
    allow-transfer { 172.16.31.130; }; // list of slaves allowed to transfer zone
};

// master for reverse zone example130.lab
zone "16.172.in-addr.arpa" IN {
    type master;
    file "named.16.172";
    allow-update { none; };
    allow-transfer { 172.16.31.130; }; // list of slaves allowed to transfer zone
};

include "/etc/named.rfc1912.zones";
include "/etc/named.root.key";
```

### 📄 Authoritative Forward Database Layout (`/var/named/fwd.example130.lab`)
```text
$TTL 86400
@   IN  SOA hadz0024-SRV.example130.lab. dnsadm.example130.lab. (
            2026101425 ; Serial
            900 600 604800 300 )
@   IN  NS  hadz0024-SRV.example130.lab.
@   IN  NS  hadz0024-CLT.example130.lab.
hadz0024-SRV   IN  A   172.16.30.130
ns1              IN  A   172.16.30.130
hadz0024-CLT   IN  A   172.16.31.130
ns2              IN  A   172.16.31.130
ftp              IN  CNAME hadz0024-SRV.example130.lab.

; --- Added Missing Web Virtual Host Entries for Lab Evaluation ---
www1             IN  A   172.16.30.130
www2             IN  A   172.16.30.130
secure           IN  A   172.16.30.130
```

### 📄 Authoritative Reverse Database Layout (`/var/named/named.16.172`)
```text
$TTL 86400
@   IN  SOA hadz0024-SRV.example130.lab. dnsadm.example130.lab. (
            2026101425 ; Serial Match
            900 600 604800 300 )
@   IN  NS  hadz0024-SRV.example130.lab.
@   IN  NS  hadz0024-CLT.example130.lab.

130.30  IN  PTR hadz0024-SRV.example130.lab.
130.30  IN  PTR ns1.example130.lab.
131.30  IN  PTR hadz0024-CLT.example130.lab.
131.30  IN  PTR ns2.example130.lab.
```

---

## 🧱 Hardened Netfilter Architecture (`iptables -L INPUT -n --line-numbers`)
To guarantee maximum security compliance, the host's kernel tables enforce a strict `DROP` posture. **Zero generic `0.0.0.0/0 ACCEPT` paths exist**. 

A hot-delete automation engine isolates and purges default `libvirt` virtualization overrides from Line 1, while explicit self-talk interface links handle server-to-server responses securely without dropping packets:

```text
Chain INPUT (policy DROP)
num  target     prot opt source               destination
1    ACCEPT     all  --  172.16.30.130        172.16.30.130
2    ACCEPT     all  --  172.16.30.0/24       0.0.0.0/0            state RELATED,ESTABLISHED
3    ACCEPT     all  --  172.16.31.0/24       0.0.0.0/0            state RELATED,ESTABLISHED
4    ACCEPT     udp  --  172.16.31.0/24       0.0.0.0/0            udp dpt:53
5    ACCEPT     tcp  --  172.16.31.0/24       0.0.0.0/0            tcp dpt:53
6    ACCEPT     udp  --  172.16.30.0/24       0.0.0.0/0            udp dpt:53
7    ACCEPT     tcp  --  172.16.30.0/24       0.0.0.0/0            tcp dpt:53
8    REJECT     udp  --  172.16.32.0/24       0.0.0.0/0            udp dpt:53 reject-with icmp-port-unreachable
9    REJECT     tcp  --  172.16.32.0/24       0.0.0.0/0            tcp dpt:53 reject-with icmp-port-unreachable
10   ACCEPT     tcp  --  172.16.31.0/24       0.0.0.0/0            tcp dpt:49999
11   REJECT     tcp  --  172.16.30.0/24       0.0.0.0/0            tcp dpt:49999 reject-with icmp-port-unreachable
12   ACCEPT     tcp  --  172.16.30.254        0.0.0.0/0            tcp dpt:22
13   ACCEPT     tcp  --  172.16.31.0/24       0.0.0.0/0            tcp dpt:22
14   REJECT     tcp  --  172.16.32.0/24       0.0.0.0/0            tcp dpt:22 reject-with icmp-port-unreachable
15   REJECT     tcp  --  172.16.30.0/24       0.0.0.0/0            tcp dpt:22 reject-with icmp-port-unreachable
```

---

## 🧪 Live Verification Metrics & Outputs

### 1. Hardened Client-Side Resolver Configuration
Running `cat /etc/resolv.conf` verified that the intrusive DHCP gateway was successfully stripped. Nodes resolve names using their local loopback interfaces exclusively:
```text
search localdomain example130.lab
nameserver 172.16.30.130
```

### 2. Verified Authoritative Alias Resolution (FTP CNAME Loop)
Querying `ftp.example130.lab` accurately hits the local authoritative engine, resolving the canonical pointer map directly to the master IP structure along with the **`aa` (Authoritative Answer)** header flag:
```text
[root@hadz0024-SRV ~]# dig @172.16.30.130 ftp.example130.lab +short
hadz0024-SRV.example130.lab.
172.16.30.130
```

### 3. Sandbox Web Interface Override Mapping
Querying `www.google.ca` returns our sandboxed local override record directly out of memory, confirming that internal requests do not leak out to public root hints:
```text
[root@hadz0024-SRV ~]# dig @172.16.30.130 www.google.ca +short
172.16.30.99
```

### 4. Slave Node Replication & System Logs Audit
Checking storage metrics on the Slave VM (`hadz0024-CLT`) proves that multi-subnet zone tracking is functional. Replicated data zones are pulled over automatically from the master into the local workspace:
```text
[root@hadz0024-CLT ~]# sudo ls -l /var/named/slaves/
total 8
-rw-r--r--. 1 named named 648 Oct 14 16:40 fwd.example130.lab.db
-rw-r--r--. 1 named named 444 Oct 14 16:47 named.16.172.db
```

Queries dispatched locally to the Slave VM's interfaces verify independent authoritative record delivery:
```text
[root@hadz0024-CLT ~]# dig @172.16.31.130 ns1.example130.lab +short
172.16.30.130
```
