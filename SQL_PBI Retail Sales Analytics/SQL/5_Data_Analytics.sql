-- 1. How many unique customers are there?
select count(distinct customer_id) as unique_customers from customer_data ;
-- 2. How many total products are available?
select count(distinct product_id) as total_products from product_data;
-- 3. What is the total number of orders?
select count(order_id) as number_of_orders from sales_data;
-- 4. What is the total revenue (gross and net)?
select sum(sale_gross_price) as Gross_value , sum(sale_net_price) as Net_value from sales_data;
-- 5. What is the total discount given across all orders?
select sum(total_discount) as total_discount from sales_data;
-- 6. Which products have the highest sales quantity?
select s.product_id , p.product_name , sum(s.quantity) as sales_quantity 
from sales_data as s inner join product_data as p 
on s.product_id = p.product_id
group by product_id , p.product_name order by sales_quantity desc;
-- 7. Which products generated the highest revenue?
select s.product_id , p.product_name , sum(s.sale_net_price) as total_revenue
from sales_data as s inner join product_data as p 
on s.product_id = p.product_id
group by product_id , p.product_name order by total_revenue desc;
-- 8. What is the average order value (gross and net)?
select avg(sale_gross_price) as avg_order_value_gross ,
avg(sale_net_price) as avg_order_value_net from sales_data ;
-- 9. How many customers belong to each loyalty tier?
select loyalty_tier , count(customer_id) as customers from customer_data group by loyalty_tier order by customers desc;
-- 10. How many orders were delivered, delayed, or cancelled?
select delivery_status , count(order_id) as orders from sales_data group by delivery_status order by orders desc;
-- 11. Which region generates the highest sales revenue?
select region , sum(sale_net_price) as sales_revenue from sales_data group by region order by sales_revenue desc;
-- 12. Which region has the highest number of orders?
select region , count(order_id) as orders from sales_data group by region order by orders desc;
-- 13. What is the monthly sales trend over time?
with raw_data as (
select sum(sale_net_price) as sales , monthname(order_date) as name_of_month from sales_data group by name_of_month),
required_data as (
select name_of_month , sales, sum(sales) over(order by name_of_month ) as running_sales from raw_data)
select *,
case
when running_sales > lag(running_sales) over(order by name_of_month) then 'increase'
when running_sales < lag(running_sales) over(order by name_of_month) then 'Decrease'
else 'Nothing'
end as status
 from required_data ;

