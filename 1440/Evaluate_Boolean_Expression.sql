/***********************************************************************************************
Purpose:
    Evaluate boolean expressions stored in the Expressions table by comparing the values of 
    variables defined in the Variables table.

Business Rules:
    • Each expression compares two variables using one of these operators: < , > , =
    • The left_operand and right_operand must exist in the Variables table.
    • The query should return True or False depending on whether the comparison is correct.

How the Query Works (Step-by-Step):
    1. Join Expressions to Variables twice:
         - First join maps left_operand to its numeric value (v1).
         - Second join maps right_operand to its numeric value (v2).
    2. A CASE expression evaluates the stored operator:
         - If operator = '<', check whether v1.value < v2.value.
         - If operator = '=', check whether v1.value = v2.value.
         - If operator = '>', check whether v1.value > v2.value.
    3. Output the original expression plus the result ("True" or "False").

***********************************************************************************************/

------------------------------------------------------------
-- DROP TABLES IF THEY ALREADY EXIST (PREVENTS ERRORS)
------------------------------------------------------------
IF OBJECT_ID('dbo.Expressions', 'U') IS NOT NULL DROP TABLE dbo.Expressions;
IF OBJECT_ID('dbo.Variables', 'U') IS NOT NULL DROP TABLE dbo.Variables;
GO


------------------------------------------------------------
-- CREATE TABLE: Variables
-- Stores variable names and their integer values.
------------------------------------------------------------
CREATE TABLE Variables (
    name  VARCHAR(255) PRIMARY KEY,   -- Variable name (unique)
    value INT NOT NULL                -- Numeric value assigned to the variable
);
GO


------------------------------------------------------------
-- CREATE TABLE: Expressions
-- Stores boolean expressions referencing variables.
------------------------------------------------------------
CREATE TABLE Expressions (
    left_operand  VARCHAR(255) NOT NULL,  -- Name of the variable on the left side
    operator      VARCHAR(1) NOT NULL,    -- Comparison operator (<, >, =)
    right_operand VARCHAR(255) NOT NULL,  -- Name of the variable on the right side

    CONSTRAINT PK_Expressions PRIMARY KEY (left_operand, operator, right_operand),

    -- Ensure operator is one of the allowed symbols
    CONSTRAINT CK_Operator CHECK (operator IN ('<', '>', '=')),

    -- Foreign key ensures operands exist in Variables table
    CONSTRAINT FK_LeftOperand FOREIGN KEY (left_operand) REFERENCES Variables(name),
    CONSTRAINT FK_RightOperand FOREIGN KEY (right_operand) REFERENCES Variables(name)
);
GO


------------------------------------------------------------
-- SAMPLE DATA FOR Variables
------------------------------------------------------------
INSERT INTO Variables (name, value) VALUES
('x', 66),
('y', 77);
GO


------------------------------------------------------------
-- SAMPLE DATA FOR Expressions
-- Each row represents a boolean comparison between two variables.
------------------------------------------------------------
INSERT INTO Expressions (left_operand, operator, right_operand) VALUES
('x', '>', 'y'),
('x', '<', 'y'),
('x', '=', 'y'),
('y', '>', 'x'),
('y', '<', 'x'),
('x', '=', 'x');
GO


------------------------------------------------------------
-- CONFIRM DATA WAS INSERTED
------------------------------------------------------------
SELECT * FROM Variables;
SELECT * FROM Expressions;


------------------------------------------------------------
-- MAIN QUERY: Evaluate Boolean Expressions
------------------------------------------------------------
SELECT 
    e.left_operand,
    e.operator,
    e.right_operand,

    -- CASE determines if expression is True or False based on operator
    CASE
        WHEN e.operator = '<' AND v1.value < v2.value THEN 'True'
        WHEN e.operator = '=' AND v1.value = v2.value THEN 'True'
        WHEN e.operator = '>' AND v1.value > v2.value THEN 'True'
        ELSE 'False'
    END AS value
FROM Expressions e
LEFT JOIN Variables v1 
    ON e.left_operand = v1.name       -- Get value for left operand
LEFT JOIN Variables v2 
    ON e.right_operand = v2.name;     -- Get value for right operand
GO
