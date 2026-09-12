# BookMyShow – Problem Solving Case (Database Design)

**Course:** Backend System Design – Airtribe
**Assignment:** Problem Solving Case – BookMyShow

## 1. Problem statement

BookMyShow lets a user pick a theatre, see the next 7 dates, choose a date, and view every show running in that theatre on that date along with its timings.

- **P1** – Identify all entities, their attributes and table structures; write MySQL DDL with sample rows; ensure 1NF, 2NF, 3NF and BCNF.
- **P2** – Write a query listing all shows on a given date at a given theatre with their show timings.

## 2. Repository layout

```
.
├── README.md                 <- this document
└── sql/
    ├── 01_schema.sql         <- P1: CREATE DATABASE + all CREATE TABLE statements
    ├── 02_sample_data.sql    <- P1: sample INSERTs
    └── 03_queries.sql        <- P2: show-listing query + supporting queries
```

Run in order on MySQL 8.x:

```bash
mysql -u root -p < sql/01_schema.sql
mysql -u root -p < sql/02_sample_data.sql
mysql -u root -p < sql/03_queries.sql
```

## 3. Entities and relationships

| Entity | Purpose | Key relationships |
|---|---|---|
| **City** | City a theatre is located in | 1 city → many theatres |
| **Theatre** | A cinema venue (e.g. *PVR Select Citywalk*) | belongs to a city; 1 theatre → many screens |
| **Screen** | An auditorium inside a theatre (*Audi 1*) | belongs to a theatre; 1 screen → many seats, many shows |
| **Seat** | A physical seat in a screen (row + number) | belongs to a screen and a seat category |
| **SeatCategory** | Silver / Gold / Platinum / Recliner | lookup |
| **Movie** | A film (title, duration, certificate, release date) | 1 movie → many shows; many-to-many with genre |
| **Genre** | Action / Drama / … | lookup |
| **MovieGenre** | Junction table for movie ↔ genre | resolves many-to-many |
| **SpokenLanguage** | Hindi / English / … | a show is played in exactly one language |
| **ShowFormat** | 2D / 3D / IMAX 2D / 4DX | a show has exactly one format |
| **MovieShow** | A screening: movie × screen × date × start time × language × format | the core entity for the brief |
| **ShowSeatPrice** | Price per seat category for a given show | resolves show ↔ seat-category pricing |
| **Customer** | A registered user | 1 customer → many bookings |
| **Booking** | One order for a show by a customer | 1 booking → many booking seats, 1+ payments |
| **BookingSeat** | A seat reserved under a booking for a show | enforces "one seat sold once per show" |
| **Payment** | Payment attempt(s) against a booking | belongs to a booking |

### ER overview

```
city ──< theatre ──< screen ──< seat >── seat_category
                         │                    │
                         └──< movie_show >──── show_seat_price
                               │  │  │
              movie ───────────┘  │  └──── show_format
                │      spoken_language
         movie_genre >── genre

customer ──< booking ──< booking_seat >── seat
                │              └──────── movie_show
                └──< payment
```

## 4. Table structures with example rows

> `show` is a reserved word in MySQL, so the show table is named `movie_show`.

### 4.1 `city`
| Column | Type | Constraints |
|---|---|---|
| city_id | INT UNSIGNED | PK, AUTO_INCREMENT |
| city_name | VARCHAR(100) | NOT NULL |
| state_name | VARCHAR(100) | NOT NULL |
| | | UNIQUE (city_name, state_name) |

| city_id | city_name | state_name |
|---|---|---|
| 1 | Delhi | Delhi |
| 2 | Gurugram | Haryana |

### 4.2 `spoken_language`
| Column | Type | Constraints |
|---|---|---|
| language_id | INT UNSIGNED | PK, AUTO_INCREMENT |
| language_name | VARCHAR(50) | NOT NULL, UNIQUE |

| language_id | language_name |
|---|---|
| 1 | Hindi |
| 2 | English |

