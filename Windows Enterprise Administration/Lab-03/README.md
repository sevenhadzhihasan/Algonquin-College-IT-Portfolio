# Lab 03 – Microsoft Exchange Server 2019 Installation

## Goal
The goal of this lab was the successful installation and configuration of **Microsoft Exchange Server 2019** inside a Windows Server 2022 environment. 

## Environment Details
* **Domain Name:** `dm89069.cst8342.com`
* **Server IP Address:** `172.16.89.69`
* **Operating System:** Windows Server 2022 (Virtual Machine)

## Key Technical Tasks Completed
1. **DNS Zone Configuration:** Configured Mail Host (A) record, Autodiscover Alias (CNAME) record, and Mail Exchanger (MX) record with a priority of 10.
2. **Active Directory Preparation:** Updated the AD Schema, prepared Active Directory definitions, and isolated local domains using PowerShell setup switches.
3. **Prerequisite Resolution:** Installed essential system features (`RSAT-Clustering`, `Web-Server`, etc.) and patched external dependencies including Visual C++ 2013 and the IIS URL Rewrite Module.
4. **Exchange Service Verification:** Validated mailbox deployments, configured core messaging services (IMAP4 and POP3) to run automatically, and accessed the Exchange Admin Center dashboard.

5. ## Key Technical Tasks Completed
1. **DNS Zone Configuration:** Configured Mail Host (A) record, Autodiscover Alias (CNAME) record, and Mail Exchanger (MX) record with a priority of 10.
2. **Active Directory Preparation:** Updated the AD Schema, prepared Active Directory definitions, and isolated local domains using PowerShell setup switches.
3. **Prerequisite Resolution:** Installed essential system features (`RSAT-Clustering`, `Web-Server`, etc.) and patched external dependencies including Visual C++ 2013 and the IIS URL Rewrite Module.
4. **Exchange Service Verification:** Validated mailbox deployments, configured core messaging services (IMAP4 and POP3) to run automatically, and accessed the Exchange Admin Center dashboard.
