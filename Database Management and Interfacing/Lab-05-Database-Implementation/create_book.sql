CREATE TABLE book (
    isbn CHAR(13) PRIMARY KEY,
    title VARCHAR(255) NOT NULL,
    rental_days SMALLINT NOT NULL
);
