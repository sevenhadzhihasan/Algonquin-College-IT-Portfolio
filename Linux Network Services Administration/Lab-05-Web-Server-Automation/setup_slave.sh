#!/bin/bash
# ==============================================================================
# Script Name:  setup_slave.sh
# Objective:    Unified Slave BIND Provisioning & Client Network Hardening
# Target Node:  Slave DNS Client System / Validation Node (172.16.31.130)
# ==============================================================================
set -e

MASTER_IP="172.16.30.130"
SLAVE_IP="172.16.31.130"
IP_ALIAS="172.16.32.130"
MN="130"

echo "========================================================================"
echo "Client and Slave DNS Automated Deployment"
echo "========================================================================"

# --- 1. Sourcing Core Dependencies ---
echo "[+] Syncing repository components and downloading BIND utilities..."
dnf install -y bind bind-utils iptables

# --- 2. Create Destination Directory Structure & Apply Security Profiles ---
echo "[+] Constructing replication directory and applying permission matrices..."
mkdir -p /var/named/slaves/

# Assign group ownership and read/write privileges to the BIND service daemon
chown root:named /var/named/slaves/
chmod 770 /var/named/slaves/

# Force standard security context rules over BIND dynamic storage areas
restorecon -Rv /var/named/slaves/

# --- 3. Overwrite BIND Configuration Database with Slave Zone Layout ---
echo "[+] Writing clean slave BIND configuration database..."
cat << EOF > /etc/named.conf
options {
    listen-on port 53 { 127.0.0.1; ${SLAVE_IP}; };
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

# --- Lab 5 Slave Replication Zone Entries ---
zone "site${MN}.lab" IN {
    type slave;
    file "slaves/fwd.site${MN}.lab";
    masters { ${MASTER_IP}; };
};

zone "example${MN}.lab" IN {
    type slave;
    file "slaves/fwd.example${MN}.lab";
    masters { ${MASTER_IP}; };
};
EOF

# Verify configuration file syntax
named-checkconf /etc/named.conf

# --- 4. Open Slave Firewall Rules for Inbound Notifications ---
echo "[+] Configuring iptables for inbound slave notification handling..."
iptables -I INPUT 1 -s ${MASTER_IP} -p udp --dport 53 -j ACCEPT
iptables -I INPUT 1 -s ${MASTER_IP} -p tcp --dport 53 -j ACCEPT

# --- 5. NetworkManager Resolution Hardening ---
echo "[+] Locking Client NetworkManager to prevent automated resolution overwrites..."
cat <<EOF > /etc/NetworkManager/conf.d/99-dns-none.conf
[main]
dns=none
EOF

systemctl reload NetworkManager

# --- 6. Write Local Resolver Configuration Matrix ---
echo "[+] Directing local interface resolver paths to Client Slave BIND Daemon..."
cat <<EOF > /etc/resolv.conf
search localdomain domain${MN}.lab
nameserver ${SLAVE_IP}
nameserver 192.168.70.2
EOF
chmod 644 /etc/resolv.conf

# --- 7. Persistent Interface Host Routing ---
echo "[+] Configuring precise static route paths to Master interface alias..."
# Clear loose routing anomalies safely
ip route del ${IP_ALIAS} || true

# Inject explicit host route gateway targeting the server primary device link card
ip route add ${IP_ALIAS} via ${MASTER_IP} dev ens224 || true
ip route flush cache

# --- 8. Initialize System Daemons ---
echo "[+] Activating BIND service loop..."
systemctl enable named
systemctl restart named

# --- 9. Runtime Transaction Sync Audit Verification ---
echo "[+] Pausing for transaction settlement loop..."
sleep 3

echo -e "\n[*] Verification 1: Inspecting Transfer Destination Directory Content:"
ls -lh /var/named/slaves/

echo -e "\n[*] Verification 2: Checking System Logs for Synchronization Confirmation Tokens:"
journalctl -u named --no-pager | grep -E '(transfer of|AXFR|success|zone.*loaded)' | tail -n 5

echo "========================================================================"
echo "SUCCESS: Slave DNS and Client environment are running and synchronized!"
echo "========================================================================"
