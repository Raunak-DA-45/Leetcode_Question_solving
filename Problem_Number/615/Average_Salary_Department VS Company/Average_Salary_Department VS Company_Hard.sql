/*
Purpose:
This query calculates the average salary per department and compares it to the company's average salary for each month.
It outputs whether each department's average salary is higher, lower, or the same as the company's average salary.

Business Rules:
1. Employee-Department Mapping:
   - Each employee belongs to a single department.

2. Salary Records:
   - Each salary record has a date (`pay_date`), employee ID, and amount.

3. Monthly Aggregation:
   - Salaries are aggregated per month using the format 'yyyy-MM'.

4. Average Calculation:
   - Department Average: Average salary for each department per month.
   - Company Average: Average salary across all employees per month.

5. Comparison Rule:
   - If department average > company average → label as 'higher'.
   - If department average = company average → label as 'same'.
   - If department average < company average → label as 'lower'.

6. Output Requirement:
   - Display one row per department per month with its comparison to the company average.

How the Query Works:
1. Data Setup:
   - Two tables are created: employee and salary.
   - Sample data is inserted for demonstration purposes.

2. Window Functions:
   - AVG() OVER(PARTITION BY ...) calculates averages without collapsing rows.
   - company_avg: Partitioned by month → average of all salaries that month.
   - dept_avg: Partitioned by month and department → average of salaries within the department that month.

3. CTE (Common Table Expression):
   - Named 'cte1'.
   - Joins salary with employee to attach department information.
   - Adds calculated columns for pay_month, company_avg, and dept_avg.

4. Comparison Step:
   - Select distinct pay_month and department_id.
   - Use CASE to compare dept_avg with company_avg and label higher/same/lower.

5. Final Output:
   - For each month and department, indicates whether that department’s average salary is higher, same, or lower than the company's monthly average.
*/

-- Drop tables if they exist to allow re-creation
IF OBJECT_ID('salary', 'U') IS NOT NULL DROP TABLE salary;
IF OBJECT_ID('employee', 'U') IS NOT NULL DROP TABLE employee;

-- Create Employee table with primary key
CREATE TABLE employee (
    employee_id INT PRIMARY KEY,
    department_id INT NOT NULL
);

-- Insert sample employee data
INSERT INTO employee (employee_id, department_id) VALUES
(1, 1),
(2, 2),
(3, 2);

-- Create Salary table with foreign key reference to Employee
CREATE TABLE salary (
    id INT PRIMARY KEY,
    employee_id INT NOT NULL,
    amount INT NOT NULL,
    pay_date DATE NOT NULL,
    CONSTRAINT FK_salary_employee FOREIGN KEY (employee_id) REFERENCES employee(employee_id)
);

-- Insert sample salary data
INSERT INTO salary (id, employee_id, amount, pay_date) VALUES
(1, 1, 9000, '2017-03-31'),
(2, 2, 6000, '2017-03-31'),
(3, 3, 10000, '2017-03-31'),
(4, 1, 7000, '2017-02-28'),
(5, 2, 6000, '2017-02-28'),
(6, 3, 8000, '2017-02-28');

-- View raw salary and employee tables for reference
SELECT * FROM salary;
SELECT * FROM employee;

-- Calculate department and company averages for each month
WITH nandini AS (
    SELECT 
        s.employee_id,
        s.amount,
        FORMAT(s.pay_date,'yyyy-MM') AS pay_month, -- Extract month in 'yyyy-MM' format
        e.department_id,
        AVG(s.amount) OVER(PARTITION BY FORMAT(s.pay_date,'yyyy-MM')) AS company_avg, -- Company average per month
        ROUND(
            AVG(CAST(amount AS FLOAT)) OVER(PARTITION BY FORMAT(s.pay_date,'yyyy-MM'), department_id), 2
        ) AS dept_avg -- Department average per month
    FROM salary s
    INNER JOIN employee e
        ON s.employee_id = e.employee_id
)

-- Compare department average to company average
SELECT DISTINCT
    pay_month,
    department_id,
    CASE
        WHEN dept_avg > company_avg THEN 'higher'
        WHEN dept_avg = company_avg THEN 'same'
        ELSE 'lower'
    END AS comparison
FROM nandini;


-- Drop tables if they exist
IF OBJECT_ID('salary', 'U') IS NOT NULL DROP TABLE salary;
IF OBJECT_ID('employee', 'U') IS NOT NULL DROP TABLE employee;

-- Create Employee table
CREATE TABLE employee (
    employee_id INT PRIMARY KEY,
    department_id INT NOT NULL
);

-- Insert sample data into Employee table
INSERT INTO employee (employee_id, department_id) VALUES
(1, 1),
(2, 2),
(3, 2);

-- Create Salary table
CREATE TABLE salary (
    id INT PRIMARY KEY,
    employee_id INT NOT NULL,
    amount INT NOT NULL,
    pay_date DATE NOT NULL,
    CONSTRAINT FK_salary_employee FOREIGN KEY (employee_id) REFERENCES employee(employee_id)
);

-- Insert sample data into Salary table
INSERT INTO salary (id, employee_id, amount, pay_date) VALUES
(1, 1, 9000, '2017-03-31'),
(2, 2, 6000, '2017-03-31'),
(3, 3, 10000, '2017-03-31'),
(4, 1, 7000, '2017-02-28'),
(5, 2, 6000, '2017-02-28'),
(6, 3, 8000, '2017-02-28');
select * from salary;
select * from employee;
with cte1 as (
select 
    s.employee_id,
    s.amount,
    format(s.pay_date,'yyyy-MM') as pay_month,
    e.department_id,
    avg(s.amount) over(partition by format(s.pay_date,'yyyy-MM')) as company_avg,
    round(avg(CAST(amount as float)) over(partition by format(s.pay_date,'yyyy-MM'),department_id),2) as dept_avg
from salary s
inner join employee e
on s.employee_id = e.employee_id)

select distinct
    pay_month,
    department_id,
    case
        when dept_avg > company_avg then 'higher'
        when dept_avg = company_avg then 'same'
        else 'lower'
    end as comparison
from cte1





