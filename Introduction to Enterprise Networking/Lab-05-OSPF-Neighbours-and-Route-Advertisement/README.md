# Lab 05 — OSPF Neighbours and Route Advertisement

## 📌 Project Overview
This project demonstrates a single-area **OSPFv2 (Open Shortest Path First)** dynamic routing deployment across a three-router topology consisting of **EDGE**, **CORE**, and **DIST** nodes using a physical **Cisco IOS-XE** lab infrastructure. 
The core objective of this deployment is to validate dynamic neighbor state synchronization, distinguish network medium behaviors, isolate control-plane/data-plane operation transitions, and introduce secure user-LAN distribution controls.

---

## 🗺️ Lab Topology & Addressing
The lab infrastructure uses an assigned sub-netting allocation parameter of **U = 12**.

*   **CORE–EDGE Link (Point-to-Point):** `10.12.12.0/29`
    *   `EDGE (Gi0/0/1): 10.12.12.1` | `CORE (Gi1/0/1): 10.12.12.2`
*   **EDGE–DIST Link (Multi-Access Broadcast):** `10.12.13.0/29`
    *   `EDGE (Gi0/0/2): 10.12.13.1` | `DIST (Gi0/0/1): 10.12.13.3`
*   **CORE–DIST Link (Point-to-Point):** `10.12.23.0/29`
    *   `CORE (Gi1/0/2): 10.12.23.2` | `DIST (Gi0/0/2): 10.12.23.3`
*   **User LAN Gateway (VLAN20):** `10.12.20.0/24` (Configured on CORE Switch)
*   **Server Loopback Interface (Loopback30):** `10.12.30.1/32` (Configured on DIST)

---

## 🛠️ Configuration Implementations

### 1. Stable Loopback Identity Configurations
Each node runs **OSPF Process 12** and locks down a stable, non-preemptive router identification address using a dedicated loopback interface.

```ios
! EDGE Router Configuration
interface Loopback100
 ip address 10.12.100.1 255.255.255.255
 ip ospf 12 area 0
!
router ospf 12
 router-id 10.12.100.1
```

### 2. Multi-Access and Point-to-Point Network Typing
To minimize link convergence latency overhead and drop unnecessary DR/BDR election states, dedicated transit segments are defined manually.
*   **Point-to-Point:** Explicitly skips multi-access link role designations (`FULL/-`).
*   **Broadcast:** Forces neighbor auto-discovery profiles and actively elects a Designated Router (DR) and Backup Designated Router (BDR) across shared segments (`FULL/DR` / `FULL/BDR`).

```ios
! Point-to-Point Optimization Example
interface GigabitEthernet0/0/1
 ip ospf 12 area 0
 ip ospf network point-to-point
```

### 3. Passive Interface Routing Controls
To align with secure infrastructure distribution policies, **VLAN20** on the **CORE** switch is declared passive. This introduces the gateway prefix boundaries into the link-state database without broadcasting cleartext OSPF hello packets over the student workstation host segments.

```ios
router ospf 12
 passive-interface vlan20
```

### 4. Dynamic Gateway Default Route Propagation
The **EDGE** router handles an upstream static default gateway hook and dynamically floods an external Type-5 LSA default entry downstream across Area 0 without utilizing risky overrides.

```ios
ip route 0.0.0.0 0.0.0.0 g0/0/0 203.0.113.254
router ospf 12
 default-information originate
```

---

## 🔍 Verification & Diagnostic Controls

*   `show ip ospf neighbor`: Validates state convergence bounds (`FULL/-` vs `FULL/BDR`).
*   `show ip ospf interface <int>`: Inspects active hello/dead parameters and operational roles.
*   `show ip route ospf`: Confirms successful route calculations (`O` internal and `O*E2` default injections).
*   `tracert -d`: Conducts host data-plane boundary path tracing tests.

![Lab Topology](l05-topology.png)
*This is the topology l05-topology.png*
