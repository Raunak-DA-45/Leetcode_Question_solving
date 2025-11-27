/*
==================================================================================
Purpose: 
    Find the N-th highest distinct salary from the Employee table. 
    If there are fewer than N distinct salaries, return NULL.

Business Rules Implemented:
    1. Employee table contains employee Id and Salary.
    2. The function dbo.getNthHighestSalary takes an integer N as input.
    3. Returns the N-th highest distinct salary.
    4. If N is greater than the number of distinct salaries, returns NULL.

How the query works step-by-step:
    1. Create Employee table if it does not exist.
    2. Insert sample employee data.
    3. Define a function dbo.getNthHighestSalary:
        - Uses DENSE_RANK() to assign ranks to distinct salaries in descending order.
        - Selects the salary where rank = N.
        - Returns NULL if N is larger than the number of distinct salaries.
==================================================================================
*/

-- ===============================
-- STEP 1: Create Employee Table
-- ===============================
IF NOT EXISTS (SELECT * FROM sys.objects 
               WHERE object_id = OBJECT_ID(N'[dbo].[Employee]') AND type in (N'U'))
BEGIN
    CREATE TABLE Employee (
        Id INT PRIMARY KEY,      -- Unique employee identifier
        Salary INT               -- Employee salary
    )
END

-- ===============================
-- STEP 2: Clear existing data
-- ===============================
TRUNCATE TABLE Employee;  -- Remove all rows to ensure consistent sample data

-- ===============================
-- STEP 3: Insert sample data
-- ===============================
INSERT INTO Employee (Id, Salary) VALUES (1, 100);  -- Employee 1 with salary 100
INSERT INTO Employee (Id, Salary) VALUES (2, 200);  -- Employee 2 with salary 200
INSERT INTO Employee (Id, Salary) VALUES (3, 300);  -- Employee 3 with salary 300

-- View inserted data
SELECT * FROM Employee;

-- ===============================
-- STEP 4: Create function to get N-th highest salary
-- ===============================
GO  -- Ensure function starts in a new batch

CREATE OR ALTER FUNCTION dbo.getNthHighestSalary
(
    @N INT
)
RETURNS INT
AS
BEGIN
    DECLARE @result INT;

    -- Use a CTE to rank distinct salaries in descending order
    ;WITH SalaryRanks AS
    (
        SELECT Salary,
               DENSE_RANK() OVER (ORDER BY Salary DESC) AS RankNum
        FROM Employee
    )
    -- Select the salary where rank = @N
    SELECT TOP 1 @result = Salary
    FROM SalaryRanks
    WHERE RankNum = @N;

    RETURN @result;  -- Returns NULL automatically if @N exceeds available ranks
END;
GO

-- ===============================
-- STEP 5: Test the function
-- ===============================
-- Example: get the 2nd highest salary
SELECT dbo.getNthHighestSalary(2) AS SecondHighestSalary;

-- Example: get the 5th highest salary (does not exist, should return NULL)
SELECT dbo.getNthHighestSalary(5) AS FifthHighestSalary;