### 4.3 `genre`
| Column | Type | Constraints |
|---|---|---|
| genre_id | INT UNSIGNED | PK, AUTO_INCREMENT |
| genre_name | VARCHAR(50) | NOT NULL, UNIQUE |

| genre_id | genre_name |
|---|---|
| 1 | Action |
| 3 | Comedy |

### 4.4 `show_format`
| Column | Type | Constraints |
|---|---|---|
| format_id | INT UNSIGNED | PK, AUTO_INCREMENT |
| format_name | VARCHAR(30) | NOT NULL, UNIQUE |

| format_id | format_name |
|---|---|
| 1 | 2D |
| 3 | IMAX 2D |

### 4.5 `seat_category`
| Column | Type | Constraints |
|---|---|---|
| seat_category_id | INT UNSIGNED | PK, AUTO_INCREMENT |
| category_name | VARCHAR(30) | NOT NULL, UNIQUE |

| seat_category_id | category_name |
|---|---|
| 1 | Silver |
| 2 | Gold |
| 4 | Recliner |

### 4.6 `theatre`
| Column | Type | Constraints |
|---|---|---|
| theatre_id | INT UNSIGNED | PK, AUTO_INCREMENT |
| theatre_name | VARCHAR(150) | NOT NULL |
| address_line | VARCHAR(255) | NOT NULL |
| city_id | INT UNSIGNED | NOT NULL, FK → city |
| | | UNIQUE (theatre_name, city_id) |

| theatre_id | theatre_name | address_line | city_id |
|---|---|---|---|
| 1 | PVR Select Citywalk | Saket District Centre, Saket | 1 |
| 2 | INOX Nehru Place | Satyam Cineplex, Nehru Place | 1 |

### 4.7 `screen`
| Column | Type | Constraints |
|---|---|---|
| screen_id | INT UNSIGNED | PK, AUTO_INCREMENT |
| theatre_id | INT UNSIGNED | NOT NULL, FK → theatre |
| screen_name | VARCHAR(50) | NOT NULL |
| | | UNIQUE (theatre_id, screen_name) |

| screen_id | theatre_id | screen_name |
|---|---|---|
| 1 | 1 | Audi 1 |
| 2 | 1 | Audi 2 |

### 4.8 `seat`
| Column | Type | Constraints |
|---|---|---|
| seat_id | INT UNSIGNED | PK, AUTO_INCREMENT |
| screen_id | INT UNSIGNED | NOT NULL, FK → screen |
| row_label | VARCHAR(3) | NOT NULL |
| seat_number | SMALLINT UNSIGNED | NOT NULL |
| seat_category_id | INT UNSIGNED | NOT NULL, FK → seat_category |
| | | UNIQUE (screen_id, row_label, seat_number) |

| seat_id | screen_id | row_label | seat_number | seat_category_id |
|---|---|---|---|---|
| 1 | 1 | A | 1 | 1 |
| 5 | 1 | B | 1 | 2 |
| 9 | 1 | C | 1 | 4 |

### 4.9 `movie`
| Column | Type | Constraints |
|---|---|---|
| movie_id | INT UNSIGNED | PK, AUTO_INCREMENT |
| title | VARCHAR(200) | NOT NULL |
| duration_min | SMALLINT UNSIGNED | NOT NULL |
| release_date | DATE | NOT NULL |
| certificate | ENUM('U','UA','A','S') | NOT NULL |
| | | UNIQUE (title, release_date) |

| movie_id | title | duration_min | release_date | certificate |
|---|---|---|---|---|
| 1 | Dune: Part Two | 166 | 2024-03-01 | UA |
| 2 | Stree 2 | 149 | 2024-08-15 | UA |

### 4.10 `movie_genre`
| Column | Type | Constraints |
|---|---|---|
| movie_id | INT UNSIGNED | PK (composite), FK → movie |
| genre_id | INT UNSIGNED | PK (composite), FK → genre |

| movie_id | genre_id |
|---|---|
| 1 | 1 |
| 1 | 2 |

