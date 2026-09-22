# Lab 02 — IPv6 Address Scope and Network Identity

## Technical Summary
This lab analyzes IPv6 address scopes and demonstrates the enforcement of administrative routing-policy boundaries on Cisco routing systems. The lab environment simulates internal enterprise networks (ULA space) and routes them securely against a globally routable public transit core (GUA space) using Cisco Packet Tracer.

---

## 🌐 Address Scope Classification

* **Link-Local Addresses (LLA) [`fe80::/10`]:** Scoped strictly to the immediate local link layer for neighbor discovery and next-hop handling.
* **Unique Local Addresses (ULA) [`fd00::/8`]:** Applied to private enterprise networks (Sites A, B, and C) to simulate internal site assets.
* **Global Unicast Addresses (GUA) [`2010::/64`]:** Utilized for public transit networks, Site D, and the External Server infrastructure.

---

## ⚙️ Policy Implementation
Instead of relying on access control lists (ACLs), this lab achieves network segregation strictly via routing-policy constraints:

1. **R1** is kept completely isolated from the internet core by intentionally omitting default routes (`::/0`) or external networks from its routing tables.
2. **R2** (the core transit engine) deliberately excludes all internal enterprise ULA prefixes (`fd00::/8`), isolating cross-site communication.
3. **Symmetrical fully specified static routes** were designed and deployed across the transit core strictly to map bidirectional traffic between Site D and the External Server.

---

## 📊 Verification Matrix Summary

| Connection Vector | Intended Policy Scope | State Result | Analytical Behavior |
| :--- | :--- | :--- | :--- |
| **Site A ↔ Site B** | ULA Link | **SUCCEED** | Internal enterprise segments share data locally across R1. |
| **Site D ↔ External Server** | GUA Static Link | **SUCCEED** | Core static routes transfer traffic successfully. |
| **Site A ↔ Site C** | Inter-Site Isolation | ❌ **BLOCKED** | Traffic dropped at core because ULA routes are withheld. |
| **Site A ↔ External Server** | Core Boundary | 🔒 **BLOCKED** | Traffic dropped by edge router due to absence of an external route. |

---

## 📁 Deliverables Inside This Directory

```text
Lab-02-IPv6-Address-Scope/
├── README.md                      # Comprehensive lab overview and verification matrix
├── Screenshot 2026-09-15 120945.png # Packet Tracer topology verification capture
├── l02-hadz0024.txt               # Active terminal logs (show ipv6 interface brief / pings)
└── a02-hadz0024.txt               # Granular configuration audit and Cisco IOS remediation steps
```
