-- =====================================================================
-- BookMyShow – Problem Solving Case
-- P1: Table definitions (MySQL 8.x)
-- All tables satisfy 1NF, 2NF, 3NF and BCNF (see README.md)
-- =====================================================================

DROP DATABASE IF EXISTS bookmyshow;
CREATE DATABASE bookmyshow CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci;
USE bookmyshow;

-- ---------------------------------------------------------------
-- Lookup / reference tables
-- ---------------------------------------------------------------
CREATE TABLE city (
    city_id     INT UNSIGNED  NOT NULL AUTO_INCREMENT,
    city_name   VARCHAR(100)  NOT NULL,
    state_name  VARCHAR(100)  NOT NULL,
    PRIMARY KEY (city_id),
    UNIQUE KEY uq_city (city_name, state_name)
) ENGINE=InnoDB;

CREATE TABLE spoken_language (
    language_id    INT UNSIGNED NOT NULL AUTO_INCREMENT,
    language_name  VARCHAR(50)  NOT NULL,
    PRIMARY KEY (language_id),
    UNIQUE KEY uq_language_name (language_name)
) ENGINE=InnoDB;

CREATE TABLE genre (
    genre_id    INT UNSIGNED NOT NULL AUTO_INCREMENT,
    genre_name  VARCHAR(50)  NOT NULL,
    PRIMARY KEY (genre_id),
    UNIQUE KEY uq_genre_name (genre_name)
) ENGINE=InnoDB;

-- 2D / 3D / IMAX 2D / 4DX etc.
CREATE TABLE show_format (
    format_id    INT UNSIGNED NOT NULL AUTO_INCREMENT,
    format_name  VARCHAR(30)  NOT NULL,
    PRIMARY KEY (format_id),
    UNIQUE KEY uq_format_name (format_name)
) ENGINE=InnoDB;

-- Silver / Gold / Platinum / Recliner
CREATE TABLE seat_category (
    seat_category_id  INT UNSIGNED NOT NULL AUTO_INCREMENT,
    category_name     VARCHAR(30)  NOT NULL,
    PRIMARY KEY (seat_category_id),
    UNIQUE KEY uq_seat_category_name (category_name)
) ENGINE=InnoDB;

-- ---------------------------------------------------------------
-- Venue
-- ---------------------------------------------------------------
CREATE TABLE theatre (
    theatre_id    INT UNSIGNED  NOT NULL AUTO_INCREMENT,
    theatre_name  VARCHAR(150)  NOT NULL,
    address_line  VARCHAR(255)  NOT NULL,
    city_id       INT UNSIGNED  NOT NULL,
    PRIMARY KEY (theatre_id),
    UNIQUE KEY uq_theatre_city (theatre_name, city_id),
    CONSTRAINT fk_theatre_city FOREIGN KEY (city_id) REFERENCES city (city_id)
) ENGINE=InnoDB;

CREATE TABLE screen (
    screen_id    INT UNSIGNED  NOT NULL AUTO_INCREMENT,
    theatre_id   INT UNSIGNED  NOT NULL,
    screen_name  VARCHAR(50)   NOT NULL,          -- "Audi 1", "Screen 3"
    PRIMARY KEY (screen_id),
    UNIQUE KEY uq_screen_theatre (theatre_id, screen_name),
    CONSTRAINT fk_screen_theatre FOREIGN KEY (theatre_id) REFERENCES theatre (theatre_id)
) ENGINE=InnoDB;

CREATE TABLE seat (
    seat_id           INT UNSIGNED  NOT NULL AUTO_INCREMENT,
    screen_id         INT UNSIGNED  NOT NULL,
    row_label         VARCHAR(3)    NOT NULL,     -- "A", "B", "AA"
    seat_number       SMALLINT UNSIGNED NOT NULL, -- 1, 2, 3 ...
    seat_category_id  INT UNSIGNED  NOT NULL,
    PRIMARY KEY (seat_id),
    UNIQUE KEY uq_seat_position (screen_id, row_label, seat_number),
    CONSTRAINT fk_seat_screen   FOREIGN KEY (screen_id)        REFERENCES screen (screen_id),
    CONSTRAINT fk_seat_category FOREIGN KEY (seat_category_id) REFERENCES seat_category (seat_category_id)
) ENGINE=InnoDB;

-- ---------------------------------------------------------------
-- Content
-- ---------------------------------------------------------------
CREATE TABLE movie (
    movie_id      INT UNSIGNED  NOT NULL AUTO_INCREMENT,
    title         VARCHAR(200)  NOT NULL,
    duration_min  SMALLINT UNSIGNED NOT NULL,
    release_date  DATE          NOT NULL,
    certificate   ENUM('U','UA','A','S') NOT NULL,
    PRIMARY KEY (movie_id),
    UNIQUE KEY uq_movie_title_release (title, release_date)
) ENGINE=InnoDB;

