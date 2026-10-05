INSERT INTO loan (copy_id, member_id, loan_date, return_date) VALUES
    (1, (SELECT member_id FROM member WHERE last_name = 'Digest'), '2026-01-10', '2026-01-20'),
    (1, (SELECT member_id FROM member WHERE last_name = 'Chapter'), '2026-01-25', '2026-02-02'),
    (2, (SELECT member_id FROM member WHERE last_name = 'Chapter'), '2026-02-05', '2026-02-12'),
    (3, (SELECT member_id FROM member WHERE last_name = 'Footnote'), '2026-02-10', '2026-02-17'),
    (4, (SELECT member_id FROM member WHERE last_name = 'Reader'), '2026-02-15', '2026-02-25'),
    (5, (SELECT member_id FROM member WHERE last_name = 'Tome'), '2026-03-01', '2026-03-10'),
    (1, (SELECT member_id FROM member WHERE last_name = 'Journal'), '2026-09-20', NULL),
    (2, (SELECT member_id FROM member WHERE last_name = 'Reader'), '2026-09-22', NULL),
    (3, (SELECT member_id FROM member WHERE last_name = 'Chapter'), '2026-09-25', NULL),
    (4, (SELECT member_id FROM member WHERE last_name = 'Digest'), '2026-09-28', NULL),
    (5, (SELECT member_id FROM member WHERE last_name = 'Footnote'), '2026-05-15', NULL),
    (6, (SELECT member_id FROM member WHERE last_name = 'Tome'), '2026-06-20', NULL);
