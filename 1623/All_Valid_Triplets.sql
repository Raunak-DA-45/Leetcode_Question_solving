/****************************************************************************************
PURPOSE
-------
This script demonstrates TWO different SQL approaches to generate all valid combinations
of students from three different schools (SchoolA, SchoolB, SchoolC) such that:
- One student is selected from each school
- No two selected students represent the same student

Both methods produce the SAME result set but use different techniques:
1. Method 1: CROSS JOIN with filtering in the WHERE clause
2. Method 2: INNER JOIN with filtering in the JOIN conditions

BUSINESS RULES
--------------
1. Each school contains its own list of students.
2. A valid group must include:
   - One student from SchoolA
   - One student from SchoolB
   - One student from SchoolC
3. A student cannot appear more than once in a group.
   - Uniqueness is enforced using both student_id and student_name.
4. All possible valid combinations that follow these rules must be returned.

STEP-BY-STEP LOGIC
------------------
1. Create and prepare the three school tables.
2. Insert sample data.
3. Display base data for learning and verification.
4. Run Method 1 using CROSS JOIN + WHERE filters.
5. Run Method 2 using INNER JOIN with inequality conditions.
****************************************************************************************/


/****************************************************************************************
TABLE DEFINITIONS
Each table represents students from a different school.
****************************************************************************************/

-- SchoolA: Students from School A
IF OBJECT_ID('dbo.SchoolA', 'U') IS NULL
BEGIN
    CREATE TABLE dbo.SchoolA (
        student_id   INT,          -- Unique student identifier
        student_name VARCHAR(20)   -- Student name
    );
END;

-- SchoolB: Students from School B
IF OBJECT_ID('dbo.SchoolB', 'U') IS NULL
BEGIN
    CREATE TABLE dbo.SchoolB (
        student_id   INT,
        student_name VARCHAR(20)
    );
END;

-- SchoolC: Students from School C
IF OBJECT_ID('dbo.SchoolC', 'U') IS NULL
BEGIN
    CREATE TABLE dbo.SchoolC (
        student_id   INT,
        student_name VARCHAR(20)
    );
END;


/****************************************************************************************
SAMPLE DATA
****************************************************************************************/

-- Clear existing data so the script is rerunnable
TRUNCATE TABLE dbo.SchoolA;
TRUNCATE TABLE dbo.SchoolB;
TRUNCATE TABLE dbo.SchoolC;

-- Insert sample students for SchoolA
INSERT INTO dbo.SchoolA (student_id, student_name) VALUES
(1, 'Alice'),
(2, 'Bob');

-- Insert sample students for SchoolB
INSERT INTO dbo.SchoolB (student_id, student_name) VALUES
(3, 'Tom');

-- Insert sample students for SchoolC
INSERT INTO dbo.SchoolC (student_id, student_name) VALUES
(3,  'Tom'),     -- Same as SchoolB (should be excluded together)
(2,  'Jerry'),
(10, 'Alice');   -- Same name as SchoolA but different ID


/****************************************************************************************
BASE DATA (for understanding)
****************************************************************************************/
SELECT * FROM dbo.SchoolA;
SELECT * FROM dbo.SchoolB;
SELECT * FROM dbo.SchoolC;


/****************************************************************************************
METHOD 1: CROSS JOIN + WHERE FILTERING
----------------------------------------------------------------------------------------
- Creates all possible combinations (Cartesian product).
- WHERE clause removes invalid combinations.
- Easier to understand for beginners, but less efficient for large datasets.
****************************************************************************************/

SELECT
    a.student_name AS member_A,
    b.student_name AS member_B,
    c.student_name AS member_C
FROM dbo.SchoolA a
CROSS JOIN dbo.SchoolB b
CROSS JOIN dbo.SchoolC c
WHERE
    -- Ensure SchoolA and SchoolB students are different
    a.student_id   <> b.student_id
AND a.student_name <> b.student_name

    -- Ensure SchoolB and SchoolC students are different
AND b.student_id   <> c.student_id
AND b.student_name <> c.student_name

    -- Ensure SchoolA and SchoolC students are different
AND a.student_id   <> c.student_id
AND a.student_name <> c.student_name;


/****************************************************************************************
METHOD 2: INNER JOIN WITH(MORE OPTIMIZED WAY)
----------------------------------------------------------------------------------------
- Filters rows earlier during joins instead of after forming all combinations.
- More optimized and preferred in real-world scenarios.
- Produces the SAME result as Method 1.
****************************************************************************************/

SELECT
    a.student_name AS member_A,
    b.student_name AS member_B,
    c.student_name AS member_C
FROM dbo.SchoolA a
INNER JOIN dbo.SchoolB b
    -- Exclude same student between SchoolA and SchoolB
    ON a.student_id   <> b.student_id
   AND a.student_name <> b.student_name
INNER JOIN dbo.SchoolC c
    -- Exclude same student across all three schools
    ON c.student_id   <> a.student_id
   AND c.student_id   <> b.student_id
   AND c.student_name <> a.student_name
   AND c.student_name <> b.student_name;
