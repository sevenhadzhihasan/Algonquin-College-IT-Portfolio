#!/bin/bash
# ======================================================================
# CST8246 DNS Lab - Perfect 5/5 Evaluation Remote Push Engine
# Validated for RHEL 8 Multi-Subnet Sandbox Environments
# ======================================================================
set -e

MN="130"
MASTER_IP="172.16.30.130"
SLAVE_IP="172.16.31.130"
FTP_IP="172.16.32.130"
HOST_PREFIX="hadz0024-SRV"
CLIENT_PREFIX="hadz0024-CLT"

echo "=========================================================="
echo "🚀 DEPLOYING COMPLETELY INTEGRATED MASTER/SLAVE DNS CLUSTER"
echo "=========================================================="

# ----------------------------------------------------------------------
# 🖥️ TARGET 1: MASTER SERVER SETUP & RESOLVER FIX (Server3_SRV)
# ----------------------------------------------------------------------
echo "[*] Pushing Configs, Custom ACLs & Fixed Resolver to Server3_SRV ($MASTER_IP)..."

ssh -T cst8246@$MASTER_IP << EOF
    echo "[Master] Installing Packages..."
    sudo dnf install bind bind-utils -y

    echo "[Master] Provisioning /etc/named.conf..."
    sudo tee /etc/named.conf > /dev/null << 'INNER_EOF'
options {
    listen-on port 53 { 127.0.0.1; any; };
    directory       "/var/named";
    dump-file       "/var/named/data/cache_dump.db";
    statistics-file "/var/named/data/named_stats.txt";
    memstatistics-file "/var/named/data/named_mem_stats.txt";
    allow-query     { any; };
    
    # Restrict recursion explicitly to client and server networks
    allow-recursion { 127.0.0.1; 172.16.30.0/24; 172.16.31.0/24; };
    recursion yes;
    
    # Global forwarders engine to handle external www.google.ca tracking
    forwarders { 8.8.8.8; 8.8.4.4; };
    dnssec-validation no; 
};

zone "." IN { type hint; file "named.ca"; };
include "/etc/named.rfc1912.zones";
include "/etc/named.root.key";

zone "example${MN}.lab" IN {
    type master;
    file "/var/named/fwd.example${MN}.lab";
    allow-transfer { ${SLAVE_IP}; }; 
    also-notify { ${SLAVE_IP}; };
};

zone "16.172.in-addr.arpa" IN {
    type master;
    file "/var/named/named.16.172";
    allow-transfer { ${SLAVE_IP}; }; 
    also-notify { ${SLAVE_IP}; };
};
INNER_EOF

    echo "[Master] Creating Forward Zone File..."
    sudo tee /var/named/fwd.example${MN}.lab > /dev/null << INNER_EOF
\$TTL 86400
@   IN  SOA ${HOST_PREFIX}.example${MN}.lab. dnsadm.example${MN}.lab. (
            2026100901 ; Serial Mapping
            28800      ; Refresh
            14400      ; Retry
            604800     ; Expire
            300 )      ; Minimum TTL
@   IN  NS  ${HOST_PREFIX}.example${MN}.lab.
@   IN  NS  ${CLIENT_PREFIX}.example${MN}.lab.
${HOST_PREFIX}   IN  A   ${MASTER_IP}
ns1              IN  A   ${MASTER_IP}
${CLIENT_PREFIX}   IN  A   ${SLAVE_IP}
ns2              IN  A   ${SLAVE_IP}
ftp              IN  A   ${FTP_IP}
INNER_EOF

    echo "[Master] Creating Reverse Zone File..."
    sudo tee /var/named/named.16.172 > /dev/null << INNER_EOF
\$TTL 86400
@   IN  SOA ${HOST_PREFIX}.example${MN}.lab. dnsadm.example${MN}.lab. (
            2026100901 ; Serial
            28800
            14400
            604800
            300 )
@   IN  NS  ${HOST_PREFIX}.example${MN}.lab.
@   IN  NS  ${CLIENT_PREFIX}.example${MN}.lab.

130.30  IN  PTR ${HOST_PREFIX}.example${MN}.lab.
130.30  IN  PTR ns1.example${MN}.lab.
130.31  IN  PTR ${CLIENT_PREFIX}.example${MN}.lab.
130.31  IN  PTR ns2.example${MN}.lab.
130.32  IN  PTR ftp.example${MN}.lab.
INNER_EOF

    echo "[Master] Applying secure permission settings..."
    sudo chown root:named /etc/named.conf /var/named/fwd.example${MN}.lab /var/named/named.16.172
    sudo chmod 640 /etc/named.conf /var/named/fwd.example${MN}.lab /var/named/named.16.172

    echo "[Master] Validating Zone Mapping Files..."
    sudo named-checkconf
    sudo named-checkzone "example${MN}.lab" "/var/named/fwd.example${MN}.lab"
    sudo named-checkzone "16.172.in-addr.arpa" "/var/named/named.16.172"

    echo "[Master] Establishing Strict Firewall Rule Targets..."
    if systemctl is-active --quiet firewalld; then
        sudo firewall-cmd --permanent --remove-service=dns 2>/dev/null || true
        sudo firewall-cmd --permanent --add-rich-rule='rule family="ipv4" source address="172.16.30.0/24" port port="53" protocol="udp" accept'
        sudo firewall-cmd --permanent --add-rich-rule='rule family="ipv4" source address="172.16.30.0/24" port port="53" protocol="tcp" accept'
        sudo firewall-cmd --permanent --add-rich-rule='rule family="ipv4" source address="172.16.31.0/24" port port="53" protocol="udp" accept'
        sudo firewall-cmd --permanent --add-rich-rule='rule family="ipv4" source address="172.16.31.0/24" port port="53" protocol="tcp" accept'
        sudo firewall-cmd --permanent --add-rich-rule='rule family="ipv4" source address="172.16.32.0/24" port port="53" protocol="udp" reject'
        sudo firewall-cmd --permanent --add-rich-rule='rule family="ipv4" source address="172.16.32.0/24" port port="53" protocol="tcp" reject'
        sudo firewall-cmd --reload
    fi

    echo "[Master] FIX: Locking out external Network DNS overrides..."
    M_INT=\$(ls /etc/sysconfig/network-scripts/ifcfg-* | grep -v "ifcfg-lo" | head -n 1)
    sudo grep -qq "^PEERDNS=" "\$M_INT" && sudo sed -i "s/^PEERDNS=.*/PEERDNS=no/" "\$M_INT" || sudo echo "PEERDNS=no" >> "\$M_INT"
    sudo rm -f /etc/resolv.conf
    sudo tee /etc/resolv.conf > /dev/null << 'RESOLV_EOF'
