# Lab 02: Deploy and Manage Software Using Group Policies
**Course:** CST8342 010,012 Windows Enterprise Administration.
**Platform:** Windows Server 2022 Standard (Virtual Environment).

## Lab Objectives
1. Implement directory-wide application provisioning using Group Policy Objects (GPOs).
2. Configure **Assigned** (mandatory, install-on-demand) software deployments.
3. Configure **Published** (optional, network advertisement) software deployments.
4. Manage application lifecycles through mandatory and optional version upgrades.
5. Execute emergency package removal protocols targeting multi-tier Organizational Units (OUs).

---

## Environment Baseline Configuration

### 1. Active Directory OU & User Infrastructure
The directory hierarchy was structured sequentially directly under the root domain (`://dm89069`).
Standard service constraints were applied to prevent account modification and password expiration.

* **ITS (Top-Level OU)**
  * `ITSAdmin` (ITS Admin Profile)
  * **CustSupport (Sub-OU)** `CSUser`
  * **Development (Sub-OU)** `DevUser`
  * **HelpDesk (Sub-OU)** `HDUser`

### 2. User Rights Assignment Overrides
By default, Windows Server restricts standard accounts from console interactive logons. Security controls were modified within the **Default Domain Controllers Policy** under the following execution path 
`Computer Configuration` `Policies` `Windows Settings` `Security Settings` `Local Policies` `User Rights Assignment` **Allow log on locally**
* **Authorized Access Control List:** `Administrators`, `Server Operators`, `Print Operators`, `Backup Operators`, `Account Operators`, and `DM89069\Domain Users`.

---

## Step-by-Step Implementation Guide

### Phase 1: Creating the Network Share Folder
1. Formatted local disk directory path to absolute path: `C:\Packages`.
2. Extracted `.msi` system validation deployment packages (`Green.msi`, `Red.msi`, `Blue.msi`, `Cosmo1.msi`, `Cosmo2.msi`).
3. Enabled network sharing under the UNC path convention: `\\Server89069\Packages`.
4. Set Advanced Share Permissions to **Everyone: Read**.

### Phase 2: Deploying Assigned Applications (Mandatory)
1. Created a new GPO named `Green Application Policy` linked to the top-level **ITS OU**
2. Configured the package source using the shared network UNC path `\\Server89069\Packages\COLORFUL\VER1\Green.msi`.
3. Set the deployment status mode to **Assigned**
4. Linked individual `Red Application Policy` and `Blue Application Policy` GPOs directly to the **HelpDesk OU** and assigned their corresponding packages.
5. Verified client-side execution via **CSUser** and **HDUser** environments to confirm automated install-on-demand behavior.

### Phase 3: Deploying Published Applications (Optional)
1. Built a new GPO named `Cosmo Application Policy` linked directly to the parent **ITS OU**
2. Added the package tracking source path pointing to `\\Server89069\Packages\COSMO1\Cosmo1.msi`.
3. Configured the deployment state properties parameter to **Published** [Scenario].
4. Validated file extension activation behavior by running a document invocation test against the `.CS00` database file, forcing an automated background install.

### Phase 4: Application Version Upgrades & Maintenance
1. **Optional Upgrade Testing:** Linked a `Cosmo Optional Upgrade Policy` to the **CustSupport OU** mapping back to the older version path.
2. Kept the *Required upgrade* checkbox cleared to permit test validation loops [Scenario].
3. **Mandatory Rollout:** Updated the root `Cosmo Application Policy` at the **ITS OU** layer to push `Cosmo2.msi'.
4. Enabled the configuration constraint **"Required upgrade for existing packages"** to forcefully sunset old versions automatically.

### Phase 5: Emergency Software Revocation
1. Initiated a mandatory software deletion pipeline targeting **Cosmo2** by using the selection tool parameter: **Immediately uninstall the software from users and computers**
2. Applied a soft lockout on the **Green** application package using: **Allow users to continue to use the software, but prevent new installations**

---

## Automated Software Removal Configurations

To address critical security advisories or application end-of-life cycles, two primary termination methods were utilized inside the GPO Editor via `All Tasks` `Remove`.

| Removal Policy Method | Visual Environment Result | Operational Impact |
| :--- | :--- | :--- |
| **Immediately uninstall the software** | Package metadata is purged cleanly from the GPO window list. | Clears the software layout from all endpoints upon next background policy refresh loop. |
| **Allow users to continue to use...** | The item remains visible in the console with a **Red X** visual indicator badge overlay. | Lockout parameters prevent any new users from pulling down the deployment package while existing users remain completely unaffected. |
