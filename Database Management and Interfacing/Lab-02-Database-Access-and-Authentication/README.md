# Lab 02: PostgreSQL Identity, Roles, and Host-Based Authentication Matrix

A technical exploration of user administration, system account matching, privilege decoupling, and Host-Based Authentication (`pg_hba.conf`) profiles within an isolated PostgreSQL 18 database engine environment.

## Laboratory Overview
This lab covers database access control management, intentional troubleshooting of local authentication errors, and isolating administrative scopes. 
The tasks involve creating alternative system administrators, defining custom restricted network identities with specific creation permissions, and configuring authentication mechanisms across `peer`, `trust`, and `md5` rules.

## 🛠️ Environment Specifications
* **Operating System Platform:** Ubuntu Linux
* **Database Engine Module:** PostgreSQL 18
* **Local Connection Interface:** Unix Domain Sockets (`local`)
* **Environment Hostname Container:** `seven-VMware-Virtual-Platform`
* **Student Network Identity Reference:** `db_hadz0024`

## Technical Progression & Role Provisioning

### 1. Alternative Database Administrator Setup
Switched execution context to system root privileges to establish a matching system operating system account named `dbadmin`. 
Authenticated against the primary background master cluster service account to provision the role as an official database-level superuser.

```bash
# Provisioning the standard system host identity account
sudo -i
useradd -m -s /bin/bash dbadmin
passwd dbadmin
exit

```bash
# Registering the superuser scope inside the DBMS environment
sudo -i -u postgres
createuser -s dbadmin
psql postgres -c "\du"
exit

### 2. Specialized Purpose-Built Network Identity Role
Utilized the new alternative database administrative credentials (`dbadmin`) to securely spin up a non-superuser account linked directly to student network credentials (`db_hadz0024`). 
The scope of this profile was explicitly isolated to have `CREATEDB` access rights.

```bash
# Connecting as alternative superuser to provision a restricted profile
sudo -i -u dbadmin
createuser --interactive db_hadz0024

# Interactive Configuration Log Choices:
# Shall the new role be a superuser? (y/n) n
# Shall the new role be allowed to create databases? (y/n) y
# Shall the new role be allowed to create more new roles? (y/n) n

# Creating the corresponding operating system identity map layer
exit
sudo -i
useradd -m -s /bin/bash db_hadz0024
exit

## Authentication Control Matrix Testing Logs

### Exercise #1: Peer Authentication Profile
* **Configuration Vector Location:** `/etc/postgresql/18/main/pg_hba.conf`
* **Active Directive Line:** `local all all peer`
* **Security Mechanics:** Requires a strict, direct 1-to-1 match between the invoking Linux environment user name and the targeted structural database role name.

| Log ID | Invoking System Prompt & Execution Command | Returned DBMS Result / Error Log String | Analytical Root Cause Evaluation |
| **`peer-1`** | `root@seven-VMware-Virtual-Platform:~# psql postgres root` | `FATAL: role "root" does not exist` | **Failure.** Operating system identity verified, but database engine lack records matching that username.
| **`peer-2`** | `root@seven-VMware-Virtual-Platform:~# psql postgres dbadmin` | `FATAL: Peer authentication failed for user "dbadmin"` | **Failure.** Intercept filter blocks access because the calling Linux host user (`root`) fails to align with the target role identifier (`dbadmin`).
| **`peer-3`** | `dbadmin@seven-VMware-Virtual-Platform:~$ psql postgres dbadmin` | `n/a` | **Success.** Seamless database session connection; invoking shell profile mirrors the exact role path definition.
| **`peer-4`** | `dbadmin@seven-VMware-Virtual-Platform:~$ psql nodb dbadmin` | `FATAL: database "nodb" does not exist` | **Failure.** Identity verification clears successfully, but the target database container file allocation structure is missing.

### Exercise #2: Trust Authentication Profile
* **Configuration Vector Location:** `/etc/postgresql/18/main/pg_hba.conf`
* **Active Directive Line:** `local all all trust`
* **Security Mechanics:** Disables intercept filters and credentials verification for local shell targets. Any host identity user can assert full access authority under any existing internal registry role.

| Log ID | Invoking System Prompt & Execution Command | Returned DBMS Result / Error Log String | Analytical Root Cause Evaluation |
| **`trust-1`** | `root@seven-VMware-Virtual-Platform:~# psql postgres root` | `FATAL: role "root" does not exist` | **Failure.** Identification checks skipped entirely, but matching role catalog rows remain missing inside database storage.
| **`trust-2`** | `root@seven-VMware-Virtual-Platform:~# psql postgres dbadmin` | `n/a` | **Success.** Connection allowed; standard user parameters successfully proxy straight into superuser spaces under trust allowances.
| **`trust-3`** | `dbadmin@seven-VMware-Virtual-Platform:~$ psql postgres dbadmin` | `n/a` | **Success.** Seamless connection established under standard validation pathways.
| **`trust-4`** | `dbadmin@seven-VMware-Virtual-Platform:~$ psql nodb dbadmin` | `FATAL: database "nodb" does not exist` | **Failure.** Security validation passed, but physical file mapping for the target space layout configuration is absent.

### Exercise #3: MD5 Password Authentication Profile
* **Configuration Vector Location:** `/etc/postgresql/18/main/pg_hba.conf`
* **Active Directive Line:** `local all all md5`
* **Security Mechanics:** Decouples physical host user layers from the system engine catalog. Relies entirely on database internal credential checks.

# Generating an isolated testing role mapped explicitly with system security passwords
sudo -i -u dbadmin
createuser -P rolepwd
exit

| Log ID | Invoking System Prompt & Execution Command | Returned DBMS Result / Error Log String | Analytical Root Cause Evaluation |
| **`md5-1`** | `dbadmin@seven-VMware-Virtual-Platform:~$ psql postgres rolepwd` | `n/a` | **Success.** Host account identity skipped. Target role verification passes when the matching secure password string payload is evaluated.
| **`md5-2`** | `dbadmin@seven-VMware-Virtual-Platform:~$ psql postgres dbadmin` | `FATAL: password authentication failed for user "dbadmin"` | **Failure.** Access blocked; the database system relies entirely on internal encrypted catalog hashes and cannot accept external system Linux user account credentials.

## Laboratory Environment Post-Run Cleanup
To ensure this local testing sandbox remains flexible for upcoming structural operations exercises throughout the term, the environment has been returned to default relaxed lab security constraints:
1. Target host configuration files:
   sudo nano /etc/postgresql/18/main/pg_hba.conf
2. Modify domain socket control values to rely strictly on `trust` routing protocols:
   # local   all             all                                     peer
   # local   all             all                                     md5
   local   all             all                                     trust
3. Refresh the engine status daemon configurations:
   sudo systemctl restart postgresql
