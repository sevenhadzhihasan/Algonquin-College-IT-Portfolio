# CST8206 – Foundation of IT Service Management
## Assignment #2: IT Service Transition & Redundancy Plan
**Course:** CST8206 - Foundation of IT Service Management  
**Case Study:** TrueNorth Airline (Strategic Initiative Plan)  
**Submission Type:** Individual Assignment Submission  

---

## Part A: Project Improvement Opportunity Summary

### Selected Initiative Name
* **Initiative #8:** Implement redundancy to critical applications and systems to mitigate a risk of failure.

### Project Description and Summary
This project designs and deploys a high-availability, geographically redundant infrastructure framework for TrueNorth Airline’s mission-critical operational systems, specifically focusing on the Flight Scheduling and Passenger Check-In applications. The IT project team will establish a secondary hot-standby cloud data center environment, configure real-time database replication pipelines, deploy automated global server load balancers (GSLB), and implement rapid failover orchestration playbooks. By eliminating single points of failure, IT provides a modern technical foundation that ensures continuous 24/7 service availability, protecting the airline against critical localized data center downtime.

### Project Value to the Organization / Department
While engineered and maintained by the IT department, the operational value directly supports the **Flight Operations and Customer Service Departments**:
* **Value to the Department:** This technology eliminates systemic system downtime for terminal staff and flight dispatchers. It allows airport personnel to process passenger check-ins and coordinate flight logs smoothly without relying on emergency manual gate paperwork.
* **Value to the Organization:** This project directly supports TrueNorth Airline's corporate strategic plan. It enables the company to meet its high-level executive strategic goals of improving operational reliability by 5% and boosting customer experience and loyalty by 15%. Furthermore, it protects financial sustainability by mitigating domino-effect flight delays, terminal congestion penalties, and passenger compensation payouts.

### Project Scope Boundaries

#### In-Scope
* Provisioning a secondary, high-availability cloud database hosting node in a distinct geographical region.
* Configuring secure, encrypted virtual private network (VPN) tunnels between active data center endpoints.
* Writing and compiling automated data-streaming synchronization scripts for log-shipping data security.
* Purchasing and configuring corporate Global Server Load Balancer (GSLB) traffic redirection network switch paths.
* Building step-by-step IT Service Desk event notification guidelines and disaster recovery runbooks.
* Executing structured, controlled User Acceptance Testing (UAT) failover drills with Operations teams.

#### Out-of-Scope
* Rewriting or modifying the base source code of legacy flight scheduling software logic.
* Upgrading or swapping physical employee desktop monitor hardware terminals across airport hubs.
* Negotiating or managing external commercial vendor repair contracts for airport terminal baggage conveyor machinery.

---

## Part B: Partial Project Plan

| # | Deliverable/Activity Name | Level of Effort (Days) | Start Date | End Date | Dependencies |
| :--- | :--- | :--- | :--- | :--- | :--- |
| **1.0** | **Redundant Cloud Infrastructure Provisioning** | | | | |
| **1.1** | Conduct architecture review of current single-point failures | 3 | 2026-12-07 | 2026-12-09 | |
| **1.2** | Sourcing and provisioning of secondary hot-standby cloud host environments | 5 | 2026-12-10 | 2026-12-14 | |
| **1.3** | Configure secure virtual private network tunnels between sites | 4 | 2026-12-15 | 2026-12-18 | Dependent on 1.2 |
| **1.4** | Establish IAM access structures and administrative boundary permissions | 2 | 2026-12-21 | 2026-12-22 | |
| **1.5** | Execute data baseline security compliance and encryption audits | 1 | 2026-12-23 | 2026-12-23 | Dependent on 1.3 |
| **2.0** | **Database Replication & Sync Script Setup** | | | | |
| **2.1** | Initialize empty target schema instances on secondary node | 2 | 2026-12-24 | 2026-12-25 | |
| **2.2** | Map active transactional tables within Flight Scheduling software | 6 | 2026-12-28 | 2027-01-02 | |
| **2.3** | Write custom data-streaming synchronization scripts | 7 | 2027-01-04 | 2027-01-10 | Dependent on 2.2 |
| **2.4** | Configure continuous log-shipping processes to prevent data drops | 2 | 2027-01-11 | 2027-01-12 | |
| **2.5** | Execute initial full-volume baseline database synchronization | 3 | 2027-01-13 | 2027-01-15 | |
| **3.0** | **Load Balancing & Network Redirection Configurations** | | | | |
| **3.1** | Purchase corporate Global Server Load Balancer (GSLB) licenses | 8 | 2027-01-18 | 2027-01-25 | |
| **3.2** | Script custom automated heartbeat health checks for primary applications | 3 | 2027-01-26 | 2027-01-28 | |
| **3.3** | Deploy network redirection rules on active corporate firewall switches | 2 | 2027-01-29 | 2027-01-30 | Dependent on 3.2 |
| **3.4** | Configure external DNS TTL records for rapid internet rerouting | 2 | 2027-02-01 | 2027-02-02 | |
| **3.5** | Validate network route traffic optimization profiles from outstation hubs | 1 | 2027-02-03 | 2027-02-03 | Dependent on 3.1 |
| **4.0** | **Failover Simulation Testing & Validation** | | | | |
| **4.1** | Execute simulated primary application crashes in sandbox environments | 4 | 2027-02-04 | 2027-02-07 | Dependent on 2.3 |
| **4.2** | Perform data transactional integrity checks post-failover | 2 | 2027-02-08 | 2027-02-09 | |
| **4.3** | Conduct full User Acceptance Testing failover drills with Operations | 5 | 2027-02-10 | 2027-02-14 | |
| **4.4** | Resolve network route timeout parameters and patch API lags | 3 | 2027-02-15 | 2027-02-17 | |
| **4.5** | Publish internal IT Service Desk event notification guidelines | 1 | 2027-02-18 | 2027-02-18 | Dependent on 4.1 |

