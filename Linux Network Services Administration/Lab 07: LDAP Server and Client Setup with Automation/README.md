# Automated Enterprise OpenLDAP Directory & NSS Network Infrastructure

**Platform:** Red Hat Enterprise Linux (RHEL) 8.10  
**Directory Engine:** Symas OpenLDAP 2.6 (MDB Backend)  
**Security & Name Resolution:** `firewalld` Priority Rich Rules, `nslcd`, Name Service Switch (NSS)  

---

## Summary
This project include end-to-end design, automated deployment, and security hardening of a centralized **Symas OpenLDAP 2.6** directory service on **RHEL 8.10**. Rather than relying on manual configuration steps, the infrastructure is provisioned through Bash automation scripts that handle repository configuration, schema loading, Directory Information Tree (DIT) population, kernel-level subnet firewalling, and client-side Name Service Switch (NSS) hostname resolution.

> **Source Code Availability Note:**  
> To maintain academic integrity and protect proprietary lab implementations, the complete automation scripts (`setup_ldap_server.sh` and `setup_ldap_client.sh`) are omitted from this public repository.


---

## Key Engineering Objectives & Skills Demonstrated
* **Automated Infrastructure Provisioning:** Engineered repeatable Bash deployment workflows (`set -e` fail-fast execution, automated configuration backups, and database initialization) for both server and client nodes.
* **Centralized Directory Architecture:** Configured a production-grade Symas OpenLDAP `mdb` backend (`dc=example130,dc=lab`) loading `core`, `cosine`, `inetorgperson`, and `nis` schemas with indexed attributes (`objectClass`, `ipHostNumber`, `cn`, `uid`) for fast query performance.
* **Zero-Trust Network Segmentation:** Implemented ordered `firewalld` priority rich rules to enforce strict subnet-level access controls on TCP port `389`, prioritizing explicit whitelist rules ahead of blanket subnet rejections.
* **OS-Level Name Resolution Integration:** Configured `nslcd` and `/etc/nsswitch.conf` fallback layers on RHEL client nodes to resolve internal hostnames directly from LDAP without relying on local `/etc/hosts` entries or external DNS.

---

## Network & System Topology

| Node Role | Hostname | IP Address | Subnet | Key Services & Components |
| :--- | :--- | :--- | :--- | :--- |
| **LDAP Master Server** | `hadz0024-SRV` | `172.16.30.130` | `172.16.30.0/24` | `symas-openldap-servers`, `slapd` (TCP/389), `firewalld` |
| **LDAP Client Agent** | `hadz0024-CLT` | `172.16.31.130` | `172.16.31.0/24` | `symas-openldap-clients`, `nss-pam-ldapd` (`nslcd`), NSS |
| **Directory Host Entry 1** | `happy.example130.lab` | `172.16.32.130` | `172.16.32.0/24` | Stored in `ou=hosts` (`ipHost` object class) |
| **Directory Host Entry 2** | `peachy.example130.lab` | `172.16.33.130` | `172.16.33.0/24` | Stored in `ou=hosts` (`ipHost` object class) |

---

## 🛠️ Automation Architecture Overview

### 1. Server Provisioning Workflow (`setup_ldap_server.sh`)
* **Repository & Package Management:** Configures the official Symas OpenLDAP 2.6 RHEL 8 repository, refreshes `dnf` metadata caches, and installs `symas-openldap-servers` and `symas-openldap-clients`.
* **Service Hardening & Configuration:** Backs up legacy `slapd.d` directories, compiles a clean file-based `/opt/symas/etc/openldap/slapd.conf` with restricted permissions (`600`), validates syntax via `slaptest`, and configures `systemd` service overrides.
* **Automated DIT Seeding:** Generates and injects a structured LDIF payload via `ldapadd` and securely purges temporary LDIF files immediately after ingestion.

### 2. Kernel-Level Firewall Access Controls (`firewalld`)
Traffic to LDAP (`389/tcp`) is governed by explicit execution priorities so trusted administrative and client subnets are evaluated before the local subnet rejection rule:

```text
rule priority="10" family="ipv4" source address="127.0.0.1" port port="389" protocol="tcp" accept
rule priority="11" family="ipv4" source address="172.16.30.130" port port="389" protocol="tcp" accept
rule priority="12" family="ipv4" source address="172.16.31.0/24" port port="389" protocol="tcp" accept
rule priority="13" family="ipv4" source address="172.16.32.0/24" port port="389" protocol="tcp" accept
rule priority="20" family="ipv4" source address="172.16.30.0/24" port port="389" protocol="tcp" reject
```

### 3. Client Agent & NSS Integration (`setup_ldap_client.sh`)
* **Daemon Configuration (`/etc/nslcd.conf`):** Backs up existing configurations, sets strict file permissions (`600`, `root:ldap`), and binds lookups to `ldap://172.16.30.130` with a dedicated host search base (`ou=hosts,dc=example130,dc=lab`).
* **System Resolver Routing (`/etc/nsswitch.conf`):** Programmatically appends `ldap` to the `hosts` lookup chain (`hosts: files dns ldap`).
* **Environment Pathing:** Deploys `/etc/profile.d/symas-ldap.sh` to expose `/opt/symas/bin` CLI utilities globally across user sessions.

---

## 📊 Directory Information Tree (DIT) Schema Design
The automated LDIF deployment instantiates **11 discrete directory objects** organized across three Organizational Units:

```text
dc=example130,dc=lab
├── ou=accounts
│   ├── uid=linuxuser1   (inetOrgPerson, posixAccount | 2 mail attributes)
│   ├── uid=linuxuser2   (inetOrgPerson, posixAccount | 1 mail attribute)
│   ├── uid=linuxuser3   (inetOrgPerson, posixAccount | 1 mail attribute)
│   └── uid=hadz0024     (inetOrgPerson, posixAccount | hadz0024@algonquinlive.com)
├── ou=groups
│   └── cn=users         (posixGroup, gidNumber: 1000 | Consolidates all 4 memberUids)
└── ou=hosts
    ├── cn=happy.example130.lab   (device, ipHost -> 172.16.32.130)
    └── cn=peachy.example130.lab  (device, ipHost -> 172.16.33.130)
```

---

## 🔍 Validation & Verification Suite

### Server-Side Audit (`172.16.30.130`)
```bash
# Confirm Symas OpenLDAP 2.6 server and client packages
rpm -q symas-openldap-servers symas-openldap-clients

# Confirm slapd daemon is bound and listening on TCP port 389
ss -tulpn | grep slapd

# Audit active firewalld priority rich rules
firewall-cmd --list-rich-rules

# Inspect recent OpenLDAP service logs for clean startup and query handling
journalctl -u symas-openldap-servers --no-pager | tail -n 30
```

### Client-Side Audit (`172.16.31.130`)
```bash
# Load Symas CLI tools into current shell PATH and verify NSS package
source /etc/profile.d/symas-ldap.sh
rpm -q nss-pam-ldapd

# Execute remote LDAP query across the DIT for mail and group attributes
ldapsearch -x -H ldap://172.16.30.130 -b "dc=example130,dc=lab" "(objectClass=*)" mail memberUid
# Expected: result: 0 Success (# numResponses: 12, # numEntries: 11)

# Verify OS-level Name Service Switch (NSS) host resolution via LDAP
getent hosts | grep -E "happy|peachy"
# Expected Output:
# 172.16.32.130   happy.example130.lab
# 172.16.33.130   peachy.example130.lab

# Verify end-to-end hostname-to-IP resolution in network utilities
ping -c 2 happy.example130.lab
ping -c 2 peachy.example130.lab
```
*(Note: For `peachy.example130.lab`, successful resolution of `172.16.33.130` in the `ping` header confirms NSS LDAP translation even when no active VM is bound to the `.33.130` test address.)*

---

