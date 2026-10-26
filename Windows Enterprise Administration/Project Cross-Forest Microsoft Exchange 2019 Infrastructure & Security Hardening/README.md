An enterprise-grade deployment of a highly resilient, isolated **multi-forest infrastructure featuring cross-domain routing pipelines, automated email transport fabrics, and strict kiosk user security lockdowns.** This architecture simulates a complex corporate B2B merger/integration environment, enforcing granular network segmentation, secure DNS zone authorities, cross-forest delivery permissions, protocol optimization, and Group Policy-driven desktop restrictions.

---

## 🏛️ Network Infrastructure & Core Topology

The lab infrastructure is built on two isolated Windows Server domain controllers hosting independent Active Directory forests. 
Inter-forest communications rely on targeted routing paths over an external laboratory network switch boundary with zero reliance on default internet gateways.

### 🌐 Server Node Configuration Matrix

| Core System Attribute | Server 1 (Lower Node) | Server 2 (Higher Node) |
| :--- | :--- | :--- |
| **Fully Qualified Domain Name (FQDN)** | `dm89071.cst8342.com` | `dm89072.cst8342.com` |
| **NetBIOS Server Hostname** | `server89071` | `server89072` |
| **Active Directory Forest Level** | Windows Server 2022 | Windows Server 2022 |
| **Red NIC (Internal Lab Core IP)** | **`172.16.89.71`** (No Gateway) | **`172.16.89.72`** (No Gateway) |
| **Blue NIC (VMware NAT / Internet)** | DHCP Allocation | DHCP Allocation |
| **Loopback Interface Binding** | `127.0.0.1` | `127.0.0.1` |
| **Exchange Organization Name** | `dm89071 hadz0024 Organization` | `dm89072 hadz0024 Organization` |

---

## 🗺️ Logical Directory & DNS Architecture

Cross-forest message routing demands independent namespace authority coupled with targeted query resolution handlers. 

### 1. DNS Namespace Management
* **Forward Lookup Zones:** Server 1 serves as the absolute authority for `dm89071.cst8342.com`, while Server 2 commands `dm89072.cst8342.com`. * Each zone contains a dedicated, statically bound **Mail Exchanger (MX)** record tracking back to a high-priority host address resource mapping named **`MAIL`**.
* **Reverse Lookup Zones:** Independent instances of classless reverse scoping pointer grids (**`89.16.172.in-addr.arpa`**) populate both domain namespaces, ensuring precise `PTR` resolution metrics for cross-domain mail hygiene.
* **Conditional Forwarders:** Cross-forest lookups bypass internet root hits entirely. Server 1 forwards all traffic matching `*.dm89072.cst8342.com` directly to `172.16.89.72`, and Server 2 matches the return path to `172.16.89.71`.

### 2. Active Directory Organizational Layout
Granular resource categorization is implemented via structured **Organizational Units (OUs)** designed to cleanly segment standard production personnel from highly monitored contract or kiosk devices.

```text
dm89071.cst8342.com (Forest Root 1)
├── 📁 Projhadz0024 (Production Staff OU)
│   └── 👤 Jack Doehadz0024 (Login: Doehadz0024)
└── 📁 Conthadz0024 (Constrained Kiosk Stations OU)
    └── 👤 Sue Lihadz0024  (Login: Lihadz0024)

dm89072.cst8342.com (Forest Root 2)
└── 📁 Usershadz0024 (Corporate Personnel OU)
    └── 👤 Joe Archadz0024 (Login: Archadz0024)
```

---

## ✉️ Exchange Server Mail Flow Mechanics & Protocol Tuning

To establish cross-domain unauthenticated message transfers over local network boundaries without trusted public security certificates, deep modifications to Exchange's default transport logic were required.
### 1. Inbound/Outbound Transport Pipelines
By default, Microsoft Exchange Server restricts anonymous, unauthenticated SMTP inbound traffic from external or untrusted namespaces. To allow the two separate organizations to exchange messages over the local lab switch boundary, custom **Receive Connectors** were configured. The `AnonymousUsers` permission group was explicitly assigned to the HubTransport frontend connectors on Port 25, enabling unauthenticated cross-domain routing without triggering message rejection or authentication challenges.

