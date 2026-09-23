CREATE TABLE member (
    member_id SERIAL PRIMARY KEY,
    first_name VARCHAR(100) NOT NULL,
    last_name VARCHAR(200) NOT NULL,
    phone VARCHAR(20)
);
