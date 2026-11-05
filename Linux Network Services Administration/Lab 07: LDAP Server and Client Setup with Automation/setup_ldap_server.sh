#!/bin/bash
# ====================================================================
# Script Name:  setup_ldap_server.sh (RHEL 8.10 Lab Master Assignment)
# Target VM:     RHEL 8.10 (172.16.30.130) [hadz0024-SRV]
# ====================================================================

set -e

# Variable Definitions
MN="130"
SERVER_IP="172.16.30.130"
STUDENT_ID="hadz0024"
BASE_DN="dc=example130,dc=lab"
ROOT_DN="cn=ldapadm,${BASE_DN}"
DB_DIR="/var/lib/ldap/example130.lab"

echo "Step 1: Configuring Official Symas OpenLDAP 2.6 Repository for RHEL 8..."

# 1. Download the official, pre-configured repo file
wget -q https://repo.symas.com/configs/SOLDAP/rhel8/release26.repo -O /etc/yum.repos.d/sofl.repo

# 2. Force dnf to drop all old cached data including the broken mirror mappings
dnf clean all

# 3. Rebuild the system package tracking matrix caches 
dnf makecache

# 4. Install the production packages directly
dnf install -y symas-openldap-servers symas-openldap-clients

echo "Step 2: Purging legacy configuration and database traces..."
systemctl stop symas-openldap-servers || true
systemctl stop sol-slapd || true

if [ -d /etc/openldap/slapd.d ]; then
    mv /etc/openldap/slapd.d /etc/openldap/slapd.d.bak.$(date +%F) || true
fi
rm -rf "$DB_DIR" && mkdir -p "$DB_DIR"

# Locate runtime tracking paths for the Symas-provided binaries
SLAPPASSWD_BIN=$(command -v slappasswd || ls /opt/symas/sbin/slappasswd /opt/symas/bin/slappasswd 2>/dev/null | head -n 1)
SLAPTEST_BIN=$(command -v slaptest || ls /opt/symas/sbin/slaptest /opt/symas/bin/slaptest 2>/dev/null | head -n 1)
LDAPADD_BIN=$(command -v ldapadd || ls /opt/symas/bin/ldapadd 2>/dev/null | head -n 1)

echo "Step 3: Compiling RHEL 8.10 File-Based configuration (slapd.conf)..."

mkdir -p /opt/symas/etc/openldap/

cat << EOF > /opt/symas/etc/openldap/slapd.conf
# Dynamic Module Engine Paths
modulepath      /opt/symas/lib/openldap
moduleload      back_mdb.la

# Schema Includes
include         /opt/symas/etc/openldap/schema/core.schema
include         /opt/symas/etc/openldap/schema/cosine.schema
include         /opt/symas/etc/openldap/schema/inetorgperson.schema
include         /opt/symas/etc/openldap/schema/nis.schema

pidfile         /var/run/openldap/slapd.pid
argsfile        /var/run/openldap/slapd.args
loglevel        256

# Database Definition Configuration
database        mdb
suffix          "${BASE_DN}"
rootdn          "${ROOT_DN}"
rootpw          secret
directory       ${DB_DIR}
maxsize         1073741824

index objectClass eq
index ipHostNumber,cn,uid eq
EOF

# Sync file-level ownership to root context
chown -R root:root /opt/symas/etc/openldap/
chown -R root:root "$DB_DIR"
chmod 700 "$DB_DIR"
chmod 600 /opt/symas/etc/openldap/slapd.conf

echo "Step 4: Validating configuration engine syntax rules..."
mkdir -p /var/run/openldap
chown -R root:root /var/run/openldap
chmod 755 /var/run/openldap

$SLAPTEST_BIN -u -f /opt/symas/etc/openldap/slapd.conf

echo "Step 5: Booting and enabling Symas slapd daemon..."
mkdir -p /etc/systemd/system/symas-openldap-servers.service.d/
cat << EOF > /etc/systemd/system/symas-openldap-servers.service.d/override.conf
[Service]
User=root
Group=root
EOF

systemctl daemon-reload
systemctl enable symas-openldap-servers.service
systemctl restart symas-openldap-servers.service
sleep 2

echo "Step 6: Engineering Criteria-Compliant DIT Layout (LDIF)..."
LDIF_DATA="/tmp/dit_populate_${MN}.ldif"

cat << EOF > "$LDIF_DATA"
dn: ${BASE_DN}
objectClass: top
objectClass: dcObject
objectClass: organization
o: Algonquin Lab Assignment Group
dc: example${MN}

dn: ou=accounts,${BASE_DN}
objectClass: organizationalUnit
ou: accounts

dn: ou=groups,${BASE_DN}
objectClass: organizationalUnit
ou: groups

