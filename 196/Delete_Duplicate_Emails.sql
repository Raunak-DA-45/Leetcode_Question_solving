/* 
===========================================================================================
PURPOSE OF THIS SCRIPT
----------------------
This script demonstrates two different SQL Server methods to delete duplicate emails 
from the Person table, while keeping the *single record with the smallest Id* for each 
email address.

BUSINESS RULES IMPLEMENTED
--------------------------
1. Each email must appear only once in the Person table after cleanup.
2. If duplicates exist, the row with the smallest Id must be kept.
3. All other rows with the same email and a higher Id must be deleted.

HOW THE QUERY WORKS (STEP-BY-STEP)
----------------------------------
1. A Person table is created if it does not already exist.
2. The table is cleared and loaded with sample data containing duplicates.
3. Two methods are provided to remove duplicates:
   

4. Finally, SELECT * FROM Person shows the cleaned dataset.

===========================================================================================
*/


/*******************************************************************************************
 SCHEMA CREATION
 A simple Person table storing Id (unique identifier) and Email (login/contact value).
*******************************************************************************************/
IF NOT EXISTS (
    SELECT 1 
    FROM sys.objects 
    WHERE object_id = OBJECT_ID(N'dbo.Person') 
      AND type = 'U'
)
BEGIN
    CREATE TABLE dbo.Person (
        Id INT,                -- Unique identifier for each person
        Email VARCHAR(255)     -- Email address (duplicates may exist in sample data)
    );
END
GO


/*******************************************************************************************
 LOAD SAMPLE DATA
 This dataset intentionally contains a duplicate email: "john@example.com".
*******************************************************************************************/
TRUNCATE TABLE dbo.Person;
GO

INSERT INTO dbo.Person (Id, Email) VALUES (1, 'john@example.com');
INSERT INTO dbo.Person (Id, Email) VALUES (2, 'bob@example.com');
INSERT INTO dbo.Person (Id, Email) VALUES (3, 'john@example.com');   -- duplicate email
GO


/*******************************************************************************************
 METHOD 1: REMOVE DUPLICATES USING SELF-JOIN DELETE
 Deletes rows whose email is duplicated AND whose Id is greater than another row's Id.
*******************************************************************************************/
DELETE p1
FROM dbo.Person p1
INNER JOIN dbo.Person p2
    ON p1.Email = p2.Email
   AND p1.Id > p2.Id;   -- ensures only higher Id duplicates are deleted


/*******************************************************************************************
 METHOD 2: REMOVE DUPLICATES USING WINDOW FUNCTION
 Assigns row numbers within each email group and deletes rows with row_number > 1.
*******************************************************************************************/
WITH Dedup AS (
    SELECT 
        *, 
        ROW_NUMBER() OVER (PARTITION BY Email ORDER BY Id) AS rn
    FROM dbo.Person
)
DELETE FROM Dedup WHERE rn > 1;
-- rn=1 = smallest Id = keep
-- rn>1 = duplicates = delete


/*******************************************************************************************
 FINAL RESULT
 The table now contains UNIQUE emails, keeping the smallest Id for each.
*******************************************************************************************/
SELECT * FROM dbo.Person;
