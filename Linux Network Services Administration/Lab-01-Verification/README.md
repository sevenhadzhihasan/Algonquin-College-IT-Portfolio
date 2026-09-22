# Lab 01: Network Setup and Automated Configuration Verification

## 📝 Lab Overview
The purpose of this lab was to establish a functional, secure, dual-homed networking environment utilizing virtualized Linux systems (Server and Client) and to build shell scripts to automate network configuration verification.

---

## 🛠️ Technical Tasks Completed

### 1. Virtual Infrastructure Provisioning
* **Dual-Homed Network Setup:** Configured two virtual network adapters on both the Server and Client VMs using VMware Workstation.
* **Primary Interface (`ens160`):** Mapped to **VMnet8 (NAT mode)** to provide external Internet access (**Blue Network**).
* **Secondary Interface (`ens224`):** Mapped to **VMnet0 (Bridged mode)** to link to a segregated, isolated local network (**Red Network**).

### 2. Operating System & Security Hardening
* **Enterprise Linux OS Platform:** Provisioned and managed **Red Hat Enterprise Linux 9.8 (Plow)** kernel architectures.
* **User Management:** Created a dedicated administrative user account (`cst8246`) and verified its root access configuration under `uid=1000(cst8246) groups=1000(cst8246),10(wheel)`.
* **Firewall Deactivation:** Stopped and disabled `firewalld` (`active: inactive (dead)`) to ensure unhindered service-to-service communication testing during the lab framework.
* **SELinux Enforcement:** Verified system operational policies while maintaining active SELinux runtime layers.

### 3. Network Interface Customization & Scripting
* **Dynamic Blueprinting (`ens160`):** Manually configured the interface script using `BOOTPROTO=dhcp` and verified its runtime address allocation at `192.168.70.143/24` with default routing metrics enabled (`DEFROUTE=yes`).
* **Static Blueprinting (`ens224`):** Assigned unique static IP profiles utilizing custom magic number parameters (`130`).
* **Isolating Red Link:** Successfully deployed `DEFROUTE=no` inside the `ifcfg-ens224` / NetworkManager keyfile configuration (`ens224.nmconnection`) running with `method=manual` and IPv6 disabled.

#### Network Interface Address Matrix

| Node Hostname | Interface Role | Subnet Allocation | Assigned Address | Gateway Policy |
| :--- | :--- | :--- | :--- | :--- |
| **Server** | Primary (`ens160`) | Blue Network (NAT) | `192.168.70.143/24` | `DEFROUTE=yes` |
| **Server** | Secondary (`ens224`) | Red Network (Bridged) | `172.16.30.130/16` | `DEFROUTE=no` |
| **Client** | Primary (`ens160`) | Blue Network (NAT) | Dynamic (DHCP) | `DEFROUTE=yes` |
| **Client** | Secondary (`ens224`) | Red Network (Bridged) | `172.16.31.130/16` | `DEFROUTE=no` |

### 4. Hostname Identity & Local Name Resolution
* Modified permanent machine nodes using `hostnamectl` to establish the target server node identity (`cst8246-SRV.example.lab`).
* Synchronized local name matching lookup priorities across both nodes by appending custom Fully Qualified Domain Name (FQDN) mappings directly into `/etc/hosts` to support client-to-server ping resolution by name.
* Audited lookup system precedence metrics inside `/etc/nsswitch.conf` to guarantee `hosts: files dns myhostname` path execution.

### 5. Automation & Verification
* Maintained real-time system diagnostic audits via `tail -f /var/log/messages`.
* Deployed an automated, non-destructive validation bash script (`testnet.sh`) to query core layer system links, service statuses, configuration states, and cross-VM connectivity pipelines instantly.

---

## 📁 File Layout

```text
Lab-01-Verification/
├── README.md         # Network setup and automated configuration documentation
├── server_config.sh  # Script containing host environment setup rules
└── testnet.sh        # Automated, non-destructive validation testing toolkit
```