-- 14. What is the yearly sales trend?
select *,
case
when running_total > lag(running_total) over(order by years) then 'increase'
when running_total < lag(running_total) over(order by years) then 'Decrease'
else 'Nothing'
end as status from (
select * , sum(sales) over (order by years) as running_total from (
select year(order_date) as years , sum(sale_net_price) as sales from sales_data group by years) as t ) as tt;
-- 15. What is the average discount applied per order?
select avg(discount_applied) as avg_discount from sales_data ;
-- 16. Which customers have placed the most orders?
select c.customer_id , count(s.order_id) as orders from customer_data as c 
inner join sales_data as s on s.customer_id = c.customer_id 
group by c.customer_id order by orders desc;
-- 17. Which customers have generated the highest revenue?
select c.customer_id , sum(s.sale_net_price) as total_revenue from 
customer_data as c inner join sales_data as s on s.customer_id = c.customer_id
group by c.customer_id order by total_revenue desc;
-- 18. How many products are in each category?
select category,count(product_name) as products from product_data group by category order by products desc;
-- 19. What is the revenue per product category?
select p.category , sum(s.sale_net_price) as revenue from product_data as p inner join sales_data as s 
on s.product_id = p.product_id 
group by p.category order by revenue desc;
-- 20. What is the average revenue per customer?
select avg(sale_net_price) as avg_revenue from sales_data;
-- 21. What is the repeat purchase rate of customers?
select * from (select sale_net_price , count(customer_id) as customers from sales_data 
group by sale_net_price ) as t where customers = (
SELECT MAX(cnt)
FROM (
SELECT COUNT(customer_id) AS cnt
FROM sales_data
GROUP BY sale_net_price
) tt
);
-- 22. What is the ratio of male vs female customers?
with raw_data as (
select 
sum(case when gender = 'Male' then 1 else 0 end) as males,
sum(case when gender = 'Female' then 1 else 0 end) as females
from customer_data 
),
required_data as (
select * , (males/females) as male_female_ratio from raw_data  
)
select * from required_data ;
-- 23. Which products were launched most recently?
select product_name , launch_date from product_data order by launch_date desc limit 3;
-- 24. How many orders used each payment method?\
select payment_method , count(order_id) as orders from sales_data group by payment_method order by orders desc;
-- 25. What is the total revenue by payment method?
select payment_method , sum(sale_net_price) as total_revenue from sales_data group by payment_method order by total_revenue desc;
-- 26. How many orders were placed in each month?
select monthname(order_date) as name_of_month , count(order_id) as orders from sales_data group by name_of_month order by name_of_month ;
-- 27. How many orders have missing or unknown data in key columns?
SELECT
SUM(CASE WHEN order_id IS NULL THEN 1 ELSE 0 END) AS missing_order_id,
SUM(CASE WHEN customer_id IS NULL THEN 1 ELSE 0 END) AS missing_customer_id,
SUM(CASE WHEN product_id IS NULL THEN 1 ELSE 0 END) AS missing_product_id,
SUM(CASE WHEN quantity IS NULL THEN 1 ELSE 0 END) AS missing_quantity,
SUM(CASE WHEN order_date IS NULL THEN 1 ELSE 0 END) AS missing_order_date,
SUM(CASE WHEN delivery_status IS NULL OR delivery_status = 'Unknown' THEN 1 ELSE 0 END) AS missing_delivery_status,
SUM(CASE WHEN payment_method IS NULL OR payment_method = 'Unknown' THEN 1 ELSE 0 END) AS missing_payment_method,
SUM(CASE WHEN region IS NULL OR region = 'Unknown' THEN 1 ELSE 0 END) AS missing_region
FROM sales_data;
-- 28. Which products have never been sold?
select p.product_id  from product_data as p 
left join sales_data as s on p.product_id = s.product_id 
where s.product_id is null;
-- 29. What is the top 10 best-selling products by quantity and revenue?
-- version 1
select p.product_id , p.product_name , sum(s.sale_net_price) as revenue , sum(s.quantity) as total_quantity from 
sales_data as s inner join product_data as p on p.product_id = s.product_id 
group by p.product_id , p.product_name
order by revenue desc, total_quantity desc
limit 10;
-- version 2
with raw_data as (
select p.product_id , p.product_name , sum(s.sale_net_price) as revenue , sum(s.quantity) as total_quantity from 
sales_data as s inner join product_data as p on p.product_id = s.product_id 
group by p.product_id , p.product_name 
),
required_data as (
select * , dense_rank()over(order by revenue desc , total_quantity desc) as rankings from raw_data )
select * from required_data where rankings <= 10;
-- 30. What is the correlation between discount applied and net sales?
select ((avg(discount_applied *sale_net_price) - ((avg(discount_applied))*(avg(sale_net_price))))/
(stddev_pop(discount_applied)*stddev_pop(sale_net_price))) as correlation from sales_data;
-- Observation :[correlation -0.10312264240085313] There is a very weak negative correlation, 
-- so orders with higher discounts tend to have slightly lower net sales, but the effect is very small 

 -- 31. Top 5 customers by total net sales
 -- version 1 
 select c.customer_id , sum(s.sale_net_price) as revenue from sales_data as s 
 inner join customer_data as c on c.customer_id = s.customer_id
 group by c.customer_id order by revenue desc limit 5 ;
 -- version 2 
 with raw_data as(
 select c.customer_id , sum(sale_net_price) as revenue from sales_data as s 
 inner join customer_data as c on c.customer_id = s.customer_id
 group by c.customer_id
 ) ,
 req as (
 select * , 
 dense_rank () over(order by revenue desc) as rankings from raw_data
 )
 select * from req where rankings <= 5;

-- 32. Products with highest average discount applied
select product_id , avg(discount_applied) as discount from sales_data group by product_id 
order by discount desc ;
-- 33. Monthly revenue trend for the last 12 months
with raw_data as (
select monthname(order_date) as name_of_month , sum(sale_net_price) as revenue from 
sales_data group by name_of_month
),
required as (
select * , sum(revenue) over (order by name_of_month) as runnings from raw_data 
)
select *,
case 
when runnings > lag(runnings) over (order by name_of_month) then 'Increase'
when runnings < lag(runnings) over (order by name_of_month) then 'Decrease'
else 'Nonthing'
end as status
 from required;