### 2. Protocol Enablement & Windows Services Automation
While modern corporate environments utilize HTTPS/MAPI frameworks for internal communications, legacy and specialized external endpoints require dedicated lightweight mail protocols. The Exchange IMAP4 and POP3 services—disabled by default—were enabled and switched to automatic execution to handle client routing.

| Windows Service Display Name | System Service Name | Assigned Startup Parameter | Operating State |
| :--- | :--- | :--- | :--- |
| **Microsoft Exchange IMAP4** | `MSExchangeIMAP4` | **Automatic** | **Running** |
| **Microsoft Exchange IMAP4 Backend** | `MSExchangeIMAP4BE` | **Automatic** | **Running** |
| **Microsoft Exchange POP3** | `MSExchangePOP3` | **Automatic** | **Running** |
| **Microsoft Exchange POP3 Backend** | `MSExchangePOP3BE` | **Automatic** | **Running** |

---

## 🔒 Hardened Kiosk Group Policy Architecture

To enforce the strict corporate compliance requirements for contractor workspaces, a restrictive **Group Policy Object (`SueLi_Kiosk_Lockdown`)** was linked directly to the `Conthadz0024` Organizational Unit. This converts the target system profile into a locked-down, single-purpose device.

### 🛡️ Applied GPO Constraint Map
* **Desktop Environment Virtualization:** Enforces *Hide all items on the desktop* (`Enabled`). This completely clears the local desktop interface, preventing files, directories, or system icons from rendering.
* **Granular Whitelisting:** Enforces *Run only specified Windows applications* (`Enabled`). The execution list is hardcoded strictly to **`thunderbird.exe`**. Any attempt to execute unauthorized tools (such as `cmd.exe`, `powershell.exe`, or `notepad.exe`) is intercepted by the OS kernel and denied.
* **Control Panel Shielding:** Enforces *Prohibit access to Control Panel and PC settings* (`Enabled`). This completely isolates core settings applets, blocking the user from modifying local adapter properties, hardware configurations, or account elements.

---

## 🚀 Step-by-Step Deployment Automation Suite

This section contains the administrative scripts and console commands executed to initialize the environment.

### 1. Complete Post-AD Promotion Infrastructure Configuration
Run this PowerShell automation script on **Server 1** and **Server 2** respectively to clean legacy zones, map A/CNAME/MX lines, configure DNS suffixes, and build the required cross-forest conditional lookups.

```powershell
# Define Core Environment Properties
\$NetworkID = "89"
\$UserToken = "hadz0024"
CurrentIP = (Get-NetIPAddress -AddressFamily IPv4 | Where-Object _.IPAddress -like "172.16.*" }).IPAddress

if (CurrentIP -eq "172.16.NetworkID.71") {
    HostName = "server89071"; DomainFQDN = "dm89071.cst8342.com"; \(RemoteIP = "172.16.89.72"; \)RemoteDomain = "dm89072.cst8342.com"; IsServer1 = true
} else {
    HostName = "server89072"; DomainFQDN = "dm89072.cst8342.com"; \(RemoteIP = "172.16.89.71"; \)RemoteDomain = "dm89071.cst8342.com"; IsServer1 = false
}

Write-Host "[*] Executing Infrastructure Provisioning for \$HostName..." -ForegroundColor Cyan

# Configure Network Suffix Overrides
ActiveAdapter = Get-NetAdapter | Where-Object _.Status -eq "Up" } | Select-Object -First 1 -ExpandProperty Name
Set-DnsClient -InterfaceAlias \$ActiveAdapter -ConnectionSpecificSuffix DomainFQDN -RegisterThisConnectionsAddress true

# Reconstruct Clean DNS Zone Architecture
Get-DnsServerZone | Where-Object { \$_.ZoneName -ne DomainFQDN -and !_.IsAutoCreated } | Remove-DnsServerZone -Force
Add-DnsServerPrimaryZone -Name "89.16.172.in-addr.arpa" -ReplicationScope Forest -ErrorAction SilentlyContinue

# Inject Authoritative Record Configurations
Add-DnsServerResourceRecordA -Name "mail" -ZoneName DomainFQDN -IPv4Address CurrentIP -CreatePtr -Force
Get-DnsServerResourceRecord -ZoneName DomainFQDN -RRType MX | Remove-DnsServerResourceRecord -ZoneName DomainFQDN -Force
Add-DnsServerResourceRecordMX -Name "@" -ZoneName DomainFQDN -MailExchange "mail.DomainFQDN" -Preference 10 -Force
Add-DnsServerResourceRecordCName -Name "autodiscover" -ZoneName DomainFQDN -HostNameAlias "mail.DomainFQDN" -Force

# Crosslink Cross-Forest Namespace Forwarding Pipeline
Add-DnsServerConditionalForwarderZone -Name RemoteDomain -MasterServers RemoteIP -Force
Write-Host "[+] Infrastructure Configuration Completed Successfully." -ForegroundColor Green
```

