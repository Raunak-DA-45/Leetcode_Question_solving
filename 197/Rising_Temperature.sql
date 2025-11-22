/*
Purpose of the Query:
---------------------
Identify the days in the Weather table where the temperature was 
higher than the previous day's temperature. Only consecutive days are considered.

Business Rules Implemented:
--------------------------
1. Compare each day's temperature with the previous day's temperature.
2. Only consider consecutive days.
3. Return the `id` of the days where the temperature increased compared to the previous day.

How the Query Works:
-------------------
Method 1 (Window Function):
1. Use LAG() to get the previous day's temperature and date.
2. Compare today's temperature with the previous day's temperature.
3. Use DATEDIFF to ensure the previous day is exactly one day before.
4. Return ids satisfying both conditions.

Method 2 (Self-Join):
1. Join the Weather table with itself on consecutive dates.
2. Compare temperatures to find increases.
3. Return ids of days with higher temperature than previous day.
*/

-- =========================
-- Step 1: Drop table if it exists (SQL Server syntax)
-- =========================
IF OBJECT_ID('dbo.Weather', 'U') IS NOT NULL
    DROP TABLE dbo.Weather;
GO

-- =========================
-- Step 2: Create the Weather table
-- =========================
CREATE TABLE dbo.Weather (
    id INT PRIMARY KEY,          -- Unique identifier for the record
    recordDate DATE NOT NULL,    -- Date of the weather measurement
    temperature INT NOT NULL     -- Temperature recorded on that date
);
GO

-- =========================
-- Step 3: Insert sample data
-- =========================
INSERT INTO dbo.Weather (id, recordDate, temperature) VALUES (1, '2015-01-01', 10);
INSERT INTO dbo.Weather (id, recordDate, temperature) VALUES (2, '2015-01-02', 25);
INSERT INTO dbo.Weather (id, recordDate, temperature) VALUES (3, '2015-01-03', 20);
INSERT INTO dbo.Weather (id, recordDate, temperature) VALUES (4, '2015-01-04', 30);
GO

-- =========================
-- Step 4: Query using Window Function (Method 1)
-- =========================
SELECT id
FROM (
    SELECT
        *,
        LAG(temperature) OVER (ORDER BY recordDate) AS prev_temp,  -- Previous day's temperature
        LAG(recordDate) OVER (ORDER BY recordDate) AS prev_date   -- Previous day's date
    FROM dbo.Weather
) t
WHERE temperature > prev_temp
  AND DATEDIFF(DAY, prev_date, recordDate) = 1;  -- Ensure consecutive days
GO

-- =========================
-- Query using Self-Join (Method 2)
-- =========================

SELECT t1.id
FROM dbo.Weather t1
INNER JOIN dbo.Weather t2
    ON t1.recordDate = DATEADD(DAY, 1, t2.recordDate)  -- t1 is the day after t2
    AND t1.temperature > t2.temperature;               -- t1 temperature higher than previous day

GO
