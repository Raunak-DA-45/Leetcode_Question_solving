/* 
============================================================
PURPOSE:
--------
Return the list of students who received an 'A' grade 
in ALL courses required for their major.

BUSINESS RULES:
---------------
1. Each student belongs to exactly one major.
2. Each course is assigned to exactly one major.
3. A student is expected to take all courses that belong to their major.
4. A student qualifies only if:
      - They are enrolled in every course of their major
      - AND they received grade = 'A' in all of them
5. If even one required course is not an 'A', the student is excluded.

HOW THE QUERY WORKS (STEP-BY-STEP):
-----------------------------------
1. Join students to courses using major to determine which courses
   each student is REQUIRED to take.
2. LEFT JOIN enrollments to check the grade received for each required course.
3. GROUP BY student to evaluate results at the student level.
4. Compare:
      - Total required courses (COUNT DISTINCT course_id)
      - Number of courses where grade = 'A'
5. If both numbers match, the student received 'A' in every required course.
============================================================
*/


/* ============================================================
   TABLE: students
   ------------------------------------------------------------
   Stores student master data.
   - student_id : Unique identifier for each student
   - name       : Student name
   - major      : The academic major the student belongs to
============================================================ */

DROP TABLE IF EXISTS students;

CREATE TABLE students (
    student_id INT,
    name VARCHAR(255),
    major VARCHAR(255)
);

INSERT INTO students (student_id, name, major) VALUES 
(1, 'Alice',   'Computer Science'),
(2, 'Bob',     'Computer Science'),
(3, 'Charlie', 'Mathematics'),
(4, 'David',   'Mathematics');



/* ============================================================
   TABLE: courses
   ------------------------------------------------------------
   Stores course catalog information.
   - course_id : Unique course identifier
   - name      : Course name
   - credits   : Number of credit hours
   - major     : Major that the course belongs to
============================================================ */

DROP TABLE IF EXISTS courses;

CREATE TABLE courses (
    course_id INT,
    name VARCHAR(255),
    credits INT,
    major VARCHAR(255)
);

INSERT INTO courses (course_id, name, credits, major) VALUES 
(101, 'Algorithms',       3, 'Computer Science'),
(102, 'Data Structures',  3, 'Computer Science'),
(103, 'Calculus',         4, 'Mathematics'),
(104, 'Linear Algebra',   4, 'Mathematics');



/* ============================================================
   TABLE: enrollments
   ------------------------------------------------------------
   Stores which student took which course and their grade.
   - student_id : References students.student_id
   - course_id  : References courses.course_id
   - semester   : Academic term
   - grade      : Final letter grade
============================================================ */

DROP TABLE IF EXISTS enrollments;

CREATE TABLE enrollments (
    student_id INT,
    course_id INT,
    semester VARCHAR(255),
    grade VARCHAR(10)
);

INSERT INTO enrollments (student_id, course_id, semester, grade) VALUES 
(1, 101, 'Fall 2023', 'A'),
(1, 102, 'Fall 2023', 'A'),
(2, 101, 'Fall 2023', 'B'),
(2, 102, 'Fall 2023', 'A'),
(3, 103, 'Fall 2023', 'A'),
(3, 104, 'Fall 2023', 'A'),
(4, 103, 'Fall 2023', 'A'),
(4, 104, 'Fall 2023', 'B');



/* ============================================================
   MAIN QUERY
   ------------------------------------------------------------
   Returns students who received 'A' in ALL courses 
   of their respective major.
============================================================ */

SELECT
    s.student_id
FROM students s

-- Join to determine all courses required for the student's major
LEFT JOIN courses c
    ON s.major = c.major

-- Join to check enrollment and grade for each required course
LEFT JOIN enrollments e
    ON e.student_id = s.student_id
   AND e.course_id  = c.course_id

GROUP BY s.student_id

HAVING 
    -- Total required courses for the student's major
    COUNT(DISTINCT c.course_id)
    
    =
    
    -- Number of required courses where student received 'A'
    SUM(CASE WHEN e.grade = 'A' THEN 1 ELSE 0 END)

ORDER BY s.student_id;