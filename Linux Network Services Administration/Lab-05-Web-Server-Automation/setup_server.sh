#!/bin/bash
# ==============================================================================
# Script Name:  automate_lab5_setup.sh
# Objective:    Automates complete Lab 5 environment provisioning: Network Manager 
#               Hardening, BIND Master DNS using domain apex mappings, multi-alias
#               Apache Virtual Hosts with global listening, and iptables rules.
# Target Node:  Linux Server System (172.16.30.130)
# ==============================================================================

set -e

MAIN_IP="172.16.30.130"
CLIENT_IP="172.16.31.130"
IP_ALIAS="172.16.32.130"
MN="130"

echo "========================================================================"
echo "Starting Lab 5"
echo "========================================================================"

# --- 1. Sourcing Software Dependencies ---
echo "[+] Syncing repository components and pulling core server packages..."
dnf -y install httpd mod_ssl openssl bind bind-utils iptables

# --- 2. Interface Aliasing Protocol ---
echo "[+] Spinning up network runtime IP interface alias: ${IP_ALIAS}..."
PRIMARY_DEV=$(ip route | grep default | awk '{print $5}')
if ! ip addr show dev "$PRIMARY_DEV" | grep -q "$IP_ALIAS"; then
    ip addr add ${IP_ALIAS}/16 dev "$PRIMARY_DEV" label "${PRIMARY_DEV}:1" || true
fi

# --- 3. NetworkManager Resolution Hardening Loop ---
echo "[+] Locking Server NetworkManager to prevent automated resolution overwrites..."
if ! grep -q "dns=none" /etc/NetworkManager/NetworkManager.conf; then
    echo -e "\n[main]\ndns=none" >> /etc/NetworkManager/NetworkManager.conf
fi
systemctl reload NetworkManager

echo "[+] Writing production server resolver configuration matrix..."
cat <<EOF > /etc/resolv.conf
search localdomain domain130.lab
nameserver 172.16.30.130
nameserver 192.168.70.2
EOF
chmod 644 /etc/resolv.conf

