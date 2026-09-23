CREATE TABLE loan (
    loan_id SERIAL PRIMARY KEY,
    copy_id INT REFERENCES book_copy(copy_id),
    member_id INT REFERENCES member(member_id),
    loan_date DATE NOT NULL,
    return_date DATE
);
