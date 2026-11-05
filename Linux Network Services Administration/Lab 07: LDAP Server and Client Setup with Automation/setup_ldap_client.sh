#!/bin/bash
# ====================================================================
# Script Name: setup_ldap_client.sh (Client Agent / Slave - Tailored RHEL 8.10)
# Target VM:   Linux Client (172.16.31.130) [hadz0024-CLT]
# Server IP:   172.16.30.130
# ====================================================================

set -e

SERVER_IP="172.16.30.130"
BASE_DN="dc=example130,dc=lab"

echo "Step 1: Mounting Symas RHEL 8 Repositories and Deploying Modules..."

# Download official repo template file
wget -q https://repo.symas.com/configs/SOLDAP/rhel8/release26.repo -O /etc/yum.repos.d/sofl.repo

# Clear and rebuild cache maps cleanly
dnf clean all
dnf makecache
dnf install -y symas-openldap-clients nss-pam-ldapd

echo "Step 2: Overhauling Name Service Connection Daemon Profiles (/etc/nslcd.conf)..."
if [ -f /etc/nslcd.conf ]; then
    cp /etc/nslcd.conf /etc/nslcd.conf.bak.$(date +%F)
    grep -vE "^(uri|base)" /etc/nslcd.conf.bak.$(date +%F) > /etc/nslcd.conf || true
fi

# Append exact workspace lookup directives
cat << EOF >> /etc/nslcd.conf
uri ldap://${SERVER_IP}
base ${BASE_DN}
base hosts ou=hosts,${BASE_DN}
EOF

chown root:ldap /etc/nslcd.conf
chmod 600 /etc/nslcd.conf

echo "Step 3: Starting and Enabling Connection Service Daemon (nslcd)..."
systemctl daemon-reload
systemctl enable nslcd
systemctl restart nslcd

echo "Step 4: Amending /etc/nsswitch.conf Resolver Arrays and Symas Pathing..."
cp /etc/nsswitch.conf /etc/nsswitch.conf.bak.$(date +%F)

if grep -q "hosts:" /etc/nsswitch.conf; then
    if ! grep "hosts:" /etc/nsswitch.conf | grep -q "ldap"; then
        sed -i 's/^hosts:.*/& ldap/' /etc/nsswitch.conf
    fi
else
    echo "hosts: files dns lhap" >> /etc/nsswitch.conf
    sed -i 's/lhap/ldap/g' /etc/nsswitch.conf
fi

# Universal PATH mapper environment profile
cat << 'EOF' > /etc/profile.d/symas-ldap.sh
if ! echo "$PATH" | grep -q "/opt/symas/bin"; then
    export PATH="/opt/symas/bin:$PATH"
fi
EOF
chmod +x /etc/profile.d/symas-ldap.sh

echo "Client Lookup Automation Initialised Successfully!"
echo "Running Assignment Verification Checks..."
echo "--------------------------------------------------------"
echo "Querying network host maps via getent:"
getent hosts | grep -E "happy|peachy" || echo "Verification warning: Make sure your Server script has finished running first!"
