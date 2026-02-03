/****************************************************************************************
PURPOSE
--------
Calculate a 3-day rolling average of daily step counts for each user, 
but only for cases where the 3 days are consecutive (no missing dates).

BUSINESS RULES
--------------
1. Rolling average is calculated per user (user_id).
2. Each rolling window includes:
   - Current day
   - Previous 2 days
3. The rolling average is shown only if:
   - The user has step data for all 3 consecutive days.
4. Results are ordered by date within each user.

HOW THE QUERY WORKS (STEP-BY-STEP)
----------------------------------
1. Create a Steps table to store daily step counts per user.
2. Insert sample step data for multiple users.
3. Use a CTE to:
   - Calculate a rolling 3-day average using a window function.
   - Capture the date from 2 rows earlier using LAG.
4. Filter the results to keep only rows where:
   - The date difference between the current date and the date 2 rows back is exactly 2 days,
     ensuring consecutive days.
****************************************************************************************/


/****************************************************************************************
TABLE SCHEMA
------------
Steps table stores daily step count data for users.
****************************************************************************************/

CREATE TABLE Steps (
    user_id INT,         -- Unique identifier for each user
    steps_count INT,     -- Number of steps taken by the user on a given day
    steps_date DATE      -- Date on which the steps were recorded
);

-- Clear existing data (useful when re-running the script)
TRUNCATE TABLE Steps;


/****************************************************************************************
SAMPLE DATA
-----------
Sample step counts for different users across multiple dates.
Some dates are intentionally missing to demonstrate filtering
of non-consecutive rolling windows.
****************************************************************************************/

INSERT INTO Steps (user_id, steps_count, steps_date) VALUES (1, 687, '2021-09-02');
INSERT INTO Steps (user_id, steps_count, steps_date) VALUES (1, 395, '2021-09-04');
INSERT INTO Steps (user_id, steps_count, steps_date) VALUES (1, 499, '2021-09-05');
INSERT INTO Steps (user_id, steps_count, steps_date) VALUES (1, 712, '2021-09-06');
INSERT INTO Steps (user_id, steps_count, steps_date) VALUES (1, 576, '2021-09-07');

INSERT INTO Steps (user_id, steps_count, steps_date) VALUES (2, 153, '2021-09-06');
INSERT INTO Steps (user_id, steps_count, steps_date) VALUES (2, 171, '2021-09-07');
INSERT INTO Steps (user_id, steps_count, steps_date) VALUES (2, 530, '2021-09-08');

INSERT INTO Steps (user_id, steps_count, steps_date) VALUES (3, 945, '2021-09-04');
INSERT INTO Steps (user_id, steps_count, steps_date) VALUES (3, 120, '2021-09-07');
INSERT INTO Steps (user_id, steps_count, steps_date) VALUES (3, 557, '2021-09-08');
INSERT INTO Steps (user_id, steps_count, steps_date) VALUES (3, 840, '2021-09-09');
INSERT INTO Steps (user_id, steps_count, steps_date) VALUES (3, 627, '2021-09-10');

INSERT INTO Steps (user_id, steps_count, steps_date) VALUES (5, 382, '2021-09-05');

INSERT INTO Steps (user_id, steps_count, steps_date) VALUES (6, 480, '2021-09-01');
INSERT INTO Steps (user_id, steps_count, steps_date) VALUES (6, 191, '2021-09-02');
INSERT INTO Steps (user_id, steps_count, steps_date) VALUES (6, 303, '2021-09-05');


-- View raw data
SELECT * FROM Steps;


/****************************************************************************************
QUERY: 3-Day Rolling Average for Consecutive Dates
****************************************************************************************/

WITH cte1 AS (
    SELECT 
        *,
        -- Rolling average of steps over current day + previous 2 days
        ROUND(
            AVG(CAST(steps_count AS FLOAT)) 
            OVER (
                PARTITION BY user_id 
                ORDER BY steps_date 
                ROWS BETWEEN 2 PRECEDING AND CURRENT ROW
            ),
            2
        ) AS rolling_avg,

        -- Date from two rows before the current row
        LAG(steps_date, 2) 
        OVER (PARTITION BY user_id ORDER BY steps_date) AS prev_2_date
    FROM Steps
)

SELECT
    user_id,
    steps_date,
    rolling_avg
FROM (
    SELECT
        user_id,
        steps_date,
        rolling_avg,
        prev_2_date
    FROM cte1
    WHERE prev_2_date IS NOT NULL      -- Ensures at least 3 rows exist
) t
WHERE DATEDIFF(DAY, prev_2_date, steps_date) = 2;  -- Ensures dates are consecutive
