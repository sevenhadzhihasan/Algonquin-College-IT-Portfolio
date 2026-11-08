# Lab 05: Azure VMs, Container Instances, and Virtual Networks

## Course Information
* **Course Code:** CST8342
* **Academic Portfolio:** Windows Enterprise Administration
* **Institution:** Algonquin College

## Objective
The objective of this lab is to explore cloud provisioning and foundational networking practices using Microsoft Azure. The exercise covers creating and connecting to a Windows Server virtual machine, hosting a functional Internet Information Services (IIS) web server, deploying a lightweight Linux container via Azure Container Instances (ACI), and inter-VM communications across an isolated Azure Virtual Network (VNet) using custom firewall configurations.

---

## Exercise 01: Create and Configure a Virtual Machine in the Azure Portal
Provisioned an advanced virtual machine instance running Windows Server 2025 Datacenter inside the Canada Central geographical zone, established secure remote configurations, and deployed a live public web root.

### Infrastructure Configuration Details
* **Resource Group:** `myRGVM_hadz0024`
* **Virtual Machine Name:** `myVm-hadz0024`
* **Region:** `Canada Central` (Zone 1)
* **Image Baseline:** Windows (Windows Server 2025 Datacenter) - Gen2 (V2)
* **Compute Size:** Standard_E2s_v3 (2 vcpus, 16 text GiB memory)
* **Administrative User:** `Azureuser-hadz0024`
* **Public IP Address:** `4.248.144.144`
* **Virtual Network/Subnet:** `vnet-canadacentral-1/snet-canadacentral-1`
* **Inbound Access Control:** RDP (3389), HTTP (80)
* **Monitoring:** Boot Diagnostics Disabled

### Feature Deployment & Post-Installation Verification
1. Established an active Remote Desktop Protocol (RDP) handshake with the virtual instance.
2. Initialized an elevated administrative Windows PowerShell environment within the system host.
3. Executed the server feature provisioning workflow to enable Internet Information Services (IIS):
   ```powershell
   Install-WindowsFeature -name Web-Server -IncludeManagementTools
   ```
4. Verified deployment by mapping connection requests from an external web browser to the public IP address `4.248.144.144` hosted by the cloud resource.

---

## Exercise 02: Deploy Azure Container Instances (ACI)
Configured and deployed a lightweight Docker container instance using standard pre-built software images. This section establishes highly available public endpoints without the operational overhead of a complete virtual machine operating system stack.

### Container Configuration Details
* **Resource Group:** `myRGContainer_hadz0024`
* **Container Architecture Name:** `mycontainer-hadz0024`
* **Region:** `Canada Central`
* **SKU / OS Type:** Standard / Linux
* **Image Repository:** Docker Hub Public Registry
* **Source Path:** `://microsoft.com` (Linux Architecture)
* **IP Address (Public):** `20.151.24.163`
* **Custom FQDN Assignment:** `mycontainerdnshadz0024.bna2fxdfdna6fmeb.canadacentral.azurecontainer.io`

### Verification
The container deployment successfully reached a `Running` status. Network connectivity was verified by navigating to the assigned Fully Qualified Domain Name (FQDN) in a standard web browser to render the public static container landing application page.

---

## Exercise 03: Create an Isolated Virtual Network & Coordinate Inter-VM Routing
Designed and deployed a structural Azure Virtual Network (VNet) topology with custom IP segmentation to manage internal compute dependencies, verifying secure internal routing rules using ICMP packets.

### VNet Infrastructure Layout
* **Resource Group:** `myRGVNet-hadz0024`
* **Virtual Network Name:** `vnet1`
* **Primary IP Routing Space:** `10.1.0.0/16`
* **Subnet Structure Name:** `default`
* **Subnet Allocations:** `10.1.0.0/24`

### Hosted Compute Nodes
Two concurrent virtual machine instances were added into the private subnet infrastructure:
1. **Node 01:** `vm1` (Assigned into `vnet1`, inbound RDP port 3389 allowed)
2. **Node 02:** `vm2` (Assigned into `vnet1`, bound to public IP mapping `vm2-ip`)

### Traffic Engineering and Diagnostic Testing
1. Initiated a remote administration session on `vm1` and targeted `vm2` with an ICMP network probe (`ping vm2`). The baseline request timed out as expected due to standard Windows Defender stateful firewall parameters.
2. Initiated a parallel session to `vm2` and executed an explicit local override security rule via PowerShell to permit inbound testing requests:
   ```powershell
   New-NetFirewallRule –DisplayName “Allow ICMPv4-In” –Protocol ICMPv4
   ```
3. Returned to the console on `vm1` and re-executed the network diagnostics. The targeted compute nodes successfully achieved intra-network communication with immediate response packets.

---