-- 34. Year-over-year sales growth per region
with raw_data as (
select year(order_date) as years , sum(sale_net_price) as sales , region from sales_data 
group by years , region
),
req as (
select * , 
sum(sales) over(partition by region order by years ) as runnings from raw_data 
)
select region, years, sales , runnings,
case 
when runnings > lag(runnings) over (partition by region order by years) then 'Increase'
when runnings < lag(runnings) over (partition by region order by years) then 'Decrease'
else 'Nothing'
end as status from req;
-- 35. Average time between customer signup and first order
with raw_data as (
select c.customer_id , c.signup_date , min(s.order_date) as first_order_date from customer_data as c 
inner join sales_data as s on s.customer_id = c.customer_id group by c.customer_id , c.signup_date 
),
req as (
select * , datediff(first_order_date,signup_date) as days_took from raw_data
)
select AVG(days_took) AS avg_days from req;
-- 36. Repeat purchase rate per loyalty tier
WITH customer_orders AS (
    SELECT 
        c.customer_id,
        c.loyalty_tier,
        COUNT(s.order_id) AS total_orders
    FROM customer_data c
    LEFT JOIN sales_data s 
        ON c.customer_id = s.customer_id
    GROUP BY c.customer_id, c.loyalty_tier
)
SELECT
    loyalty_tier,
    COUNT(*) AS total_customers,
    SUM(CASE WHEN total_orders >= 2 THEN 1 ELSE 0 END) AS repeat_customers,
    SUM(CASE WHEN total_orders >= 2 THEN 1 ELSE 0 END) / COUNT(*) AS repeat_rate
FROM customer_orders
GROUP BY loyalty_tier
ORDER BY loyalty_tier;


-- 37. Cohort analysis: customers grouped by signup month and their total spend
with raw_data as (
select c.customer_id , min(s.order_date) as first_order , sum(s.sale_net_price) as total_spend from 
customer_data as c inner join sales_data as s on c.customer_id = s.customer_id group by c.customer_id 
)
select date_format(first_order , '%Y-%m-01') as cohort_month , count(customer_id) as ids ,
sum(total_spend) as total_revenue from raw_data group by cohort_month;

-- 38. Top 3 payment methods per region
with raw_data as (
select region , payment_method , count(order_id) as orders from sales_data group by region , payment_method
)
select * from (select * ,dense_rank() over(partition by region order by orders desc) as rankings from raw_data) as t where rankings <=3 ;
-- 39. Products never ordered
select p.product_id , p.product_name from product_data as p left join sales_data as s on
 s.product_id = p.product_id where s.product_id is null;

-- 40. Sales distribution by product category
SELECT 
p.category,
SUM(s.sale_net_price) AS total_sales,
ROUND(
SUM(s.sale_net_price) * 100.0 
/ SUM(SUM(s.sale_net_price)) OVER (), 2
) AS sales_percentage
FROM product_data p
JOIN sales_data s
ON p.product_id = s.product_id
GROUP BY p.category;

-- 41. Correlation between discount applied and net sales
select ((avg(discount_applied*sale_net_price) - (avg(discount_applied) * avg(sale_net_price)))/
(stddev_pop(discount_applied)*stddev_pop(sale_net_price))) as correlation from sales_data ;
-- 42. Percentage of cancelled vs delivered vs delayed orders per month
with raw_data as (
select monthname(order_date) as name_of_month ,
sum(case when delivery_status = 'Delivered' then 1 else 0 end) as Delivered_count ,
sum(case when delivery_status = 'Cancelled' then 1 else 0 end) as Cancelled_count ,
sum(case when delivery_status = 'Delayed' then 1 else 0 end) as Delayed_count ,
sum(case when delivery_status in('Delivered','Cancelled', 'Delayed') then 1 else 0 end) as Total_count from sales_data 
group by name_of_month
)
select name_of_month , 
round((Delivered_count/Total_count),2) as Delivered_percentage,
round((Cancelled_count/Total_count),2) as Cancelled_percentage,
round((Delayed_count/Total_count),2) as Delayed_percentage from raw_data;
-- 43. Average order value per customer
select avg(sale_net_price) as avg_order from sales_data;
-- 44. Customers with no orders in the last 6 months
SELECT c.customer_id
FROM customer_data c
LEFT JOIN sales_data s
ON s.customer_id = c.customer_id
AND s.order_date >= DATE_SUB(CURDATE(), INTERVAL 6 MONTH)
WHERE s.customer_id IS NULL;

