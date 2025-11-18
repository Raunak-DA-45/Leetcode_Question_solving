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
with nandini as (
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
from nandini




