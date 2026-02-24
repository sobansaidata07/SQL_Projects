select distinct(prod) from raw_products;
select count(distinct(product_name)) from raw_products;

select distinct(delivery_status) from raw_sales;
select distinct(payment_method) from raw_sales;

select distinct(gender) from raw_customer;
select distinct(region) from raw_sales;
select distinct(region) from raw_customer;


select * from raw_products;
select distinct(category) from raw_products;

select distinct(delivery_status) from raw_sales;

select distinct(loyalty_tier) from raw_customer;

select distinct(launch_date) from raw_products;

select (order_date) from raw_sales;
SELECT order_id, COUNT(*) 
FROM raw_sales 
GROUP BY order_id 
HAVING COUNT(*) > 1;
