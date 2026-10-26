# Lab 07: Form SQL Queries

## 📌 Project Overview
The objective of this lab is to develop multi-table SQL relational queries against an existing PostgreSQL relational library database model. This portfolio artifact demonstrates proficiency in querying structural entity attributes, utilizing sorting methods (`ORDER BY`), filtering via complex search conditionals (`WHERE`), handling `JOIN` mechanisms across intersecting tables, and tracking transaction logs.

## 🛠️ Relational Database Schema
The database contains the following relational structure:
* **`book`**: `isbn` (PK), `title`, `rental_days`
* **`book_copy`**: `copy_id` (PK), `isbn` (FK), `acquisition_date`
* **`member`**: `member_id` (PK), `first_name`, `last_name`, `phone`
* **`loan`**: `loan_id` (PK), `copy_id` (FK), `member_id` (FK), `loan_date`, `return_date`

---

## 💻 Query Implementations & Solution Syntax

### 1. Two-Table Relational Join with Sorting
**Objective:** Display the descriptive book titles and absolute physical acquisition dates of all indexed individual physical book copies, sorted systematically by book title.

```sql
SELECT title, acquisition_date
FROM book
JOIN book_copy ON book.isbn = book_copy.isbn
ORDER BY title;
```

### 2. Complex Four-Table Intersecting Join
**Objective:** Track global account historical logs by extracting complete transaction records containing member last names, book titles, loan initiation dates, and return confirmations for all recorded library rentals. Result sets are ordered alphabetically by the patron's last name.

```sql
SELECT last_name, title, loan_date, return_date
FROM member
JOIN loan ON member.member_id = loan.member_id
JOIN book_copy ON loan.copy_id = book_copy.copy_id
JOIN book ON book_copy.isbn = book.isbn
ORDER BY last_name ASC;
```

---

## 📊 Query Processing Outputs

### Output Results for Multi-Table Transaction Log (Query #14)
Running the four-way relational table join query inside the terminal environment prints the following data matrix output:

```text
 last_name |        title        | loan_date  | return_date 
-----------+---------------------+------------+-------------
 Chapter   | 1984                | 2026-02-05 | 2026-02-12
 Chapter   | Emma                | 2026-09-25 | 
 Chapter   | 1984                | 2026-01-25 | 2026-02-02
 Digest    | Emma                | 2026-09-28 | 
 Digest    | 1984                | 2026-01-10 | 2026-01-20
 Footnote  | Emma                | 2026-02-10 | 2026-02-17
 Footnote  | Emma                | 2026-05-15 | 
 Journal   | 1984                | 2026-09-20 | 
 Reader    | 1984                | 2026-09-22 | 
 Reader    | Emma                | 2026-02-15 | 2026-02-25
 Tome      | Emma                | 2026-03-01 | 2026-03-10
 Tome      | Moby Dick           | 2026-06-20 | 
(12 rows)
```
