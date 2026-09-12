-- =====================================================================
-- BookMyShow – P2
-- List all shows on a given date at a given theatre with show timings
-- =====================================================================
USE bookmyshow;

-- ---------------------------------------------------------------
-- P2 (main answer): one row per show
--   Parameters: theatre_id = 1, show_date = '2026-09-12'
-- ---------------------------------------------------------------
SELECT
    t.theatre_name,
    ms.show_date,
    m.title                                                     AS movie,
    l.language_name                                             AS language,
    f.format_name                                               AS format,
    s.screen_name                                               AS screen,
    TIME_FORMAT(ms.start_time, '%h:%i %p')                      AS show_time,
    TIME_FORMAT(ADDTIME(ms.start_time, SEC_TO_TIME(m.duration_min * 60)), '%h:%i %p') AS approx_end_time
FROM movie_show      ms
JOIN screen          s ON s.screen_id    = ms.screen_id
JOIN theatre         t ON t.theatre_id   = s.theatre_id
JOIN movie           m ON m.movie_id     = ms.movie_id
JOIN spoken_language l ON l.language_id  = ms.language_id
JOIN show_format     f ON f.format_id    = ms.format_id
WHERE t.theatre_id = 1
  AND ms.show_date = '2026-09-12'
ORDER BY m.title, ms.start_time;

-- ---------------------------------------------------------------
-- P2 (grouped view, as shown on the BookMyShow UI):
-- one row per movie/language/format with all timings comma-separated
-- ---------------------------------------------------------------
SELECT
    m.title                                   AS movie,
    l.language_name                           AS language,
    f.format_name                             AS format,
    GROUP_CONCAT(
        TIME_FORMAT(ms.start_time, '%h:%i %p')
        ORDER BY ms.start_time SEPARATOR ', '
    )                                         AS show_timings
FROM movie_show      ms
JOIN screen          s ON s.screen_id   = ms.screen_id
JOIN movie           m ON m.movie_id    = ms.movie_id
JOIN spoken_language l ON l.language_id = ms.language_id
JOIN show_format     f ON f.format_id   = ms.format_id
WHERE s.theatre_id = 1
  AND ms.show_date = '2026-09-12'
GROUP BY m.movie_id, m.title, l.language_name, f.format_name
ORDER BY m.title;

-- ---------------------------------------------------------------
-- Supporting query: the "next 7 dates" strip for a theatre
-- (dates on/after today that have at least one show)
-- ---------------------------------------------------------------
SELECT DISTINCT ms.show_date
FROM movie_show ms
JOIN screen s ON s.screen_id = ms.screen_id
WHERE s.theatre_id = 1
  AND ms.show_date >= CURDATE()
ORDER BY ms.show_date
LIMIT 7;

-- ---------------------------------------------------------------
-- Supporting query: available seats for a given show (show_id = 1)
-- ---------------------------------------------------------------
SELECT
    st.row_label,
    st.seat_number,
    sc.category_name,
    ssp.price
FROM movie_show ms
JOIN seat             st  ON st.screen_id = ms.screen_id
JOIN seat_category    sc  ON sc.seat_category_id = st.seat_category_id
JOIN show_seat_price  ssp ON ssp.show_id = ms.show_id
                         AND ssp.seat_category_id = st.seat_category_id
LEFT JOIN booking_seat bs ON bs.show_id = ms.show_id AND bs.seat_id = st.seat_id
WHERE ms.show_id = 1
  AND bs.seat_id IS NULL
ORDER BY st.row_label, st.seat_number;
