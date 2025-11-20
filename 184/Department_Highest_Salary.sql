/************************************************************************************************
-- Purpose:
-- This script retrieves the highest-paid employee(s) from each department.
-- Business Rules:
-- 1. Each department may have multiple employees.
-- 2. Only the employee(s) with the maximum salary in their department should be returned.
-- How it works step-by-step:
--   a. The Employee table contains employee details including salary and department ID.
--   b. The Department table contains department names and IDs.
--   c. Join Employee and Department tables to get the department name for each employee.
--   d. Two alternate methods are demonstrated:
--       Method 1: Using RANK() to rank employees by salary within each department.
--       Method 2: Using MAX() OVER() window function to determine top salary per department.
--   e. Filter results to include only top-paid employee(s) in each department.
************************************************************************************************/

-- ================================
-- SCHEMA CREATION AND SAMPLE DATA
-- ================================

-- Drop tables if they exist to avoid errors on re-run
IF OBJECT_ID('dbo.Employee', 'U') IS NOT NULL
    DROP TABLE dbo.Employee;

IF OBJECT_ID('dbo.Department', 'U') IS NOT NULL
    DROP TABLE dbo.Department;

-- Create Department table
CREATE TABLE dbo.Department (
    id INT PRIMARY KEY,        -- Department ID
    name VARCHAR(255)          -- Department Name
);

-- Create Employee table
CREATE TABLE dbo.Employee (
    id INT PRIMARY KEY,        -- Employee ID
    name VARCHAR(255),         -- Employee Name
    salary INT,                -- Employee Salary
    departmentId INT           -- Foreign Key referencing Department
);

-- Insert sample data into Department table
INSERT INTO dbo.Department (id, name) VALUES
(1, 'IT'),
(2, 'Sales');

-- Insert sample data into Employee table
INSERT INTO dbo.Employee (id, name, salary, departmentId) VALUES
(1, 'Joe', 70000, 1),
(2, 'Jim', 90000, 1),
(3, 'Henry', 80000, 2),
(4, 'Sam', 60000, 2),
(5, 'Max', 90000, 1);

-- ================================
-- METHOD 1: Using RANK()
-- ================================
WITH cte_rank AS (
    SELECT 
        d.name AS department,         -- Department name
        e.name AS employee,           -- Employee name
        e.salary AS salary,           -- Employee salary
        RANK() OVER(PARTITION BY d.name ORDER BY e.salary DESC) AS r1  -- Rank employees by salary within each department
    FROM dbo.Employee e
    INNER JOIN dbo.Department d
        ON e.departmentId = d.id
)
SELECT 
    department,
    employee,
    salary
FROM cte_rank
WHERE r1 = 1;  -- Only include top-paid employee(s) per department

-- ================================
-- METHOD 2: Using MAX() OVER()
-- ================================
WITH cte1 AS (
    SELECT 
        e.name AS employee,                 -- Employee name
        e.salary AS salary,                 -- Employee salary
        d.name AS department,               -- Department name
        MAX(e.salary) OVER(PARTITION BY d.name) AS max_salary  -- Maximum salary per department
    FROM dbo.Employee e
    INNER JOIN dbo.Department d
        ON e.departmentId = d.id
)
SELECT 
    department,
    employee,
    salary
FROM cte1
WHERE salary = max_salary;  -- Only include top-paid employee(s) per department