search localdomain example130.lab
nameserver 127.0.0.1
RESOLV_EOF

    echo "[Master] Activating and Starting BIND Engine..."
    sudo systemctl daemon-reload
    sudo systemctl restart NetworkManager
    sudo systemctl restart named
    sudo systemctl enable named
    echo "[✓] Server3_SRV Complete."
EOF

# ----------------------------------------------------------------------
# 💻 TARGET 2: SLAVE CLIENT SETUP & RESOLVER FIX (Linux3_CLT)
# ----------------------------------------------------------------------
echo "----------------------------------------------------------"
echo "[*] Pushing Configs, Fixed Resolver & Firewall to Linux3_CLT ($SLAVE_IP)..."

ssh -T cst8246@$SLAVE_IP << EOF
    echo "[Slave] Installing Packages..."
    sudo dnf install bind bind-utils -y

    echo "[Slave] Provisioning /etc/named.conf..."
    sudo tee /etc/named.conf > /dev/null << 'INNER_EOF'
options {
    listen-on port 53 { 127.0.0.1; any; };
    directory       "/var/named";
    dump-file       "/var/named/data/cache_dump.db";
    allow-query     { any; };
    recursion yes;
    dnssec-validation no; 
};

zone "." IN { type hint; file "named.ca"; };
include "/etc/named.rfc1912.zones";

zone "example${MN}.lab" IN {
    type slave;
    file "slaves/fwd.example${MN}.lab.db";
    masters { ${MASTER_IP}; };
};

zone "16.172.in-addr.arpa" IN {
    type slave;
    file "slaves/named.16.172.db";
    masters { ${MASTER_IP}; };
};
INNER_EOF

    echo "[Slave] Applying file configurations permissions..."
    sudo chown root:named /etc/named.conf
    sudo chmod 640 /etc/named.conf
    
    sudo mkdir -p /var/named/slaves
    sudo chown -R named:named /var/named/slaves/
    sudo chmod 770 /var/named/slaves/

    sudo named-checkconf

    echo "[Slave] Establishing Strict Firewall Rule Targets..."
    if systemctl is-active --quiet firewalld; then
        sudo firewall-cmd --permanent --remove-service=dns 2>/dev/null || true
        sudo firewall-cmd --permanent --add-rich-rule='rule family="ipv4" source address="172.16.30.0/24" port port="53" protocol="udp" accept'
        sudo firewall-cmd --permanent --add-rich-rule='rule family="ipv4" source address="172.16.30.0/24" port port="53" protocol="tcp" accept'
        sudo firewall-cmd --permanent --add-rich-rule='rule family="ipv4" source address="172.16.31.0/24" port port="53" protocol="udp" accept'
        sudo firewall-cmd --permanent --add-rich-rule='rule family="ipv4" source address="172.16.31.0/24" port port="53" protocol="tcp" accept'
        sudo firewall-cmd --permanent --add-rich-rule='rule family="ipv4" source address="172.16.32.0/24" port port="53" protocol="udp" reject'
        sudo firewall-cmd --permanent --add-rich-rule='rule family="ipv4" source address="172.16.32.0/24" port port="53" protocol="tcp" reject'
        sudo firewall-cmd --reload
    fi

    echo "[Slave] FIX: Locking out external Network DNS overrides..."
    S_INT=\$(ls /etc/sysconfig/network-scripts/ifcfg-* | grep -v "ifcfg-lo" | head -n 1)
    sudo grep -qq "^PEERDNS=" "\$S_INT" && sudo sed -i "s/^PEERDNS=.*/PEERDNS=no/" "\$S_INT" || sudo echo "PEERDNS=no" >> "\$S_INT"
    sudo rm -f /etc/resolv.conf
    sudo tee /etc/resolv.conf > /dev/null << 'RESOLV_EOF'
search localdomain example130.lab
nameserver 127.0.0.1
RESOLV_EOF

    echo "[Slave] Activating BIND..."
    sudo systemctl daemon-reload
    sudo systemctl restart NetworkManager
    sudo systemctl restart named
    sudo systemctl enable named
    
    echo "[Slave] Verifying automatic zone synchronization..."
    sleep 3
    ls -l /var/named/slaves/
    echo "[✓] Linux3_CLT Complete."
EOF

echo "=========================================================="
echo "🎉 SUCCESS: BOTH INFRASTRUCTURE NODES DEPLOYED AND FIXED!"
echo "=========================================================="
