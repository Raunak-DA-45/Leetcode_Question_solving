/* ============================================================
   PURPOSE
   --------
   This query counts how many files mention the words
   "bull" and "bear" in their text content.

   BUSINESS RULES
   --------------
   1. Each file is counted at most once per word:
      - If a file contains the word "bull", it contributes 1.
      - If a file contains the word "bear", it contributes 1.
   2. The search is case-insensitive (default behavior in most
      SQL Server collations).
   3. Words are matched with surrounding spaces to avoid
      partial matches (e.g., "bullet" should not match "bull").

   STEP-BY-STEP LOGIC
   ------------------
   1. Create and populate the Files table with sample text data.
   2. Scan file contents for the word "bull".
   3. Scan file contents for the word "bear".
   4. Aggregate results so each word returns a single count.
   ============================================================ */


/* ============================================================
   TABLE SCHEMA
   ============================================================ */

-- Files table represents text files stored in the system.
CREATE TABLE Files (
    file_name VARCHAR(100),  -- Name of the file
    content   TEXT           -- Full textual content of the file
);


/* ============================================================
   SAMPLE DATA
   ============================================================ */

-- Clear existing data so the script can be re-run safely
TRUNCATE TABLE Files;

-- Insert sample file contents
INSERT INTO Files (file_name, content)
VALUES (
    'draft1.txt',
    'The stock exchange predicts a bull market which would make many investors happy.'
);

INSERT INTO Files (file_name, content)
VALUES (
    'draft2.txt',
    'The stock exchange predicts a bull market which would make many investors happy, 
     but analysts warn of possibility of too much optimism and that in fact we are awaiting a bear market.'
);

INSERT INTO Files (file_name, content)
VALUES (
    'final.txt',
    'The stock exchange predicts a bull market which would make many investors happy, 
     but analysts warn of possibility of too much optimism and that in fact we are awaiting a bear market. 
     As always predicting the future market is an uncertain game and all investors should follow their instincts and best practices.'
);

-- View the raw data
SELECT * FROM Files;


/* ============================================================
   WORD COUNT QUERY
   ============================================================ */

-- Count how many files contain the word "bull"
SELECT
    'bull' AS word,
    SUM(IIF(content LIKE '% bull %', 1, 0)) AS count
FROM Files

UNION ALL

-- Count how many files contain the word "bear"
SELECT
    'bear' AS word,
    SUM(IIF(content LIKE '% bear %', 1, 0)) AS count
FROM Files;
