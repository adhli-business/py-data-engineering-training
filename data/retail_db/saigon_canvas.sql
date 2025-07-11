-- total aggregation

select count(*) from orders

select order_status from orders

select distinct(order_status) from orders

select count(distinct(order_status)) from orders

select distinct(order_date) from orders

select count(distinct(order_date)) from orders

select * from order_items

select sum(order_item_subtotal)
from order_items
where order_item_order_id = 2;

-- group by aggregation
select * from orders

select order_status, count(*) as order_count
from orders
group by 1
order by 2 desc

select order_date, count(*) as order_count
from orders
group by 1
order by 2 desc

select to_char(order_date, 'yyyy-MM') as order_month, count(*) as order_count
from orders
group by 1
order by 1 desc

SELECT to_char(order_date, 'yyyy-MM') AS order_month, count(*) AS order_count
FROM orders
GROUP BY 1
ORDER BY 2 DESC;

select * from order_items

-- 5. Get the order revenue for each order id
select order_item_order_id, 
	round(sum(order_item_subtotal)::numeric, 2) as revenue
from order_items
group by order_item_order_id
order by order_item_order_id 

SELECT order_item_order_id, 
    round(sum(order_item_subtotal)::numeric, 2) AS order_revenue
FROM order_items
GROUP BY 1
ORDER BY 1;

-- filter on aggregration

-- 1. Get the records that have a count of order date grater than or equal to 120  
-- and descending order by order count and they should be in complete or closed status

select * from orders;

select order_date, count(*) as order_count
from orders
where order_status in ('COMPLETE', 'CLOSED')
group by 1
having count(*) >= 120 
order by 2 desc

SELECT order_date, count(*) AS order_count
FROM orders
WHERE order_status IN ('COMPLETE', 'CLOSED')
GROUP BY 1
HAVING count(*) >= 120
ORDER BY 2 DESC;

-- 3. Get the records which have order revenue more than or equal to 2000
select * from order_items

select order_item_order_id, 
	round(sum(order_item_subtotal)::numeric, 2) as revenue
from order_items
group by 1
	having round(sum(order_item_subtotal)::numeric, 2) > 2000
order by 2 desc

SELECT order_item_order_id,
    round(sum(order_item_subtotal)::numeric, 2) AS order_revenue
FROM order_items
GROUP BY 1
HAVING round(sum(order_item_subtotal)::numeric, 2) >= 2000
ORDER BY 2 DESC;

-- 1. INNER JOIN - Get all the records from both datasets which satisfy the JOIN condition.
select * from orders
select * from order_items

select *
from orders as o
	join order_items as oi
		on o.order_id = oi.order_item_order_id

select *
from orders as o
	left join order_items as oi
		on o.order_id = oi.order_item_order_id

select *
-- SELECT o.order_id, o.order_date,
--     oi.order_item_id ,
--     oi.order_item_product_id,
--     oi.order_item_subtotal
from orders as o
	left join order_items as oi
		on o.order_id = oi.order_item_order_id
order by 1

-- 1. OUTER JOIN - Get all the records which satisfy join condition
-- and also those records which present in orders but not in order_items
-- order_items fields will have null values
SELECT o.order_id, o.order_date,
    oi.order_item_id ,
    oi.order_item_product_id,
    oi.order_item_subtotal
FROM orders AS o
    LEFT OUTER JOIN order_items AS oi
        ON o.order_id = oi.order_item_order_id
ORDER BY 1;

-- 1. Query to filter and aggregate on top of join results
select * from orders
select * from order_items

-- step 1
select *
from orders as o
	join order_items as oi
		on o.order_id = oi.order_item_order_id

-- step 2
select o.order_date, 
	oi.order_item_product_id,
	oi.order_item_subtotal
from orders as o
	join order_items as oi
		on o.order_id = oi.order_item_order_id

-- step 3
select o.order_date, 
	oi.order_item_product_id,
	sum(oi.order_item_subtotal)
from orders as o
	join order_items as oi
		on o.order_id = oi.order_item_order_id
group by 1,2

-- step 4
select o.order_date, 
	oi.order_item_product_id,
	round(sum(oi.order_item_subtotal)::numeric, 2) as revenue
from orders as o
	join order_items as oi
		on o.order_id = oi.order_item_order_id
group by 1,2

-- step 5
select o.order_date, 
	oi.order_item_product_id,
	round(sum(oi.order_item_subtotal)::numeric, 2) as revenue
from orders as o
	join order_items as oi
		on o.order_id = oi.order_item_order_id
where o.order_status in ('COMPLETED','CLOSED')
group by 1,2
order by 1,3 desc

-- CTAS
CREATE TABLE daily_revenue
AS
SELECT o.order_date,
    round(sum(oi.order_item_subtotal)::numeric, 2) AS order_revenue
FROM orders AS o
    JOIN order_items AS oi
        ON o.order_id = oi.order_item_order_id
WHERE o.order_status IN ('COMPLETE', 'CLOSED')
GROUP BY 1;

SELECT * FROM daily_revenue
ORDER BY order_date;

CREATE TABLE daily_product_revenue
AS
SELECT o.order_date,
    oi.order_item_product_id,
    round(sum(oi.order_item_subtotal)::numeric, 2) AS order_revenue
FROM orders AS o
    JOIN order_items AS oi
        ON o.order_id = oi.order_item_order_id
WHERE o.order_status IN ('COMPLETE', 'CLOSED')
GROUP BY 1,2;

