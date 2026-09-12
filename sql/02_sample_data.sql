-- =====================================================================
-- BookMyShow – Sample data (run after 01_schema.sql)
-- =====================================================================
USE bookmyshow;

INSERT INTO city (city_name, state_name) VALUES
('Delhi',     'Delhi'),
('Gurugram',  'Haryana'),
('Bengaluru', 'Karnataka');

INSERT INTO spoken_language (language_name) VALUES
('Hindi'), ('English'), ('Tamil'), ('Telugu');

INSERT INTO genre (genre_name) VALUES
('Action'), ('Drama'), ('Comedy'), ('Thriller'), ('Animation');

INSERT INTO show_format (format_name) VALUES
('2D'), ('3D'), ('IMAX 2D'), ('IMAX 3D'), ('4DX');

INSERT INTO seat_category (category_name) VALUES
('Silver'), ('Gold'), ('Platinum'), ('Recliner');

INSERT INTO theatre (theatre_name, address_line, city_id) VALUES
('PVR Select Citywalk', 'Saket District Centre, Saket', 1),
('INOX Nehru Place',    'Satyam Cineplex, Nehru Place', 1),
('PVR Ambience Mall',   'Ambience Mall, NH-8',          2);

INSERT INTO screen (theatre_id, screen_name) VALUES
(1, 'Audi 1'), (1, 'Audi 2'), (1, 'Audi 3'),
(2, 'Screen 1'), (2, 'Screen 2'),
(3, 'Audi 1');

-- A small seat map for Audi 1 of PVR Select Citywalk (screen_id = 1)
INSERT INTO seat (screen_id, row_label, seat_number, seat_category_id) VALUES
(1, 'A', 1, 1), (1, 'A', 2, 1), (1, 'A', 3, 1), (1, 'A', 4, 1),
(1, 'B', 1, 2), (1, 'B', 2, 2), (1, 'B', 3, 2), (1, 'B', 4, 2),
(1, 'C', 1, 4), (1, 'C', 2, 4);

INSERT INTO movie (title, duration_min, release_date, certificate) VALUES
('Dune: Part Two',  166, '2024-03-01', 'UA'),
('Stree 2',         149, '2024-08-15', 'UA'),
('Inside Out 2',     96, '2024-06-14', 'U'),
('Kalki 2898 AD',   181, '2024-06-27', 'UA');

INSERT INTO movie_genre (movie_id, genre_id) VALUES
(1, 1), (1, 2),          -- Dune: Action, Drama
(2, 3), (2, 4),          -- Stree 2: Comedy, Thriller
(3, 5), (3, 3),          -- Inside Out 2: Animation, Comedy
(4, 1), (4, 4);          -- Kalki: Action, Thriller

-- Shows at PVR Select Citywalk (theatre 1, screens 1-3) on 2026-09-12 and 2026-09-13
INSERT INTO movie_show (screen_id, movie_id, language_id, format_id, show_date, start_time) VALUES
-- 2026-09-12
(1, 1, 2, 3, '2026-09-12', '10:15:00'),   -- Dune,  English, IMAX 2D
(1, 1, 2, 3, '2026-09-12', '14:00:00'),
(1, 1, 2, 3, '2026-09-12', '18:30:00'),
(2, 2, 1, 1, '2026-09-12', '11:00:00'),   -- Stree 2, Hindi, 2D
(2, 2, 1, 1, '2026-09-12', '15:00:00'),
(2, 2, 1, 1, '2026-09-12', '19:15:00'),
(2, 2, 1, 1, '2026-09-12', '22:45:00'),
(3, 3, 2, 2, '2026-09-12', '09:30:00'),   -- Inside Out 2, English, 3D
(3, 3, 1, 1, '2026-09-12', '12:00:00'),   -- Inside Out 2, Hindi, 2D
(3, 4, 4, 1, '2026-09-12', '20:00:00'),   -- Kalki, Telugu, 2D
-- 2026-09-13
(1, 1, 2, 3, '2026-09-13', '10:15:00'),
(1, 1, 2, 3, '2026-09-13', '17:45:00'),
(2, 2, 1, 1, '2026-09-13', '11:00:00'),
(2, 2, 1, 1, '2026-09-13', '19:15:00'),
(3, 3, 2, 2, '2026-09-13', '09:30:00'),
-- Another theatre, same date (should NOT appear in the P2 result for theatre 1)
(4, 2, 1, 1, '2026-09-12', '13:00:00'),
(6, 1, 2, 1, '2026-09-12', '16:00:00');

-- Pricing for the first show (show_id = 1)
INSERT INTO show_seat_price (show_id, seat_category_id, price) VALUES
(1, 1, 250.00), (1, 2, 350.00), (1, 4, 900.00),
(4, 1, 180.00), (4, 2, 260.00), (4, 4, 700.00);

INSERT INTO customer (full_name, email, phone) VALUES
('Aarav Mehta', 'aarav.mehta@example.com', '9876543210'),
('Diya Sharma', 'diya.sharma@example.com', '9123456780');

INSERT INTO booking (customer_id, show_id, status) VALUES
(1, 1, 'CONFIRMED'),
(2, 4, 'PENDING');

INSERT INTO booking_seat (booking_id, show_id, seat_id) VALUES
(1, 1, 5), (1, 1, 6),      -- Aarav: B1, B2 (Gold) for show 1
(2, 4, 9);                 -- Diya: C1 (Recliner) for show 4

INSERT INTO payment (booking_id, amount, payment_method, payment_status) VALUES
(1, 700.00, 'UPI', 'SUCCESS');
