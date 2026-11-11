# Lab 07: Azure Governance, RBAC, Resource Locks, and Tagging

## Overview
Microsoft Azure governance and compliance mechanisms. By configuring Role-Based Access Control (RBAC), Resource Locks, and Azure Policy tagging rules, administrators can enforce the Principle of Least Privilege, protect critical infrastructure from accidental deletion, and standardize resource organization across a subscription.

## Objectives
* Configure and validate **Role-Based Access Control (RBAC)** permissions at the resource group scope.
* Implement **Resource Locks** to test lock inheritance and prevent unauthorized or accidental resource deletion.
* Enforce metadata compliance using **Azure Policy** to require specific resource tags prior to deployment.
* Filter and audit deployed resources using **Azure Tags** and properly deprovision lab environments to prevent unnecessary cloud costs.

---

## Lab Walkthrough & Key Takeaways

### 1. Manage Access with RBAC
* **Configuration:** Assigned the built-in **Reader** role to a test user account on a dedicated resource group (`myRGRBAC`) via **Access control (IAM)**.
* **Validation:** Verified that the test user could view resources within the scope but was blocked from modifying settings (e.g., changing a storage account's access tier), enforcing the *Principle of Least Privilege*.
* **Evidence:** `Lab07-05` *(Access denied / unauthorized error upon attempting a write operation)*.

### 2. Implement Resource Locks & Inheritance
* **Configuration:** Created a `Delete` lock (`RGLock`) at the parent resource group level (`myRGLocks`) and deployed a general-purpose v2 storage account (`StorageV2`, `LRS`) inside it.
* **Validation:** Attempted to delete the child storage account directly. Azure blocked the action because **locks are inherited** by all child resources within a locked resource group.
* **Cleanup:** Removed the resource group lock under **Settings > Locks** to restore deletion capabilities.
* **Evidence:** `Lab07-03` *(Error message confirming deletion was blocked by a parent delete lock)*.

### 3. Enforce Resource Tagging with Azure Policy
* **Configuration:** Assigned the **Require a tag on resources** policy at the subscription scope with the mandatory key set to `Company`.
* **Validation:**
  * Attempted to deploy a storage account without tags, which failed Azure pre-validation with a policy disallowance error.
  * Added the required tag (`Company: Contoso`), passed validation, and deployed the storage account.
  * Used the **All resources** filter (`Company: Contoso`) to isolate and audit compliant resources.
* **Evidence:** `Lab07-04` *(Filtered All resources view displaying only the compliant tagged storage account)*.

### 4. Environment Deprovisioning
* Deleted the policy assignment (`Require a tag on resources`) to prevent interference with future deployments.
* Removed all lab resource groups (`myRGRBAC`, `myRGLocks`, `myRGTags`) and verified via **Resource groups** and **All resources** that zero active billable resources remained in the subscription.

---

## Technologies & Services Used
* **Microsoft Azure Portal**
* **Azure Active Directory / Microsoft Entra ID (RBAC)**
* **Azure Resource Manager (Resource Locks & Tags)**
* **Azure Policy**
* **Azure Storage Accounts**
