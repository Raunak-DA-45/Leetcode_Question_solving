/* ==========================================================================================
   PURPOSE OF THIS SCRIPT
   ------------------------------------------------------------------------------------------
   This script identifies all numbers in a log table that appear at least **three times
   consecutively**, regardless of where those sequences occur.

   BUSINESS RULES
   ------------------------------------------------------------------------------------------
   - A number qualifies as "ConsecutiveNums" only if it appears **three or more times in a row**
     based on ascending `id`.
   - Output each qualifying number only once.

   HOW THE QUERY WORKS (Two Methods Shown)
   ------------------------------------------------------------------------------------------
   Method 1 (Using LEAD Window Function):
     1. For each row, look ahead to the next and next-next row using LEAD().
     2. If the current row's value equals both forward-looking values, it starts a run of 3+.
     3. Select the distinct numbers that meet this condition.

   Method 2 (Using ROW_NUMBER to detect consecutive groups):
     1. Assign a row_number() for each number ordered by id.
     2. Compute a "diff" = id - row_number(). Identical diff values indicate consecutive runs.
     3. Group by (num, diff) and count rows in each run.
     4. Keep only groups with count >= 3 and return the distinct numbers.

   Both methods return the same correct result.
============================================================================================= */


-------------------------------------------
-- SCHEMA: Logs table
-- Represents sequential log records.
-- id  = event position (strictly increasing)
-- num = event value we want to check for consecutive repetition
-------------------------------------------

-- Drop table if it exists so this script is fully rerunnable
IF OBJECT_ID('dbo.Logs', 'U') IS NOT NULL
    DROP TABLE dbo.Logs;

-- Create the table
CREATE TABLE dbo.Logs (
    id INT PRIMARY KEY,
    num INT
);

-------------------------------------------
-- SAMPLE DATA
-- Contains intentional consecutive and non-consecutive values:
-- - num = 1 appears three times consecutively at ids 1,2,3
-- - num = 2 appears only twice at ids 6,7 (not enough)
-------------------------------------------

INSERT INTO dbo.Logs (id, num) VALUES
(1, 1),
(2, 1),
(3, 1),
(4, 2),
(5, 1),
(6, 2),
(7, 2);


-------------------------------------------------------------------------------------
-- METHOD 1: Using LEAD to compare current row with next two rows
-------------------------------------------------------------------------------------
WITH cte1 AS (
    SELECT
        *,
        LEAD(num) OVER (ORDER BY id)      AS Next_Num,
        LEAD(num, 2) OVER (ORDER BY id)   AS Next_2_Num
    FROM dbo.Logs
)
SELECT DISTINCT num AS ConsecutiveNums
FROM cte1
WHERE num = Next_Num        -- current value matches next value
  AND num = Next_2_Num;     -- current value matches value two rows ahead


-------------------------------------------------------------------------------------
-- METHOD 2: Using ROW_NUMBER to detect groups of consecutive values
-------------------------------------------------------------------------------------

WITH cte1 AS (
    SELECT
        *,
        ROW_NUMBER() OVER (PARTITION BY num ORDER BY id) AS r1
        -- r1 resets for every num, letting us detect run lengths
    FROM dbo.Logs
),
cte2 AS (
    SELECT
        *,
        id - r1 AS diff
        -- diff is constant for consecutive rows of same num
    FROM cte1
),
cte3 AS (
    SELECT
        diff, num
    FROM cte2
    GROUP BY diff, num
    HAVING COUNT(*) >= 3     -- only keep runs of 3 or more
)
SELECT DISTINCT num AS ConsecutiveNums
FROM cte3;
