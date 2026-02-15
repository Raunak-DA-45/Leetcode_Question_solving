/*****************************************************************************************
Purpose:
--------
Return the list of students who satisfy ALL of the following academic rules:

Business Rules Implemented:
---------------------------
1) The student must receive an 'A' in ALL mandatory courses for their major.
2) The student must receive at least TWO non-mandatory (elective) courses
   with grade 'A' or 'B'.
3) The student's overall average GPA must be at least 2.5.
4) Evaluation is based only on courses that belong to the student's major.

How the Query Works (Step-by-Step):
-----------------------------------
1) Join students to courses based on matching major.
   ? This ensures we evaluate required/elective courses for each student's major.
2) LEFT JOIN enrollments to bring grade and GPA data.
3) GROUP BY student_id to evaluate conditions per student.
4) Use conditional aggregation (SUM with IIF) to:
      - Count mandatory courses.
      - Count mandatory courses passed with 'A'.
      - Count elective courses passed with 'A' or 'B'.
5) Compare counts in HAVING clause to enforce rules.
6) Calculate AVG(GPA) to enforce minimum GPA requirement.
*****************************************************************************************/


/*****************************************************************************************
STEP 1 — CLEANUP (Drop tables in correct dependency order: child ? parent)
*****************************************************************************************/
IF OBJECT_ID('enrollments', 'U') IS NOT NULL DROP TABLE enrollments;
IF OBJECT_ID('courses', 'U') IS NOT NULL DROP TABLE courses;
IF OBJECT_ID('students', 'U') IS NOT NULL DROP TABLE students;



/*****************************************************************************************
STEP 2 — CREATE TABLES
*****************************************************************************************/

-- =====================================
-- TABLE: students
-- Stores basic student information.
-- =====================================
CREATE TABLE students (
    student_id INT PRIMARY KEY,   -- Unique identifier for each student
    name VARCHAR(255),            -- Student full name
    major VARCHAR(255)            -- Student's declared major
);


-- =====================================
-- TABLE: courses
-- Stores course catalog information.
-- =====================================
CREATE TABLE courses (
    course_id INT PRIMARY KEY,    -- Unique course identifier
    name VARCHAR(255),            -- Course name
    credits INT,                  -- Number of credit hours
    major VARCHAR(255),           -- Major this course belongs to
    mandatory VARCHAR(3)          -- Indicates if course is mandatory
        CONSTRAINT CHK_courses_mandatory 
        CHECK (mandatory IN ('Yes','No'))  -- Only allow Yes/No
        DEFAULT 'No'
);


-- =====================================
-- TABLE: enrollments
-- Stores which student took which course,
-- along with grade and GPA value.
-- =====================================
CREATE TABLE enrollments (
    student_id INT,               -- References students.student_id
    course_id INT,                -- References courses.course_id
    semester VARCHAR(255),        -- Semester taken (e.g., Fall 2023)
    grade VARCHAR(10),            -- Letter grade (A, B, etc.)
    GPA DECIMAL(3,2),             -- Numeric GPA equivalent

    CONSTRAINT FK_enrollments_students 
        FOREIGN KEY (student_id) REFERENCES students(student_id),

    CONSTRAINT FK_enrollments_courses 
        FOREIGN KEY (course_id) REFERENCES courses(course_id)
);



/*****************************************************************************************
STEP 3 — INSERT SAMPLE DATA
*****************************************************************************************/

-- Insert sample students
INSERT INTO students VALUES
(1, 'Alice', 'Computer Science'),
(2, 'Bob', 'Computer Science'),
(3, 'Charlie', 'Mathematics'),
(4, 'David', 'Mathematics');


-- Insert sample courses
INSERT INTO courses VALUES
(101, 'Algorithms', 3, 'Computer Science', 'Yes'),
(102, 'Data Structures', 3, 'Computer Science', 'Yes'),
(103, 'Calculus', 4, 'Mathematics', 'Yes'),
(104, 'Linear Algebra', 4, 'Mathematics', 'Yes'),
(105, 'Machine Learning', 3, 'Computer Science', 'No'),
(106, 'Probability', 3, 'Mathematics', 'No'),
(107, 'Operating Systems', 3, 'Computer Science', 'No'),
(108, 'Statistics', 3, 'Mathematics', 'No');


-- Insert enrollments
INSERT INTO enrollments VALUES
(1, 101, 'Fall 2023', 'A', 4.0),
(1, 102, 'Spring 2023', 'A', 4.0),
(1, 105, 'Spring 2023', 'A', 4.0),
(1, 107, 'Fall 2023', 'B', 3.5),
(2, 101, 'Fall 2023', 'A', 4.0),
(2, 102, 'Spring 2023', 'B', 3.0),
(3, 103, 'Fall 2023', 'A', 4.0),
(3, 104, 'Spring 2023', 'A', 4.0),
(3, 106, 'Spring 2023', 'A', 4.0),
(3, 108, 'Fall 2023', 'B', 3.5),
(4, 103, 'Fall 2023', 'B', 3.0),
(4, 104, 'Spring 2023', 'B', 3.0);



/*****************************************************************************************
STEP 4 — FINAL QUERY
*****************************************************************************************/

SELECT
    s.student_id
FROM students s

-- Join courses that belong to the student's major
LEFT JOIN courses c
    ON s.major = c.major

-- Join enrollment records for matching student & course
LEFT JOIN enrollments e
    ON e.student_id = s.student_id
    AND e.course_id = c.course_id

GROUP BY s.student_id

HAVING

    -- Rule 1:
    -- Total mandatory courses must equal
    -- mandatory courses where grade = 'A'
    SUM(IIF(c.mandatory = 'Yes', 1, 0)) =
    SUM(IIF(c.mandatory = 'Yes', 1, 0) *
        IIF(e.grade = 'A', 1, 0))

    AND

    -- Rule 2:
    -- At least 2 elective courses with grade A or B
    SUM(IIF(c.mandatory = 'No', 1, 0) *
        IIF(e.grade IN ('A','B'), 1, 0)) >= 2

    AND

    -- Rule 3:
    -- Minimum average GPA
    AVG(e.GPA * 1.0) >= 2.5

ORDER BY s.student_id;
