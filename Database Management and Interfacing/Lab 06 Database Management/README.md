# Lab 06: Manage Data in a Database

## Project Overview
This lab focuses on data management within a relational database tracking a library loan system utilizing PostgreSQL (`psql`). The primary objective is executing full CRUD (Create, Read, Update, Delete) operations using SQL Data Manipulation Language (DML) and Data Query Language (DQL).

## Database Schema Model
The database tracks information across four core relational tables:
* **member**: Library patrons with auto-generated surrogate keys.
* **book**: Inventory records mapped via a natural primary key (`isbn`).
* **book_copy**: Individual inventory items referenced via foreign keys.
* **loan**: Tracking transactional loan history using sub-query evaluations to verify relationship integrity.

---

## Directory Structure
To comply with the structural constraints of the lab, all database population scripts are isolated within a dedicated insertion folder:

```text
.
└── Lab 06 Database Management/
    └── sql_insert.d/
        ├── insert_book.sql
        ├── insert_book_copy.sql
        └── insert_loan.sql
```

---

## SQL Deployment Scripts

### 1. Parent Table: Members (`psql` Command Prompt)
Members were populated directly inside the interactive `psql` shell using automated surrogate keys:
```sql
INSERT INTO member (first_name, last_name, phone) VALUES ('Chris', 'Chapter', '6131231234');
INSERT INTO member (first_name, last_name, phone) VALUES ('Danny', 'Digest', '6131112233');
INSERT INTO member (first_name, last_name, phone) VALUES ('Finlay', 'Footnote', '6138889999');
INSERT INTO member (first_name, last_name, phone) VALUES ('Robin', 'Reader', '6135554444');
INSERT INTO member (first_name, last_name, phone) VALUES ('Tracy', 'Tome', '6136667777');
INSERT INTO member (first_name, last_name, phone) VALUES ('Jessie', 'Journal', '6137778888');
```

### 2. Books Script (`sql_insert.d/insert_book.sql`)
```sql
INSERT INTO book (isbn, title, rental_days) VALUES
('isbn1', '1984', 14),
('isbn3', 'Emma', 7),
('isbn4', 'Moby Dick', 7),
('isbn5', 'Pride and Prejudice', 14),
('isbn6', 'Hamlet', 14);
```

### 3. Book Copies Script (`sql_insert.d/insert_book_copy.sql`)
```sql
INSERT INTO book_copy (isbn, acquisition_date) VALUES
((SELECT isbn FROM book WHERE title = '1984'), '2025-12-24'),
((SELECT isbn FROM book WHERE title = '1984'), '2025-12-24'),
((SELECT isbn FROM book WHERE title = 'Emma'), '2026-01-15'),
((SELECT isbn FROM book WHERE title = 'Emma'), '2026-01-15'),
((SELECT isbn FROM book WHERE title = 'Emma'), '2026-03-21'),
((SELECT isbn FROM book WHERE title = 'Moby Dick'), '2026-03-21'),
((SELECT isbn FROM book WHERE title = 'Moby Dick'), '2026-04-10'),
((SELECT isbn FROM book WHERE title = 'Pride and Prejudice'), '2026-04-10'),
((SELECT isbn FROM book WHERE title = 'Pride and Prejudice'), '2026-04-10'),
((SELECT isbn FROM book WHERE title = 'Hamlet'), '2026-04-10');
```

### 4. Transactional Loans Script (`sql_insert.d/insert_loan.sql`)
```sql
INSERT INTO loan (copy_id, member_id, loan_date, return_date) VALUES
    -- Completed Loans (Returned On-Time)
    (1, (SELECT member_id FROM member WHERE last_name = 'Digest'), '2026-01-10', '2026-01-20'),
    (1, (SELECT member_id FROM member WHERE last_name = 'Chapter'), '2026-01-25', '2026-02-02'),
    (2, (SELECT member_id FROM member WHERE last_name = 'Chapter'), '2026-02-05', '2026-02-12'),
    (3, (SELECT member_id FROM member WHERE last_name = 'Footnote'), '2026-02-10', '2026-02-17'),
    (4, (SELECT member_id FROM member WHERE last_name = 'Reader'), '2026-02-15', '2026-02-25'),
    (5, (SELECT member_id FROM member WHERE last_name = 'Tome'), '2026-03-01', '2026-03-10'),
    
    -- Current Active Loans (No Return Date)
    (1, (SELECT member_id FROM member WHERE last_name = 'Journal'), '2026-09-20', NULL),
    (2, (SELECT member_id FROM member WHERE last_name = 'Reader'), '2026-09-22', NULL),
    (3, (SELECT member_id FROM member WHERE last_name = 'Chapter'), '2026-09-25', NULL),
    (4, (SELECT member_id FROM member WHERE last_name = 'Digest'), '2026-09-28', NULL),
    
    -- Overdue Active Loans (No Return Date & Beyond Policy Limits)
    (5, (SELECT member_id FROM member WHERE last_name = 'Footnote'), '2026-05-15', NULL),
    (6, (SELECT member_id FROM member WHERE last_name = 'Tome'), '2026-06-20', NULL);
```

---

## Verification

Database `lib_hadz0024`, enter the directory, and execute the files sequentially:

```bash
cd library_db/sql_insert.d
psql -d lib_hadz0024
```

At the `psql` prompt:
```sql
-- Execute files
\(\i insert_book.sql \i insert_book_copy.sql \i\) insert_loan.sql

-- Confirmirmation:
SELECT COUNT(*) FROM member;     -- Expected: 6
SELECT COUNT(*) FROM book;       -- Expected: 5
SELECT COUNT(*) FROM book_copy;  -- Expected: 10
SELECT COUNT(*) FROM loan;       -- Expected: 12
```

---

## Section B: Data Modification Actions (CRUD Maintenance)

### Tuple Modification Exercises
```sql
-- 1. Explicit targeted field updates
UPDATE book SET rental_days = 7 WHERE title = 'Emma';

-- 2. Global schema parameters shift
UPDATE book SET rental_days = 21 WHERE rental_days = 14;

-- 3. Dependency-safe conditional tuple removals
DELETE FROM member WHERE last_name = 'Terminator';
```