-- Many-to-many: a movie can belong to several genres
CREATE TABLE movie_genre (
    movie_id  INT UNSIGNED NOT NULL,
    genre_id  INT UNSIGNED NOT NULL,
    PRIMARY KEY (movie_id, genre_id),
    CONSTRAINT fk_mg_movie FOREIGN KEY (movie_id) REFERENCES movie (movie_id),
    CONSTRAINT fk_mg_genre FOREIGN KEY (genre_id) REFERENCES genre (genre_id)
) ENGINE=InnoDB;

-- ---------------------------------------------------------------
-- Scheduling  ("show" is a reserved word in MySQL, hence movie_show)
-- ---------------------------------------------------------------
CREATE TABLE movie_show (
    show_id      INT UNSIGNED NOT NULL AUTO_INCREMENT,
    screen_id    INT UNSIGNED NOT NULL,
    movie_id     INT UNSIGNED NOT NULL,
    language_id  INT UNSIGNED NOT NULL,           -- language this show is played in
    format_id    INT UNSIGNED NOT NULL,           -- 2D / 3D / IMAX ...
    show_date    DATE         NOT NULL,
    start_time   TIME         NOT NULL,
    PRIMARY KEY (show_id),
    -- one screen cannot start two shows at the same instant
    UNIQUE KEY uq_show_slot (screen_id, show_date, start_time),
    KEY idx_show_date_screen (show_date, screen_id),
    CONSTRAINT fk_show_screen   FOREIGN KEY (screen_id)   REFERENCES screen (screen_id),
    CONSTRAINT fk_show_movie    FOREIGN KEY (movie_id)    REFERENCES movie (movie_id),
    CONSTRAINT fk_show_language FOREIGN KEY (language_id) REFERENCES spoken_language (language_id),
    CONSTRAINT fk_show_format   FOREIGN KEY (format_id)   REFERENCES show_format (format_id)
) ENGINE=InnoDB;

-- Price depends on (show, seat category) – not on the show alone
CREATE TABLE show_seat_price (
    show_id           INT UNSIGNED  NOT NULL,
    seat_category_id  INT UNSIGNED  NOT NULL,
    price             DECIMAL(8,2)  NOT NULL,
    PRIMARY KEY (show_id, seat_category_id),
    CONSTRAINT fk_ssp_show     FOREIGN KEY (show_id)          REFERENCES movie_show (show_id),
    CONSTRAINT fk_ssp_category FOREIGN KEY (seat_category_id) REFERENCES seat_category (seat_category_id)
) ENGINE=InnoDB;

-- ---------------------------------------------------------------
-- Customers & bookings
-- ---------------------------------------------------------------
CREATE TABLE customer (
    customer_id  INT UNSIGNED  NOT NULL AUTO_INCREMENT,
    full_name    VARCHAR(120)  NOT NULL,
    email        VARCHAR(150)  NOT NULL,
    phone        VARCHAR(15)   NOT NULL,
    PRIMARY KEY (customer_id),
    UNIQUE KEY uq_customer_email (email),
    UNIQUE KEY uq_customer_phone (phone)
) ENGINE=InnoDB;

CREATE TABLE booking (
    booking_id   INT UNSIGNED NOT NULL AUTO_INCREMENT,
    customer_id  INT UNSIGNED NOT NULL,
    show_id      INT UNSIGNED NOT NULL,
    booked_at    DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP,
    status       ENUM('PENDING','CONFIRMED','CANCELLED') NOT NULL DEFAULT 'PENDING',
    PRIMARY KEY (booking_id),
    KEY idx_booking_customer (customer_id),
    CONSTRAINT fk_booking_customer FOREIGN KEY (customer_id) REFERENCES customer (customer_id),
    CONSTRAINT fk_booking_show     FOREIGN KEY (show_id)     REFERENCES movie_show (show_id)
) ENGINE=InnoDB;

-- One physical seat can be sold only once per show
CREATE TABLE booking_seat (
    booking_id  INT UNSIGNED NOT NULL,
    show_id     INT UNSIGNED NOT NULL,
    seat_id     INT UNSIGNED NOT NULL,
    PRIMARY KEY (booking_id, seat_id),
    UNIQUE KEY uq_seat_per_show (show_id, seat_id),
    CONSTRAINT fk_bs_booking FOREIGN KEY (booking_id) REFERENCES booking (booking_id),
    CONSTRAINT fk_bs_show    FOREIGN KEY (show_id)    REFERENCES movie_show (show_id),
    CONSTRAINT fk_bs_seat    FOREIGN KEY (seat_id)    REFERENCES seat (seat_id)
) ENGINE=InnoDB;

CREATE TABLE payment (
    payment_id      INT UNSIGNED  NOT NULL AUTO_INCREMENT,
    booking_id      INT UNSIGNED  NOT NULL,
    amount          DECIMAL(10,2) NOT NULL,
    payment_method  ENUM('UPI','CARD','NETBANKING','WALLET') NOT NULL,
    payment_status  ENUM('INITIATED','SUCCESS','FAILED','REFUNDED') NOT NULL,
    paid_at         DATETIME      NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (payment_id),
    KEY idx_payment_booking (booking_id),
    CONSTRAINT fk_payment_booking FOREIGN KEY (booking_id) REFERENCES booking (booking_id)
) ENGINE=InnoDB;