-- 45. Highest grossing product per month
with raw_data as (select monthname(s.order_date) as name_of_month , p.product_name , sum(s.sale_net_price) as revenue from 
product_data as p inner join sales_data as s on s.product_id = p.product_id group by name_of_month , p.product_name ),
req as (
select * , 
dense_rank() over ( partition by name_of_month order by revenue desc) as rankings from raw_data)
select * from req where rankings = 1;

-- 46. Top 5 regions by total net sales
select region, sum(sale_net_price) as sales from sales_data group by region order by sales desc;
WITH raw_data AS (
SELECT 
c.customer_id,
COUNT(s.order_id) AS orders,
SUM(s.sale_net_price) AS revenue
FROM customer_data c INNER JOIN sales_data s  ON s.customer_id = c.customer_id GROUP BY c.customer_id
),
revenue_calc AS (
SELECT *,
SUM(revenue) OVER () AS total_revenue,SUM(revenue) OVER (ORDER BY revenue DESC) AS cumulative_revenue FROM raw_data
)
SELECT *,
(cumulative_revenue / total_revenue) * 100 AS cumulative_percentage
FROM revenue_calc
WHERE (cumulative_revenue / total_revenue) <= 0.80
ORDER BY revenue DESC;

-- 48. Trend of new customer acquisition by month
-- no data
-- 49. Products with most inconsistent pricing (variance in unit_price)
with raw_data as (
select p.product_id , max(s.unit_price) as high_price , min(s.unit_price) as low_price  from product_data as p inner join sales_data as s 
on s.product_id = p.product_id group by p.product_id
),
requirement as (
select * , (high_price - low_price) as diff_price from raw_data
)
select * from requirement order by diff_price desc;

-- 50. Average discount by loyalty tier
select c.loyalty_tier , avg(s.discount_applied) as avg_discount from customer_data as c 
inner join sales_data as s on s.customer_id = c.customer_id 
group by c.loyalty_tier order by avg_discount;
-- 51. Net sales vs gross sales ratio per month
select name_month,gross_sales,net_sales,(net_sales/gross_sales) as net_gross_sale_ratio from (
select monthname(order_date) as name_month, sum(sale_net_price) as net_sales , sum(sale_gross_price) as gross_sales from 
sales_data group by name_month order by name_month ) as t ;
-- 52. Most common order quantity per product
select quantity , count(order_id) as orders from sales_data group by quantity order by orders desc limit 1;
-- 53. Orders with mismatched region between customer and sale
with raw_data as (
select s.order_id , c.region , s.region  from customer_data as c inner join sales_data as s 
on s.customer_id = c.customer_id 
where c.region <> s.region)
select * from raw_data;

-- 54. Average time from order date to delivery date (if you have delivery timestamps)
-- dont have any related data

-- 55. Net revenue lost due to cancelled orders
select sum(sale_net_price) as sales from sales_data where delivery_status = 'Cancelled';

-- 56. Customers per loyalty tier 
select loyalty_tier , count(customer_id) as customers from customer_data group by loyalty_tier order by customers desc;
-- 57. Top suppliers by total sales
select p.supplier_code , sum(s.sale_net_price) as sales from sales_data as s inner join product_data as p 
on p.product_id = s.product_id group by p.supplier_code order by sales desc;
-- 58. Seasonality: products with peak sales in specific months
with raw_data as (
select p.product_id , p.product_name , monthname(s.order_date) as name_month ,sum(s.sale_net_price) as total_sales 
from product_data as p inner join sales_data as s on s.product_id = p.product_id 
group by p.product_id , p.product_name , name_month order by total_sales desc ) , required as (
select * , 
dense_rank() over (partition by name_month order by total_sales desc) as rankings from raw_data)
select *  from required where rankings = 1;

-- 59. Sales trend during promotional periods (if you have promo flags)
-- no related data

-- 60. Customer segmentation based on total spend 
with raw_data as (
select c.customer_id , sum(s.sale_net_price) as total_spend from customer_data as c 
inner join sales_data as s on s.customer_id = c.customer_id 
group by c.customer_id
order by total_spend desc
),
required_data as(
select * , 
case 
when total_spend < 250 then 'Reasonable Customer'
when total_spend >= 250 and total_spend < 500 then 'Loyal Customer' 
when total_spend >= 500 and total_spend < 1000 then 'Good Customer'
when total_spend >= 1000 then 'Premium Customer'
end as segement_customer  from raw_data
)
select * from required_data;

