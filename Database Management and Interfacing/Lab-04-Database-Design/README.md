# Lab 04 - Relational Database Design

This directory contains the logical design schema for a relational database library system based on Algonquin College specifications. The objective is to translate a conceptual Entity-Relationship Diagram (ERD) into structured relations, attributes, primary keys, and foreign keys while adhering to relational normalization principles.

## Business Logic & Rules

* **Inventory Control:** A base book entity can have one or many physical `book_copy` records in stock.
* **Many-to-Many Resolution:** Library users (`member`) may borrow any number of items over time. The many-to-many relationship between a user and a physical item copy is explicitly resolved using an associative intersection table (`loan`).
* **Derived Metrics:** The system tracks temporal parameters (`loan_date`, `return_date`) and implicitly computes the field `due_date` dynamically via an active query function (`loan_date + rental_days`) to maximize data integrity.

---

## Relational Database Logical Design Summary

| Entity | Relation Name | Attribute Names |
| :--- | :--- | :--- |
| **Book** | `book` | **PK:** `isbn`<br>• `title`<br>• `rental_days` |
| **Book copy** | `book_copy` | **PK:** `book_copy_id`<br>**FK:** `isbn` (references `book`) <br>• `date_acquired` |
| **Member** | `member` | **PK:** `member_id`<br>• `first_name`<br>• `last_name`<br>• `phone_number` |
| **Book loan** | `loan` | **PK:** `loan_id`<br>**FK:** `book_copy_id` (references `book_copy`) <br>**FK:** `member_id` (references `member`) <br>• `loan_date`<br>• `return_date`<br>• `due_date` (derived) |

---

## Key Naming & Relational Integrity Conventions Followed

* **Case & Plurality Rules:** All tables and system fields exclusively utilize singular, lowercase terms separated by underscores (`words_separated_by_underscore`).
* **Surrogate Key Mechanics:** Artificial integer identifiers (`_id`) are explicitly implemented on tables missing natural, immutable key properties.
* **Referential Integrity Constraints:** Foreign keys map back precisely onto their respective parent unique identifier records to prevent orphaned rows and data anomalies.

---

## 📁 File Layout

```text
Lab-04-Database-Design/
├── README.md        # Relational design documentation and summary table
└── Lab_04.xlsx      # Working relational database design spreadsheet
```
