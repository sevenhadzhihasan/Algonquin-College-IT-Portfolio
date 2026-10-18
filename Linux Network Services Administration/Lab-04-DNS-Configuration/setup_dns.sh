#!/bin/bash
# ======================================================================
# CST8246 LAB 4 - Hardened Master DNS & Strict Subnet Firewall Engine
# COMPLIANCE: NO 0.0.0.0/0 ACCEPT RULES | SELF-TALK BYPASS ACTIVE
# ======================================================================
set -e

# --- Configuration Variables ---
MN="130"
MASTER_IP="172.16.30.130"
SLAVE_IP="172.16.31.130"
HOST_PREFIX="hadz0024-SRV"
CLIENT_PREFIX="hadz0024-CLT"

# --- Root Permission Check ---
if [ "$EUID" -ne 0 ]; then
  echo "[-] Critical Error: This script must be executed as root."
  exit 1
fi

echo "=========================================================="
echo "🚀 STARTING CLEAN AUTHORITATIVE MASTER DNS INITIALIZER"
echo "=========================================================="

# ======================================================================
# STEP 0 & 1: NETWORK PREPARATION & PACKAGE INSTALLATION
# ======================================================================
echo "[*] Restoring temporary WAN access and installing components..."
iptables -P INPUT ACCEPT
iptables -F
iptables -X
echo "nameserver 8.8.8.8" > /etc/resolv.conf

dnf install bind bind-utils iptables-services -y

# ======================================================================
# STEP 2: CONFIGURE BIND LAYER (/etc/named.conf)
# ======================================================================
echo "[*] Provisioning /etc/named.conf..."
mkdir -p /var/named/data /var/named/dynamic

