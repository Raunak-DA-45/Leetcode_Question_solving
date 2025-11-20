---------------------------------------
-- DROP TABLE IF EXISTS
---------------------------------------
IF OBJECT_ID('dbo.Candidates', 'U') IS NOT NULL
    DROP TABLE dbo.Candidates;
GO

---------------------------------------
-- CREATE TABLE (T-SQL compatible)
---------------------------------------
CREATE TABLE Candidates (
    employee_id INT PRIMARY KEY,
    experience VARCHAR(10) CHECK (experience IN ('Senior', 'Junior')),
    salary INT NOT NULL
);
GO

---------------------------------------
-- SAMPLE DATA (Example 1)
---------------------------------------
INSERT INTO Candidates (employee_id, experience, salary) VALUES
(1, 'Junior', 10000),
(9, 'Junior', 10000),
(2, 'Senior', 20000),
(11, 'Senior', 20000),
(13, 'Senior', 50000),
(4, 'Junior', 40000);

-- ---------------------------------------
-- SAMPLE DATA (Example 2)
-- Uncomment this block if you want example 2
-- ---------------------------------------
-- DELETE FROM Candidates;
--INSERT INTO Candidates (employee_id, experience, salary) VALUES
--(1, 'Junior', 10000),
--(9, 'Junior', 10000),
--(2, 'Senior', 80000),
--(11, 'Senior', 80000),
--(13, 'Senior', 80000),
--(4, 'Junior', 40000);
GO
select * from Candidates;

--A company wants to hire new employees. 
--The budget of the company for the salaries is $70000. 
--The company's criteria for hiring are:

/*Hiring the largest number of seniors.
After hiring the maximum number of seniors, use the remaining budget to hire the largest number of juniors.
Write an SQL query to find the number of seniors and juniors hired under the mentioned criteria.
Return the result table in any order.
The query result format is in the following example.*/
with raunak as (
select
    *,
    sum(salary) over(partition by experience order by salary rows unbounded preceding) as running_total
from candidates)

select 'senior' as experience,isnull(count(employee_id),0) as accepted_candidates
from raunak
where experience = 'senior' and running_total <= 70000
union all
select 'junior' as experience,isnull(count(employee_id),0) as accepted_candidates
from raunak
where experience='junior' and running_total <= 70000
-isnull((select max(running_total) from raunak where experience = 'senior' and running_total <=70000),0)
