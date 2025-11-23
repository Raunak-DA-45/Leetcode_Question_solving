/*
================================================================================
SQL Script: Independently Order Columns of Data Table

Purpose:
This query generates a result where two columns from the Data table are ordered
independently:
1. 'first_col' is ordered in ascending order.
2. 'second_col' is ordered in descending order.

How the Query Works Step-by-Step:
1. Create the Data table and insert sample data (with no primary key; duplicates allowed).
2. Use a Common Table Expression (CTE) 'cte1' to assign row numbers to first_col 
   ordered ascending.
3. Use a CTE 'cte2' to assign row numbers to second_col ordered descending.
4. Join cte1 and cte2 on their row numbers so that the first smallest value of 
   first_col pairs with the largest value of second_col, second smallest with second largest, etc.
================================================================================
*/

-- Drop table if it exists (cleanup)
IF OBJECT_ID('dbo.Data', 'U') IS NOT NULL DROP TABLE dbo.Data;

--------------------------------------------------------------------------------
-- Table: Data
-- Purpose: Stores two integer columns for sorting practice.
-- Columns:
--   first_col  INT -> First integer column to sort ascending.
--   second_col INT -> Second integer column to sort descending.
-- Note: No primary key; duplicates are allowed.
--------------------------------------------------------------------------------
CREATE TABLE Data (
    first_col INT,
    second_col INT
);

--------------------------------------------------------------------------------
-- Sample data
--------------------------------------------------------------------------------
INSERT INTO Data (first_col, second_col) VALUES
(4, 2),
(2, 3),
(3, 1),
(1, 4);

--------------------------------------------------------------------------------
-- Verify the data
--------------------------------------------------------------------------------
SELECT * FROM Data;

--------------------------------------------------------------------------------
-- Query: Independently order first_col ascending and second_col descending
--------------------------------------------------------------------------------
WITH cte1 AS (
    -- Assign row numbers to first_col in ascending order
    SELECT 
        first_col,
        ROW_NUMBER() OVER(ORDER BY first_col ASC) AS r1
    FROM Data
),
cte2 AS (
    -- Assign row numbers to second_col in descending order
    SELECT 
        second_col,
        ROW_NUMBER() OVER(ORDER BY second_col DESC) AS r2
    FROM Data
)
-- Join the two CTEs on their row numbers to align independent ordering
SELECT
    t1.first_col,
    t2.second_col
FROM cte1 t1
INNER JOIN cte2 t2
    ON t1.r1 = t2.r2;