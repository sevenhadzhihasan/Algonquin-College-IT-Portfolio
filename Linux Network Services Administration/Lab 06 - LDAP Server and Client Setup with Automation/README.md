# Lab 06 - LDAP Server and Client Setup with Automation

## Objectives
* Install, configure, and automate an enterprise-grade directory server using **Symas OpenLDAP 2.6** on RHEL 8.10.
* Provision a functional Directory Information Tree (DIT) with automated schema management and user/group mappings.
* Implement centralized network hostname resolution provider functionality via auxiliary `ipHost` and structural `device` object classes.
* Secure directory service sockets over multi-subnet network domains via advanced granular `firewalld` rich rule isolation matrices.
* Configure Name Service Switch (NSS) fallback interfaces on remote network clientVM agents to map automated directory queries.

## Environment Details
* **Course Code:** CST8246 - Linux Network Services Administration
* **Target Operating System:** Red Hat Enterprise Linux 8.10 (Ootpa)
* **Master Server Node:** `hadz0024-SRV` (`172.16.30.130`)
* **Client VM Agent Node:** `hadz0024-CLT` (`172.16.31.130`)
* **Magic Number (MN):** 130
* **Student Network ID:** hadz0024

---

## 🎛️ Server-Side Automation Architecture

### Script: `setup_ldap_server.sh`
```bash
#!/bin/bash
# ====================================================================
# Script Name:  setup_ldap_server.sh (RHEL 8.10 Lab Master Assignment)
# Target VM:     RHEL 8.10 (172.16.30.130) [hadz0024-SRV]
# ====================================================================

set -e

MN="130"
SERVER_IP="172.16.30.130"
STUDENT_ID="hadz0024"
BASE_DN="dc=example130,dc=lab"
ROOT_DN="cn=ldapadm,${BASE_DN}"
DB_DIR="/var/lib/ldap/example130.lab"

echo "Step 1: Configuring Official Symas OpenLDAP 2.6 Repository for RHEL 8..."
wget -q https://symas.com -O /etc/yum.repos.d/sofl.repo
dnf clean all
dnf makecache
dnf install -y symas-openldap-servers symas-openldap-clients

echo "Step 2: Purging legacy configuration and database traces..."
systemctl stop symas-openldap-servers || true
systemctl stop sol-slapd || true
if [ -d /etc/openldap/slapd.d ]; then
    mv /etc/openldap/slapd.d /etc/openldap/slapd.d.bak.$(date +%F) || true
fi
rm -rf "$DB_DIR" && mkdir -p "$DB_DIR"

SLAPPASSWD_BIN=$(command -v slappasswd || ls /opt/symas/sbin/slappasswd /opt/symas/bin/slappasswd 2>/dev/null | head -n 1)
SLAPTEST_BIN=$(command -v slaptest || ls /opt/symas/sbin/slaptest /opt/symas/bin/slaptest 2>/dev/null | head -n 1)
LDAPADD_BIN=$(command -v ldapadd || ls /opt/symas/bin/ldapadd 2>/dev/null | head -n 1)

echo "Step 3: Compiling RHEL 8.10 File-Based configuration (slapd.conf)..."
mkdir -p /opt/symas/etc/openldap/

cat << EOF > /opt/symas/etc/openldap/slapd.conf
modulepath      /opt/symas/lib/openldap
moduleload      back_mdb.la

include         /opt/symas/etc/openldap/schema/core.schema
include         /opt/symas/etc/openldap/schema/cosine.schema
include         /opt/symas/etc/openldap/schema/inetorgperson.schema
include         /opt/symas/etc/openldap/schema/nis.schema

pidfile         /var/run/openldap/slapd.pid
argsfile        /var/run/openldap/slapd.args
loglevel        256

database        mdb
suffix          "${BASE_DN}"
rootdn          "${ROOT_DN}"
rootpw          secret
directory       ${DB_DIR}
maxsize         1073741824

index objectClass eq
index ipHostNumber,cn,uid eq
EOF

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

dn: cn=users,ou=groups,${BASE_DN}
objectClass: posixGroup
cn: users
gidNumber: 1000
memberUid: linuxuser1
memberUid: linuxuser2
memberUid: linuxuser3
memberUid: ${STUDENT_ID}

dn: cn=happy.example130.lab,ou=hosts,${BASE_DN}
objectClass: device
objectClass: ipHost
cn: happy.example130.lab
ipHostNumber: 172.16.32.130
description: Happy server

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
if systemctl is-active --quiet firewalld; then
    firewall-cmd --permanent --remove-service=ldap || true
    firewall-cmd --permanent --add-rich-rule='rule family="ipv4" source address="127.0.0.1" port port="389" protocol="tcp" accept'
    firewall-cmd --permanent --add-rich-rule='rule family="ipv4" source address="'${SERVER_IP}'" port port="389" protocol="tcp" accept'
    firewall-cmd --permanent --add-rich-rule='rule family="ipv4" source address="172.16.31.0/24" port port="389" protocol="tcp" accept'
    firewall-cmd --permanent --add-rich-rule='rule family="ipv4" source address="172.16.32.0/24" port port="389" protocol="tcp" accept'
    firewall-cmd --permanent --add-rich-rule='rule family="ipv4" source address="172.16.30.0/24" port port="389" protocol="tcp" reject'
    firewall-cmd --reload
fi

echo "Deployment Automated Successfully on RHEL 8.10!"
```

---

## 🖥️ Client-Side Automation Architecture

### Script: `setup_ldap_client.sh`
```bash
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
wget -q https://symas.com -O /etc/yum.repos.d/sofl.repo
dnf clean all
dnf makecache
dnf install -y symas-openldap-clients nss-pam-ldapd

echo "Step 2: Overhauling Name Service Connection Daemon Profiles (/etc/nslcd.conf)..."
if [ -f /etc/nslcd.conf ]; then
    cp /etc/nslcd.conf /etc/nslcd.conf.bak.$(date +%F)
    grep -vE "^(uri|base)" /etc/nslcd.conf.bak.$(date +%F) > /etc/nslcd.conf || true
fi

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
    echo "hosts: files dns ldap" >> /etc/nsswitch.conf
fi

cat << 'EOF' > /etc/profile.d/symas-ldap.sh
if ! echo "$PATH" | grep -q "/opt/symas/bin"; then
    export PATH="/opt/symas/bin:$PATH"
fi
EOF
chmod +x /etc/profile.d/symas-ldap.sh

echo "Client Lookup Automation Initialised Successfully!"
```

---

## 🧪 Verification Logs and Validation Proof

### 1. Centralized Identity and DIT Hierarchy Validation
Running an authenticated, structured `ldapsearch` query from the client VM against the directory server securely pulls the matching entries, verifying that `linuxuser1` holds exactly two distinct mail parameters as required:
```bash
[root@hadz0024-CLT ~]# /opt/symas/bin/ldapsearch -x -H ldap://172.16.30.130 -b "dc=example130,dc=lab" "uid=linuxuser1" mail
# extended LDIF
