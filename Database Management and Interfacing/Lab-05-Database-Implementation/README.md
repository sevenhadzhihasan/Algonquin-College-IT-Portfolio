# Lab 05: Database Implementation

This folder contains the physical database schema and implementation scripts for a relational library system using PostgreSQL. The project involves interpreting a logical Entity-Relationship Diagram (ERD), finalizing physical design mappings, and deploying structured SQL scripts.

## 📐 Schema Mapping & Data Types

The authoritative database architecture implements the following data types and relational structures:

| Table Name | Attribute Name | Constraint / Key | Data Type | Notes |
| :--- | :--- | :--- | :--- | :--- |
| **member** | `member_id` | PRIMARY KEY | `SERIAL` | Auto-incrementing identifier |
| | `first_name` | NOT NULL | `VARCHAR(100)`| Patron's first name |
| | `last_name` | NOT NULL | `VARCHAR(200)`| Patron's last name |
| | `phone` | | `VARCHAR(20)` | Optional profile contact |
| **book** | `isbn` | PRIMARY KEY | `CHAR(13)` | Fixed 13-digit standard code |
| | `title` | NOT NULL | `VARCHAR(255)`| Title of the literary work |
| | `rental_days` | NOT NULL | `SMALLINT` | 2-byte integer checkout cap |
| **book_copy**| `copy_id` | PRIMARY KEY | `SERIAL` | Individual item identifier |
| | `isbn` | FOREIGN KEY | `CHAR(13)` | References `book(isbn)` |
| | `acquisition_date`| | `DATE` | Asset tracking date |
| **loan** | `loan_id` | PRIMARY KEY | `SERIAL` | Surrogate transactional key |
| | `copy_id` | FOREIGN KEY | `INT` | References `book_copy(copy_id)` |
| | `member_id` | FOREIGN KEY | `INT` | References `member(member_id)` |
| | `loan_date` | NOT NULL | `DATE` | Checkout timestamp |
| | `return_date` | | `DATE` | Nullable until asset return |
| | *due_date* | *Derived* | *N/A* | *Calculated dynamically (Not Stored)* |

## 🚀 Deployment Instructions

### 1. Initialize the Environment
Log into your database terminal profile as `dbadmin` and prepare the relational database workspace:
```sql
CREATE DATABASE lib_your_network_ID;
\c lib_your_network_ID
```

### 2. Execute Data Definition Language (DDL) Scripts
Run the scripts using the interactive `psql` shell file importer in the following sequence to preserve mandatory foreign key dependencies:
```text
\i create_member.sql
\i create_book.sql
\i create_book_copy.sql
\i create_loan.sql
```

### 3. Verify Database Objects
Confirm structural integrity using built-in system shortcuts:
* `\dt` — Verifies the presence of all 4 tables.
* `\d loan` — Inspects fields, data types, sequences, and active constraints.
