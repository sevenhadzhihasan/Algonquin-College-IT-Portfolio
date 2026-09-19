# Lab 03 — IPv6 Neighbour Discovery Protocol (NDP) and SLAAC

![Lab 03 Topology Diagram](topology.jpg)

## Purpose
Observe and document how IPv6 hosts dynamically discover their local network infrastructure, construct Global Unicast Addresses (GUAs) using SLAAC, and use the Neighbour Discovery Protocol (NDP) to map Layer 3 addresses to Layer 2 MAC addresses.

## Deployment Method
* **Primary Assessment:** Executed on live physical hardware (Cisco ISR4331 EDGE Router and Alpine Linux VM) inside the Algonquin College in-person networking lab.
* **Pre-Lab Simulation:** Designed and verified using Cisco Packet Tracer to validate routing tables, SLAAC address scopes, and upstream static path navigation prior to physical deployment.

## Network Topology Context
* **EDGE Router Hostname:** `hadz0024-EDGE`
* **Local LAN Interface:** `GigabitEthernet0/0/1`
* **Local Network Prefix:** `2010:acad:12:aa::/64` (Pod 12)
* **EDGE Gateway Link-Local Address:** `fe80::12`
* **EDGE Gateway Global Address:** `2010:acad:12:aa::12`
* **Alpine VM Target MAC Address:** `02:00:00:00:12:09`

## Core Concepts Verified
1. **Stateless Address Autoconfiguration (SLAAC):** Traced the lifecycle from initial host Link-Local creation up to GUA assignment driven by Router Advertisements (RAs).
2. **Neighbour Unreachability Detection (NUD):** Monitored real-time neighbor cache state movements using active ICMPv6 debugging tools.
3. **Duplicate Address Detection (DAD):** Verified how the operating system kernel blocks a duplicate IP address assignment to maintain structural link safety.

## Configuration & Logs Summary
* **l03-c01-hadz0024.txt:** Applied the boilerplate automation script and configured the local RA source interface manually.
* **l03-c02-hadz0024.txt:** Monitored the initial Router Solicitation (RS) and subsequent Router Advertisement (RA) exchange logs.
* **l03-c03-hadz0024.txt:** Traced active NS/NA resolution loops and verified the resulting `REACHABLE` neighbor tracking status.
* **l03-c04-hadz0024.txt:** Intentionally forced an address collision state to verify functional kernel DAD protection.
* **l03-c05-hadz0024.txt:** Compiled final end-to-end off-link connectivity proofs using the automated execution manifest engine.