---

## Part C: Risk/Issue Mitigation Register

| Risk Name/Description | Impact (High, Med, Low) | Likelihood of Occurrence (High, Medium, Low) | Mitigation (Risk) | The Risk Occurred (Issue) |
| :--- | :--- | :--- | :--- | :--- |
| **Data Synchronization Lag:** Network transit latency over wide area network (WAN) links slows replication speeds between database nodes. | High | Medium | Deploy dedicated point-to-point high-speed fiber routes and configure full copy compressed database data packet distributions. | Configure temporary transactional data holding buffers on localized check-in terminal endpoints until WAN bandwidth stabilizes. |
| **Legacy Integration Schema Blockage:** Outdated airport check-in kiosk terminals fail to parse or route through the new modern GSLB path protocols. | High | High | Conduct a full firmware compatibility scan on physical peripheral endpoints across all global transit hubs prior to live deployment. | Roll back the global DNS router redirection map instantly, and push out a customized client configuration patch directly to the older local terminals. |
| **Vendor Cloud Resource Constraints:** Selected regional public cloud partner experiences infrastructure scaling or physical capacity provisioning bottlenecks. | Medium | Medium | Secure early guaranteed capacity reservations via pre-paid compute commitment infrastructure policies with primary suppliers. | Pivot infrastructure orchestration deployment scripts instantly to spin up backup environments in an alternate, pre-approved cloud vendor region. |
| **IT Staff Execution Deviation:** Infrastructure support personnel misinterpret or misapply complex sequential orchestration runbooks during a high-pressure crisis. | Medium | Medium | Conduct structured, mandatory step-by-step documentation reviews and routine table-top simulation walkthrough exercises across all shifts. | Delegate authority controls to senior engineers on-call and initiate pre-recorded automated recovery scripts via the centralized control console. |
| **Concurrently Scheduled Core Upgrades:** Central airline enterprise network group schedules unrelated router maintenance during critical failover test windows. | Low | Low | Log all scheduled project iterations inside the central corporate IT Change Advisory Board (CAB) master database 4 weeks ahead. | Pause active traffic testing patterns instantly, isolate the staging environment, and defer validation tasks until enterprise maintenance completes. |

---

## Part D: Partial Cost Sheet

| Resource # | Resource Name | Resource Type | Cost Allocation | Cost Model / Justification |
| :--- | :--- | :--- | :--- | :--- |
| **1** | Redundant Cloud Infrastructure Hosting Node | Software/Cloud | \$24,000.00 | Dedicated server hosting infrastructure slice within a Canadian regional hot-standby cloud. |
| **2** | Enterprise Global Server Load Balancer License | Software/Network | \$14,500.00 | Annual enterprise tool subscription fee for automated active traffic load mapping. |
| **3** | Principal High-Availability Cloud Architect | Human Resource | \$16,800.00 | 14 business days of expert consultant design time billed at a standard rate of \$1,200/day. |
| **4** | Senior Network Routing Engineer | Human Resource | \$7,200.00 | 8 business days of specialized regional networking configuration setup metrics at \$900/day. |
| **5** | Redundant Core Network Fiber Channel Layout | Infrastructure | \$5,100.00 | Flat-rate point-to-point commercial pipeline installation fee from independent telecom carriers. |
| **6** | Failover Script Orchestration Automation Suite | Software/Tools | \$3,200.00 | Internal script orchestration suite licensing package for terminal synchronization tracking. |
| **7** | IT Service Desk Performance Monitoring Upgrades | Software/APM | \$2,800.00 | Live health diagnostics reporting terminal endpoint monitoring agent tool seat licenses. |
