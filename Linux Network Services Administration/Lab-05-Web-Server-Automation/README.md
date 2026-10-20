# Lab 05: Web Server Configuration and Network Automation

📌 Project Overview
This project automates the deployment, provisioning, and verification of a secure, multi-tenant enterprise web infrastructure on Red Hat Enterprise Linux (RHEL) 8/9. It integrates network interface aliasing, an authoritative **BIND DNS Master-Slave Replication Cluster**, an Apache HTTP Server utilizing both Name-Based and IP-Based Virtual Hosting, and a robust `iptables` firewall matrix to enforce strict subnet isolation.

The entire infrastructure is built using structured, production-ready Bash scripts to ensure programmatic execution, absolute consistency, and platform alignment across local enterprise networks.

---

🚀 Key Objectives & Technologies

1. Secure SSL/TLS Apache Web Infrastructure
   * Deployed an Apache HTTP Server (`httpd`) environment configured to serve multi-tiered data over unencrypted HTTP (Port 80) and encrypted HTTPS (Port 443).
   * Generated 120-day asymmetric cryptographic key pairs via OpenSSL (`mod_ssl`).
   * Secured the traffic backend utilizing custom paths with strict Linux DAC file permissions (`0600`/`0644`).

2. Dual-Paradigm Virtual Hosting Configuration
   * Name-Based Hosting: Configured `www.example130.lab` and `www.site130.lab` to share a single primary IP address (`172.16.30.130:80`). Apache dynamically maps directory indexing by inspecting the incoming HTTP `Host:` header field.
   * IP-Based Hosting: Provisioned `secure.example130.lab` on an isolated network address segment (`172.16.32.130:443`).
   * Interface Aliasing: Automated the dynamic runtime assignment of a secondary network interface IP alias mapping (`ens224:1` / `eth0:1`) via NetworkManager (`nmcli`) to avoid physical NIC bloat.

3. Redundant Master-Slave BIND DNS Deployment
   * Cluster Topology: Engineered an authoritative Master DNS node (`172.16.30.130`) paired with a functional Client-Slave DNS Replication node (`172.16.31.130`).
   * Zone Transfers: Implemented secure AXFR zone replication using modernized BIND syntax regulations (`primaries` directives instead of deprecated `masters` statements) to support modern enterprise Linux distributions (RHEL 9 / Rocky Linux 9).
   * Apex Domain Variants: Configured native naked domain resolving, ensuring structural entries like `site130.lab` automatically route identically to `www.site130.lab`.
   * Access Hardening: Restricted recursion and query access control lists strictly to verified internal network blocks (`172.16.0.0/16`).

4. Advanced iptables Subnet Isolation
   * Built a packet-filtering matrix to enforce perimeter security directly at the kernel layer.
   * Explicit Rules Allowed: Fully permits targeted web and resolution transactions (Ports 80, 443, 53) originating from the verified client testing subnet (`172.16.31.0/24`). Includes explicit rules to prevent administrative SSH (`port 22`) terminal disconnection during runtime firewall flushes.
   * Explicit Rules Dropped/Rejected: Explicitly rejects Port 80 cleartext traffic hitting the secure alias IP to force encryption compliance, and applies a strict global default DROP policy on unvetted traffic.

---

🛠️ Project Automation Architecture

The directory contains three core automated production scripts:

### 1. Server Provisioning Suite (`dns_master_replication_final.sh`)
Executes the full structural build of the Primary Master Platform:
* **Package Synchronization:** Installs package binaries securely (`httpd`, `mod_ssl`, `bind`, `iptables`).
* **Persistent Interface Aliasing:** Configures the `172.16.32.130` virtual network identity persistently across system reboots via NetworkManager.
* **Database Authoring:** Writes BIND master forward zone files under proper security boundaries (`root:named`).
* **VHost Compilation:** Generates localized Virtual Host templates and applies absolute directory permissions.

### 2. Slave DNS Replication Setup (`dns_slave_and_client_setup_final.sh`)
Provisioned on the backup node to establish client-side redundancy:
* **Dynamic Directory Isolation:** Spines up the secure `/var/named/slaves/` container with specialized `770` permissions and SELinux context rules (`restorecon`).
* **Zone Synchronization:** Configures modern replication listeners to pull real-time zone transfers from the Master.
* **Network Interconnect Routing:** Injects explicit host routes mapping to the Master's IP alias across dynamic interface pathways.

### 3. Client-Side Test Engine (`verification.sh`)
Executed on the validation node to audit and prove operational status:
* **Resolver Audit Verification:** Ensures local lookups trace directly through the **Slave DNS Engine** rather than bypassing it, fully validating true end-to-end zone replication.
* **Transaction Validation:** Leverages clean `curl` lookups with connection timeouts. Includes the `-k` (insecure) flag to cleanly evaluate the data stream and bypass localized self-signed SSL warnings.

---

💻 Deployment and Execution

### Step 1: Clone and Stage the Target Environment
Ensure your terminal session is mapped inside your cloned local repository path:
```bash
cd Algonquin-College-IT-Portfolio/"Linux Network Services Administration"/Lab-05-Web-Server-Automation
```

### Step 2: Apply System Permissions
Before executing the deployment cycle, explicitly define executable permissions on the script files:
```bash
chmod +x dns_master_replication_final.sh dns_slave_and_client_setup_final.sh verification.sh
```

### Step 3: Execute Master Server Automation
Run the primary automated blueprint on the server node (`172.16.30.130`):
```bash
sudo .setup_server.sh
```

### Step 4: Provision Slave and Client Node
Run the secondary environment engine on the separate slave client node (`172.16.31.130`):
```bash
sudo ./setup_client
```

### Step 5: Run Automated Client Validation
Execute the verification test suite on the slave client node to prove the architecture resolves and routes successfully:
```bash
sudo ./verification.sh
```

---

📁 System Verification Logs & Paths

For tracking or troubleshooting system errors during evaluation, the infrastructure outputs logging properties to these targets:

* **Apache Global Configuration Check:** `apachectl -t` or `apachectl configtest`
* **Apache Real-Time Error Stream:** `tail -f /var/www/vhosts/www.example130.lab/log/error.log`
* **BIND Daemon Event Logs:** `tail -f /var/named/data/named.run` or `journalctl -u named -f`
* **Firewall Rule Tables Inspection:** `iptables -L INPUT -v -n --line-numbers`
