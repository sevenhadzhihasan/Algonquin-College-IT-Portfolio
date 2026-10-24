# Production Integration Test Plan Matrix
**System Target Handle:** `library_hadz0024`

This matrix documents the functional validation traced across all operational layers of the fully integrated PostgreSQL client program.

## 📋 Comprehensive Functional Assertion Matrix

### **Test case ID: TC-01**
*   **Test Purpose:** Verify initial database connection and user interface layout mapping.
*   **Test Data:** Launch program via `./library_hadz0024.py`
*   **Expected Result:** Pipeline successfully binds to the server cluster, outputs `"Database connection successful"`, and displays the core option menu layout.
*   **Actual Result:** **Pass.** Successfully initialized cursor handles and generated clean console menus.

### **Test case ID: TC-02**
*   **Test Purpose:** Validate lowercase quit input string and resource cleanup teardown.
*   **Test Data:** Input: `q`
*   **Expected Result:** Program exits the read loop, outputs cleanup notifications, and executes `cursor.close()` and `connection.close()` to drop open socket handles cleanly.
*   **Actual Result:** **Pass.** Execution dropped back out to the native Linux terminal prompt safely with zero resource leaks.

### **Test case ID: TC-03**
*   **Test Purpose:** Validate uppercase quit input string character normalization.
*   **Test Data:** Input: `Q`
*   **Expected Result:** Automatically normalizes the string to lowercase `'q'`, executes clean exit routines, and safely closes active server connection lines.
*   **Actual Result:** **Pass.** Successfully escaped the runtime loop context without any unhandled exceptions.

### **Test case ID: TC-04**
*   **Test Purpose:** Trap out-of-bounds menu selection entries.
*   **Test Data:** Input: `7` or Input: `28` (when prompted for a member phone at option 5 menu)
*   **Expected Result:** The user entry validation loop blocks out-of-bounds inputs, alerts an entry failure notification (`"Invalid choice"` or `"Member not in database."`), and safely re-prompts the user.
*   **Actual Result:** **Pass.** Prevented malformed out-of-bound variables from being transmitted to the database cluster.

### **Test case ID: TC-05**
*   **Test Purpose:** Trap alphabetic string values typed inside choice input blocks.
*   **Test Data:** Input: `show`
*   **Expected Result:** Input validation flags the bad data type, prevents queries from parsing text strings, outputs an error message, and retains focus for a valid entry.
*   **Actual Result:** **Pass.** Blocked bad choice commands immediately, protecting driver loops from crashing.

### **Test case ID: TC-06**
*   **Test Purpose:** Verify Option 1 query execution path behavior (Books sorted by Title).
*   **Test Data:** Option selection character: `1`
*   **Expected Result:** Runs `query_books()`. Relational join pulls live records across `book` and `book_copy`, outputting rows sequentially using a `fetchone()` loop ordered alphabetically by title.
*   **Actual Result:** **Pass.** Successfully listed book titles paired with their corresponding physical database copies.

### **Test case ID: TC-07**
*   **Test Purpose:** Verify Option 2 query execution path behavior (Members sorted by Name).
*   **Test Data:** Option selection character: `2`
*   **Expected Result:** Runs `query_members()`. Queries all member profiles, arranging user listings strictly by their last name first, then first name.
*   **Actual Result:** **Pass.** Returned organized data streams where Marge Simpson displays perfectly at the bottom based on her family name.

### **Test case ID: TC-08**
*   **Test Purpose:** Block empty/blank search field inputs from reaching target queries.
*   **Test Data:** Hit `[Enter Key]` without typing values when prompted for lookup arguments.
*   **Expected Result:** The form handler wrapper stops completely blank parameter strings, outputs `"Input field cannot be left blank."`, and loops back until data is typed.
*   **Actual Result:** **Pass.** Effectively prevented query errors by intercepting blank space parameters.

### **Test case ID: TC-09**
*   **Test Purpose:** Verify Option 3 query execution path behavior (List loans by member phone lookup).
*   **Test Data:** Option selection character: `3` then input phone: `6131222345`
*   **Expected Result:** Resolves the phone reference, tracks active open loan transactions (`return_date IS NULL`), and prints out matching entries alongside dynamic calendar due dates.
*   **Actual Result:** **Pass.** Cleanly extracted outstanding copies (e.g., *Murder on the Orient Express*) with exact timelines computed by the server.

### **Test case ID: TC-10**
*   **Test Purpose:** Verify Option 4 data manipulation transaction flow (Insert a valid Loan).
*   **Test Data:** Option selection character: `4` then phone: `6131013333` then Copy ID: `5`
*   **Expected Result:** Resolves member ID, verifies the copy exists and is currently unloaned, inserts a new loan entry using `CURRENT_DATE`, and commits changes to the database server.
*   **Actual Result:** **Pass.** Confirmed entry update; running option 3 verifies the new loan row is saved.

### **Test case ID: TC-11**
*   **Test Purpose:** Enforce asset availability to block multiple concurrent checkouts of a single book copy.
*   **Test Data:** Attempt to check out Copy ID: `1` while it is already flagged out on an unreturned loan row.
*   **Expected Result:** Database check flags that the copy is currently checked out, stops the query from running, and outputs `[Error] Book copy ID 1 is currently checked out on active loan.`
*   **Actual Result:** **Pass.** Safely blocked duplicate checkout attempts to maintain strict data tracking integrity.

### **Test case ID: TC-12**
*   **Test Purpose:** Verify Option 5 database update modification execution flow (Return a Loan).
*   **Test Data:** Option selection character: `5` then phone: `6131222345` then Loan ID: `28`
*   **Expected Result:** Pulls active user loans, locates the row matching ID 28, updates `return_date` to `CURRENT_DATE`, and commits changes. Submitting option 3 confirms the loan is cleared.
*   **Actual Result:** **Pass.** Loan transaction successfully finalized. Item marked as returned and copy status shifted back to available.