### 4.11 `movie_show`
| Column | Type | Constraints |
|---|---|---|
| show_id | INT UNSIGNED | PK, AUTO_INCREMENT |
| screen_id | INT UNSIGNED | NOT NULL, FK → screen |
| movie_id | INT UNSIGNED | NOT NULL, FK → movie |
| language_id | INT UNSIGNED | NOT NULL, FK → spoken_language |
| format_id | INT UNSIGNED | NOT NULL, FK → show_format |
| show_date | DATE | NOT NULL |
| start_time | TIME | NOT NULL |
| | | UNIQUE (screen_id, show_date, start_time); INDEX (show_date, screen_id) |

| show_id | screen_id | movie_id | language_id | format_id | show_date | start_time |
|---|---|---|---|---|---|---|
| 1 | 1 | 1 | 2 | 3 | 2026-09-12 | 10:15:00 |
| 4 | 2 | 2 | 1 | 1 | 2026-09-12 | 11:00:00 |
| 8 | 3 | 3 | 2 | 2 | 2026-09-12 | 09:30:00 |

End time is intentionally **not** stored – it is derivable from `start_time + movie.duration_min` (storing it would be a transitive dependency).

### 4.12 `show_seat_price`
| Column | Type | Constraints |
|---|---|---|
| show_id | INT UNSIGNED | PK (composite), FK → movie_show |
| seat_category_id | INT UNSIGNED | PK (composite), FK → seat_category |
| price | DECIMAL(8,2) | NOT NULL |

| show_id | seat_category_id | price |
|---|---|---|
| 1 | 1 | 250.00 |
| 1 | 2 | 350.00 |

### 4.13 `customer`
| Column | Type | Constraints |
|---|---|---|
| customer_id | INT UNSIGNED | PK, AUTO_INCREMENT |
| full_name | VARCHAR(120) | NOT NULL |
| email | VARCHAR(150) | NOT NULL, UNIQUE |
| phone | VARCHAR(15) | NOT NULL, UNIQUE |

| customer_id | full_name | email | phone |
|---|---|---|---|
| 1 | Aarav Mehta | aarav.mehta@example.com | 9876543210 |

### 4.14 `booking`
| Column | Type | Constraints |
|---|---|---|
| booking_id | INT UNSIGNED | PK, AUTO_INCREMENT |
| customer_id | INT UNSIGNED | NOT NULL, FK → customer |
| show_id | INT UNSIGNED | NOT NULL, FK → movie_show |
| booked_at | DATETIME | NOT NULL, DEFAULT CURRENT_TIMESTAMP |
| status | ENUM('PENDING','CONFIRMED','CANCELLED') | NOT NULL |

| booking_id | customer_id | show_id | booked_at | status |
|---|---|---|---|---|
| 1 | 1 | 1 | 2026-09-11 18:02:11 | CONFIRMED |

Total amount is **not** stored – it is the sum of the prices of the booked seats.

### 4.15 `booking_seat`
| Column | Type | Constraints |
|---|---|---|
| booking_id | INT UNSIGNED | PK (composite), FK → booking |
| show_id | INT UNSIGNED | NOT NULL, FK → movie_show |
| seat_id | INT UNSIGNED | PK (composite), FK → seat |
| | | UNIQUE (show_id, seat_id) – a seat can be sold once per show |

| booking_id | show_id | seat_id |
|---|---|---|
| 1 | 1 | 5 |
| 1 | 1 | 6 |

### 4.16 `payment`
| Column | Type | Constraints |
|---|---|---|
| payment_id | INT UNSIGNED | PK, AUTO_INCREMENT |
| booking_id | INT UNSIGNED | NOT NULL, FK → booking |
| amount | DECIMAL(10,2) | NOT NULL |
| payment_method | ENUM('UPI','CARD','NETBANKING','WALLET') | NOT NULL |
| payment_status | ENUM('INITIATED','SUCCESS','FAILED','REFUNDED') | NOT NULL |
| paid_at | DATETIME | NOT NULL, DEFAULT CURRENT_TIMESTAMP |

