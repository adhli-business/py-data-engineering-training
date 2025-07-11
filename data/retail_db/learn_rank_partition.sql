CREATE TABLE t_sales (
    id SERIAL PRIMARY KEY,
    region VARCHAR(50),
    sales_amount INTEGER
);

INSERT INTO t_sales (region, sales_amount) VALUES
('East', 150),
('West', 250),
('East', 150),
('West', 300),
('East', 100);

-- truncate t_sales

-- ALTER SEQUENCE t_sales_id_seq RESTART WITH 1;


-- select * from t_sales

-- 1 group by biasa
select region, 
	sum(sales_amount) as total_sales
from t_sales
group by region
order by 2

-- 2 group by partition
select region, 
	sales_amount, -- individual row yg mau ditampilkan
	sum(sales_amount) over (partition by region) as region_sales -- gantinya group by
from t_sales
-- group by region --> dihilangkan
order by 3 desc

-- 3 global rank
select region,
	sales_amount,
	rank() over (order by sales_amount desc) as rnk,
	dense_rank() over (order by sales_amount desc) as drnk
from t_sales

-- 4 partition rank
select region,
	sales_amount,
	sum(sales_amount) over (partition by region) as region_sales,
	dense_rank() over (order by sales_amount desc) as sales_rank
from t_sales
order by 4

select region,
	sales_amount,
	-- sum(sales_amount) over (partition by region) as region_sales, --> TIDAK PERLU!!
	dense_rank() over (partition by region order by sales_amount desc) as sales_rank
from t_sales
order by 1

--------------------------------
--------------------------------

CREATE TABLE t2_sales (
    id SERIAL PRIMARY KEY,
    region VARCHAR(50),
    sales_amount INTEGER
);

INSERT INTO t2_sales (region, sales_amount) VALUES
('West', 1000),
('West', 100),
('West', 150),
('West', 100),
('East', 500),
('East', 600),
('East', 400),
('East', 300);

-- Expected rank
-- 1. East 600 (karena total region 1800)
-- 2. East 500 (karena total region 1800)
-- dan seterusnya
-- 5. West 1000 (karena total region 1350)
-- 6. West 150 (karena total region 1350)



WITH sales_with_total AS (
    SELECT 
        region,
        sales_amount,
        SUM(sales_amount) OVER (PARTITION BY region) AS total_region_sales
    FROM t2_sales
)

SELECT 
    region,
    sales_amount,
    RANK() OVER (
        ORDER BY total_region_sales DESC, sales_amount DESC
    ) AS rank
FROM sales_with_total;



-------------- OR ------------------

select * from t2_sales

create table total_region_sales as
select region,
	sales_amount,
	sum(sales_amount) over (partition by region) as total_region_sales
from t2_sales

drop table total_region_sales

select region,
	sales_amount,
	total_region_sales,
	rank() over (
		order by total_region_sales desc,
		sales_amount desc
	) as rank
from total_region_sales

