# Lab 05: Web Server Configuration and Network Automation

## 📌 Project Overview
This project automates the deployment, provisioning, and verification of a secure, multi-tenant enterprise web infrastructure on **Redhat Linux / RHEL 8+**. 
It integrates network interface aliasing, an authoritative **BIND DNS Master Server**, an **Apache HTTP Server** utilizing both Name-Based and IP-Based Virtual Hosting, and a robust **iptables firewall matrix** to enforce strict subnet isolation.

The entire infrastructure is built using structural Bash scripts to ensure programmatic running, absolute consistency, and platform alignment across local enterprise networks.

---

## 🚀 Key Objectives & Technologies

### 1. Secure SSL/TLS Apache Web Infrastructure
* Deployed an **Apache HTTP Server (`httpd`)** environment configured to serve multi-tiered data over unencrypted HTTP (Port 80) and encrypted HTTPS (Port 443).
* Generated 120-day asymmetric cryptographic key pairs via **OpenSSL** (`mod_ssl`).
* Secured the traffic backend utilizing custom paths with strict Linux DAC file permissions (`0600`/`0644`).

### 2. Dual-Paradigm Virtual Hosting Configuration
* **Name-Based Hosting:** Configured `www.example130.lab` and `www.site130.lab` to share a single primary IP address (`172.16.30.130:80`). Apache dynamically maps directory indexing and tracking by inspecting the HTTP incoming `Host:` header field.
* **IP-Based Hosting:** Provisioned `secure.example130.lab` on an isolated network address segment (`172.16.32.130:443`).
* **Interface Aliasing:** Automated the dynamic runtime assignment of a secondary network interface IP alias mapping (`eth0:1`) to avoid physical NIC bloat.

### 3. Authoritative Master BIND DNS Deployment
* Engineered a master **BIND (`named`) DNS environment** serving as the local source of truth for the `.lab` domain space.
* Implemented **Apex Domain Variants** (naked domain resolving), ensuring structural entries like `site130.lab` automatically route identically to `www.site130.lab`.
* Hardened resolution integrity via custom root anchors and conditional query/recursion access controls restricted to the `172.16.0.0/16` network blocks.

### 4. Advanced iptables Subnet Isolation
* Built a packet-filtering matrix to enforce perimeter security directly at the kernel layer.
* **Explicit Rules Allowed:** Fully permits targeted web and resolution transactions (Ports 80, 443, 53) originating from the verified client testing subnet (`172.16.31.0/24`).
* **Explicit Rules Dropped/Rejected:** Rejects server network management access onto HTTP loops, explicitly rejects Port 80 cleartext traffic hitting the secure alias IP to force encryption compliance, and applies a strict global default `DROP` policy.

---

## 🛠️ Project Automation Architecture

The directory contains two core automated production scripts:

### 1. Server Provisioning Suite (`setup_server.sh`)
Executes the full structural build of the server platform in sequential order:
* **Package Synchronization:** Installs package binaries (`httpd`, `mod_ssl`, `bind`, `iptables`) securely.
* **NetworkManager Hardening:** Injects structural `dns=none` properties into configuration stanzas to lock down `/etc/resolv.conf` from runtime DHCP overwrites.
* **Database Authoring:** Writes BIND templates and zone files under proper security boundaries (`root:named`).
* **VHost Compilation:** Generates localized Virtual Host configuration files and handles absolute directory access privileges to block **HTTP 403 Forbidden** errors.
* **Firewall Initialization:** Flushes active chains, mounts stateful tracking (`ESTABLISHED,RELATED`) rules to prevent active SSH console disconnects, and activates the isolation matrix.

### 2. Client-Side Test Engine (`verification.sh`)
Executed on the client verification node (`172.16.31.130`) to audit the platform:
* **Resolution Checking:** Leverages explicit network calls (`dig @IP`) to confirm BIND returns the correct target addresses for name-based and IP-based vhosts.
* **Transaction Validation:** Leverages clean `curl` lookups with connection timeouts. Includes the `-k` (insecure) flag to cleanly evaluate the data stream and bypass localized self-signed SSL warnings.

---

## 💻 Deployment and Execution

### Step 1: Clone and Stage the Target Environment
Ensure your terminal session is mapped inside your cloned local repository path:
```bash
cd Algonquin-College-IT-Portfolio/"Linux Network Services Administration"/Lab-05-Web-Server-Automation
```

### Step 2: Apply System Permissions
Before executing the deployment cycle, explicitly define executable permissions on the script files:
```bash
chmod +x setup_server.sh verification.sh
```

### Step 3: Execute Server Automation
Run the automated blueprint on the server node (`172.16.30.130`):
```bash
sudo ./setup_server.sh
```

### Step 4: Run Client Validation
Run the validation script on the separate client testing node (`172.16.31.130`):
```bash
sudo ./verification.sh
```

---

## 📁 System Verification Logs & Paths

For tracking or troubleshooting system errors during evaluation, the infrastructure outputs logging properties to these targets:
* **Apache Global Configuration Check:** `apachectl -t` or `apachectl configtest`
* **Apache Real-Time Error Stream:** `tail -f /var/www/vhosts/www.example130.lab/log/error.log`
* **BIND Logs:** `tail -f /var/named/data/named.run`
* **Firewall Rule Tables Inspection:** `iptables -L INPUT -v -n --line-numbers`
