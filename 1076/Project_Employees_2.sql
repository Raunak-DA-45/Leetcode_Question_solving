/* ==========================================================================================
   PURPOSE OF THIS SCRIPT
   ------------------------------------------------------------------------------------------
   This script identifies **which project(s)** have the **highest number of employees**
   assigned to them. If more than one project is tied for the maximum employee count,
   all such projects must be returned.

   HOW THE QUERY WORKS (Two Methods Provided)
   ------------------------------------------------------------------------------------------
   Method 1 (Aggregate + Subquery):
     1. Count how many employees are assigned to each project.
     2. Compare each project's employee count to the maximum count.
     3. Return all project_ids that match the maximum.

   Method 2 (Window Function):
     1. Count employees per project (same as Method 1).
     2. Apply ROW_NUMBER or RANK (here ROW_NUMBER is used).
     3. Select the project(s) ranked #1 by employee count.

   Both methods produce the same correct output.
============================================================================================== */


----------------------------------------------------------------------------------------------
-- SCHEMA: Employee table
-- Represents employees in the company.
-- employee_id       : Unique identifier
-- name              : Employee name
-- experience_years  : Number of years of experience
----------------------------------------------------------------------------------------------
IF OBJECT_ID('dbo.Employee', 'U') IS NOT NULL
    DROP TABLE dbo.Employee;

CREATE TABLE dbo.Employee (
    employee_id INT PRIMARY KEY,
    name VARCHAR(50),
    experience_years INT
);


-- Clear existing data to make this script fully rerunnable
TRUNCATE TABLE Employee;


----------------------------------------------------------------------------------------------
-- SAMPLE DATA: Employees
-- Provides a small set of employees with varying experience levels.
----------------------------------------------------------------------------------------------
INSERT INTO Employee (employee_id, name, experience_years) VALUES
(1, 'Khaled', 3),
(2, 'Ali', 2),
(3, 'John', 1),
(4, 'Doe', 2);


----------------------------------------------------------------------------------------------
-- SCHEMA: Project table
-- Represents employee assignments to projects.
-- project_id  : Identifier for the project
-- employee_id : Employee assigned to that project
-- PRIMARY KEY ensures one employee cannot be assigned twice to the same project.
----------------------------------------------------------------------------------------------
IF OBJECT_ID('dbo.Project', 'U') IS NOT NULL
    DROP TABLE dbo.Project;

CREATE TABLE dbo.Project (
    project_id INT,
    employee_id INT,
    PRIMARY KEY (project_id, employee_id),
    FOREIGN KEY (employee_id) REFERENCES Employee(employee_id)
);


-- Clear existing data
TRUNCATE TABLE Project;


----------------------------------------------------------------------------------------------
-- SAMPLE DATA: Project assignments
-- Project 1 has three employees (1,2,3).
-- Project 2 has two employees (1,4).
-- Therefore, Project 1 should be returned as having the most employees.
----------------------------------------------------------------------------------------------
INSERT INTO Project (project_id, employee_id) VALUES
(1, 1),
(1, 2),
(1, 3),
(2, 1),
(2, 4);


----------------------------------------------------------------------------------------------
-- View sample data (optional for beginners)
----------------------------------------------------------------------------------------------
SELECT * FROM Project;
SELECT * FROM Employee;



/* ==========================================================================================
   METHOD 1: Aggregation + MAX() Subquery
   - Count employees per project
   - Identify the project(s) with the highest count
============================================================================================== */

WITH project_counts AS (
    SELECT 
        project_id,
        COUNT(employee_id) AS employee_count
    FROM Project
    GROUP BY project_id
)
SELECT project_id
FROM project_counts
WHERE employee_count = (
    SELECT MAX(employee_count) FROM project_counts   -- only keep projects with max employees
);



/* ==========================================================================================
   METHOD 2: Using Window Function (ROW_NUMBER)
   - Counts employees per project
   - Ranks projects by descending employee count
   - Returns only rank 1 projects
============================================================================================== */

WITH project_counts AS (
    SELECT 
        project_id,
        COUNT(employee_id) AS employee_count
    FROM Project
    GROUP BY project_id
),
ranked_projects AS (
    SELECT 
        project_id,
        employee_count,
        ROW_NUMBER() OVER (ORDER BY employee_count DESC) AS row_num
        -- ROW_NUMBER returns exactly 1 row if there is a tie; use RANK if ties should be included
)
SELECT project_id
FROM ranked_projects
WHERE row_num = 1;   -- top-ranked project(s)