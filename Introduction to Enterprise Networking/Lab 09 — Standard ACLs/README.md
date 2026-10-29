# Lab 09 — Standard ACLs: Follow the Traffic
**Course:** Introduction to Enterprise Networking  
**Student Identifier:** hadz0024  
**Lab Subnet Variable (U):** 12  
**Environment:** Cisco Modeling Labs (CML-Free)

---

## 🗺️ 1. Topology & Network Design Matrix
The network consists of two Cisco IOL-XE routers and three Alpine Linux endpoints fully synchronized via an active OSPF routing process.

| Link Name | Source Node / Interface | Destination Node / Interface | Subnet Network (U=12) |
| :--- | :--- | :--- | :--- |
| **Transit** | `hadz0024-R1` Ethernet0/0 | `hadz0024-R2` Ethernet0/0 | `198.18.12.0/30` |
| **Engineering** | `hadz0024-R1` Ethernet0/1 | `PC1` eth0 | `198.18.12.32/28` |
| **Accounting** | `hadz0024-R1` Ethernet0/2 | `PC2` eth0 | `198.18.12.64/28` |
| **Payroll** | `hadz0024-R2` Ethernet0/1 | `SRV` eth0 | `198.18.12.96/28` |

### 📋 Layer 3 Addressing Specifications
* Routers automatically recive the first usable host ID within their configured subnets.
* Linux nodes adopt the last usable host ID within their configured subnets.
* Default gateways point directly to the local router interface boundaries.

---

## 🛠️ 2. Laboratory Security Policies & ACL Implementation

### 🔏 Checkpoint C01 — Policy #1: BLOCK-ACCOUNTING
* **Objective:** Stop all hosts inside the Accounting subnet from reaching the Payroll segment while allowing all other outside networks unhindered access.
* **Placement Strategy:** Applied **outbound** on **R2 interface `Ethernet0/1`**. Because standard Access Control Lists filter traffic solely on source parameters, placing this rule close to the destination prevents unintended access drops to intermediate networks.

```text
! Applied on hadz0024-R2
ip access-list standard BLOCK-ACCOUNTING
 deny 198.18.12.64 0.0.0.15
 permit any
!
interface Ethernet0/1
 ip access-group BLOCK-ACCOUNTING out
```

### 🔏 Checkpoint C02 — Policy #2: BLOCK-PC1
* **Objective:** Prevent the individual Engineering computer (`PC1`) from pushing traffic into the Accounting domain while keeping its routing paths active for outside zones.
* **Placement Strategy:** Applied **outbound** on **R1 interface `Ethernet0/2`**. This successfully drops PC1's packets right at the entry point of the Accounting segment gateway without dropping its path to the public internet/transit link.

```text
! Applied on hadz0024-R1
ip access-list standard BLOCK-PC1
 deny host 198.18.12.46
 permit any
!
interface Ethernet0/2
 ip access-group BLOCK-PC1 out
```

### 🔏 Checkpoint C03 — Policy #3: MGMT-R2
* **Objective:** Secure the local management plane of router R2 by ensuring only the explicit administrative host (`PC1`) can open remote VTY sessions.
* **Placement Strategy:** Bound **inbound** inside **R2's virtual line interfaces (`line vty 0 4`)** via the `access-class` command framework.

```text
! Applied on hadz0024-R2
ip access-list standard MGMT-R2
 permit host 198.18.12.46
 deny any
!
line vty 0 4
 access-class MGMT-R2 in
 transport input telnet ssh
```

---

## 🔬 3. Verification Metrics & Traffic Path Analysis

### 📊 Verification 1 — Data Plane Boundary Check (C01)
* **Pings Generated:** 4 packets from `PC2` (Accounting) to `SRV` (Payroll) resulted in **100% packet loss**. 4 packets from `PC1` (Engineering) to `SRV` successfully registered **0% packet loss**.
* **Router Telemetry:** `show ip access-lists BLOCK-ACCOUNTING` accurately captured exactly **4 deny matches** and **4 permit matches** corresponding to the test hosts.
* **Path Boundary Trace:** `traceroute` from PC2 successfully mapped hop 1 (`198.18.12.65` - R1) and hop 2 (`198.18.12.2` - R2) before printing an `!A` flag, confirming that R2 dropped the packet outbound.

### 📊 Verification 2 — Stateless Return Path Surprises (C02)
* **The Return Flow Catch:** While testing traffic paths, an interesting behavioral anomaly occurs where **PC2 cannot ping PC1**, even though the rule explicitly specifies blocking PC1. 
* **Mechanics:** Because standard ACLs are completely **stateless**, they do not maintain a connection state table. PC2's request passes safely to PC1, but PC1's returning response (ICMP Echo Reply) gets trapped and discarded outbound at R1's `Ethernet0/2` boundary interface, causing the counter to register **8 deny hits** total (4 requests from PC1, 4 replies from PC1).
* **Local Router Exception:** Pings initiated directly from R1's console terminal to PC2 succeed seamlessly. Locally generated engine traffic exits the router using the local port interface IP address (`198.18.12.65`) as its source identifier rather than PC1's host IP, safely matching the `permit any` statement.

### 📊 Verification 3 — Management Plane Isolation (C03)
* **Secure Shell Behavior:** Launching `ssh admin@198.18.12.2` from PC1 connects to the router successfully. Launching the exact same command string from PC2 yields an immediate `Connection refused` error message.
* **Terminal States:** Calling `show users` on R2 reveals an active line terminal mapping back to PC1's source IP:
  ```text
     Line       User       Host(s)              Idle       Location
  *  0 con 0                idle                 00:00:00   
     2 vty 0     admin      idle                 00:01:33   198.18.12.46
  ```
* **Console Port Safety:** The local router console port (`con 0`) remains entirely operational and immune to VTY access-list changes because it utilizes a dedicated physical asynchronous circuit layout that entirely bypasses virtual software-defined security profiles.

---

## 🏁 4. Core Laboratory Conclusions
1. **Placement Architecture:** Standard Access Control Lists inspect **only** the layer 3 source IP address. Because they are unable to differentiate target destinations, they must always be configured **as close to the destination network as possible** to avoid breaking routing behaviors to unintended domains.
2. **Stateless Limitations:** Cisco standard interface filters inspect every passing frame completely independently. When troubleshooting ACL layout architectures, the network operator must trace both the incoming forward request link and the reverse return path flow to maintain complete topology coherence.
