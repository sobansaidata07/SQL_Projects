-- Number of Orders per regions
select o.region as regions , count(distinct o.order_id) as orders 
from orders_data as o group by o.region order by orders desc;

-- Number of Order per supplier
with base as (
select o.region , count(distinct o.order_id) as orders , po.Person as Supplier from 
orders_data as o inner join peoples_data as po on po.region = o.region group by  po.Person , o.region)
select supplier , region , orders from base order by orders desc;

-- Products that yield more Profit per year
with base as (
select year(o.order_date) as years , p.product_id , p.product_name , sum(s.profit) as profits from 
sales_data as s inner join orders_data as o on o.order_id = s.order_id 
inner join products_data as p on p.product_id = s.product_id
group by years, p.product_id , p.product_name ),
req as (
select * , 
rank() over (partition by years order by profits desc) as rankings from base )
select * from req where rankings =1;

-- Customer Segmentation based on sales values.
with base as (
select c.customer_id,c.customer_name,sum(s.sales) as total_revenue
from sales_data as s inner join orders_data as o on o.order_id = s.order_id
inner join customers_data as c on c.customer_id = s.customer_id
group by c.customer_id, c.customer_name
),
totals as (
select sum(total_revenue) as total_sales from base
),
final_req as (
select b.*,
round((b.total_revenue / t.total_sales) * 100,2) as revenue_percent
from base b
cross join totals as t) 
select *,case 
when revenue_percent >= 0.5 then 'Gold'
when revenue_percent >= 0.2 then 'Silver'
else 'Bronze'
end as status from final_req;

-- I choose 0.5% bcz my total sales is 22 lakh and max salevalue per customer is 25k so choosing 0.5% is correct approach.

-- Show Sales and Profit trend over time
select year(o.order_date) as years , sum(s.sales) as total_sales , sum(s.profit) as total_profit from 
sales_data as s inner join orders_data as o on o.order_id = s.order_id 
group by years;

-- Identify top 10 customers by profit contribution
select c.customer_id , c.customer_name , sum(s.profit) as total_profit from customers_data as c 
inner join sales_data as s on s.customer_id = c.customer_id group by c.customer_id , c.customer_name 
order by total_profit desc limit 10;

-- Sales by region 
select o.region , sum(s.sales) as total_sales from orders_data as o inner join sales_data as s 
on s.order_id = o.order_id group by region order by total_sales desc;

-- Total Sales, Total Profit, Profit Ratio

select round(sum(sales),2) as total_sales , round(sum(profit),2) as total_profit , 
round(((sum(profit)) / (sum(sales)))*100,2) as Profit_ratio 
 from sales_data ;

-- Category-Subcategory profitability matrix -Identify loss-making subcategories within each category.
with base as (select p.category , p.subcategory , 
sum(s.profit) as profits from sales_data as s inner join products_data as p
on p.product_id = s.product_id group by  p.category , p.subcategory ), 
req as (
select * , 
case
when profits >= 0 then "PROFIT MAKING"
when profits <0 then "LOSS MAKING"
else "Unknown"
end as profit_loss_status from base )
select * from req;

-- Top 5 Products with sales 
select p.product_id , p.product_name , sum(s.profit) as total_sales from 
sales_data as s inner join products_data as p on p.product_id = s.product_id 
group by p.product_id , p.product_name 
order by total_sales desc 
limit 5;

-- Returned orders from which city and states
select o.city , o.state , count(r.Order_ID) as return_orders from orders_data as o 
inner join returns_data as r on r.Order_ID = o.order_id group by o.city,o.state order by return_orders desc;