dn: ou=hosts,${BASE_DN}
objectClass: organizationalUnit
ou: hosts

# linuxuser1 with exactly TWO distinct mail attributes
dn: uid=linuxuser1,ou=accounts,${BASE_DN}
objectClass: inetOrgPerson
objectClass: posixAccount
cn: linuxuser1
sn: User1
uid: linuxuser1
uidNumber: 1001
gidNumber: 1000
homeDirectory: /home/linuxuser1
loginShell: /bin/bash
mail: linuxuser1@example130.lab
mail: linuxuser1.alt@example130.lab
userPassword: {SSHA}E+p7qGZ6BqNnKclR43V3O/B/R3hLcXdt

# linuxuser2 with exactly ONE mail attribute
dn: uid=linuxuser2,ou=accounts,${BASE_DN}
objectClass: inetOrgPerson
objectClass: posixAccount
cn: linuxuser2
sn: User2
uid: linuxuser2
uidNumber: 1002
gidNumber: 1000
homeDirectory: /home/linuxuser2
loginShell: /bin/bash
mail: linuxuser2@example130.lab
userPassword: {SSHA}E+p7qGZ6BqNnKclR43V3O/B/R3hLcXdt

# linuxuser3 with exactly ONE mail attribute
dn: uid=linuxuser3,ou=accounts,${BASE_DN}
objectClass: inetOrgPerson
objectClass: posixAccount
cn: linuxuser3
sn: User3
uid: linuxuser3
uidNumber: 1003
gidNumber: 1000
homeDirectory: /home/linuxuser3
loginShell: /bin/bash
mail: linuxuser3@example130.lab
userPassword: {SSHA}E+p7qGZ6BqNnKclR43V3O/B/R3hLcXdt

# Algonquin ID tracking entry with ONE mail attribute
dn: uid=${STUDENT_ID},ou=accounts,${BASE_DN}
objectClass: inetOrgPerson
objectClass: posixAccount
cn: ${STUDENT_ID}
sn: Student
uid: ${STUDENT_ID}
uidNumber: 1004
gidNumber: 1000
homeDirectory: /home/${STUDENT_ID}
loginShell: /bin/bash
mail: ${STUDENT_ID}@algonquinlive.com
userPassword: {SSHA}E+p7qGZ6BqNnKclR43V3O/B/R3hLcXdt

# Single Group Map consolidating all 3 lab users + student account
dn: cn=users,ou=groups,${BASE_DN}
objectClass: posixGroup
cn: users
gidNumber: 1000
memberUid: linuxuser1
memberUid: linuxuser2
memberUid: linuxuser3
memberUid: ${STUDENT_ID}

# Hostname device entry - Happy
dn: cn=happy.example130.lab,ou=hosts,${BASE_DN}
objectClass: device
objectClass: ipHost
cn: happy.example130.lab
ipHostNumber: 172.16.32.130
description: Happy server

# Hostname device entry - Peachy
dn: cn=peachy.example130.lab,ou=hosts,${BASE_DN}
objectClass: device
objectClass: ipHost
cn: peachy.example130.lab
ipHostNumber: 172.16.33.130
description: Peachy server
EOF

echo "Step 7: Injecting Object blueprints into Live DIT..."
sleep 1
$LDAPADD_BIN -x -D "${ROOT_DN}" -w secret -f "$LDIF_DATA"
rm -f "$LDIF_DATA"

echo "Step 8: Configuring Multi-Subnet Subnet Priority Rules (Firewalld)..."
# 1. Enable and start the firewalld daemon immediately
systemctl enable --now firewalld

# 2. Clear loose pre-existing service rules if running (Silenced output configuration)
firewall-cmd --permanent --remove-service=ldap 2>/dev/null || true

# 3. Apply all required subnet rules to the permanent storage configuration
firewall-cmd --permanent --add-rich-rule='rule priority=10 family="ipv4" source address="127.0.0.1" port port="389" protocol="tcp" accept'
firewall-cmd --permanent --add-rich-rule='rule priority=11 family="ipv4" source address="'${SERVER_IP}'" port port="389" protocol="tcp" accept'
firewall-cmd --permanent --add-rich-rule='rule priority=12 family="ipv4" source address="172.16.31.0/24" port port="389" protocol="tcp" accept'
firewall-cmd --permanent --add-rich-rule='rule priority=13 family="ipv4" source address="172.16.32.0/24" port port="389" protocol="tcp" accept'
firewall-cmd --permanent --add-rich-rule='rule priority=20 family="ipv4" source address="172.16.30.0/24" port port="389" protocol="tcp" reject'

# 4. Force the firewall to reload and activate them right now
firewall-cmd --reload

# 5. Print out the active list to verify they are running
firewall-cmd --list-rich-rules

echo "Deployment Automated Successfully on RHEL 8.10!"
