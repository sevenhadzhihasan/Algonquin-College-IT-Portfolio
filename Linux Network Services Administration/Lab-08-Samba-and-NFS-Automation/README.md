# Lab 08: Samba & NFS File Sharing (With Automation)

**Course:** CST8246 - Linux Network Services Administration  
**Environment:** RHEL 8.10 (Server & Client VMs)  
**Author:** hadz0024 

---

## Overview
This lab demonstrates the automated installation, configuration, and verification of **Samba (SMB/CIFS)** and **NFS (Network File System)** services across a multi-subnet Linux environment. 
Bash automation scripts were developed to provision shared directories, configure user-based and subnet-based access controls, manage SELinux and firewall rules, and establish persistent client mounts via `/etc/fstab`.

---

## Network Topology

| Role | Hostname | IP Address | Subnet | Access Profile |
| :--- | :--- | :--- | :--- | :--- |
| **Linux Server** | `hadz0024-SRV` | `172.16.30.130` | `172.16.30.0/24` | Hosts Samba & NFS shares; Read-Only NFS access |
| **Linux Client** | `hadz0024-CLT` | `172.16.31.130` | `172.16.31.0/24` | Mounts Samba & NFS shares; Read-Write NFS access |

---

## Share Architecture & Access Controls

### 1. Samba Shares (`/etc/samba/smb.conf`)
* **`samba-public` (`/public`)**: Browseable and Read/Write for all users and guests (`chmod 1777` sticky bit enabled).
* **`samba-private` (`/private`)**: Restricted authenticated share (`valid users = user1 user2`).
  * `user1`: **Read-Write** (`write list = user1`)
  * `user2`: **Read-Only**

### 2. NFS Exports (`/etc/exports`)
* **`/srv/nfs` (with `/srv/nfs/restricted`)**:
  * `172.16.31.0/24` (Client Network): **Read-Write (`rw`)**
  * `172.16.30.0/24` (Server Network): **Read-Only (`ro`)**

---

## Automation Scripts

### 1. Server Setup (`server_setup.sh`)
Installs `samba`, `cifs-utils`, `rpcbind`, and `nfs-utils`; provisions `user1` and `user2`; applies directory permissions (`1777` sticky bit on `/public`, `0755` on `/private`, `0777` on `/srv/nfs/restricted`); configures SELinux booleans/contexts and `firewalld`; and generates `/etc/samba/smb.conf` and `/etc/exports`.

```bash
#!/bin/bash
# CST8246 - Lab 08: Automated Samba & NFS Server Setup
# Server IP: 172.16.30.130

set -e

SMB_PUBLIC="/public"
SMB_PRIVATE="/private"
NFS_BASE="/srv/nfs"
NFS_RESTRICTED="/srv/nfs/restricted"

echo "=== [1/6] Installing Samba and NFS Packages ==="
dnf install -y samba samba-client samba-common cifs-utils rpcbind nfs-utils

echo "=== [2/6] Creating Linux & Samba Users (user1 & user2) ==="
for U in user1 user2; do
    if ! id "\$U" &>/dev/null; then
        useradd -m "\$U"
        echo "U:U" | chpasswd
    fi
    (echo "\$U"; echo "U") | smbpasswd -s -a "U"
    smbpasswd -e "\$U"
done

echo "=== [3/6] Creating Directories & Setting Exact Permissions ==="
mkdir -p "\$SMB_PUBLIC" "\(SMB_PRIVATE" "\)NFS_RESTRICTED"
chmod 1777 "\$SMB_PUBLIC"
chown -R user1:user1 "\$SMB_PRIVATE"
chmod 0755 "\$SMB_PRIVATE"
chmod 0755 "\$NFS_BASE"
chmod 0777 "\$NFS_RESTRICTED"
echo "Hi My Dear Students!" > "\$NFS_RESTRICTED/README.nfs"
chmod 0777 "\$NFS_RESTRICTED/README.nfs"

echo "=== [4/6] Configuring SELinux & Firewall ==="
if command -v semanage &>/dev/null; then
    semanage fcontext -a -t samba_share_t "\${SMB_PUBLIC}(/.*)?" || true
    semanage fcontext -a -t samba_share_t "\${SMB_PRIVATE}(/.*)?" || true
    restorecon -Rv "\(SMB_PUBLIC" "\)SMB_PRIVATE"
    setsebool -P samba_enable_home_dirs on
fi

if systemctl is-active --quiet firewalld; then
    firewall-cmd --permanent --add-service=samba
    firewall-cmd --permanent --add-service=nfs
    firewall-cmd --permanent --add-service=rpc-bind
    firewall-cmd --permanent --add-service=mountd
    firewall-cmd --reload
fi

echo "=== [5/6] Configuring /etc/samba/smb.conf ==="
cp -n /etc/samba/smb.conf /etc/samba/smb.conf.bak

cat <<EOF > /etc/samba/smb.conf
[global]
    workgroup = cst8246
    security = user
    passdb backend = tdbsam
    map to guest = Bad User

[samba-public]
    comment = Public Samba Share
    path = /public
    public = yes
    browseable = yes
    writeable = yes

[samba-private]
    comment = Private Samba Share
    path = /private
    public = no
    valid users = user1 user2
    write list = user1
EOF

testparm -s

echo "=== [6/6] Configuring /etc/exports & Starting Services ==="
cat <<EOF > /etc/exports
/srv/nfs 172.16.30.0/24(ro) 172.16.31.0/24(rw)
EOF

systemctl enable --now smb nmb rpcbind nfs-server
systemctl restart smb nmb rpcbind nfs-server
exportfs -ra
```

