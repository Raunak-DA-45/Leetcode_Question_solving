/********************************************************************************************
Purpose:
    This query calculates how many website visits resulted in 0, 1, 2, ... N transactions.
    It returns a distribution table showing:
        - transactions_count  ? number of transactions during a visit
        - visits_count        ? number of visits that had that many transactions

Business Rules Implemented:
    1. A "visit" is uniquely identified by (user_id, visit_date).
    2. A transaction belongs to a visit ONLY if:
            - user_id matches
            - transaction_date = visit_date
    3. If a visit has no transactions, it must still be counted (0 transactions).
    4. The output must include all counts from 0 up to the maximum number of 
       transactions recorded in a single visit — even if some counts are zero.

How the Query Works (Step-by-Step):
    Step 1: Count number of transactions per visit (CTE1).
    Step 2: Find the maximum transactions in a single visit (CTE2).
    Step 3: Generate a sequence from 0 to max transactions using a recursive CTE (CTE3).
    Step 4: LEFT JOIN the generated sequence with visit counts to build the final distribution.
********************************************************************************************/

---------------------------------------
-- 1??  TABLE SCHEMA
---------------------------------------

-- Table: Visits
-- Stores each time a user visited the platform.
-- One row = one visit per user per day.
CREATE TABLE Visits (
    user_id INT,          -- Unique identifier of the user
    visit_date DATE       -- Date when the user visited
);

-- Table: Transactions
-- Stores purchases made by users.
-- A user can make multiple transactions per day.
CREATE TABLE Transactions (
    user_id INT,             -- User who made the transaction
    transaction_date DATE,   -- Date of transaction (should match visit_date to belong to that visit)
    amount INT               -- Purchase amount (not used in calculation, only counting transactions)
);

---------------------------------------
-- 2??  SAMPLE DATA
---------------------------------------

TRUNCATE TABLE Visits;

-- User visits (multiple visits per user allowed)
INSERT INTO Visits VALUES (1,  '2020-01-01');
INSERT INTO Visits VALUES (2,  '2020-01-02');
INSERT INTO Visits VALUES (12, '2020-01-01');
INSERT INTO Visits VALUES (19, '2020-01-03');
INSERT INTO Visits VALUES (1,  '2020-01-02');
INSERT INTO Visits VALUES (2,  '2020-01-03');
INSERT INTO Visits VALUES (1,  '2020-01-04');
INSERT INTO Visits VALUES (7,  '2020-01-11');
INSERT INTO Visits VALUES (9,  '2020-01-25');
INSERT INTO Visits VALUES (8,  '2020-01-28');

TRUNCATE TABLE Transactions;

-- Transactions (some visits have multiple transactions, some have none)
INSERT INTO Transactions VALUES (1, '2020-01-02', 120);
INSERT INTO Transactions VALUES (2, '2020-01-03', 22);
INSERT INTO Transactions VALUES (7, '2020-01-11', 232);
INSERT INTO Transactions VALUES (1, '2020-01-04', 7);
INSERT INTO Transactions VALUES (9, '2020-01-25', 33);
INSERT INTO Transactions VALUES (9, '2020-01-25', 66);
INSERT INTO Transactions VALUES (8, '2020-01-28', 1);
INSERT INTO Transactions VALUES (9, '2020-01-25', 99);

---------------------------------------
-- 3??  MAIN QUERY
---------------------------------------

WITH cte1 AS (
    -- Count number of transactions per visit
    SELECT
        v.user_id,
        v.visit_date,
        COUNT(t.amount) AS cnt   -- COUNT ignores NULL, so visits with no transactions return 0
    FROM Visits v
    LEFT JOIN Transactions t
        ON v.user_id = t.user_id
        AND t.transaction_date = v.visit_date
    GROUP BY v.user_id, v.visit_date
),

cte2 AS (
    -- Get maximum number of transactions in a single visit
    SELECT MAX(cnt) AS max_cnt 
    FROM cte1
),

cte3 AS (
    -- Recursive CTE to generate numbers from 0 ? max_cnt
    SELECT 0 AS no_of_transactions
    UNION ALL
    SELECT no_of_transactions + 1
    FROM cte3
    CROSS JOIN cte2
    WHERE no_of_transactions < max_cnt
)

-- Final result: Distribution of visits by number of transactions
SELECT
    t3.no_of_transactions AS transactions_count,
    COUNT(t1.user_id) AS visits_count
FROM cte3 t3
LEFT JOIN cte1 t1
    ON t1.cnt = t3.no_of_transactions
GROUP BY t3.no_of_transactions
ORDER BY t3.no_of_transactions;