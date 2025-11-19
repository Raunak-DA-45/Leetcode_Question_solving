/* ==========================================================================================
   PURPOSE OF THIS SCRIPT
   ------------------------------------------------------------------------------------------
   This script calculates the **total investment value in 2016 (tiv_2016)** for all
   policyholders who satisfy BOTH of the following rules:

     1. Their **tiv_2015 value is shared** with at least one other policyholder.
     2. Their **(lat, lon) location is unique**, meaning no other policyholder shares it.

   Only policyholders meeting *both* conditions are included, and the sum of their 2016
   investment values is returned, rounded to two decimal places.


   HOW THE QUERY WORKS
   ------------------------------------------------------------------------------------------
   1. A CTE (cte1) uses window functions:
        • COUNT(*) OVER (PARTITION BY tiv_2015) ? how many share the same tiv_2015.
        • COUNT(*) OVER (PARTITION BY lat, lon) ? how many share the same location.
   2. Filter rows:
        • policy_count > 1  ? shared tiv_2015
        • lat_lon_count = 1 ? unique location
   3. SUM the tiv_2016 values that meet both conditions.
   4. ROUND the final result to two decimal places.

   The full script below includes:
   - Table creation
   - Sample data
   - Fully functional query with professional-level comments
============================================================================================== */



/* ==========================================================================================
   SCHEMA AND SAMPLE DATA
============================================================================================== */

----------------------------------------------------------
-- Drop table for rerun safety
----------------------------------------------------------
IF OBJECT_ID('dbo.Insurance', 'U') IS NOT NULL
    DROP TABLE dbo.Insurance;


----------------------------------------------------------
-- Insurance table
-- pid        : policyholder ID
-- tiv_2015   : total investment value in 2015
-- tiv_2016   : total investment value in 2016
-- lat, lon   : geographic coordinates of policyholder
----------------------------------------------------------
CREATE TABLE Insurance (
    pid INT PRIMARY KEY,
    tiv_2015 FLOAT,
    tiv_2016 FLOAT,
    lat FLOAT,
    lon FLOAT
);


----------------------------------------------------------
-- Sample data
-- Demonstrates:
--   - shared tiv_2015 values
--   - shared and unique locations
----------------------------------------------------------
INSERT INTO Insurance (pid, tiv_2015, tiv_2016, lat, lon) VALUES
(1, 10, 5, 10, 10),
(2, 20, 20, 20, 20),
(3, 10, 30, 20, 20),
(4, 10, 40, 40, 40);


----------------------------------------------------------
-- Optional preview
----------------------------------------------------------
-- SELECT * FROM Insurance;



/* ==========================================================================================
   QUERY: Sum tiv_2016 for qualifying policyholders
============================================================================================== */

WITH cte1 AS (
    SELECT 
        *,
        COUNT(pid) OVER (PARTITION BY tiv_2015) AS policy_count,    -- how many share tiv_2015
        COUNT(pid) OVER (PARTITION BY lat, lon) AS lat_lon_count    -- how many share location
    FROM Insurance
)
SELECT 
    ROUND(SUM(tiv_2016 * 1.0), 2) AS tiv_2016   -- ensure decimal, round to 2 places
FROM cte1
WHERE policy_count > 1        -- shared tiv_2015
  AND lat_lon_count = 1;      -- unique location