| payment_id | booking_id | amount | payment_method | payment_status | paid_at |
|---|---|---|---|---|---|
| 1 | 1 | 700.00 | UPI | SUCCESS | 2026-09-11 18:02:40 |

## 5. Normalization

**1NF – atomic values, no repeating groups.**
Every column holds a single value. Show timings are not stored as a comma-separated list on the movie/theatre; each timing is its own row in `movie_show`. Genres are not a list on `movie`; they live in `movie_genre`. Seats are individual rows, not a "seat map" blob.

**2NF – no partial dependency on a composite key.**
The only composite-key tables are `movie_genre (movie_id, genre_id)`, `show_seat_price (show_id, seat_category_id)` and `booking_seat (booking_id, seat_id)`. In each, every non-key column (`price`, `show_id`) depends on the *whole* key, not on part of it. All other tables use a single surrogate key, so partial dependencies cannot arise.

**3NF – no transitive dependency.**
- `theatre` stores `city_id` only; city name/state live in `city` (otherwise `theatre_id → city_id → city_name`).
- `movie_show` stores `screen_id` only; `theatre_id` is reached through `screen` (otherwise `show_id → screen_id → theatre_id`).
- `movie_show` does not store `end_time` (`show_id → movie_id → duration_min`, so end time would be transitively dependent).
- `booking` does not store `total_amount` (derivable from `booking_seat` × `show_seat_price`).
- Language, format and seat category are lookup tables referenced by id, not repeated text.

**BCNF – every determinant is a candidate key.**
For each table, the only functional dependencies are from candidate keys:
- `screen`: `screen_id → *` and `(theatre_id, screen_name) → *` – both are keys.
- `seat`: `seat_id → *` and `(screen_id, row_label, seat_number) → *` – both are keys.
- `movie_show`: `show_id → *` and `(screen_id, show_date, start_time) → *` – both are keys.
- `booking_seat`: `(booking_id, seat_id) → show_id` and `(show_id, seat_id) → booking_id` – both are keys (the second is enforced with a UNIQUE constraint). Note that `booking_id → show_id` also holds in the real world, but `booking_id` is not a key of `booking_seat`; that dependency is captured in the `booking` table where `booking_id` *is* the key, so it does not violate BCNF here. `show_id` is kept in `booking_seat` solely to enforce the "one seat per show" uniqueness at the database level.
- Lookup tables have a surrogate key and a UNIQUE natural key; both are candidate keys.

## 6. P1 – SQL

Full DDL is in [`sql/01_schema.sql`](sql/01_schema.sql); sample rows are in [`sql/02_sample_data.sql`](sql/02_sample_data.sql). Excerpt of the core table:

```sql
CREATE TABLE movie_show (
    show_id      INT UNSIGNED NOT NULL AUTO_INCREMENT,
    screen_id    INT UNSIGNED NOT NULL,
    movie_id     INT UNSIGNED NOT NULL,
    language_id  INT UNSIGNED NOT NULL,
    format_id    INT UNSIGNED NOT NULL,
    show_date    DATE         NOT NULL,
    start_time   TIME         NOT NULL,
    PRIMARY KEY (show_id),
    UNIQUE KEY uq_show_slot (screen_id, show_date, start_time),
    KEY idx_show_date_screen (show_date, screen_id),
    CONSTRAINT fk_show_screen   FOREIGN KEY (screen_id)   REFERENCES screen (screen_id),
    CONSTRAINT fk_show_movie    FOREIGN KEY (movie_id)    REFERENCES movie (movie_id),
    CONSTRAINT fk_show_language FOREIGN KEY (language_id) REFERENCES spoken_language (language_id),
    CONSTRAINT fk_show_format   FOREIGN KEY (format_id)   REFERENCES show_format (format_id)
) ENGINE=InnoDB;
```

## 7. P2 – Shows on a given date at a given theatre

Full query file: [`sql/03_queries.sql`](sql/03_queries.sql).

