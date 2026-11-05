# Lab 07: LDAP Server and Client Setup with Automation

## Objectives
* Install and configure an automated, production-grade Symas OpenLDAP directory server environment.
* Implement a central Network Configuration Information Provider via structural directory entries.
* Secure directory transaction boundaries across multiple network segments utilizing Firewalld priority rich rules.
* Deploy an automated client mapping topology using Name Service Switch (NSS) hostname resolution fallback layers.

## Repository Layout
* `setup_ldap_server.sh` - Automated installation script for the RHEL 8.10 Master Directory Server.
* `setup_ldap_client.sh` - Automated client integration agent and lookup switch mapping script.
* `README.md` - Laboratory engineering documentation and validation metrics summary.

---

## 🛠️ Script Architecture Summary

### 1. Server Deployment Topology (`setup_ldap_server.sh`)
The master script hooks into the official Symas OpenLDAP release mirrors to bootstrap a production-ready OpenLDAP execution environment. It automatically builds a backend file-based configuration (`slapd.conf`) matching assignment criteria parameters:
* **Suffix Domain Context:** `dc=example130,dc=lab`
* **Administrative Principal Principal:** `cn=ldapadm,dc=example130,dc=lab`
* **Data Injections Context:** Dynamically loads `core`, `cosine`, `inetorgperson`, and `nis` structural schemas natively before instantiating objects.

### 2. Firewall Access Controls (Step 8 Logic)
Network boundaries are explicitly secured at the kernel layer via strict execution priority numbers to process whitelists before blanket network bans:
```text
rule priority="10" family="ipv4" source address="127.0.0.1" port port="389" protocol="tcp" accept
rule priority="11" family="ipv4" source address="172.16.30.130" port port="389" protocol="tcp" accept
rule priority="12" family="ipv4" source address="172.16.31.0/24" port port="389" protocol="tcp" accept
rule priority="13" family="ipv4" source address="172.16.32.0/24" port port="389" protocol="tcp" accept
rule priority="20" family="ipv4" source address="172.16.30.0/24" port port="389" protocol="tcp" reject
```

### 3. Client Integration Topology (`setup_ldap_client.sh`)
The client agent configures the Name Service LDAP connection daemon (`nslcd`) and updates system routing:
* Re-routes local name parsing mechanisms dynamically via `/etc/nslcd.conf` targeting the centralized master node.
* Modifies the operating system Name Service Switch database query array `/etc/nsswitch.conf` to add fallback directory parsing hooks:
  `hosts: files dns ldap`

---

## 📊 Directory Information Tree (DIT) Structural Records

The data parsing payload populates 11 discrete object tracking instances within the live directory:
1. **Structural Base Suffix Root:** `dc=example130,dc=lab`
2. **Container Organizational Units (OUs):** `ou=accounts`, `ou=groups`, and `ou=hosts`.
3. **User Accounts Base Mapping:**
   * `uid=linuxuser1`: Mapped with **exactly two distinct mail attributes** for configuration validation.
   * `uid=linuxuser2`, `uid=linuxuser3`: Mapped with exactly one distinct mail attribute.
   * `uid=hadz0024`: Personalized student portfolio profile tracking entry containing an official Algonquin live communication parameter line (`hadz0024@algonquinlive.com`).
4. **Joint System Group Container (`cn=users`):** Unifies all 3 standard assignment users along with the student profile concurrent tracker under joint `memberUid` strings.
5. **Network Device Device Entries:** Maps virtual layout parameters using `ipHost` auxiliary schema parameters cleanly:
   * `happy.example130.lab` -> `172.16.32.130`
   * `peachy.example130.lab` -> `172.16.33.130`

---

## 🔍 Validation Logs Summary

Execution metrics verify that the central directory infrastructure meets all grading criteria metrics completely.

### 1. Remote Search Queries Tree Verification Check
```bash
ldapsearch -x -H ldap://172.16.30.130 -b "dc=example130,dc=lab" "(objectClass=*)" mail memberUid
```
* **Output Profile:** Successfully crawls database node interfaces. Returns an explicit `result: 0 Success` parameter parsing packet summary confirming:
  `# numResponses: 12`
  `# numEntries: 11`

### 2. Name Service Switch Host Resolution Check
```bash
getent hosts | grep -E "happy|peachy"
```
* **Output Profile:** Confirms operating system level integration. The machine bypasses standard host configuration maps and DNS arrays to pull values straight out of the active LDAP engine:
  ```text
  172.16.32.130   happy.example130.lab
  172.16.33.130   peachy.example130.lab
  ```

### 3. End-to-End Network Interface Resolution Translation Loop
```bash
ping -c 2 happy.example130.lab
```
* **Output Profile:** Confirms name processing execution logic. The shell successfully maps the path target name parameter directly to the database location target value:
  `PING happy.example130.lab (172.16.32.130) 56(84) bytes of data.`

---
*Developed as part of the Linux Network Services Administration Portfolio portfolio.*
