/* ============================================================
   PURPOSE
   ------------------------------------------------------------
   This query is designed to find the second-highest salary 
   within each department (Sales, IT, Marketing, HR, etc.).
   
   BUSINESS RULES
   ------------------------------------------------------------
   - For each department, we are ranking employees based on their
     salary in descending order.
   - The query filters out the highest salary (rank 1) and returns
     the employee(s) with the second-highest salary (rank 2).
   
   HOW THE QUERY WORKS (STEP-BY-STEP)
   ------------------------------------------------------------
   1) The table `Employees` holds employee details like `emp_id`, 
      `salary`, and `dept`.
   2) The subquery applies the `DENSE_RANK()` window function to 
      each department, ranking employees based on their salary 
      (highest to lowest).
   3) The outer query filters for employees who are ranked as 
      `2` (second-highest salary).
   4) The final result is ordered by employee ID (`emp_id`).
   ============================================================ */


/* ============================================================
   TABLE SCHEMA
   ------------------------------------------------------------
   employees:
   Stores details of employees in various departments.
   ============================================================ */

CREATE TABLE Employees (
    emp_id INT,              -- Unique identifier for each employee
    salary INT,              -- Salary of the employee
    dept VARCHAR(50)         -- Department in which the employee works
);


/* ============================================================
   SAMPLE DATA
   ------------------------------------------------------------
   Inserting employee records for testing the query.
   ============================================================ */

TRUNCATE TABLE employees;


/* Sample employee data */
INSERT INTO employees (emp_id, salary, dept) VALUES ('1', '70000', 'Sales');
INSERT INTO employees (emp_id, salary, dept) VALUES ('2', '80000', 'Sales');
INSERT INTO employees (emp_id, salary, dept) VALUES ('3', '80000', 'Sales');
INSERT INTO employees (emp_id, salary, dept) VALUES ('4', '90000', 'Sales');
INSERT INTO employees (emp_id, salary, dept) VALUES ('5', '55000', 'IT');
INSERT INTO employees (emp_id, salary, dept) VALUES ('6', '65000', 'IT');
INSERT INTO employees (emp_id, salary, dept) VALUES ('7', '65000', 'IT');
INSERT INTO employees (emp_id, salary, dept) VALUES ('8', '50000', 'Marketing');
INSERT INTO employees (emp_id, salary, dept) VALUES ('9', '55000', 'Marketing');
INSERT INTO employees (emp_id, salary, dept) VALUES ('10', '55000', 'HR');


/* ============================================================
   QUERY (UNCHANGED)
   ------------------------------------------------------------
   The query below finds the second-highest salary per department.
   ============================================================ */

SELECT * FROM Employees;

SELECT
    emp_id,
    dept
FROM (
    SELECT
        *, 
        DENSE_RANK() OVER (PARTITION BY dept ORDER BY salary DESC) AS rnk
    FROM employees
) t
WHERE rnk = 2
ORDER BY 1;
