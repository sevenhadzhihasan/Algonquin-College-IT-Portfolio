#!/bin/bash
# ==============================================================================
# Script Name:  mail_server_master.sh
# Objective:    Integrated Postfix Mail Server + DNS Master Environment
# Target Node:  Master DNS / Mail Server System (172.16.30.130)
# ==============================================================================
set -e

MAIN_IP="172.16.30.130"
SLAVE_IP="172.16.31.130"
MN="130"

DOMAIN="example${MN}.lab"
HOSTNAME="mail.${DOMAIN}"
MY_CLIENT_NET="172.16.31.0/24"
ALIAS_NET="172.16.99.0/24"
TEST_USER="user8246"

echo "========================================================================"
echo "Initializing Consolidated Postfix Mail & DNS Master Configuration"
echo "========================================================================"

# --- 1. Sourcing Core Dependencies ---
echo "[+] Syncing repository components and pulling core service daemons..."
dnf install -y postfix mailx bind bind-utils firewalld

# --- 2. Postfix Configuration & Explicit Spool Setup ---
echo "[+] Structuring file systems and hardcoding main.cf parameters..."
POSTFIX_CONF_DIR="/etc/postfix"
POSTFIX_QUEUE_DIR="/var/spool/postfix"
MBOX_SPOOL_DIR="/var/spool/mail"

mkdir -p "$POSTFIX_CONF_DIR" "$POSTFIX_QUEUE_DIR" "$MBOX_SPOOL_DIR"

postconf -e "myhostname = ${HOSTNAME}"
postconf -e "mydomain = ${DOMAIN}"
postconf -e "mydestination = \$myhostname, \$mydomain, localhost, localhost.localdomain"
postconf -e "inet_interfaces = all"
postconf -e "myorigin = \$mydomain" # Hostname Masquerading Enabled
postconf -e "mail_spool_directory = ${MBOX_SPOOL_DIR}"
postconf -e "queue_directory = ${POSTFIX_QUEUE_DIR}"

# Mandatory Lab Update: Allow raw numeric bracketed addresses in SMTP handshakes
postconf -e "allow_numeric_addresses = yes"

systemctl enable --now postfix

# --- 3. Address Rewriting & Aliases Setup ---
echo "[+] Writing distribution matrices into /etc/aliases..."
sed -i '/^dnsadmin:/d' /etc/aliases
sed -i '/^geeks:/d' /etc/aliases

echo "dnsadmin: root" >> /etc/aliases
echo "geeks: ${TEST_USER}, dnsadmin" >> /etc/aliases
postalias /etc/aliases

# --- 4. Firewalld Policy Configuration Matrices ---
echo "[+] Hardening port thresholds via firewalld rich rules..."
systemctl enable --now firewalld

# Allow access to SMTP (Port 25) from client and server networks
firewall-cmd --permanent --zone=public --add-rich-rule="rule family='ipv4' source address='172.16.30.0/24' port port='25' protocol='tcp' accept"
firewall-cmd --permanent --zone=public --add-rich-rule="rule family='ipv4' source address='${MY_CLIENT_NET}' port port='25' protocol='tcp' accept"

# Explicitly reject access to SMTP from the forbidden alias network
firewall-cmd --permanent --zone=public --add-rich-rule="rule family='ipv4' source address='${ALIAS_NET}' port port='25' protocol='tcp' reject"

# Open DNS ports for slave transfer lanes
firewall-cmd --permanent --add-service=dns
firewall-cmd --reload

systemctl restart postfix

# --- 5. NetworkManager Resolution Hardening ---
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

# --- 6. BIND DNS Server Master Configuration ---
echo "[+] Overwriting /etc/named.conf with optimized replication options..."
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

zone "${DOMAIN}" IN {
    type master;
    file "fwd.${DOMAIN}";
    allow-update { none; };
    allow-transfer { ${SLAVE_IP}; };
    also-notify { ${SLAVE_IP}; };
};
EOF

# --- 7. Creating DNS Forward Zone Database File ---
echo "[+] Authoring zone record master database: /var/named/fwd.${DOMAIN}"
cat <<EOF > /var/named/fwd.${DOMAIN}
\$TTL 86400
\$ORIGIN ${DOMAIN}.
@   IN  SOA ${DOMAIN}. dnsadmin.${DOMAIN}. (
            2026103101 ; serial
            1D         ; refresh
            1H         ; retry
            1W         ; expire
            3H )       ; minimum
@       IN  NS      mail.${DOMAIN}.
mail    IN  A       ${MAIN_IP}
@       IN  MX  10  mail.${DOMAIN}.
EOF

chown root:named /var/named/fwd.${DOMAIN}
chmod 640 /var/named/fwd.${DOMAIN}

# --- 8. Initialization & Verification Loop ---
echo "[+] Performing validation audits and launching BIND service loop..."
named-checkconf /etc/named.conf
named-checkzone ${DOMAIN} /var/named/fwd.${DOMAIN}

systemctl enable named
systemctl restart named

# Create targeted UNIX testing user profile if it doesn't exist
if ! id "$TEST_USER" &>/dev/null; then
    useradd -m "$TEST_USER"
fi

echo "========================================================================"
echo "SUCCESS: Integrated Postfix and DNS Master Configuration are active!"
echo "========================================================================"
