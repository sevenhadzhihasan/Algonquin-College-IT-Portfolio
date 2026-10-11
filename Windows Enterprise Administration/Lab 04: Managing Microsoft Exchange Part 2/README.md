## ⚙️ Lab 04: Managing Microsoft Exchange Part 2

This section focuses on the manual configuration of granular database storage limits, custom notification intervals, and specific administrative mailbox overrides for user accounts using both the **Exchange Admin Center (EAC/ECP)** and the **Exchange Management Shell (PowerShell)**.

---

### 📂 Configuration Breakdown & Verification Checkpoints

#### 🛠️ Section 1: Staff Database Provisioning & Policies
A dedicated database was initialized to house organizational staff mailboxes with custom storage and item retention guards.

*   **Database Specifications:**
    *   **Name:** `Staff`
    *   **EDB Database Path:** `C:\DDrive\databases\Staff.edb`
    *   **Log Folder Path:** `C:\EDrive\logs\`
*   **Database Storage Quotas:**
    *   **Issue Warning Threshold:** 10 GB
    *   **Prohibit Send Threshold:** 12 GB
    *   **Prohibit Send/Receive Threshold:** 14 GB
*   **Warning Notification Interval Setup:**
    *   Configured specific 15-minute generation blocks at **9:00 AM**, **1:00 PM**, and **3:00 PM** to manage resource notification frequencies dynamically.
*   **Data Retention & Safeguard Matrix:**
    *   **Deleted Item Retention:** 30 days
    *   **Deleted Mailbox Retention:** 60 days
    *   **Backup Guard:** Enabled constraint preventing permanent deletions from being flushed out until a database backup operation has run successfully.

---

#### 👤 Section 2: Targeted User Account Overrides (Richard Hagemeyer)
The user mailbox for **Richard Hagemeyer** was provisioned inside the target **ExchUsers** Organizational Unit and configured with precise individual service level policy overrides.

#### **Mailbox Architecture Matrix**
*   **Account Settings:** First name `Richard`, Last Name `Hagemeyer`, Login Identity `RichardH`, Primary Email `rh@dm89069.cst8342.com`.
*   **Database Target:** Hosted directly on the newly created **Staff** database.
*   **On-Premises Archiving:** Active and explicitly targeted onto the **Staff** database volume.

#### **Contact Tracking Metadata**
*   **Profile Parameter:** Updated the account's structural **Street Address** attribute to feature active tracking footprint strings containing unique identification credentials: `[hadz0024]`.

#### **Client Protocol Access Control Lists**
*   **Security Actions:** Explicitly disabled inbound client message collection access layers over **POP3** and **IMAP4** for this specific account, securing transport boundaries to modern web-based (OWA) and native MAPI connection parameters.

#### **Temporal Retention Hold Deployment**
*   **Action:** Bypassed layout limitations inside the ECP dashboard by run an administrative prompt block inside the **Exchange Management Shell** to lock mailbox parameters under an explicit 1 week data preservation hold while the user is away on holiday:
    ```powershell
    Set-Mailbox "RichardH" -RetentionHoldEnabled $true -EndDate ((Get-Date).AddDays(7))
    ```

#### **Granular Storage Quotas & Maximum Message Sizes**
*   **Storage Rule Overrides:** Customized the configuration to override default container database options with expanded capacity allocations:
    *   **Issue Warning:** 15 GB
    *   **Prohibit Send:** 20 GB
    *   **Prohibit Send/Receive:** 25 GB
    *   **Custom Archive Quota Limit:** 100 GB
*   **Transport Size Restrictions:** Modified Maximum Sent and Maximum Received tracking values to a ceiling threshold of exactly **10 MB** (`10240` KB).

#### **Mail Routing Redirection**
*   **Action:** Enabled email flow redirection rules to manage delivery routing profiles. Inbound communications are simultaneously routed to the user's primary mailbox and cloned to the host student tracking account mailbox with active verification flags confirming full automation metrics:
    ```powershell
    Set-Mailbox "RichardH" -ForwardingAddress "hadz0024@dm89069.cst8342.com" -DeliverToMailboxAndForward \$true
    ```

    
