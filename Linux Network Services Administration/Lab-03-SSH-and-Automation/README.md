# Lab 03 - Basic Internet Services and Automated SSH Configuration

## 📋 Project Overview
This repository contains the deliverables for Lab 03 of CST8246 (Linux Network Services Administration). 
The objectives of this lab are to automate the installation, configuration, and hardening of an OpenSSH server on Red Hat Enterprise Linux 8, configure an IP alias network interface, and set up robust network firewall rules via `iptables`.

## 🛠️ Network Configuration Details
* **Server Primary (RED) IP:** `172.16.30.130`
* **Server Aliased Interface IP:** `172.16.32.130`
* **Client Workstation IP Subnet:** `172.16.31.0/24`
* **Admin User Accounts Allowed:** `cst8246`, `abc`

---

## 💾 Core Deliverables & Scripts

### 1. SSH Automation Script (`ssh.sh`)
This script automates package validation, implements interface bindings, blocks direct root execution, enforces key-based public authentication methods, and explicitly whitelists valid environment users.

```bash
#!/bin/sh
# CST8246 – OpenSSH Installation and Configuration Automation

CONFIG_FILE="/etc/ssh/sshd_config"

echo "=== OpenSSH Server Configuration Automation ==="

# 1. Install/Update OpenSSH packages
sudo dnf install -y openssh-server openssh-clients

# 2. Clean out any previous lab blocks to prevent duplicate lines
sudo sed -i '/# === CST8246 LAB START ===/,/# === CST8246 LAB END ===/d' "$CONFIG_FILE"

# 3. Append the evaluation requirements to sshd_config
sudo tee -a "$CONFIG_FILE" > /dev/null << EOF

# === CST8246 LAB START ===
# Listen on all active local interfaces
# ListenAddress 0.0.0.0
ListenAddress 172.16.32.130
ListenAddress 172.16.30.130

# Hardening Configurations
PermitRootLogin no
AllowUsers cst8246 abc
PubkeyAuthentication yes
PasswordAuthentication no
# === CST8246 LAB END ===
EOF

# 4. Validate syntax and restart the service
sudo sshd -t
if [ $? -eq 0 ]; then
    sudo systemctl enable sshd
    sudo systemctl restart sshd
    echo "=== SSH Service successfully automated! ==="
else
    echo "[!] Configuration syntax error detected."
    exit 1
fi
```

### 2. Network Firewall Rules (`firewall.sh`)
This script implements strict access management control for inbound system ports, explicitly accepting connections from the client management workspace while rejecting loops and malicious scans.

```bash
#!/bin/bash
echo "----------------------------------------"
echo "Configuring firewall policies..."
echo "----------------------------------------"

# 1. Flush existing rules
iptables -F

# 2. Set default permissive policies
iptables -P INPUT ACCEPT
iptables -P FORWARD ACCEPT
iptables -P OUTPUT ACCEPT

# --- LAB_02 RULES ---
iptables -A INPUT -s 172.16.31.0/24 -p tcp --dport 49999 -j ACCEPT
iptables -A INPUT -s 172.16.30.0/24 -p tcp --dport 49999 -j REJECT

# --- CURRENT LAB SSH RULES ---
# Accept connections from client subnet (172.16.31.0/24)
iptables -A INPUT -s 172.16.31.0/24 -p tcp --dport 22 -j ACCEPT

# Accept connections from alias subnet (172.16.32.0/24)
iptables -A INPUT -s 172.16.32.0/24 -p tcp --dport 22 -j ACCEPT

# Reject connections from server subnet (172.16.30.0/24)
iptables -A INPUT -s 172.16.30.0/24 -p tcp --dport 22 -j REJECT

# Block all other incoming SSH traffic for security
iptables -A INPUT -p tcp --dport 22 -j DROP

# List out the updated rule structure
echo "----------------------------------------"
echo "Active Firewall Rules Grid:"
echo "----------------------------------------"
iptables -L -n --line-numbers
```

---

## 🔍 Verification & Testing Demonstrations

### Milestone 1: Interface Binding Proof
Verify that the `sshd` process is running successfully and actively monitoring both local interface addresses.
```bash
sudo ss -ltpn | grep :22
```

### Milestone 2: Active Firewall Policies
Verify that the iptables filter rules are active and blocking target networks.
```bash
sudo iptables -L INPUT -n --line-numbers
```

### Milestone 3: Key-Based Passwordless Authentication
Confirming that a standard remote connection from the Client terminal (`172.16.31.130`) to the Server Aliased IP (`172.16.32.130`) maps successfully without prompting for a user account password password verification sequence.
```bash
ssh cst8246@172.16.32.130
```

### Milestone 4: Administrative Root Hardening Test
Confirming that direct root administrative shell sessions are denied globally.
```bash
ssh root@172.16.32.130
# Output: Permission denied (publickey).
```
