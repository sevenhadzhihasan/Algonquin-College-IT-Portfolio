CREATE TABLE book_copy (
    copy_id SERIAL PRIMARY KEY,
    isbn CHAR(13) REFERENCES book(isbn),
    acquisition_date DATE
);
