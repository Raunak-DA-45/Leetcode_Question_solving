Create table  employees(employee_id int, employee_name varchar(100), manager_id int, salary int)
Truncate table Employees
insert into Employees (employee_id, employee_name, manager_id, salary) values ('1', 'Alice', NULL, '150000')
insert into Employees (employee_id, employee_name, manager_id, salary) values ('2', 'Bob', '1', '120000')
insert into Employees (employee_id, employee_name, manager_id, salary) values ('3', 'Charlie', '1', '110000')
insert into Employees (employee_id, employee_name, manager_id, salary) values ('4', 'David', '2', '105000')
insert into Employees (employee_id, employee_name, manager_id, salary) values ('5', 'Eve', '2', '100000')
insert into Employees (employee_id, employee_name, manager_id, salary) values ('6', 'Frank', '3', '95000')
insert into Employees (employee_id, employee_name, manager_id, salary) values ('7', 'Grace', '3', '98000')
insert into Employees (employee_id, employee_name, manager_id, salary) values ('8', 'Helen', '5', '90000')

select * from employees;

with cte1 as(
select
	*,
	0 as hierarchy_level
from employees
where manager_id is null

union all

select
	e.*,
	t.hierarchy_level+1 as hierarchy_level
from employees e
inner join cte1 t
on e.manager_id=t.employee_id)

select 
	employee_id as subordinate_id,
	employee_name as subordinate_name,
	hierarchy_level,
	salary-(select salary from employees where manager_id is null) as salary_difference
from cte1
where hierarchy_level>0
order by 1,2