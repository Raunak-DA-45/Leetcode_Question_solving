/* ==========================================================================================
   PURPOSE OF THIS SCRIPT
   ------------------------------------------------------------------------------------------
   This script identifies employees who:
     1. Earn a salary strictly less than $30,000, AND
     2. Their manager has left the company.

   HOW THE QUERY WORKS
   ------------------------------------------------------------------------------------------
   Method 1:
     - Select employees with salary < 30000.
     - Check that their manager_id does not exist as an employee_id in the table.
     - Return the sorted list of employee_ids.

   Method 2 (Self Join):
     - Left join employees (as e1) to employees (as e2) using manager_id.
     - If e2.employee_id IS NULL, then the manager no longer exists.
     - Apply salary < 30000 filter and return the employee_id.

   Both methods produce identical results.
============================================================================================== */



/* ==========================================================================================
   SCHEMA AND SAMPLE DATA
============================================================================================== */

--------------------------------------------------------------
-- Drop the table if it already exists
--------------------------------------------------------------
IF OBJECT_ID('dbo.Employees', 'U') IS NOT NULL
    DROP TABLE dbo.Employees;


--------------------------------------------------------------
-- Employees table
-- employee_id : Unique identifier
-- name        : Employee's name
-- manager_id  : The employee_id of their manager (NULL = no manager)
-- salary      : Annual salary for the employee
--------------------------------------------------------------
CREATE TABLE Employees (
    employee_id INT PRIMARY KEY,
    name VARCHAR(20),
    manager_id INT NULL,
    salary INT
);


--------------------------------------------------------------
-- Sample data
-- Includes:
-- - Employees with NULL managers (top-level employees)
-- - Employees whose manager_id refers to someone NOT in the table
--   ? this simulates managers who left the company
--------------------------------------------------------------
INSERT INTO Employees (employee_id, name, manager_id, salary) VALUES
(3,  'Mila',      9,   60301),    -- Manager exists (Mikaela)
(12, 'Antonella', NULL, 31000),   -- No manager
(13, 'Emery',     NULL, 67084),   -- No manager
(1,  'Kalel',     11,  21241),    -- Manager 11 exists
(9,  'Mikaela',   NULL, 50937),   -- No manager
(11, 'Joziah',    6,   28485);    -- Manager 6 DOES NOT exist ? manager left


--------------------------------------------------------------
-- (Optional) View data
--------------------------------------------------------------
-- SELECT * FROM Employees;


/* ==========================================================================================
   METHOD 1: Using a Subquery
============================================================================================== */
SELECT employee_id
FROM Employees
WHERE salary < 30000
  AND manager_id NOT IN (SELECT employee_id FROM Employees)   -- manager no longer exists
ORDER BY employee_id;


/* ==========================================================================================
   METHOD 2: Using a LEFT JOIN (Self Join)
============================================================================================== */
SELECT e1.employee_id
FROM Employees e1
LEFT JOIN Employees e2
       ON e1.manager_id = e2.employee_id   -- attempt to find the manager
WHERE e1.salary < 30000
  AND e1.manager_id IS NOT NULL            -- exclude top-level employees
  AND e2.employee_id IS NULL               -- manager not found = manager left
ORDER BY e1.employee_id;
