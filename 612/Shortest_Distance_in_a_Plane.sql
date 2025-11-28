/********************************************************************************************
Purpose:
    Compute the **shortest Euclidean distance** between all unique pairs of 2D points
    stored in table `point_2d`, rounded to 2 decimal places.

Business Rules:
    • Each row in point_2d represents a unique point in a 2D plane with coordinates (x, y).
    • Distance formula used: sqrt( (x2 - x1)² + (y2 - y1)² )
    • Only **unique** point pairs should be compared — no duplicates, no self-joins.
    • The join condition ensures each pair is considered exactly once by comparing
      only pairs where `(p1.x > p2.x)` OR `(p1.x = p2.x AND p1.y > p2.y)`.

How the Query Works (Step-by-Step):
    1. The table is self-joined to compare every point with every other point.
    2. The join condition filters out:
           - pairs where both points are identical,
           - reversed duplicates (e.g., A?B, B?A),
       keeping only the lexicographically "larger" point as p1.
    3. The distance between each valid pair is computed using POWER() and SQRT().
    4. MIN() selects the shortest distance found among all pairs.
    5. ROUND() formats the final result to 2 decimal places.

********************************************************************************************/

------------------------------------------------------------
-- DROP old table so the script can run without conflicts --
------------------------------------------------------------
IF OBJECT_ID('dbo.point_2d', 'U') IS NOT NULL
    DROP TABLE dbo.point_2d;
GO

------------------------------------------------------------
-- Create table for storing 2D points                     --
-- x : X-coordinate                                       --
-- y : Y-coordinate                                       --
-- Each row = one point in the plane                      --
------------------------------------------------------------
CREATE TABLE dbo.point_2d (
    x INT NOT NULL,
    y INT NOT NULL
);
GO

------------------------------------------------------------
-- Insert sample data                                     --
-- These points represent coordinates on a 2D plane       --
------------------------------------------------------------
INSERT INTO dbo.point_2d (x, y) VALUES
(-1, -1),
(0,  0),
(-1, -2);
GO

------------------------------------------------------------
-- View all points                                        --
------------------------------------------------------------
SELECT * FROM point_2d;
GO

------------------------------------------------------------
-- Query: Shortest distance between any two unique points --
------------------------------------------------------------
SELECT
    ROUND( MIN( SQRT(
        POWER(p2.x - p1.x, 2) +        -- squared difference in x
        POWER(p2.y - p1.y, 2)          -- squared difference in y
    )), 2) AS shortest
FROM point_2d p1
INNER JOIN point_2d p2
    ON  p1.x > p2.x
    OR (p1.x = p2.x AND p1.y > p2.y);  -- ensures unique pairs only
GO