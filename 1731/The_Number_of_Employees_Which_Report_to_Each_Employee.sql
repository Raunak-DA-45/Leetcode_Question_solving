/* ==========================================================================================
   PURPOSE OF THIS SCRIPT
   ------------------------------------------------------------------------------------------
   This script identifies all **managers**—defined as employees who have at least one other
   employee reporting directly to them—and returns:
     • manager_id
     • manager_name
     • number of direct reports
     • average age of their direct reports (rounded to nearest integer)

   HOW THE QUERY WORKS (Two Different Methods Provided)
   ------------------------------------------------------------------------------------------
   Method 1 (CTE + GROUP BY):
     1. Aggregate by `reports_to` to calculate:
          - number of employees reporting to each manager
          - average age of those reports
     2. Join this aggregated result back to Employees to get manager names.

   Method 2 (Self Join):
     1. Join Employees to itself:
          - e1 = employee (the report)
          - e2 = employee's manager
     2. Group by manager to calculate:
          - number of direct reports
          - average age of those reports
     3. Filter where a manager actually exists.

   Both methods produce identical results.
============================================================================================== */


/* ==========================================================================================
   SCHEMA: Employees table
   ------------------------------------------------------------------------------------------
   Represents a simple employee hierarchy:
     - employee_id : unique identifier for each employee
     - name        : employee's name
     - reports_to  : manager's employee_id (NULL if no manager)
     - age         : employee's age
============================================================================================== */

IF OBJECT_ID('dbo.Employees', 'U') IS NOT NULL
    DROP TABLE dbo.Employees;

CREATE TABLE dbo.Employees (
    employee_id INT,
    name        VARCHAR(20),
    reports_to  INT NULL,     -- NULL = top-level employee, no manager
    age         INT
);


/* ==========================================================================================
   SAMPLE DATA
   ------------------------------------------------------------------------------------------
   The data intentionally includes:
     - Employee 9 (Hercy), who manages Alice and Bob
     - Employee 2 (Winston), who manages no one
   This allows us to test identifying managers correctly.
============================================================================================== */

INSERT INTO Employees (employee_id, name, reports_to, age) VALUES
(9, 'Hercy',   NULL, 43),   -- Manager of Alice and Bob
(6, 'Alice',   9,    41),   -- Reports to 9
(4, 'Bob',     9,    36),   -- Reports to 9
(2, 'Winston', NULL, 37);   -- Reports to no one, not a manager



/* ==========================================================================================
   METHOD 1: Using CTE + GROUP BY
============================================================================================== */

WITH mgr_stats AS (
    SELECT 
        reports_to AS employee_id,
        COUNT(*)   AS reports_count,
        ROUND(AVG(age * 1.0), 0) AS average_age  -- cast to float for accurate avg
    FROM Employees
    WHERE reports_to IS NOT NULL              -- only employees with managers
    GROUP BY reports_to
)
SELECT 
    m.employee_id,
    e.name,
    m.reports_count,
    m.average_age
FROM mgr_stats m
LEFT JOIN Employees e ON m.employee_id = e.employee_id
ORDER BY m.employee_id;



/* ==========================================================================================
   METHOD 2: Using a SELF JOIN
============================================================================================== */

SELECT 
    mgr.employee_id,
    mgr.name,
    COUNT(emp.employee_id) AS reports_count,
    ROUND(AVG(emp.age * 1.0), 0) AS average_age
FROM Employees emp
LEFT JOIN Employees mgr      -- emp = report, mgr = manager
       ON emp.reports_to = mgr.employee_id
WHERE mgr.employee_id IS NOT NULL            -- ensures emp actually has a manager
GROUP BY mgr.employee_id, mgr.name
ORDER BY mgr.employee_id;
