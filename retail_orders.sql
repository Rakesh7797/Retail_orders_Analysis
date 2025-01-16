create table u_orders (
order_id int primary key,
order_date date,
ship_mode varchar(20),
segment varchar(20),
country varchar (20),
city varchar (20),
state varchar (20),
postal_code varchar (20),
region varchar (20),
category varchar (20),
sub_category varchar (20),
product_id varchar(50),
quantity int,
discount decimal(7,2),
sale_price decimal (7,2),
profit decimal(7,2)
);
select*from u_orders;

# find top 10 highest profit generating products
create view top_10_profit_products as
select sub_category, sum(profit) as profitable from u_orders
group by sub_category
order by profitable desc limit 10;

select* from top_10_profit_products;

# find top 10 highest revenue generating products
select product_id, sum(sale_price) as sales from u_orders
group by product_id
order by sales desc limit 10;

# find top 5 highest selling products in each region
select product_id, region, sum(sale_price) as sales from u_orders
group by region
order by sales desc limit 5;

# find month over month growth comparison for 2022 and 2023 sales 
WITH sales_data AS (
    SELECT 
        YEAR(order_date) AS order_year,
        MONTH(order_date) AS order_month,
        SUM(sale_price) AS sales
    FROM u_orders
    WHERE YEAR(order_date) IN (2022, 2023)
    GROUP BY YEAR(order_date), MONTH(order_date)
)
SELECT 
    order_year,
    order_month,
    sales,
    LAG(sales) OVER (PARTITION BY order_year ORDER BY order_month) AS previous_month_sales,
    ROUND(((sales - LAG(sales) OVER (PARTITION BY order_year ORDER BY order_month)) / LAG(sales) OVER (PARTITION BY order_year ORDER BY order_month)) * 100, 2) AS month_over_month_growth
FROM sales_data
WHERE order_year IN (2022, 2023)
ORDER BY order_year, order_month;

#for each category which month has highest sales
with sales_data as (
select category, year(order_date) as order_year,
month(order_date) as order_month,
sum(sale_price) as sales from u_orders
where year(order_date) in(2022,2023)
group by category, year( order_date), month(order_date)
),

 ranked_sales as(
 select category, order_year,order_month,sales,
 rank() over (partition by category order by sales desc) as sales_rank
 from sales_data)
 select category, order_year, order_month,sales from ranked_sales 
 where sales_rank =1 
 order by category, order_year, order_month;
 
 
 # which sub category had highest growth by profit in 2023 compare to 2022
 with yearly_profit as (
 select sub_category, year(order_date) as order_year, sum(profit) as profit1 from u_orders 
 where year(order_date) in (2022,2023)
 group by sub_category, order_year
 ),
 
 profit_growth as (
 select sub_category,
 max(case when order_year =2023 then profit end ) as profit_2023,
 max(case when order_year =2022 then profit end ) as profit_2022
 from yearly_profit
 group by sub_category
 )
 
 SELECT 
    subcategory,
    profit_2023,
    profit_2022,
    ROUND(((profit_2023 - profit_2022) / profit_2022) * 100, 2) AS growth_percentage
FROM profit_growth
WHERE profit_2022 > 0  -- To avoid division by zero
ORDER BY growth_percentage DESC
LIMIT 1;
 
 
 
 
 
 
