------------------------------------------------------------
-- PURPOSE:
-- This query identifies buyers who have purchased the product 'S8'
-- but have never purchased 'iPhone'.
--
-- BUSINESS RULES:
-- 1. Only consider buyers who have bought 'S8'.
-- 2. Exclude any buyers who have also bought 'iPhone'.
-- 3. A buyer may have multiple purchases; duplicates are ignored.
--
-- HOW THE QUERY WORKS:
-- Step 1: Create CTE (cte1) that joins Sales with Product to get product names.
-- Step 2: Select distinct buyer_ids from cte1 where product_name = 'S8'.
-- Step 3: Exclude buyers who appear in cte1 with product_name = 'iPhone'.
------------------------------------------------------------

------------------------------------------------------------
-- DROP TABLES IF THEY ALREADY EXIST
------------------------------------------------------------
IF OBJECT_ID('dbo.Sales', 'U') IS NOT NULL DROP TABLE dbo.Sales;
IF OBJECT_ID('dbo.Product', 'U') IS NOT NULL DROP TABLE dbo.Product;
GO

------------------------------------------------------------
-- TABLE: Product
-- Stores product information
------------------------------------------------------------
CREATE TABLE Product (
    product_id   INT PRIMARY KEY,      -- Unique ID for each product
    product_name VARCHAR(50) NOT NULL, -- Name of the product
    unit_price   INT NOT NULL          -- Price per unit
);
GO

------------------------------------------------------------
-- TABLE: Sales
-- Stores sales transactions
------------------------------------------------------------
CREATE TABLE Sales (
    seller_id   INT NOT NULL,           -- ID of the seller
    product_id  INT NOT NULL,           -- ID of the product sold (FK to Product)
    buyer_id    INT NOT NULL,           -- ID of the buyer
    sale_date   DATE NOT NULL,          -- Date of sale
    quantity    INT NOT NULL,           -- Quantity sold
    price       INT NOT NULL,           -- Total price for this sale
    CONSTRAINT FK_Product FOREIGN KEY (product_id) REFERENCES Product(product_id)
);
GO

------------------------------------------------------------
-- INSERT SAMPLE DATA INTO Product
------------------------------------------------------------
INSERT INTO Product (product_id, product_name, unit_price) VALUES
(1, 'S8', 1000),
(2, 'G4', 800),
(3, 'iPhone', 1400);
GO

------------------------------------------------------------
-- INSERT SAMPLE DATA INTO Sales
------------------------------------------------------------
INSERT INTO Sales (seller_id, product_id, buyer_id, sale_date, quantity, price) VALUES
(1, 1, 1, '2019-01-21', 2, 2000),
(1, 2, 2, '2019-02-17', 1, 800),
(2, 1, 3, '2019-06-02', 1, 800),
(3, 3, 3, '2019-05-13', 2, 2800);
GO

------------------------------------------------------------
-- QUERY: Buyers who bought 'S8' but not 'iPhone'
------------------------------------------------------------
WITH cte1 AS (
    -- Join Sales with Product to get product names for each sale
    SELECT s.*, p.product_name
    FROM Sales s
    LEFT JOIN Product p
        ON s.product_id = p.product_id
)
SELECT DISTINCT buyer_id
FROM cte1
WHERE product_name = 'S8'                     -- Buyers who purchased 'S8'
AND buyer_id NOT IN (
    -- Exclude buyers who also purchased 'iPhone'
    SELECT DISTINCT buyer_id
    FROM cte1
    WHERE product_name = 'iPhone'
)
ORDER BY buyer_id;
