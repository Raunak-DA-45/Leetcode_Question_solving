/*
====================================================================
Purpose:
    Calculate the MEDIAN value from a dataset where numbers are stored
    in aggregated form (each number has a frequency instead of being
    stored multiple times).

Business Rules Implemented:
    1. The table stores numbers and how many times each number appears.
    2. The median is the middle value when all numbers are ordered.
    3. If the total count is odd ? return the single middle value.
    4. If the total count is even ? return the average of the two middle values.
    5. The result is rounded to 2 decimal places.

How the Query Works (Step-by-Step):
    Step 1: Create a table to store numbers and their frequencies.
    Step 2: Insert sample data.
    Step 3: Use window functions to:
            - Calculate cumulative frequency from smallest to largest (rnk1).
            - Calculate cumulative frequency from largest to smallest (rnk2).
            - Calculate total frequency (suming).
    Step 4: Identify the row(s) that fall in the median position using:
            rnk1 >= total/2
            AND
            rnk2 >= total/2 + 1
    Step 5: Take the average of those row(s) to correctly handle both
            even and odd total counts.
====================================================================
*/

--------------------------------------------------------------------
-- TABLE SCHEMA
--------------------------------------------------------------------

-- Drop table if it already exists (for re-runnable script)
DROP TABLE IF EXISTS Numbers;

-- Create table:
-- num        ? The numeric value
-- frequency  ? How many times that number appears in the dataset
CREATE TABLE Numbers (
    num INT,          -- The actual number
    frequency INT     -- Count of occurrences of that number
);

--------------------------------------------------------------------
-- SAMPLE DATA
--------------------------------------------------------------------

-- This means:
-- Number 0 appears 7 times
-- Number 1 appears 1 time
-- Number 2 appears 3 times
-- Number 3 appears 1 time
INSERT INTO Numbers (num, frequency) VALUES (0, 7);
INSERT INTO Numbers (num, frequency) VALUES (1, 1);
INSERT INTO Numbers (num, frequency) VALUES (2, 3);
INSERT INTO Numbers (num, frequency) VALUES (3, 1);

-- View the raw data
SELECT * FROM Numbers;

--------------------------------------------------------------------
-- MEDIAN CALCULATION QUERY
--------------------------------------------------------------------

WITH cte1 AS (
    SELECT
        num,
        frequency,

        -- Running total from smallest number to largest
        SUM(frequency) OVER (ORDER BY num) AS rnk1,

        -- Running total from largest number to smallest
        SUM(frequency) OVER (ORDER BY num DESC) AS rnk2,

        -- Total count of all numbers
        SUM(frequency) OVER () AS suming

    FROM Numbers
)

SELECT
    ROUND(AVG(num), 2) AS median
FROM cte1
-- Select only rows that fall in the median position
WHERE rnk1 >= suming / 2
  AND rnk2 >= suming / 2 + 1;