SELECT * FROM daily_product_revenue
ORDER BY 1, 3 DESC;

-- window function (over partition)

-- 1
SELECT * FROM daily_revenue
ORDER BY order_date;

-- 2
SELECT to_char(order_date::timestamp, 'yyyy-MM') as order_month, order_revenue
FROM daily_revenue
ORDER BY 1

-- 3 Menampilkan aggregate sum berdasarkan bulan
-- individual date --> tidak kelihatan
SELECT to_char(order_date::timestamp, 'yyyy-MM') as order_month, 
	sum(order_revenue) as month_revenue
FROM daily_revenue
group by 1
ORDER BY 1

-- 4 Menampilkan aggregate sum berdasarkan bulan
-- Agar individual date kelihatan --> gunakan over partition
SELECT to_char(order_date::timestamp, 'yyyy-MM') as order_month, 
	order_date,
	sum(order_revenue) over (
		partition by to_char(order_date::timestamp, 'yyyy-MM')
	)	
	as monthly_revenue
FROM daily_revenue
-- group by 1
ORDER BY 1

-- 5 Menampilkan aggregate sum berdasarkan bulan
-- Agar individual date kelihatan --> gunakan over partition
-- Agar individual revenue date kelihatan --> gunakan over partition
SELECT to_char(order_date::timestamp, 'yyyy-MM') as order_month, 
	order_date,
	order_revenue,
	sum(order_revenue) over (
		partition by to_char(order_date::timestamp, 'yyyy-MM')
	)	
	as monthly_revenue
FROM daily_revenue
-- group by 1
ORDER BY 2

---------------------

-- 1
SELECT * 
FROM daily_revenue
-- ORDER BY order_date;

-- 2
SELECT *,
	sum(order_revenue) over (
		partition by 1 -- maksudnya partisi jadi 1 group GOBLOK!!!
	) AS total_order_revenue
FROM daily_revenue
ORDER BY order_date;

SELECT dr.*,
    sum(order_revenue) OVER (PARTITION BY 1) AS total_order_revenue
FROM daily_revenue AS dr
ORDER BY 1;


-- RANKING

SELECT count(*) FROM daily_product_revenue;

SELECT * FROM daily_product_revenue
ORDER BY order_date, order_revenue DESC;

-- To compute global ranks use ORDER BY only
SELECT order_date,
    order_item_product_id,
    order_revenue,
    rank() OVER (ORDER BY order_revenue DESC) AS rnk,
    dense_rank() OVER (ORDER BY order_revenue DESC) AS drnk
FROM daily_product_revenue
WHERE order_date = '2014-01-01 00:00:00.0'
ORDER BY order_revenue DESC;

SELECT order_date,
    order_item_product_id,
    order_revenue
FROM daily_product_revenue
WHERE to_char(order_date::date, 'yyyy-MM') = '2014-01'
ORDER BY order_date, order_revenue DESC;

-- partition rank
SELECT order_date,
    order_item_product_id,
    order_revenue
FROM daily_product_revenue
WHERE to_char(order_date::date, 'yyyy-MM') = '2014-01'
ORDER BY order_date, order_revenue DESC;

SELECT order_date,
    order_item_product_id,
    order_revenue,
    rank() OVER (
        PARTITION BY order_date
        ORDER BY order_revenue DESC
    ) AS rnk
FROM daily_product_revenue
WHERE to_char(order_date::date, 'yyyy-MM') = '2014-01'
ORDER BY order_date, order_revenue DESC;

SELECT order_date,
    order_item_product_id,
    order_revenue,
    rank() OVER (
        PARTITION BY order_date
        ORDER BY order_revenue DESC
    ) AS rnk,
    dense_rank() OVER (
        PARTITION BY order_date
        ORDER BY order_revenue DESC
    ) AS drnk
FROM daily_product_revenue
WHERE to_char(order_date::date, 'yyyy-MM') = '2014-01'
ORDER BY order_date, order_revenue DESC;


-- Filtering based on Global Ranks using Nested Queries and CTEs in SQL

    SELECT order_date,
        order_item_product_id,
        order_revenue
    FROM daily_product_revenue
    WHERE order_date = '2014-01-01 00:00:00.0'


    SELECT order_date,
        order_item_product_id,
        order_revenue,
        rank() OVER (ORDER BY order_revenue DESC) AS rnk,
        dense_rank() OVER (ORDER BY order_revenue DESC) AS drnk
    FROM daily_product_revenue
    WHERE order_date = '2014-01-01 00:00:00.0'


-- Using Nested Query
SELECT * FROM (
    SELECT order_date,
        order_item_product_id,
        order_revenue,
        rank() OVER (ORDER BY order_revenue DESC) AS rnk,
        dense_rank() OVER (ORDER BY order_revenue DESC) AS drnk
    FROM daily_product_revenue
    WHERE order_date = '2014-01-01 00:00:00.0'
) AS q
WHERE drnk <= 5
-- ORDER BY order_revenue DESC;

-- Using Common Table Expressions or CTEs
WITH daily_product_revenue_ranks AS (
    SELECT order_date,
        order_item_product_id,
        order_revenue,
        rank() OVER (ORDER BY order_revenue DESC) AS rnk,
        dense_rank() OVER (ORDER BY order_revenue DESC) AS drnk
    FROM daily_product_revenue
    WHERE order_date = '2014-01-01 00:00:00.0'
) SELECT * FROM daily_product_revenue_ranks
WHERE drnk <= 5
ORDER BY order_revenue DESC;

------------------


