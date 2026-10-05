# Lab 06: Manage Data in a Database

## Project Overview
This lab focuses on data management within a relational database tracking a library loan system utilizing PostgreSQL (`psql`). 
The primary objective is executing full CRUD (Create, Read, Update, Delete) operations using SQL Data Manipulation Language (DML) and Data Query Language (DQL).

## Database Schema Model
The database tracks information across four core relational tables:
* `member`: Library patrons with auto-generated surrogate keys.
* `book`: Inventory records mapped via a natural primary key (`isbn`).
* `book_copy`: Individual inventory items referenced via foreign keys.
* `loan`: Tracking transactional loan history using sub-query evaluations to verify relationship integrity.

## Included SQL Scripts
* `insert_book.sql`: Bulk loading raw data for parent text structures.
* `insert_book_copy.sql`: Managing tracking entries via sub-query identifiers.
* `insert_loan.sql`: Formatted transactional log tracking active, complete, and overdue rentals.
