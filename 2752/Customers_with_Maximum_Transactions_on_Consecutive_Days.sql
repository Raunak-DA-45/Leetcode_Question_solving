/****************************************************************************************
PURPOSE
-------
Find all customers who made the maximum number of transactions on consecutive days.

BUSINESS RULES
--------------
1. Transactions are considered consecutive if they occur on back-to-back calendar days.
2. Consecutive days are evaluated separately for each customer.
3. A customer may have multiple consecutive-day sequences.
4. We find the length of each consecutive sequence.
5. Customers whose longest sequence equals the overall maximum are returned.
6. Output only customer_id, ordered in ascending order.

HOW THE QUERY WORKS (STEP-BY-STEP)
----------------------------------
1. Assign a row number to each transaction per customer ordered by transaction_date.
2. Subtract row_number from transaction_date to form a grouping key for consecutive dates.
3. Count transactions per customer per consecutive-date group.
4. Rank these counts in descending order to identify the maximum streak.
5. Return customer_ids whose streak rank is 1.
****************************************************************************************/


/****************************************************************************************
TABLE: Transactions
-------------------
Stores transaction details for each customer.

COLUMNS
-------
- transaction_id   : Unique identifier for each transaction
- customer_id      : Customer who made the transaction
- transaction_date : Date of transaction
- amount           : Transaction amount
****************************************************************************************/

Create table Transactions (
    transaction_id int,
    customer_id int,
    transaction_date date,
    amount int
);

-- Clear table before inserting sample data
Truncate table Transactions;


/****************************************************************************************
SAMPLE DATA
-----------
Represents multiple customers with different transaction patterns
to test consecutive-day logic.
****************************************************************************************/

insert into Transactions (transaction_id, customer_id, transaction_date, amount) values ('1', '101', '2023-05-01', '100');
insert into Transactions (transaction_id, customer_id, transaction_date, amount) values ('2', '101', '2023-05-02', '150');
insert into Transactions (transaction_id, customer_id, transaction_date, amount) values ('3', '101', '2023-05-03', '200');

insert into Transactions (transaction_id, customer_id, transaction_date, amount) values ('4', '102', '2023-05-01', '50');
insert into Transactions (transaction_id, customer_id, transaction_date, amount) values ('5', '102', '2023-05-03', '100');
insert into Transactions (transaction_id, customer_id, transaction_date, amount) values ('6', '102', '2023-05-04', '200');

insert into Transactions (transaction_id, customer_id, transaction_date, amount) values ('7', '105', '2023-05-01', '100');
insert into Transactions (transaction_id, customer_id, transaction_date, amount) values ('8', '105', '2023-05-02', '150');
insert into Transactions (transaction_id, customer_id, transaction_date, amount) values ('9', '105', '2023-05-03', '200');


-- Verify data
Select * from Transactions;


/****************************************************************************************
QUERY LOGIC
****************************************************************************************/

with cte1 as (
    select
        *,
        -- Assigns sequence number per customer ordered by transaction date
        row_number() over(partition by customer_id order by transaction_date) as rn
    from transactions
),
cte2 as (
    select
        customer_id,
        -- Same value for consecutive dates; changes when a gap exists
        dateadd(day, -rn, transaction_date) as day,
        -- Counts length of each consecutive transaction streak
        count(amount) as cnting,
        -- Ranks streaks globally to find maximum consecutive transactions
        dense_rank() over(order by count(amount) desc) as rnking
    from cte1
    group by customer_id, dateadd(day, -rn, transaction_date)
)
select
    customer_id
from cte2
where rnking = 1
order by 1;