# --- 4. BIND DNS Server Configuration (Full Configuration Overwrite) ---
echo "[+] Overwriting /etc/named.conf with precise global options..."
cat <<EOF > /etc/named.conf
options {
    listen-on port 53 { 127.0.0.1; ${MAIN_IP}; };
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

zone "site${MN}.lab" IN {
    type master;
    file "fwd.site${MN}.lab";
    allow-update { none; };
};

zone "example${MN}.lab" IN {
    type master;
    file "fwd.example${MN}.lab";
    allow-update { none; };
};
EOF

# --- 5. Creating DNS Forward Zone Database Files (Apex Variant) ---
echo "[+] Authoring zone record master database: /var/named/fwd.site${MN}.lab"
cat <<EOF > /var/named/fwd.site${MN}.lab
\$TTL 86400
\$ORIGIN site${MN}.lab.
@   IN  SOA site${MN}.lab. dnsadmin.site${MN}.lab. (
            20191120 ; serial
            1D       ; refresh
            1H       ; retry
            1W       ; expire
            3H )     ; minimum
@   IN  NS  site${MN}.lab.
@   IN  A   ${MAIN_IP}
www IN  A   ${MAIN_IP}
EOF

echo "[+] Authoring zone record master database: /var/named/fwd.example${MN}.lab"
cat <<EOF > /var/named/fwd.example${MN}.lab
\$TTL 86400
\$ORIGIN example${MN}.lab.
@   IN  SOA example${MN}.lab. dnsadmin.example${MN}.lab. (
            20191120 ; serial
            1D       ; refresh
            1H       ; retry
            1W       ; expire
            3H )     ; minimum
@   IN  NS  example${MN}.lab.
@   IN  A   ${MAIN_IP}
www IN  A   ${MAIN_IP}
secure IN A ${IP_ALIAS}
EOF

chown root:named /var/named/fwd.site${MN}.lab /var/named/fwd.example${MN}.lab
chmod 640 /var/named/fwd.site${MN}.lab /var/named/fwd.example${MN}.lab

# --- 6. Directory Infrastructure & Web Assets Creation ---
echo "[+] Building file structures and custom HTML indexes..."
SITES=("www.example${MN}.lab" "www.site${MN}.lab" "secure.example${MN}.lab")
for SITE in "${SITES[@]}"; do
    mkdir -p "/var/www/vhosts/$SITE/html"
    mkdir -p "/var/www/vhosts/$SITE/log"
done

cat <<EOF > "/var/www/vhosts/www.example${MN}.lab/html/index.html"
Host:www.example${MN}.lab [${MAIN_IP}:80]
EOF

cat <<EOF > "/var/www/vhosts/www.site${MN}.lab/html/index.html"
Host:www.site${MN}.lab [${MAIN_IP}:80]
EOF

cat <<EOF > "/var/www/vhosts/secure.example${MN}.lab/html/index.html"
Host:secure.example${MN}.lab [${IP_ALIAS}:443]
EOF

# --- 7. Self-Signed SSL/TLS Certificates Engine ---
echo "[+] Formulating self-signed 120-day RSA public certificate material..."
mkdir -p /etc/httpd/tls/key /etc/httpd/tls/cert
openssl req -x509 -newkey rsa:2048 -days 120 -nodes \
    -keyout "/etc/httpd/tls/key/example${MN}.key" \
    -out "/etc/httpd/tls/cert/example${MN}.cert" \
    -subj "/C=CA/ST=ON/L=Ottawa/O=CST8246/OU=example${MN}.lab/CN=secure.example${MN}.lab" \
    >/dev/null 2>&1

# --- 8. Core Apache Configuration Template Generation ---
echo "[+] Rendering specialized virtual host templates..."
cat <<EOF > /etc/httpd/conf.d/lab5_vhosts.conf
User apache
Group apache
ServerAdmin root@example130.lab
EnableMMAP off
EnableSendfile on
Listen 443

<VirtualHost 172.16.30.130:80>
    ServerName      www.example130.lab
    ServerAlias     example130.lab
    DocumentRoot    /var/www/vhosts/www.example130.lab/html/
    ErrorLog        /var/www/vhosts/www.example130.lab/log/error.log
</VirtualHost>

<VirtualHost 172.16.30.130:80>
    ServerName      www.site130.lab
    ServerAlias     site130.lab
    DocumentRoot    /var/www/vhosts/www.site130.lab/html/
    ErrorLog        /var/www/vhosts/www.site130.lab/log/error.log
</VirtualHost>

<VirtualHost 172.16.32.130:443>
    ServerName      secure.example130.lab
    ServerAlias     secure.example130.lab
    DocumentRoot    /var/www/vhosts/secure.example130.lab/html/
    SSLCertificateFile    /etc/httpd/tls/cert/example130.cert
    SSLCertificateKeyFile    /etc/httpd/tls/key/example130.key
    SSLEngine On
</VirtualHost>
EOF

# Prevent conflicts with default settings and fix mod_ssl defaults if reinstalled
mv /etc/httpd/conf.d/ssl.conf /etc/httpd/conf.d/ssl.conf.bak || true
sed -i '/^Listen 80/d' /etc/httpd/conf.d/lab5_vhosts.conf

chown -R apache:apache /var/www/vhosts/
find /var/www/vhosts/ -type d -exec chmod 755 {} \;
find /var/www/vhosts/ -type f -exec chmod 644 {} \;

# --- 9. IPTables Firewall Source Subnet Filtering Layout ---
echo "[+] Applying strict iptables firewall matrix..."
iptables -F INPUT || true

# Explicit clean top-down execution logic matching your verified screen loops
iptables -A INPUT -s 172.16.31.0/24 -p tcp --dport 80 -j ACCEPT
iptables -A INPUT -s 172.16.31.0/24 -p tcp --dport 443 -j ACCEPT
iptables -A INPUT -s 172.16.31.0/24 -p udp --dport 53 -j ACCEPT
iptables -A INPUT -s 172.16.31.0/24 -p tcp --dport 53 -j ACCEPT

iptables -A INPUT -s 172.16.30.0/24 -p tcp --dport 80 -j REJECT
iptables -A INPUT -s 172.16.30.0/24 -p tcp --dport 443 -j REJECT
iptables -A INPUT -s 172.16.32.0/24 -p tcp --dport 80 -j REJECT
iptables -A INPUT -i lo -j ACCEPT

# --- 10. Initialization and Verification Loop ---
echo "[+] Verifying configuration syntax and running server daemons..."
apachectl -t
systemctl daemon-reload

systemctl enable named httpd
systemctl restart named httpd

echo "========================================================================"
echo "SUCCESS: Final multi-alias environment deployed and active!"
echo "========================================================================"
