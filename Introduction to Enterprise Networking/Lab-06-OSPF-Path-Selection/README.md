# Lab 06 — OSPF Path Selection and Multi-Access Segment Operations

![Lab 06 OSPF Network Topology Map](l06-topology.png)

## 📌 Project Overview
This repository contains the engineering evidence logs and automated collection topologies for **Lab 06 (OSPF Dynamic Routing Protocols)**. 
The core objective of this deployment was to isolate link cost parameters, evaluate multi-access non-preemptive election mechanics, enforce edge default route propagation, and configure Equal-Cost Multi-Path (ECMP) convergence across multi-layered transit backbones.

All configurations were engineered utilizing student magic number constraint **`U = 12`** under the account profile **`hadz0024`**.

---

## 🛠️ Network Engineering Architecture & Deliverables
The infrastructure layer is split into 4 core routers managing localized link-state topologies:
*   **hadz0024-EDGE:** Aggregates transit endpoints and runs autonomous static boundary metrics to originate default paths (`0.0.0.0/0`) down the enterprise tree.
*   **hadz0024-CORE:** Manages core dynamic backbones, orchestrating transit loops across the internal networks.
*   **hadz0024-DIST:** Operates secondary fallback pathways and acts as a localized anchor point for multi-access segment redundancy.
*   **hadz0024-ACCESS:** Enforces loop-free edge perimeter defense by operating a passive user LAN gateway (`Ethernet0/3`) to suppress hazardous multi-cast dynamic hello overhead.

---

## 📋 Lab Cost Metrics & Calculation Parameters

### 1. Default Baseline State (Reference Bandwidth = 100 Mbps)
By default, OSPF sets its scaling calculation reference target to 100 Mbps. Because all infrastructure adapters operate on 1 Gbps physical fiber connections, the metric math drops below 1 and rounds up to a generic cost floor:

\[\text{Cost} = \frac{100 \text{ Mbps}}{1,000 \text{ Mbps}} = 0.1 \rightarrow \textbf{1 (Generic Floor)}\]

*   **CORE Routing Matrix Result:** Path cost selection chooses the shortest physical line to reach the loopback targets with a cumulative metric of **`2`**.

### 2. Scaled Standardized State (Reference Bandwidth = 10,000 Mbps)
To allow OSPF to differentiate path performance accurately across higher-speed multi-gigabit connections, the dynamic metric ceiling was adjusted to 10,000 Mbps:

\[\text{Cost} = \frac{10,000 \text{ Mbps}}{1,000 \text{ Mbps}} = \textbf{10 (Precision Metric)}\]

*   **CORE Routing Matrix Result:** Transit link values scale directly to a cost of **`10`**, adjusting the primary optimized loopback pathway metric total to **`11`** (Transit Cost 10 + Loopback Cost 1).

---

## 🔬 Protocol Diagnostics & Verification Signatures
*   **Non-Preemptive Segment Elections:** Verified that raising priority to `200` on an active broadcast switch does not evict a running senior incumbent router.
*   **Priority 0 Ineligibility:** Enforced state constraints proving that a priority value of `0` permanently prevents a router node from claiming DR or BDR roles during failover events.
*   **Equal-Cost Multi-Path (ECMP) Injection:** Artificially altered core costs to `20` to equalize pathways, forcing the CEF engine to load-balance traffic streams concurrently across multiple next-hops.

---

## 📁 Repository Deliverables Checklist
This workspace folder contains exactly 5 production logging files captured from the live lab runtime environment:
1.  `l06-c01-hadz0024.txt` — Mixed process migrations and standardized best-practice captures.
2.  `l06-c02-hadz0024.txt` — Segment seniority election steps and point-to-point interface rules.
3.  `l06-c03-hadz0024.txt` — Reference bandwidth modifications and auto-cost metric shifts.
4.  `l06-c04-hadz0024.txt` — ECMP path control overrides, interface failures, and recovery logs.
5.  `l06-xremote-hadz0024.txt` — Automated diagnostic output snapshot harvested via the Paramiko script engine.
