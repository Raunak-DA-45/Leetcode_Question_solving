/***************************************************************************************************
PURPOSE:
This query generates a monthly country-level report showing:
- Number and total amount of APPROVED transactions.
- Number and total amount of chargebacks.

BUSINESS RULES IMPLEMENTED:
1. Only transactions with state = 'approved' are counted in approved metrics.
2. Chargeback metrics are grouped by the chargeback date (NOT the original transaction date).
3. Chargeback amount is taken from the original transaction amount.
4. If a month has chargebacks but no approved transactions, approved metrics should return 0.
5. Report is grouped by Year-Month (yyyy-MM) and country.

HOW THE QUERY WORKS (STEP-BY-STEP):
1. Create Transactions table to store all transaction records.
2. Create Chargebacks table to store chargeback events linked to transactions.
3. Insert sample data.
4. CTE1 aggregates approved transactions by month and country.
5. CTE2 aggregates chargebacks by month and country.
6. Final SELECT joins chargeback data with approved transaction data.
7. ISNULL ensures missing approved values return 0 instead of NULL.
***************************************************************************************************/


/***************************************************************************************************
STEP 1: DROP TABLES IF THEY EXIST (for re-runnable script)
***************************************************************************************************/
IF OBJECT_ID('dbo.Chargebacks', 'U') IS NOT NULL DROP TABLE dbo.Chargebacks;
IF OBJECT_ID('dbo.Transactions', 'U') IS NOT NULL DROP TABLE dbo.Transactions;


/***************************************************************************************************
STEP 2: CREATE TRANSACTIONS TABLE

This table stores all transactions processed by the system.

Columns:
- id          : Unique transaction identifier (Primary Key)
- country     : Country where transaction occurred
- state       : Transaction status ('approved' or 'declined')
- amount      : Transaction amount in dollars
- trans_date  : Date when transaction occurred
***************************************************************************************************/
CREATE TABLE dbo.Transactions (
    id INT PRIMARY KEY,                           -- Unique transaction ID
    country VARCHAR(4) NOT NULL,                  -- Country code (e.g., US)
    state VARCHAR(10) NOT NULL                    -- Transaction status
        CHECK (state IN ('approved', 'declined')),
    amount INT NOT NULL,                          -- Transaction amount
    trans_date DATE NOT NULL                      -- Transaction date
);


/***************************************************************************************************
STEP 3: CREATE CHARGEBACKS TABLE

This table stores chargeback events.
A chargeback happens when a previously processed transaction is disputed.

Columns:
- trans_id   : References the original transaction
- trans_date : Date when chargeback was recorded
***************************************************************************************************/
CREATE TABLE dbo.Chargebacks (
    trans_id INT NOT NULL,                        -- Original transaction ID
    trans_date DATE NOT NULL,                     -- Chargeback date
    CONSTRAINT FK_Chargebacks_Transactions 
        FOREIGN KEY (trans_id) REFERENCES dbo.Transactions(id)
);


/***************************************************************************************************
STEP 4: INSERT SAMPLE DATA INTO TRANSACTIONS
***************************************************************************************************/
INSERT INTO dbo.Transactions (id, country, state, amount, trans_date) VALUES
(101, 'US', 'approved', 1000, '2019-05-18'),
(102, 'US', 'declined', 2000, '2019-05-19'),
(103, 'US', 'approved', 3000, '2019-06-10'),
(104, 'US', 'declined', 4000, '2019-06-13'),
(105, 'US', 'approved', 5000, '2019-06-15');


/***************************************************************************************************
STEP 5: INSERT SAMPLE DATA INTO CHARGEBACKS
Note: Chargeback date can be different from original transaction date.
***************************************************************************************************/
INSERT INTO dbo.Chargebacks (trans_id, trans_date) VALUES
(102, '2019-05-29'),  -- Chargeback for declined transaction (still counted)
(101, '2019-06-30'),
(105, '2019-09-18');


/***************************************************************************************************
STEP 6: REPORT QUERY
***************************************************************************************************/
WITH cte_approved AS (
    -- Aggregate approved transactions by transaction month and country
    SELECT
        FORMAT(trans_date, 'yyyy-MM') AS month,
        country,
        SUM(CASE WHEN state = 'approved' THEN 1 ELSE 0 END) AS approved_count,
        SUM(CASE WHEN state = 'approved' THEN amount ELSE 0 END) AS approved_amount
    FROM dbo.Transactions
    GROUP BY FORMAT(trans_date, 'yyyy-MM'), country
),
cte_chargebacks AS (
    -- Aggregate chargebacks by chargeback month and country
    SELECT 
        FORMAT(c.trans_date, 'yyyy-MM') AS month,
        t.country,
        COUNT(c.trans_id) AS chargeback_count,
        SUM(t.amount) AS chargeback_amount
    FROM dbo.Chargebacks c
    LEFT JOIN dbo.Transactions t
        ON c.trans_id = t.id   -- Join to get country and amount from original transaction
    GROUP BY FORMAT(c.trans_date, 'yyyy-MM'), t.country
)

SELECT
    cb.month,
    cb.country,
    ISNULL(a.approved_count, 0)  AS approved_count,
    ISNULL(a.approved_amount, 0) AS approved_amount,
    cb.chargeback_count,
    cb.chargeback_amount
FROM cte_chargebacks cb
LEFT JOIN cte_approved a
    ON a.month = cb.month
    AND a.country = cb.country
ORDER BY cb.month, cb.country;
