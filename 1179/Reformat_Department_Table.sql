/****************************************************************************************************
Purpose of the Query:
    Transform (PIVOT) monthly revenue stored in row format into a single row per department,
    where each month becomes a separate revenue column (Jan_Revenue, Feb_Revenue, etc.).

Step-by-Step Explanation:
    1. The Department table stores revenue by department and month, one row per month.
    2. The SELECT statement uses conditional aggregation:
         • A CASE expression checks each row and returns revenue only for matching months.
         • MAX() converts these CASE outputs into month-based columns (pivot effect).
    3. GROUP BY id ensures the final output contains one row per department.

****************************************************************************************************/


/*==========================================================
  T-SQL Schema & Sample Data for Department Table
==========================================================*/

-- Remove Department table if it already exists (keeps script re-runnable)
IF OBJECT_ID('dbo.Department', 'U') IS NOT NULL
    DROP TABLE dbo.Department;

-- Create Department table
CREATE TABLE dbo.Department (
    id INT NOT NULL,             -- Department identifier
    revenue INT NOT NULL,        -- Revenue for the month
    [month] VARCHAR(5) NOT NULL  -- Month abbreviation: Jan, Feb, Mar, etc.
);

-- Ensure table is empty before inserting sample data
TRUNCATE TABLE dbo.Department;

-- Sample data showing revenue for various months
INSERT INTO dbo.Department (id, revenue, [month]) VALUES (1, 8000, 'Jan');
INSERT INTO dbo.Department (id, revenue, [month]) VALUES (2, 9000, 'Jan');
INSERT INTO dbo.Department (id, revenue, [month]) VALUES (3, 10000, 'Feb');
INSERT INTO dbo.Department (id, revenue, [month]) VALUES (1, 7000, 'Feb');
INSERT INTO dbo.Department (id, revenue, [month]) VALUES (1, 6000, 'Mar');

-- Quick check of input data
SELECT * FROM dbo.Department;


/*==========================================================
  Pivot Monthly Revenue into Columns
==========================================================*/

SELECT
    id,

    -- Month-specific revenue columns (NULL if a department has no entry for that month)
    MAX(CASE WHEN LOWER([month]) = 'jan' THEN revenue END) AS Jan_Revenue,
    MAX(CASE WHEN LOWER([month]) = 'feb' THEN revenue END) AS Feb_Revenue,
    MAX(CASE WHEN LOWER([month]) = 'mar' THEN revenue END) AS Mar_Revenue,
    MAX(CASE WHEN LOWER([month]) = 'apr' THEN revenue END) AS Apr_Revenue,
    MAX(CASE WHEN LOWER([month]) = 'may' THEN revenue END) AS May_Revenue,
    MAX(CASE WHEN LOWER([month]) = 'jun' THEN revenue END) AS Jun_Revenue,
    MAX(CASE WHEN LOWER([month]) = 'jul' THEN revenue END) AS Jul_Revenue,
    MAX(CASE WHEN LOWER([month]) = 'aug' THEN revenue END) AS Aug_Revenue,
    MAX(CASE WHEN LOWER([month]) = 'sep' THEN revenue END) AS Sep_Revenue,
    MAX(CASE WHEN LOWER([month]) = 'oct' THEN revenue END) AS Oct_Revenue,
    MAX(CASE WHEN LOWER([month]) = 'nov' THEN revenue END) AS Nov_Revenue,
    MAX(CASE WHEN LOWER([month]) = 'dec' THEN revenue END) AS Dec_Revenue

FROM dbo.Department
GROUP BY id;   -- Ensures one row per department