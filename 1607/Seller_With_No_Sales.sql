/* ==========================================================================================
   PURPOSE OF THIS SCRIPT
   ------------------------------------------------------------------------------------------
   This script identifies **all sellers who did NOT make any sales in the year 2020**.

   HOW THE QUERY WORKS (Step-by-Step)
   ------------------------------------------------------------------------------------------
   1. We LEFT JOIN Seller to Orders while filtering Orders only for year = 2020.
      This lets us see which sellers have matching 2020 sales.
   2. Sellers with NO matching 2020 orders will have NULL values on the Orders side.
   3. We select only sellers where o.order_id IS NULL ? meaning no 2020 sales exist.
   4. Finally, we order the result by seller_name in ascending order.

   This method is preferred because it avoids grouping and handles “zero matching rows”
   efficiently using LEFT JOIN + NULL filter.
============================================================================================== */



/* ==========================================================================================
   SCHEMA AND SAMPLE DATA
============================================================================================== */

----------------------------------------------------------
-- Drop existing tables for a clean rerun
----------------------------------------------------------
IF OBJECT_ID('dbo.Orders', 'U') IS NOT NULL DROP TABLE dbo.Orders;
IF OBJECT_ID('dbo.Customer', 'U') IS NOT NULL DROP TABLE dbo.Customer;
IF OBJECT_ID('dbo.Seller', 'U') IS NOT NULL DROP TABLE dbo.Seller;


----------------------------------------------------------
-- Customer table
-- customer_id     : Unique ID of the customer
-- customer_name   : Name of the customer
----------------------------------------------------------
CREATE TABLE Customer (
    customer_id   INT PRIMARY KEY,
    customer_name VARCHAR(100)
);


----------------------------------------------------------
-- Seller table
-- seller_id     : Unique seller identifier
-- seller_name   : Name of the seller
----------------------------------------------------------
CREATE TABLE Seller (
    seller_id   INT PRIMARY KEY,
    seller_name VARCHAR(100)
);


----------------------------------------------------------
-- Orders table
-- order_id     : Unique order identifier
-- sale_date    : Date when the purchase was made
-- order_cost   : Cost of the order
-- customer_id  : FK ? customer who made the purchase
-- seller_id    : FK ? seller who handled the sale
----------------------------------------------------------
CREATE TABLE Orders (
    order_id    INT PRIMARY KEY,
    sale_date   DATE,
    order_cost  INT,
    customer_id INT,
    seller_id   INT,
    FOREIGN KEY (customer_id) REFERENCES Customer(customer_id),
    FOREIGN KEY (seller_id) REFERENCES Seller(seller_id)
);


----------------------------------------------------------
-- Insert sample customer data
----------------------------------------------------------
INSERT INTO Customer (customer_id, customer_name) VALUES
(101, 'Alice'),
(102, 'Bob'),
(103, 'Charlie');


----------------------------------------------------------
-- Insert sample seller data
----------------------------------------------------------
INSERT INTO Seller (seller_id, seller_name) VALUES
(1, 'Daniel'),
(2, 'Elizabeth'),
(3, 'Frank');


----------------------------------------------------------
-- Insert sample orders
-- Note: Only sellers 1 and 2 have 2020 sales.
--       Seller 3 has no sales in 2020 ? should appear in result.
----------------------------------------------------------
INSERT INTO Orders (order_id, sale_date, order_cost, customer_id, seller_id) VALUES
(1, '2020-03-01', 1500, 101, 1),
(2, '2020-05-25', 2400, 102, 2),
(3, '2019-05-25', 800, 101, 3),
(4, '2020-09-13', 1000, 103, 2),
(5, '2019-02-11', 700, 101, 2);



/* ==========================================================================================
   QUERY: Sellers who did NOT make any sales in 2020
============================================================================================== */

SELECT 
    s.seller_name
FROM Seller s
LEFT JOIN Orders o
    ON s.seller_id = o.seller_id
    AND YEAR(o.sale_date) = 2020   -- Only match orders from 2020
WHERE o.order_id IS NULL           -- NULL means the seller had no 2020 sales
ORDER BY s.seller_name;            -- Sort alphabetically
