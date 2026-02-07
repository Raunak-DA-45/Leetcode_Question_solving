/****************************************************************************************
PURPOSE
-------
Identify the seller(s) who sold the highest number of DISTINCT items
that are NOT from their own favorite brand.

BUSINESS RULES
--------------
1. Each seller has a favorite brand stored in the Users table.
2. Orders placed by sellers are stored in the Orders table.
3. Each item belongs to a specific brand stored in the Items table.
4. Only items whose brand is DIFFERENT from the seller’s favorite brand
   should be counted.
5. Sellers are ranked by the number of distinct non-favorite-brand items sold.
6. Return only the seller(s) with the highest such count.

HOW THE QUERY WORKS (HIGH LEVEL)
--------------------------------
Step 1: Join Orders with Users and Items to associate sellers with item brands.
Step 2: Filter out items that match the seller’s favorite brand.
Step 3: Count distinct items sold per seller.
Step 4: Rank sellers based on this count (highest first).
Step 5: Return seller(s) with rank = 1 (top performers).
****************************************************************************************/


/****************************************************************************************
TABLE SCHEMAS
-------------
Each CREATE TABLE statement below defines the structure of the data.
Comments explain the purpose of each table and column.
****************************************************************************************/

-- Stores seller-level information
Create table Users (
    seller_id int,              -- Unique identifier for each seller
    join_date date,              -- Date the seller joined the platform
    favorite_brand varchar(10)   -- Seller's preferred brand
);

-- Stores order-level transactions
Create table Orders (
    order_id int,               -- Unique identifier for each order
    order_date date,            -- Date the order was placed
    item_id int,                -- Item sold in the order
    seller_id int               -- Seller who made the sale
);

-- Stores item-level details
Create table Items (
    item_id int,                -- Unique identifier for each item
    item_brand varchar(10)      -- Brand associated with the item
);


/****************************************************************************************
SAMPLE DATA
-----------
The TRUNCATE statements ensure a clean slate.
INSERT statements populate tables with small, meaningful examples.
****************************************************************************************/

-- Clear existing data
Truncate table Users;

-- Sample sellers
insert into Users (seller_id, join_date, favorite_brand) values ('1', '2019-01-01', 'Lenovo');
insert into Users (seller_id, join_date, favorite_brand) values ('2', '2019-02-09', 'Samsung');
insert into Users (seller_id, join_date, favorite_brand) values ('3', '2019-01-19', 'LG');

-- Clear existing orders
Truncate table Orders;

-- Sample orders placed by sellers
insert into Orders (order_id, order_date, item_id, seller_id) values ('1', '2019-08-01', '4', '2');
insert into Orders (order_id, order_date, item_id, seller_id) values ('2', '2019-08-02', '2', '3');
insert into Orders (order_id, order_date, item_id, seller_id) values ('3', '2019-08-03', '3', '3');
insert into Orders (order_id, order_date, item_id, seller_id) values ('4', '2019-08-04', '1', '2');
insert into Orders (order_id, order_date, item_id, seller_id) values ('5', '2019-08-04', '4', '2');

-- Clear existing items
Truncate table Items;

-- Sample items and their brands
insert into Items (item_id, item_brand) values ('1', 'Samsung');
insert into Items (item_id, item_brand) values ('2', 'Lenovo');
insert into Items (item_id, item_brand) values ('3', 'LG');
insert into Items (item_id, item_brand) values ('4', 'HP');


/****************************************************************************************
DATA VERIFICATION
-----------
Quick checks to see the loaded data.
****************************************************************************************/

select * from users;
select * from orders;
select * from Items;


/****************************************************************************************
ORIGINAL QUERY (UNCHANGED)
-----------
This query calculates the number of distinct non-favorite-brand items sold
per seller and returns the seller(s) with the highest count.
****************************************************************************************/

with cte1 as(
select
	o.seller_id,
	count(distinct o.item_id) as num_items,
	dense_rank() over(order by count(distinct o.item_id) desc) as rnk
from orders o
left join users u
on  u.seller_id=o.seller_id
left join items i
on i.item_id=o.item_id
where i.item_brand <> u.favorite_brand
group by o.seller_id)

select
	seller_id,
	num_items
from cte1
where rnk=1
order by 1;
