# Lab 04: Managing Microsoft Exchange – CST8342

## 📊 Environment Configuration
* **Server Hostname:** `SERVER89069`
* **Fully Qualified Domain Name (FQDN):** `://cst8342.com`
* **Active Directory Domain:** `://cst8342.com`
* **Server IP Address:** `172.16.89.69`

---

## 📂 Deliverables & Verification Benchmarks

### lab04-01 DNS Resolution Testing
Verification of local Active Directory Domain Services (AD DS) and Exchange server resource records:
```cmd
nslookup ://cst8342.com
nslookup mail.://cst8342.com
```

### lab04-02 Core Services Verification
* **Status:** Verified via `services.msc`. All core `MSExchange*` microservices (including IMAP4, POP3, and Frontend Transport) are set to **Automatic** startup types and actively in a **Running** status state.

### lab04-03 License Status Audit
Executed inside the **Exchange Management Shell** to inspect User Client Access Licenses (CAL):
```powershell
Get-ExchangeServerAccessLicense | ft -AutoSize
Get-ExchangeServerAccessLicenseUser -LicenseName "Exchange Server 2016 Standard CAL"
```
* **Active Matrix Baseline:** Displays Standard/Enterprise Editions alongside verified CAL tokens for `Administrator@://cst8342.com`.

### lab04-04 Remote Domain Verification
Verification of remote domain handling rules via Exchange Management Shell:
```powershell
Get-RemoteDomain
```
* **Active Domain Target:** Default matching space points to `*` with an External AllowedOOFType property.

### lab04-05 Accepted Domains Topology
* **Path:** Exchange Admin Center (ECP) > Mail Flow > Accepted Domains
* **Status:** Active configurations captured showing the local domain routing authorization status.

### lab04-06 SMTP Send Connector Creation
* **Path:** ECP > Mail Flow > Send Connectors
* **Configuration:** Added a custom `Internet` type Send Connector named `SMTP`. Status verified as **Enabled** with an address space scope of `*`.

### lab04-07 & lab04-08 Server Protocol Port Mapping
* **Path:** ECP > Servers > Servers > Edit Server Property Nodes > POP3 / IMAP4 tabs
* **IMAP4 Mappings:** Port `143` (TLS/Unencrypted) and Port `993` (Secure SSL/TLS Connections).
* **POP3 Mappings:** Port `110` (TLS/Unencrypted) and Port `995` (Secure SSL/TLS Connections).

### lab04-09 Receive Connector Scoping
* **Path:** ECP > Mail Flow > Receive Connectors > Default Frontend SERVER89069 Edit > Scoping Tab
* **Network Binding Configurations:** Configured to bind on all available IPv6/IPv4 interfaces listening on Port `25`.
* **Security Group Rules:** Formally verified with `Anonymous users` permission rules checked and enabled.

### lab04-10 User Mailbox Provisioning
* **Path:** ECP > Recipients > Mailboxes > Add User Mailbox
* **Target Profile Account:** Created and initialized student profile **`hadz0024`** (`hadz0024@://cst8342.com`).

### lab04-11 Mailbox Property Node Review
* **Path:** ECP > Recipients > Mailboxes > Edit Properties > General tab
* **Status:** Property metrics verified for User Principal Node identity string `hadz0024@://cst8342.com` with matching custom Alias flags.

### lab04-12 & lab04-13 Outlook Web Access (OWA) Validation
* **Endpoint:** `https://mail.://cst8342.com/owa/#path=/mail`
* **Status:** Verified intra-organizational message delivery. Successfully tracked delivery of the initial test message from the Domain Administrator to `hadz0024` and the corresponding response acknowledgement thread.

### lab04-14 Mail Client Topology (Mozilla Thunderbird)
* **Inbound Protocol (POP3):** `mail.://cst8342.com` | Port: `110` | Connection Security: `STARTTLS` | Authentication: `Normal password`
* **Outbound Protocol (SMTP):** `mail.://cst8342.com` | Port: `25` (or `587`) | Connection Security: `STARTTLS` | Authentication: `Normal password`
* **Status:** Operational verification confirmed. Successfully authenticated client-side transport workflows using the student service account mailbox, showing complete folder synchronization and message logs.

### lab04-15 Mailbox Database Architecture Matrix
* **Path:** ECP > Servers > Databases > New Database Wizard
* **Database Spec Path:** `C:\Databases\dm89069_hadz0024\dm89069_hadz0024.edb`
* **Log Spec Path:** `C:\Logs\dm89069_hadz0024`
* **Status:** Custom storage paths populated, saved, and successfully mapped onto `SERVER89069` with the "Mount this database" flag verified.

### lab04-16 Advanced Directory Mailbox Provisioning
* **Target Profile Account:** Doug Dacey (`daceyd@://cst8342.com`)
* **Organizational Unit Target:** `ExchUsers` (Provisioned inside ADUC)
* **Target Storage Node:** Assigned manually to your custom storage database node partition `dm89069_hadz0024` under More Options.

### lab04-17 Remote Boundary Test via Telnet
Local port-probing check to ensure raw internal mail relay paths are active:
```cmd
telnet mail.://cst8342.com 25
```
* **Expected Successful Transaction Greeting:** 
  `220 ://cst8342.com Microsoft ESMTP MAIL Service ready`
