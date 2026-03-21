use Sales_Analytics;
-- Customer view
create or replace view customer_data as 
select customer_id, email, signup_date, gender, region, loyalty_tier from customers;

-- product view
create or replace view product_data as 
select product_id, product_name, category, launch_date, base_price, supplier_code from products;

-- sales view
create or replace view sales_data as 
select 
s.order_id, s.customer_id, s.product_id,s.quantity, s.unit_price, s.order_date, 
s.delivery_status, s.payment_method, s.region, s.discount_applied ,
((s.quantity * s.unit_price)) as sale_gross_price ,
(s.quantity * s.unit_price) * (1 - s.discount_applied) AS sale_net_price,
(s.quantity * s.unit_price) * s.discount_applied AS total_discount from sales as s;
 
-- view the views
select * from sales_data;
select * from product_data ;
select * from customer_data ;

