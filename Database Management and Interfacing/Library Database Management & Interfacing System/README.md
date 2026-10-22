# Library Database Management & Interfacing System
**Course Portfolio Project** — Database Management and Interfacing

## 📋 Project Overview
This project delivers a multi-phase command-line interface (CLI) application integrated with a relational PostgreSQL database. Built for a local library client, the program enables administrators to handle day-to-day operations, search records, track physical book copy allocations, and manage user lending transactions.

All aspects of this project follow strict structural guidelines under the standardized project identifier string: **`library_hadz0024`**.

---

## 🛠️ Project Phases & Milestones

### 🔹 Milestone #1: Program Design & Core Skeleton (Current Status)
* **Goal:** Architect core interface application loops, implement structured functional modularity, and implement user parameter parsing validation.
* **Deliverables:** 
  * `library_hadz0024.py` — Complete Python CLI menu driver engine adhering to rigid non-recursive read-loop requirements.
  * `TEST_PLAN.md` — Formal 12-point functional verification testing criteria logging execution routes and input constraint boundaries.

### 🔹 Milestone #2: Database Schema & Relational Implementation (Upcoming)
* **Goal:** Convert logical Entity-Relationship Diagrams (ERDs) into physical relational structures inside PostgreSQL.
* **Deliverables:** Structured database schema creation scrips, automated constraint logic configuration, and relational sample mock datasets loading.

### 🔹 Milestone #3: System Integration & Verification Testing (Upcoming)
* **Goal:** Interface Python script modules natively with active database tables utilizing the `psycopg2` driver.
* **Deliverables:** Live production CRUD transactions execution, dynamic query formatting layout generators, and completed test plan assertions.

---

## 🖥️ System Interface Menu Functions
The core runtime environment processes the following system tracking events directly through user input options:
1. **Display all books:** Renders active catalog listings structured sequentially by text titles.
2. **Display all members:** Renders full library account registers sorted alphabetically.
3. **List all current book loans by a member:** Performs indexed lookups to locate unreturned loans.
4. **Insert a book loan:** Stages user criteria parameters to construct historical transaction records.
5. **Update a book loan return date:** Commits instant current timestamps to close open lending loops.

---

## 🚀 Execution & Verification Tests
To run and test the interface loop locally within a Linux/VMware shell environment without requiring active database endpoints, run the script directly using standard Python:

```bash
python3 library_hadz0024.py
```

### Constraint Handling Verification Highlights:
* **Empty Argument Interception:** Rejects blank values on lookup keys instantly by displaying: `Input field cannot be left blank.`
* **Index Boundary Filtering:** Traps choices outside bounds safely by outputting: `Invalid choice. Please select 1, 2, 3, 4, 5, or Q.`
* **Resource Safety Closures:** Leverages structural error wrappers to close tracking contexts cleanly upon quitting with option `q`.