### 2. Active Directory User and Mailbox Provisioning
Execute this script block inside the **Exchange Management Shell (EMS)** on the corresponding server node to spin up OUs, user templates, and link specific storage databases.

#### Server 1 (Lower Server)
```powershell
Import-Module ActiveDirectory
\$SecurePass = ConvertTo-SecureString "CST8342SecurePass!" -AsPlainText -Force

# Generate Target OUs
New-ADOrganizationalUnit -Name "Projhadz0024" -Path "DC=dm89071,DC=cst8342,DC=com"
New-ADOrganizationalUnit -Name "Conthadz0024" -Path "DC=dm89071,DC=cst8342,DC=com"

# Provision Mailbox Objects
New-Mailbox -UserPrincipalName "Doehadz0024@dm89071.cst8342.com" -Alias "Doehadz0024" -Name "Jack Doehadz0024" -FirstName "Jack" -LastName "Doehadz0024" -OrganizationalUnit "Projhadz0024" -Password \$SecurePass
New-Mailbox -UserPrincipalName "Lihadz0024@dm89071.cst8342.com" -Alias "Lihadz0024" -Name "Sue Lihadz0024" -FirstName "Sue" -LastName "Lihadz0024" -OrganizationalUnit "Conthadz0024" -Password \$SecurePass

# Deploy and Mount Isolated DB for Manager
New-MailboxDatabase -Name "Dacey" -Server server89071
Mount-Database -Identity "Dacey"
New-Mailbox -UserPrincipalName "daceyd@dm89071.cst8342.com" -Alias "daceyd" -Name "Doug Dacey" -FirstName "Doug" -LastName "Dacey" -Database "Dacey" -Password \$SecurePass
Set-Mailbox -Identity "daceyd" -PrimarySmtpAddress "Doug.Dacey@dm89071.cst8342.com" -EmailAddressPolicyEnabled \$false
```

#### Server 2 (Higher Server)
```powershell
Import-Module ActiveDirectory
\$SecurePass = ConvertTo-SecureString "CST8342SecurePass!" -AsPlainText -Force

# Generate Target OU
New-ADOrganizationalUnit -Name "Usershadz0024" -Path "DC=dm89072,DC=cst8342,DC=com"

# Provision Mailbox Object
New-Mailbox -UserPrincipalName "Archadz0024@dm89072.cst8342.com" -Alias "Archadz0024" -Name "Joe Archadz0024" -FirstName "Joe" -LastName "Archadz0024" -OrganizationalUnit "Usershadz0024" -Password \$SecurePass

# Deploy and Mount Isolated DB for Manager
New-MailboxDatabase -Name "Dacey" -Server server89072
Mount-Database -Identity "Dacey"
New-Mailbox -UserPrincipalName "daceyd@dm89072.cst8342.com" -Alias "daceyd" -Name "Doug Dacey" -FirstName "Doug" -LastName "Dacey" -Database "Dacey" -Password \$SecurePass
Set-Mailbox -Identity "daceyd" -PrimarySmtpAddress "Doug.Dacey@dm89072.cst8342.com" -EmailAddressPolicyEnabled \$false
```

---

## 🔍 Live Verification Protocols

Run these terminal validation strings before signaling your evaluator to begin grading:

```cmd
:: 1. Verify two-way DNS resolution across the infrastructure
nslookup mail.dm89071.cst8342.com
nslookup mail.dm89072.cst8342.com
nslookup server89071.dm89071.cst8342.com
nslookup server89072.dm89072.cst8342.com

:: 2. Test cross-network SMTP port connectivity (Port 25)
telnet mail.dm89072.cst8342.com 25
telnet mail.dm89071.cst8342.com 25
```
