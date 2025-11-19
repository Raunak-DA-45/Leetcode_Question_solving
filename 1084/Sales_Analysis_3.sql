/* ==========================================================================================
   PURPOSE OF THIS SCRIPT
   ------------------------------------------------------------------------------------------
   This script identifies **products that were sold exclusively in the first quarter (Q1)
   of 2019**, meaning every sale for that product occurred between:
         • 2019-01-01  and  2019-03-31  (inclusive)

   HOW THE QUERY WORKS (Step-by-Step)
   ------------------------------------------------------------------------------------------
   1. Join Sales and Product tables to access product details.
   2. Group by product so we can evaluate all of its sales.
   3. Use MIN(sale_date) and MAX(sale_date) to check the date boundaries.
   4. Keep only products whose entire sale date range falls within Q1-2019.

   Below the main query, an alternative “NOT IN” method (using a CTE) is provided.
============================================================================================== */



/* ==========================================================================================
   SCHEMA AND SAMPLE DATA
============================================================================================== */

----------------------------------------------------------
-- Drop existing tables for a clean rerun
----------------------------------------------------------
IF OBJECT_ID('dbo.Sales', 'U') IS NOT NULL DROP TABLE dbo.Sales;
IF OBJECT_ID('dbo.Product', 'U') IS NOT NULL DROP TABLE dbo.Product;


----------------------------------------------------------
-- Product table
-- product_id    : Unique product identifier
-- product_name  : Short name of the product
-- unit_price    : Price per unit
----------------------------------------------------------
CREATE TABLE Product (
    product_id INT PRIMARY KEY,
    product_name VARCHAR(10),
    unit_price INT
);


----------------------------------------------------------
-- Sales table
-- seller_id   : ID of seller
-- product_id  : Product being sold (FK to Product)
-- buyer_id    : ID of buyer
-- sale_date   : Date of sale
-- quantity    : Number of units sold
-- price       : Total price for the transaction
----------------------------------------------------------
CREATE TABLE Sales (
    seller_id INT,
    product_id INT,
    buyer_id INT,
    sale_date DATE,
    quantity INT,
    price INT,
    FOREIGN KEY (product_id) REFERENCES Product(product_id)
);


----------------------------------------------------------
-- Insert sample product data
----------------------------------------------------------
INSERT INTO Product (product_id, product_name, unit_price) VALUES
(1, 'S8', 1000),
(2, 'G4', 800),
(3, 'iPhone', 1400);


----------------------------------------------------------
-- Insert sample sales data
-- Note: Some sales occur within Q1 2019, others outside.
----------------------------------------------------------
INSERT INTO Sales (seller_id, product_id, buyer_id, sale_date, quantity, price) VALUES
(1, 1, 1, '2019-01-21', 2, 2000),   -- Q1
(1, 2, 2, '2019-02-17', 1, 800),    -- Q1
(2, 2, 3, '2019-06-02', 1, 800),    -- Outside Q1 (disqualifies product 2)
(3, 3, 4, '2019-05-13', 2, 2800);   -- Outside Q1 (disqualifies product 3)

-- SELECT * FROM Product;
-- SELECT * FROM Sales;



/* ==========================================================================================
   MAIN SOLUTION: Products sold ONLY within Q1-2019
============================================================================================== */

SELECT 
    p.product_id,
    p.product_name
FROM Sales s
INNER JOIN Product p 
    ON s.product_id = p.product_id
GROUP BY 
    p.product_id, 
    p.product_name
HAVING 
    MIN(s.sale_date) BETWEEN '2019-01-01' AND '2019-03-31'  -- earliest sale is in Q1
    AND 
    MAX(s.sale_date) BETWEEN '2019-01-01' AND '2019-03-31'; -- latest sale is in Q1



/* ==========================================================================================
   ALTERNATE SOLUTION (Using CTE and NOT IN)
   ------------------------------------------------------------------------------------------
   1. Identify products with ANY sale outside Q1 2019.
   2. Exclude them from the final result.
============================================================================================== */

WITH cte_outside_q1 AS (
    SELECT product_id
    FROM Sales
    WHERE sale_date < '2019-01-01'
       OR sale_date > '2019-03-31'
)
SELECT DISTINCT 
    p.product_id,
    p.product_name
FROM Product p
JOIN Sales s 
    ON p.product_id = s.product_id
WHERE p.product_id NOT IN (SELECT product_id FROM cte_outside_q1);
