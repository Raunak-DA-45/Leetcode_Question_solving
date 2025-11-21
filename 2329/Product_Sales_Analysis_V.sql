/********************************************************************************************
Purpose of this Script
----------------------
This full T-SQL script demonstrates how to:
1. Create two tables (`Product` and `Sales`) that store pricing and purchase activity.
2. Insert sample data into these tables.
3. Calculate the **total spending per user** by multiplying quantity × price for each sale.
4. Return results ordered by:
      • Spending in descending order (highest spenders first)
      • user_id ascending when spending is tied

Business Rules Implemented
--------------------------
• Each product has a unique product_id and a fixed price.
• Each sale belongs to exactly one product and one user.
• A user may have multiple sales, across one or more products.
• Total spending = SUM(quantity × price) across all the user's purchases.

How the Final Query Works (Step-by-Step)
----------------------------------------
1. Join Sales to Product using product_id to bring price into the calculation.
2. Multiply quantity × price to get each sale’s monetary value.
3. Group by user_id so we can total all spending per user.
4. Order by:
      • spending DESC (larger spending first)
      • user_id ASC to break ties consistently.
********************************************************************************************/


/******************************************
  TABLE SCHEMAS (BEGINNER-FRIENDLY EXPLANATION)
******************************************/

-- The Product table holds a list of products.
-- Each product has:
--   • product_id: A unique identifier for the product.
--   • price: How much one unit of this product costs.
IF OBJECT_ID('dbo.Product', 'U') IS NOT NULL
    DROP TABLE dbo.Product;
GO

CREATE TABLE dbo.Product (
    product_id INT PRIMARY KEY,
    price INT NOT NULL
);
GO


-- The Sales table represents each purchase event made by a user.
-- Columns:
--   • sale_id: Unique ID for each sale.
--   • product_id: Which product was purchased (links to Product table).
--   • user_id: Which user made the purchase.
--   • quantity: How many units of the product were bought.
IF OBJECT_ID('dbo.Sales', 'U') IS NOT NULL
    DROP TABLE dbo.Sales;
GO

CREATE TABLE dbo.Sales (
    sale_id INT PRIMARY KEY,
    product_id INT NOT NULL,
    user_id INT NOT NULL,
    quantity INT NOT NULL,
    CONSTRAINT FK_Sales_Product FOREIGN KEY (product_id)
        REFERENCES dbo.Product(product_id)
);
GO



/******************************************
  SAMPLE DATA
******************************************/

-- Sample pricing for three products.
INSERT INTO dbo.Product (product_id, price) VALUES
(1, 10),   -- Product 1 costs $10
(2, 25),   -- Product 2 costs $25
(3, 15);   -- Product 3 costs $15
GO

-- Sample sales records.
INSERT INTO dbo.Sales (sale_id, product_id, user_id, quantity) VALUES
(1, 1, 101, 10),  -- User 101 bought 10 units of product 1 ($10 each)
(2, 2, 101, 1),   -- User 101 bought 1 unit of product 2 ($25 each)
(3, 3, 102, 3),   -- User 102 bought 3 units of product 3 ($15 each)
(4, 3, 102, 2),   -- User 102 bought 2 more units of product 3
(5, 2, 103, 3);   -- User 103 bought 3 units of product 2
GO



/******************************************
  FINAL QUERY — CALCULATE USER SPENDING
******************************************/

SELECT 
    s.user_id,
    SUM(s.quantity * p.price) AS spending  -- Calculate total spending per user
FROM dbo.Sales AS s
LEFT JOIN dbo.Product AS p
    ON p.product_id = s.product_id        -- Bring in the product price
GROUP BY s.user_id
ORDER BY 
    spending DESC,                        -- Highest spenders first
    s.user_id ASC;                        -- Break ties by user_id
GO
