# Library Database Management & Interfacing System
**Course Portfolio Project — Database Management and Interfacing**  
**Standardized System Identifier:** `library_hadz0024`

## 📋 Project Overview
This project delivers a multi-table, enterprise-grade relational database management application built to handle day-to-day operations for a library environment. The platform integrates a non-recursive Python Command-Line Interface (CLI) natively with a multi-table **PostgreSQL** server backend database using the `psycopg2` driver pipeline.

The entire application architecture enforces strict data integrity rules, flagless state-loop mechanisms, sequential server-side cursor caching, and parameter input validations to safeguard records from malformed transactions.

---

## 🛠️ Project Architecture & Milestone Roadmap
The platform was architected across three distinct software lifecycle engineering phases:

### 🔹 Milestone #1: Program Design & Core Skeleton Logic
*   **Objective:** Define pseudo-code architecture and establish full CLI command layouts.
*   **Deliverables:** Monolithic, flagless modular read-loop script framework built to pass parameter validation checks without runtime structural short-circuits.

### 🔹 Milestone #2: Physical Database Design & Schema Seeding
*   **Objective:** Translate a Logical ERD blueprint into an optimized, fully normalized physical database workspace.
*   **Deliverables:** Dedicated database security role management configuration, seven highly structured table schemas containing auto-counters (`SERIAL`), composite keys, and relational data sheets seeding more than 20 default records.

### 🔹 Milestone #3: System Integration & Verification Testing
*   **Objective:** Bind the user interface layer to live database engines to support runtime operational changes.
*   **Deliverables:** Parameterized transaction script execution (`psycopg2`), sequential row streaming algorithms (`cursor.fetchone()`), input constraint blocks, and completed system assertion trace matrices.

---

## 💾 Relational Database Schema
The physical layout layer handles relationship metrics across seven primary tables inside PostgreSQL:

*   `publisher` — Tracks publishing house indexes and direct contacts.
*   `author` — Logs individual writers and their country of origin.
*   `book` — Retains core book metadata catalog entries linked to publishers.
*   `book_author` — An associative bridge table handling Many-to-Many author-to-book links.
*   `book_copy` — Handles independent physical assets using distinct tracking keys.
*   `member` — Tracks unique library card holders indexed by unique phone hashes.
*   `loan` — Tracks lending event parameters, computing dynamic return deadlines on the server.

---

## 🖥️ System Interface Menu Controller
The core application handles five primary database tracking routines:

1. **Display all books:** Runs cross-table relational joins to list all titles alongside their active catalog copies, ordered alphabetically.
2. **Display all members:** Streams the complete registered library user base sorted strictly by `last_name`, then `first_name`.
3. **List all current loans:** Runs conditional lookups to locate unreturned items (`return_date IS NULL`) assigned to a target member profile.
4. **Insert a book loan:** Verifies copy availability constraints before committing fresh lending transaction entries to database logs.
5. **Update a book loan return date:** Locates active rows and updates checkout lines with the `CURRENT_DATE` timestamp to return items back to inventory.

---

## 🚀 Environment Setup & Local Deployment

### 1. Database Initialization (PostgreSQL Shell)
Log into your local PostgreSQL engine and run the administrative schema commands:
```sql
CREATE ROLE library_hadz0024 WITH LOGIN PASSWORD 'dbadmin2026' CREATEDB;
CREATE DATABASE library_hadz0024 OWNER library_hadz0024;
```

### 2. Populate Workspace Tables & Seeding Assets
Excute your structured table and insertion scripts directly inside your Linux shell environment:
```bash
cat sql_create_table.d/*.sql | psql -U library_hadz0024 -d library_hadz0024
cat sql_insert.d/*.sql | psql -U library_hadz0024 -d library_hadz0024
```

### 3. Launch the Application Driver Interface
Install the required system dependency connector and run the master script file:
```bash
sudo apt install python3-psycopg2
chmod +x library_hadz0024.py
./library_hadz0024.py
```

---

## 🛡️ Constraint & Data Integrity Highlights
*   **Flagless State Maintenance:** Loop continuity relies entirely on assessing input bounds directly against a terminal value boundary (`'q'`), removing state sentinel variable errors.
*   **Sequential Caching Loops:** Uses memory-safe sequential lookahead functions (`cursor.fetchone()`) to process row records line-by-line without overloading client system buffers.
*   **Double-Checkout Protection Intercept:** Option 4 actively checks for unreturned loan rows before allowing a checkout to prevent a book copy from being loaned to multiple members at once.
*   **Input Data Validation:** Traps empty entry rows directly via `get_attribute_value()` and blocks non-numeric inputs using `.isdigit()` data-type guards before arguments reach active queries.
