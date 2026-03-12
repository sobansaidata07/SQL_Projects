-- Create views 

-- 1                    People data View

create or replace view peoples_data_view as 
select * from peoples_data;

select * from peoples_data_view;
-- ===============================================================
-- 2                   Returns Data view
create or replace view returns_data_view as 
select * from returns_data;

select * from returns_data_view;
-- ===============================================================
-- 3                  Customer Data View
create or replace view customer_data_view as 
select row_number() over (order by customer_id) as C_No,customer_id,customer_name,segment
from customers_data;

select * from customer_data_view;
-- ===============================================================
-- 4                 Product Data View
create or replace view product_data_view as 
select row_number() over (order by product_id) as P_No , product_id,category,subcategory,product_name 
from products_data;

select * from product_data_view;
-- ===============================================================
-- 5                Orders Data View 
create or replace view orders_data_view as 
select row_number() over (order by order_id) as O_No , 
order_id, customer_id,order_date,ship_date,
timestampdiff(day,order_date,ship_date) as days_taken_ship ,                        --  Find days between as requirement
ship_mode, country, city, state, postal_code, region from orders_data ;

select * from orders_data_view;
-- ===============================================================
-- 6                Sale Data View 
create or replace view sales_data_view as 
select 
order_id, product_id, customer_id,
quantity as total_quantity , ROUND(discount, 4) as discount_rate,
ROUND((sales - profit), 2) as Cost,
ROUND(CASE WHEN discount = 1 THEN NULL ELSE sales/(1-discount)END,2) as Gross_sales ,
ROUND(sales, 2) as Net_sales,
ROUND(profit, 2) as Actual_Profit ,
ROUND(CASE WHEN discount = 1 THEN NULL ELSE (sales/(1-discount))-(sales - profit) end,2) as Potential_profit,
ROUND(CASE WHEN discount = 1 THEN NULL ELSE((sales/(1-discount)) - sales)End, 2) AS Discount_value, 
ROUND(CASE WHEN quantity = 0 THEN NULL ELSE((sales/quantity))end , 2) as sale_per_unit, 
ROUND(CASE WHEN quantity = 0 THEN NULL ELSE ((sales - profit)/(quantity)) end,2)as cost_per_unit,
ROUND(CASE WHEN quantity = 0 THEN NULL ELSE((profit/quantity)) end,2) as profit_per_unit 
 from sales_data;
 
 select * from sales_data_view;
-- ===============================================================

-- ===============================================================
--                   TABLES
-- ===============================================================
show tables;
select * from customers_data;
select * from products_data ;
select * from orders_data ;
select * from sales_data;
-- ===============================================================
--                   VIEWS
-- ===============================================================
select * from peoples_data_view;
select * from returns_data_view ;
select * from customer_data_view ;
select * from product_data_view;
select * from orders_data_view;
select * from sales_data_view;