---

### 2. Client Setup (`client_setup.sh`)
Installs client mount utilities (`cifs-utils`, `nfs-utils`), secures Samba credentials in `/etc/cred.txt` (`chmod 600`), adds persistent entries to `/etc/fstab`, mounts all shares, and creates verification files (`readme.smb` and `readme.nfs`).

```bash
#!/bin/bash
# CST8246 - Lab 08: Automated Client Setup & Mounting
# Server IP: 172.16.30.130 | Client IP: 172.16.31.130

set -e

SERVER_IP="172.16.30.130"
STUDENT_NAME="hadz0024"

echo "=== [1/4] Installing Client Utilities ==="
dnf install -y cifs-utils nfs-utils

echo "=== [2/4] Creating /etc/cred.txt & Local Mount Directories ==="
cat <<EOF > /etc/cred.txt
username=user1
password=user1
EOF
chmod 600 /etc/cred.txt

mkdir -p /public /private /mnt/nfs

echo "=== [3/4] Adding Persistent Mounts to /etc/fstab ==="
cp -n /etc/fstab /etc/fstab.bak

if ! grep -q "samba-public" /etc/fstab; then
    echo "//\${SERVER_IP}/samba-public   /public   cifs   defaults,_netdev,guest   0 0" >> /etc/fstab
fi

if ! grep -q "samba-private" /etc/fstab; then
    echo "//\${SERVER_IP}/samba-private  /private  cifs   defaults,_netdev,cred=/etc/cred.txt   0 0" >> /etc/fstab
fi

if ! grep -q "/srv/nfs" /etc/fstab; then
    echo "\${SERVER_IP}:/srv/nfs   /mnt/nfs   nfs   intr,_netdev   0 0" >> /etc/fstab
fi

echo "=== [4/4] Mounting All Shares & Creating Deliverable Files ==="
systemctl daemon-reload
mount -a

echo "\$STUDENT_NAME" > /private/readme.smb
echo "\$STUDENT_NAME" > /private/README.smb
echo "\$STUDENT_NAME" > /mnt/nfs/restricted/readme.nfs
echo "\$STUDENT_NAME" > /mnt/nfs/restricted/README.nfs
```

---

## Verification Commands

### 1. Client Verification (`hadz0024-CLT` — `172.16.31.130`)

* **Test `samba-public` (Read-Write for everyone):**
  ```bash
  mount -o username=user1 //172.16.30.130/samba-public /mnt
  df -h
  echo "Client RW Test" > /mnt/client_test.txt
  cd / && umount /mnt
  ```

* **Test `samba-private` as `user1` (Read-Write):**
  ```bash
  mount -o username=user1 //172.16.30.130/samba-private /mnt
  df -h
  cat /mnt/readme.smb
  cd / && umount /mnt
  ```

* **Test `samba-private` as `user2` (Read-Only):**
  ```bash
  mount -o username=user2 //172.16.30.130/samba-private /mnt
  df -h
  touch /mnt/denied.txt    # Expected: Permission denied
  cd / && umount /mnt
  ```

* **Test `/srv/nfs` from `172.16.31.0/24` network (Read-Write):**
  ```bash
  mount -o intr -t nfs 172.16.30.130:/srv/nfs /mnt
  df -h
  cat /mnt/restricted/readme.nfs
  touch /mnt/restricted/client_nfs_test
  cd / && umount /mnt
  ```

---

### 2. Server Verification (`hadz0024-SRV` — `172.16.30.130`)

* **Verify Samba public file created by client:**
  ```bash
  ls -l /public
  cat /public/client_test.txt
  ```

* **Test `/srv/nfs` from `172.16.30.0/24` network (Read-Only):**
  ```bash
  mount -o intr -t nfs 172.16.30.130:/srv/nfs /mnt
  df -h
  cat /mnt/restricted/readme.nfs
  touch /mnt/restricted/server_ro_test   # Expected: Read-only file system
  cd / && umount /mnt
  ```

---

## Service & Troubleshooting Commands
* **Check Active Services & Ports:** `ss -tulnp | grep -E "smbd|nmbd|rpc|nfs"` (Samba: TCP `445`/`139`, NFS: TCP `2049`)
* **Validate Samba Configuration:** `testparm -s`
* **Inspect Active NFS Exports:** `exportfs -v` and `showmount -e 172.16.30.130`
* **Verify Installed RPM Packages:** `rpm -qa | grep -E "samba|cifs|nfs|rpcbind"`
