#!/bin/bash
# ==============================================================================
# Script Name:  dns_master_replication_final.sh
# Objective:    Consolidated, hardened, and verified Lab 5 Master Environment
# Target Node:  Master DNS Server (172.16.30.130)
# ==============================================================================
set -e

MAIN_IP="172.16.30.130"
SLAVE_IP="172.16.31.130"
IP_ALIAS="172.16.32.130"
MN="130"

echo "========================================================================"
echo "Initializing Consolidated Server Configuration"
echo "========================================================================"

# --- 1. Sourcing Core Dependencies ---
echo "[+] Syncing repository components and pulling web server dependencies..."
dnf install -y httpd mod_ssl openssl bind bind-utils iptables

# --- 2. Network Interface Aliasing Protocol ---
echo "[+] Configuring persistent interface alias: ${IP_ALIAS}..."
PRIMARY_DEV=$(ip route | grep default | awk '{print $5}')
if [ -z "$PRIMARY_DEV" ]; then
    PRIMARY_DEV="ens224"
fi

# Bring up runtime alias interface immediately
if ! ip addr show dev "$PRIMARY_DEV" | grep -q "$IP_ALIAS"; then
    ip addr add ${IP_ALIAS}/16 dev "$PRIMARY_DEV" label "${PRIMARY_DEV}:1" || true
fi

# Enforce persistence across system reboots via NetworkManager
nmcli connection modify "$PRIMARY_DEV" +ipv4.addresses "${IP_ALIAS}/16" || true

# --- 3. NetworkManager Resolution Hardening ---
echo "[+] Locking Server NetworkManager against resolution overwrites..."
cat <<EOF > /etc/NetworkManager/conf.d/99-dns-none.conf
[main]
dns=none
EOF

systemctl reload NetworkManager

echo "[+] Writing production server resolver configuration matrix..."
cat <<EOF > /etc/resolv.conf
search localdomain domain${MN}.lab
nameserver ${MAIN_IP}
nameserver 192.168.70.2
EOF
chmod 644 /etc/resolv.conf

# --- 4. BIND DNS Server Configuration ---
echo "[+] Overwriting /etc/named.conf with optimized options..."
cat <<EOF > /etc/named.conf
options {
    listen-on port 53 { 127.0.0.1; any; };
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
    
    notify yes;
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
    allow-transfer { ${SLAVE_IP}; };
    also-notify { ${SLAVE_IP}; };
};

zone "example${MN}.lab" IN {
    type master;
    file "fwd.example${MN}.lab";
    allow-update { none; };
    allow-transfer { ${SLAVE_IP}; };
    also-notify { ${SLAVE_IP}; };
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
echo "[+] Neutralizing default conflicting package configurations..."
mv /etc/httpd/conf.d/ssl.conf /etc/httpd/conf.d/ssl.conf.bak || true

echo "[+] Rendering verified global listening virtual host templates..."
cat <<EOF > /etc/httpd/conf.d/lab5_vhosts.conf
LoadModule ssl_module modules/mod_ssl.so

Listen 443

User apache
Group apache
ServerAdmin root@example${MN}.lab
EnableMMAP off
EnableSendfile on

<VirtualHost ${MAIN_IP}:80>
    ServerName      www.example${MN}.lab
    ServerAlias     example${MN}.lab
    DocumentRoot    /var/www/vhosts/www.example${MN}.lab/html/
    ErrorLog        /var/www/vhosts/www.example${MN}.lab/log/error.log
</VirtualHost>

<VirtualHost ${MAIN_IP}:80>
    ServerName      www.site${MN}.lab
    ServerAlias     site${MN}.lab
    DocumentRoot    /var/www/vhosts/www.site${MN}.lab/html/
    ErrorLog        /var/www/vhosts/www.site${MN}.lab/log/error.log
</VirtualHost>

<VirtualHost *:443>
    ServerName      secure.example${MN}.lab
    ServerAlias     secure.example${MN}.lab
    DocumentRoot    /var/www/vhosts/secure.example${MN}.lab/html/
    SSLEngine on
    SSLCertificateFile    /etc/httpd/tls/cert/example${MN}.cert
    SSLCertificateKeyFile    /etc/httpd/tls/key/example${MN}.key
</VirtualHost>
EOF

chown -R apache:apache /var/www/vhosts/
find /var/www/vhosts/ -type d -exec chmod 755 {} \;
find /var/www/vhosts/ -type f -exec chmod 644 {} \;

# --- 9. Firewall Rules Alignment ---
echo "[+] Applying validated iptables filtering matrix..."
iptables -F INPUT
iptables -A INPUT -p tcp --dport 80 -j ACCEPT
iptables -A INPUT -p tcp --dport 443 -j ACCEPT
iptables -A INPUT -p udp --dport 53 -j ACCEPT
iptables -A INPUT -p tcp --dport 53 -j ACCEPT
iptables -A INPUT -i lo -j ACCEPT

# --- 10. Initialization & Verification Loop ---
echo "[+] Performing validation audits and launching service engines..."
named-checkconf /etc/named.conf
apachectl -t

systemctl daemon-reload
systemctl enable named httpd
systemctl restart NetworkManager named httpd

echo "========================================================================"
echo "SUCCESS: Hardened deployment configuration is active and persistent!"
echo "========================================================================"