```sql
SELECT
    t.theatre_name,
    ms.show_date,
    m.title                                AS movie,
    l.language_name                        AS language,
    f.format_name                          AS format,
    s.screen_name                          AS screen,
    TIME_FORMAT(ms.start_time, '%h:%i %p') AS show_time,
    TIME_FORMAT(ADDTIME(ms.start_time, SEC_TO_TIME(m.duration_min * 60)), '%h:%i %p') AS approx_end_time
FROM movie_show      ms
JOIN screen          s ON s.screen_id   = ms.screen_id
JOIN theatre         t ON t.theatre_id  = s.theatre_id
JOIN movie           m ON m.movie_id    = ms.movie_id
JOIN spoken_language l ON l.language_id = ms.language_id
JOIN show_format     f ON f.format_id   = ms.format_id
WHERE t.theatre_id = 1
  AND ms.show_date = '2026-09-12'
ORDER BY m.title, ms.start_time;
```

Expected output on the sample data (theatre 1, 2026-09-12):

| theatre_name | show_date | movie | language | format | screen | show_time | approx_end_time |
|---|---|---|---|---|---|---|---|
| PVR Select Citywalk | 2026-09-12 | Dune: Part Two | English | IMAX 2D | Audi 1 | 10:15 AM | 01:01 PM |
| PVR Select Citywalk | 2026-09-12 | Dune: Part Two | English | IMAX 2D | Audi 1 | 02:00 PM | 04:46 PM |
| PVR Select Citywalk | 2026-09-12 | Dune: Part Two | English | IMAX 2D | Audi 1 | 06:30 PM | 09:16 PM |
| PVR Select Citywalk | 2026-09-12 | Inside Out 2 | English | 3D | Audi 3 | 09:30 AM | 11:06 AM |
| PVR Select Citywalk | 2026-09-12 | Inside Out 2 | Hindi | 2D | Audi 3 | 12:00 PM | 01:36 PM |
| PVR Select Citywalk | 2026-09-12 | Kalki 2898 AD | Telugu | 2D | Audi 3 | 08:00 PM | 11:01 PM |
| PVR Select Citywalk | 2026-09-12 | Stree 2 | Hindi | 2D | Audi 2 | 11:00 AM | 01:29 PM |
| PVR Select Citywalk | 2026-09-12 | Stree 2 | Hindi | 2D | Audi 2 | 03:00 PM | 05:29 PM |
| PVR Select Citywalk | 2026-09-12 | Stree 2 | Hindi | 2D | Audi 2 | 07:15 PM | 09:44 PM |
| PVR Select Citywalk | 2026-09-12 | Stree 2 | Hindi | 2D | Audi 2 | 10:45 PM | 01:14 AM |

Shows at other theatres on the same date (INOX Nehru Place, PVR Ambience Mall) are correctly excluded.

A second variant in `03_queries.sql` groups timings per movie/language/format with `GROUP_CONCAT`, matching the BookMyShow UI layout (one line per movie, timings listed across):

| movie | language | format | show_timings |
|---|---|---|---|
| Dune: Part Two | English | IMAX 2D | 10:15 AM, 02:00 PM, 06:30 PM |
| Inside Out 2 | English | 3D | 09:30 AM |
| Inside Out 2 | Hindi | 2D | 12:00 PM |
| Kalki 2898 AD | Telugu | 2D | 08:00 PM |
| Stree 2 | Hindi | 2D | 11:00 AM, 03:00 PM, 07:15 PM, 10:45 PM |

The file also includes the "next 7 dates" query used for the date strip and an available-seats query for a show.

## 8. Indexing notes

- `movie_show (show_date, screen_id)` covers the P2 access pattern (filter by date, join to screen → theatre).
- `UNIQUE (screen_id, show_date, start_time)` prevents double-scheduling a screen.
- `UNIQUE (show_id, seat_id)` on `booking_seat` prevents double-selling a seat; with `InnoDB` row locks, concurrent bookings of the same seat fail at insert time rather than silently succeeding.
