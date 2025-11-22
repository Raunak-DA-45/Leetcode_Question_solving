/*
Purpose of the Query:
---------------------
For each product, calculate the total amount due (rest), paid, canceled, and refunded across all invoices.

Business Rules Implemented:
--------------------------
1. Aggregate invoice amounts per product.
2. Only sum amounts from existing invoices.
3. Display totals for each product ordered alphabetically by product name.

How the Query Works (Step-by-Step):
-----------------------------------
1. Create two tables: Product and Invoice, with proper primary and foreign keys.
2. Insert sample data into both tables.
3. Join Invoice and Product tables using product_id.
4. Use SUM() to aggregate rest, paid, canceled, and refunded amounts per product.
5. Use ISNULL() to ensure that if a product has no invoices, the total shows as 0.
6. Group results by product name and order alphabetically.
*/

-- =========================
-- Step 1: Drop tables if they exist to avoid errors
-- =========================
IF OBJECT_ID('dbo.Invoice', 'U') IS NOT NULL
    DROP TABLE dbo.Invoice;
IF OBJECT_ID('dbo.Product', 'U') IS NOT NULL
    DROP TABLE dbo.Product;
GO

-- =========================
-- Step 2: Create Product table
-- =========================
CREATE TABLE dbo.Product (
    product_id INT PRIMARY KEY,    -- Unique ID of the product
    name VARCHAR(50) NOT NULL      -- Name of the product (lowercase letters)
);
GO

-- =========================
-- Step 3: Create Invoice table
-- =========================
CREATE TABLE dbo.Invoice (
    invoice_id INT PRIMARY KEY,    -- Unique ID of the invoice
    product_id INT NOT NULL,       -- ID of the product for this invoice
    rest INT NOT NULL,             -- Amount left to pay
    paid INT NOT NULL,             -- Amount paid
    canceled INT NOT NULL,         -- Amount canceled
    refunded INT NOT NULL,         -- Amount refunded
    CONSTRAINT FK_Product FOREIGN KEY (product_id) REFERENCES dbo.Product(product_id)
);
GO

-- =========================
-- Step 4: Insert sample data into Product
-- =========================
INSERT INTO dbo.Product (product_id, name) VALUES (0, 'ham');    -- Product: ham
INSERT INTO dbo.Product (product_id, name) VALUES (1, 'bacon');  -- Product: bacon
GO

-- =========================
-- Step 5: Insert sample data into Invoice
-- =========================
INSERT INTO dbo.Invoice (invoice_id, product_id, rest, paid, canceled, refunded) VALUES (23, 0, 2, 0, 5, 0);
INSERT INTO dbo.Invoice (invoice_id, product_id, rest, paid, canceled, refunded) VALUES (12, 0, 0, 4, 0, 3);
INSERT INTO dbo.Invoice (invoice_id, product_id, rest, paid, canceled, refunded) VALUES (1, 1, 1, 1, 0, 1);
INSERT INTO dbo.Invoice (invoice_id, product_id, rest, paid, canceled, refunded) VALUES (2, 1, 1, 0, 1, 1);
INSERT INTO dbo.Invoice (invoice_id, product_id, rest, paid, canceled, refunded) VALUES (3, 1, 0, 1, 1, 1);
INSERT INTO dbo.Invoice (invoice_id, product_id, rest, paid, canceled, refunded) VALUES (4, 1, 1, 1, 1, 0);
GO

-- =========================
-- Step 6: Query to get total amounts per product
-- =========================
SELECT
    p.name,                                      -- Product name
    ISNULL(SUM(i.rest), 0) AS rest,             -- Total amount left to pay
    ISNULL(SUM(i.paid), 0) AS paid,             -- Total paid
    ISNULL(SUM(i.canceled), 0) AS canceled,     -- Total canceled
    ISNULL(SUM(i.refunded), 0) AS refunded      -- Total refunded
FROM dbo.Invoice i
LEFT JOIN dbo.Product p
    ON p.product_id = i.product_id              -- Match invoices to products
GROUP BY p.name                                  -- Aggregate totals by product
ORDER BY p.name;                                -- Order alphabetically
GO