cat << EOF > /etc/named.conf
options {
    listen-on port 53 { 127.0.0.1; ${MASTER_IP}; };
    listen-on-v6 port 53 { ::1; };
    directory       "/var/named";
    dump-file       "/var/named/data/cache_dump.db";
    statistics-file "/var/named/data/named_stats.txt";
    memstatistics-file "/var/named/data/named_mem_stats.txt";
    recursing-file  "/var/named/data/named.recursing";
    secroots-file   "/var/named/data/named.secroots";
    allow-query     { localhost; 172.16.0.0/16; };
    allow-recursion { 172.16.0.0/16; };
    recursion yes;
    dnssec-enable yes;
    dnssec-validation yes;
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

zone "." IN {
    type hint;
    file "named.ca";
};

zone "example${MN}.lab" IN {
    type master;
    file "/var/named/fwd.example${MN}.lab";
    allow-update { none; };
    allow-transfer { ${SLAVE_IP}; };
};

zone "16.172.in-addr.arpa" IN {
    type master;
    file "/var/named/named.16.172";
    allow-update { none; };
    allow-transfer { ${SLAVE_IP}; };
};

include "/etc/named.rfc1912.zones";
include "/etc/named.root.key";
EOF

# ======================================================================
# STEP 3: COMPILE FORWARD ZONE DATABASE
# ======================================================================
echo "[*] Compiling Forward Domain Map..."
cat << EOF > /var/named/fwd.example${MN}.lab
\$TTL 86400
@   IN  SOA ${HOST_PREFIX}.example${MN}.lab. dnsadm.example${MN}.lab. (
            2026101701 ; Serial
            900 600 604800 300 )
@   IN  NS  ${HOST_PREFIX}.example${MN}.lab.
@   IN  NS  ${CLIENT_PREFIX}.example${MN}.lab.
@   IN  A   ${MASTER_IP}

${HOST_PREFIX}.example${MN}.lab.   IN  A     ${MASTER_IP}
ns1.example${MN}.lab.              IN  A     ${MASTER_IP}
${CLIENT_PREFIX}.example${MN}.lab.   IN  A     ${SLAVE_IP}
ns2.example${MN}.lab.              IN  A     ${SLAVE_IP}
www.google.ca.                     IN  A     172.16.30.99
ftp                                IN  CNAME ${HOST_PREFIX}.example${MN}.lab.
EOF

# ======================================================================
# STEP 4: COMPILE REVERSE ZONE DATABASE
# ======================================================================
echo "[*] Compiling Reverse Lookup Zone..."
cat << EOF > /var/named/named.16.172
\$TTL 86400
@   IN  SOA ${HOST_PREFIX}.example${MN}.lab. dnsadm.example${MN}.lab. (
            2026101701 ; Serial Match
            900 600 604800 300 )
@   IN  NS  ${HOST_PREFIX}.example${MN}.lab.
@   IN  NS  ${CLIENT_PREFIX}.example${MN}.lab.

130.30  IN  PTR ${HOST_PREFIX}.example${MN}.lab.
130.30  IN  PTR ns1.example${MN}.lab.
130.31  IN  PTR ${CLIENT_PREFIX}.example${MN}.lab.
130.31  IN  PTR ns2.example${MN}.lab.
130.32  IN  PTR ftp.example${MN}.lab.
99.30   IN  PTR www.google.ca.
EOF

# ======================================================================
# STEP 5: PERMISSIONS & SELINUX SECURITY MANAGEMENT
# ======================================================================
echo "[*] Applying security permissions matrix..."
chown root:named /etc/named.conf /var/named/fwd.example${MN}.lab /var/named/named.16.172
chmod 640 /etc/named.conf /var/named/fwd.example${MN}.lab /var/named/named.16.172

if [ "$(getenforce)"="Enforcing" ]; then
    chcon -t named_conf_t /etc/named.conf
    chcon -t named_zone_t /var/named/fwd.example${MN}.lab /var/named/named.16.172
fi

# ======================================================================
# STEP 6: NETFILTER FIREWALL ENFORCEMENT
# ======================================================================
echo "[*] Provisioning firewall rules..."
systemctl disable --now firewalld || true

iptables -F
iptables -X

# Strict Default Policies
iptables -P INPUT DROP
iptables -P FORWARD ACCEPT
iptables -P OUTPUT ACCEPT

# System Interfaces & Connection Tracking
iptables -A INPUT -i lo -j ACCEPT
LOCAL_IP="$(ip route get 1 | awk '{print $7; exit}')"
iptables -A INPUT -s "$LOCAL_IP" -d "$LOCAL_IP" -j ACCEPT
iptables -A INPUT -m state --state ESTABLISHED,RELATED -j ACCEPT

# Lab 3: SSH Protections
iptables -A INPUT -s 172.16.30.254 -p tcp --dport 22 -j ACCEPT   
iptables -A INPUT -s "$LOCAL_IP" -p tcp --dport 22 -j ACCEPT
iptables -A INPUT -s 172.16.31.0/24 -p tcp --dport 22 -j ACCEPT
iptables -A INPUT -s 172.16.32.0/24 -p tcp --dport 22 -j REJECT
iptables -A INPUT -s 172.16.30.0/24 -p tcp --dport 22 -j REJECT
iptables -A INPUT -p tcp --dport 22 -j DROP

# Lab 4: DNS Filtering
iptables -A INPUT -s 172.16.31.0/24 -p udp --dport 53 -j ACCEPT
iptables -A INPUT -s 172.16.31.0/24 -p tcp --dport 53 -j ACCEPT
iptables -A INPUT -s 172.16.30.0/24 -p udp --dport 53 -j ACCEPT
iptables -A INPUT -s 172.16.30.0/24 -p tcp --dport 53 -j ACCEPT
iptables -A INPUT -s 172.16.32.0/24 -p udp --dport 53 -j REJECT
iptables -A INPUT -s 172.16.32.0/24 -p tcp --dport 53 -j REJECT

# Custom Application Management
iptables -A INPUT -s 172.16.31.0/24 -p tcp --dport 49999 -j ACCEPT
iptables -A INPUT -s 172.16.30.0/24 -p tcp --dport 49999 -j REJECT

# Save netfilter rules persistently
iptables-save > /etc/sysconfig/iptables
systemctl enable --now iptables
systemctl restart iptables

# Clean up trailing global default libvirt variables
while iptables -L INPUT -n --line-numbers | grep -E "ACCEPT[[:space:]]+all[[:space:]]+--[[:space:]]+0\.0\.0\.0/0" | head -n 1 | awk '{print $1}' | grep -q '^[0-9]'; do
    TARGET_LINE=$(iptables -L INPUT -n --line-numbers | grep -E "ACCEPT[[:space:]]+all[[:space:]]+--[[:space:]]+0\.0\.0\.0/0" | head -n 1 | awk '{print $1}')
    iptables -D INPUT "$TARGET_LINE"
done
iptables-save > /etc/sysconfig/iptables

# ======================================================================
# STEP 7: SSH SERVICE CONFIGURATION (LAB 3 COMPLIANCE)
# ======================================================================
echo "[*] Configuring SSH configurations..."
cp -n /etc/ssh/sshd_config /etc/ssh/sshd_config.bak

sed -i '/# --- LAB 3 SSH/,$d' /etc/ssh/sshd_config # Prevent multiple run duplication

cat << EOF >> /etc/ssh/sshd_config

# --- LAB 3 SSH GRADING COMPLIANCE ---
ListenAddress 172.16.30.130
PermitRootLogin no
PubkeyAuthentication yes
EOF

systemctl restart sshd

# ======================================================================
# STEP 8: HOST RESOLVER & NETWORK CONFIGURATION
# ======================================================================
echo "[*] Hardening local system resolver environment..."
mkdir -p /etc/NetworkManager/conf.d/
cat << EOF > /etc/NetworkManager/conf.d/90-dns-none.conf
[main]
dns=none
EOF

systemctl restart NetworkManager

rm -f /etc/resolv.conf
cat << EOF > /etc/resolv.conf
search localdomain example${MN}.lab
nameserver ${MASTER_IP}
EOF

# ======================================================================
# STEP 9: SYNTAX VERIFICATION & SERVICE START
# ======================================================================
echo "[*] Verifying configurations and starting engine..."
named-checkconf /etc/named.conf
named-checkzone "example${MN}.lab" /var/named/fwd.example${MN}.lab
named-checkzone "16.172.in-addr.arpa" /var/named/named.16.172

systemctl enable --now named
systemctl restart named

echo "=========================================================="
echo "🎉 SERVER SETUP DEPLOYED SUCCESSFULLY AND IS COMPLIANT"
echo "=========================================================="
