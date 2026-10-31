#### Lab 06: Automating Postfix Installation, Configuration, and Testing

#### Overview

This laboratory project provides an end-to-end automated deployment framework for an enterprise-grade Postfix Mail Transfer Agent (MTA) integrated with an authoritative Master/Slave BIND DNS infrastructure. Designed specifically for a dual-subnet isolated environment, the architecture features network service automation, custom firewall path filtering matrices, alias distribution trees, and address masquerading features. 

#### Infrastructure Blueprint

* **Domain Context:** example130.lab
* **Mail Exchange FQDN:** mail.example130.lab
* **Master Server IP Address:** 172.16.30.130
* **Slave Client/Validation Node IP Address:** 172.16.31.130
* **Explicitly Forbidden Network Subnet:** 172.16.99.0/24
* **Local System Testing Mailbox User:** user8246

#### Automated Architectural Features

1. **MTA Configuration Hardening:** Hardcodes structural configuration properties directly via the postconf engine, enabling multi-interface network binding (inet_interfaces = all) and explicit path spools.
2. **Mailbox Format Enforcement:** Configures local mbox storage file pathways within the mandatory /var/spool/mail/ tree.
3. **Address Masquerading and Clean-Up:** Removes individual host node sub-domain headers from outbound headers via myorigin = $mydomain to mask system architecture.
4. **Distribution Group Aliasing:** Authors an alias translation matrix mapping local shortcuts (geeks, dnsadmin) directly to target distribution endpoints.
5. **Firewalld Policy Filtering Matrix:** Restricts inbound SMTP traffic on Port 25 via advanced rich-rules, selectively permitting validation subnets while dropping unauthorized packets.
6. **DNS Replication Architecture:** Coordinates zones transfers over port 53 with automated BIND synchronization validation tokens.

#### Step-by-Step Functional Verification Framework

Execute these exact testing pathways sequentially from the **Linux Client VM console (172.16.31.130)** to audit network performance. 

#### Phase 1: DNS Replication & Cross-Subnet Resolution Audits

Verify that the replicated zone datasets are active and answering queries correctly over network links: 

bash

dig @172.16.31.130 example130.lab MX
dig @172.16.31.130 mail.example130.lab A

Use code with caution.

#### Phase 2: Core Email Delivery Verification Matrix

##### Test 1: Specifying the Recipient by IP Address Literal (Bypasses DNS Lookup)

Delivers mail directly via raw network sockets to target the core server system card, requiring single quotes to bypass shell regex evaluation: 

bash

echo "Testing IP literal mailing address route" | mail -v -S smtp=172.16.30.130 -s "IP Mail Test" user8246@\[172.16.30.130\]

Use code with caution.

##### Test 2: Delivery by Fully Qualified Hostname (FQDN Route)

Verifies explicit standard host node mapping deliveries across the network architecture: 

bash

echo "Testing Full Hostname FQDN routing map" | mail -v -S smtp=172.16.30.130 -s "FQDN Mail Test" user8246@mail.example130.lab

Use code with caution.

##### Test 3: Delivery by Bare Domain Name / Team Distribution Alias (Triggers MX Records)

Pushes mail to the group alias endpoint, verifying both the BIND MX prioritization table and Postfix database expansion mechanics: 

bash

echo "Testing stripped bare domain mapping address" | mail -v -S smtp=172.16.30.130 -s "Domain Masquerade Test" geeks@example130.lab

Use code with caution.

#### System Spool Inspection (Run on Server: 172.16.30.130)

Execute this print lookup from the server workspace to audit the internal plain-text file storage structure and review successful transaction headers: 

bash

tail -n 50 /var/spool/mail/user8246

Use code with caution.
