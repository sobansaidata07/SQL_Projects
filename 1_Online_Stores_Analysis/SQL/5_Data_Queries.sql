-- ===============================================================
--                WITH NORMALIZED DATA FOR GIVEN QUERIES
-- ===============================================================
-- Identify customers whose total sales are above the average sales of all customers
with Base as (
select c.customer_id , c.customer_name , sum(s.sales) as total_sales 
from sales_data as s inner join customers_data as c on c.customer_id = s.customer_id
group by c.customer_id , c.customer_name ) , 
requirement as (
select avg(total_sales) as avg_sales from base )
select b.customer_id , b.customer_name , b.total_sales from Base as b 
cross join requirement as j where b.total_sales > j.avg_sales order by b.total_sales desc;    -- avg sales is 2865.64

-- =====================================================================================================================

-- Find the customer who has made the maximum number of  orders in each category:
with base as
(select c.customer_id , c.customer_name,p.category , count(distinct s.order_id) as customer_orders from customers_data as c 
inner join orders_data as o on c.customer_id = o.customer_id 
inner join sales_data as s on s.order_id = o.order_id
inner join products_data as p on s.product_id = p.product_id 
group by  c.customer_id , c.customer_name,p.category ), 
req as (
select * , rank() over (partition by category order by customer_orders desc) as rankings from base )
SELECT category, customer_id, customer_name, customer_orders
FROM req
WHERE rankings = 1
ORDER BY category;
-- =====================================================================================================================

-- Find the top 3 products in each category based on their sales.
with base as (
select p.category , p.product_id , p.product_name , sum(s.sales) as total_sales 
from sales_data as s inner join products_data as p on p.product_id = s.product_id 
group by p.product_id , p.product_name , p.category),
ranks as (
select * , 
dense_rank() over (partition by category order by total_sales desc) as rankings from base )
select * from ranks where rankings in (1,2,3)
order by category;
-- =====================================================================================================================
-- Calculate year-over-year (YoY) sales growth  
with base as (
select year(o.order_date) as years , sum(s.sales) as total_sales from sales_data as s 
inner join orders_data as o on o.order_id = s.order_id 
group by years),
req as (
select years ,
lag(total_sales) over (order by years) as previous_year_sale , 
total_sales as current_year_sale from base )
select * , 
(current_year_sale-previous_year_sale) as impact_on_sales,
round(((current_year_sale-previous_year_sale)/previous_year_sale)*100,2) as 'impact_as_%',
case 
when previous_year_sale < current_year_sale then "Growth" 
when previous_year_sale > current_year_sale then "Decline" 
else "No Change" end as Growth_analysis
from req; 

-- =====================================================================================================================
-- Find the most profitable shipping mode for each region
delimiter //
create procedure shipmode_region_metric (IN metric varchar(10) , required int )
BEGIN

If metric = "sales" and required <> 0 then
with base as (
select o.region ,  o.ship_mode , sum(s.sales) as total_sales
from orders_data as o inner join sales_data as s on s.order_id = o.order_id
group by  o.ship_mode , o.region 
),
req as (
select * , 
dense_rank() over(partition by region order by total_sales desc) as rankings from base)
select * from req where rankings <= required ;

elseif metric = "sales" and required = 0 then
with base as (
select o.region ,  o.ship_mode , sum(s.sales) as total_sales
from orders_data as o inner join sales_data as s on s.order_id = o.order_id
group by  o.ship_mode , o.region 
),
req as (
select * , 
dense_rank() over(partition by region order by total_sales desc) as rankings from base)
select * from req ;

elseif metric = "profit" and required = 0 then
with base as (
select o.region ,  o.ship_mode , sum(s.profit) as total_profit
from orders_data as o inner join sales_data as s on s.order_id = o.order_id
group by  o.ship_mode , o.region 
),
req as (
select * , 
dense_rank() over(partition by region order by  total_profit desc) as rankings from base)
select * from req ;

elseif metric = "profit" and required <> 0 then
with base as (
select o.region ,  o.ship_mode , sum(s.profit) as total_profit
from orders_data as o inner join sales_data as s on s.order_id = o.order_id
group by  o.ship_mode , o.region 
),
req as (
select * , 
dense_rank() over(partition by region order by total_profit desc) as rankings from base)
select * from req where rankings <= required ;

elseif metric = "both" and required <> 0 then
with base as (
select o.region ,  o.ship_mode , sum(s.sales) as total_sales , sum(s.profit) as total_profit
from orders_data as o inner join sales_data as s on s.order_id = o.order_id
group by  o.ship_mode , o.region 
),
req as (
select * , 
dense_rank() over(partition by region order by total_sales desc, total_profit desc) as rankings from base)
select * from req where rankings <= required;

elseif metric = "both" and required = 0 then
with base as (
select o.region ,  o.ship_mode , sum(s.sales) as total_sales , sum(s.profit) as total_profit
from orders_data as o inner join sales_data as s on s.order_id = o.order_id
group by  o.ship_mode , o.region 
),
req as (
select * , 
dense_rank() over(partition by region order by total_sales desc, total_profit desc) as rankings from base)
select * from req ;

end if ;
end //
delimiter ;

-- Note : "Sales": based on sales , "Profit" : based on profit , "both": based on profit
-- Note : 0 : Full details , (1,2,3,4) : as per requriments
-- Enter between 0 to 4 only


call shipmode_region_metric ("sales" , 0);     -- All Ranks based on Sales
call shipmode_region_metric ("sales" , 1);     -- Top Ranks (user defined) based on Sales
call shipmode_region_metric ("profit" , 0);    -- All Ranks based on Sales
call shipmode_region_metric ("profit" , 1);    -- Top Ranks (user defined) on Profit
call shipmode_region_metric ("both" , 0);      -- All Ranks based on Sales & Profit
call shipmode_region_metric ("both" , 1);      -- Top Ranks (user defined) based on Sales & Profit
call shipmode_region_metric ("both" , 2);      -- Top Ranks (user defined) based on Sales & Profit

-- =====================================================================================================================
-- lets create a table orders with following details
-- In the table Orders with columns OrderID, CustomerID, OrderDate, TotalAmount, and Status.
create table 
Table_orders (
TO_Order_id varchar(20) primary key , 
TO_Customer_id varchar(20),
TO_order_date date ,
TO_total_amount decimal(12,2) ,
TO_status varchar(5),
foreign key (TO_Customer_id) references customers_data(customer_id));

insert into Table_orders (TO_Order_id , TO_Customer_id , TO_order_date , TO_total_amount , TO_status)
select o.order_id , o.customer_id , o.order_date , sum(s.sales) as sales , 
case when r.Returned = "Yes" then "Yes" else "NO" end as Returned_status from  
sales_data as s
inner join orders_data as o on o.order_id = s.order_id 
left join Returns_data as r on r.order_id = o.order_id
group by o.order_id , o.customer_id , o.order_date , r.Returned ;

select * from Table_orders ;
select TO_status,sum(TO_total_amount) as total_value from Table_orders
 where TO_status = "YES" group by TO_status;

-- ==========================================================================================================================

-- You need to create a stored procedure Get_Customer_Orders that takes a CustomerID as input and returns a table with
-- the following columns, you will need to create a function also that calculates the number of days between two dates
-- OrderDate , TotalAmount , TotalOrders, AvgAmount, LastOrderDate, DaysSinceLastOrder: 

-- lets create a function 
delimiter //
create function function_days_between(Order_date date , Ship_date date) 
returns int 
deterministic
begin
declare days int ;
set days = timestampdiff(day,order_date , ship_date);
return days ;
end //
delimiter ;

drop function function_days_between;
select function_days_between("2014-03-12","2014-03-18") as daysbetween;

-- ==========================================================================================================================
-- lets create the procedure  

delimiter //
create procedure Get_Customer_Orders(IN cid varchar(20))      -- For Individual details
BEGIN
select  
c.customer_id as customerid ,
c.customer_name as name,
o.order_id as orderid,
o.order_date  as OrderDate,
o.ship_date as shipdate,
(select function_days_between(o.order_date,o.ship_date)) as days_between,   -- include that function here 
sum(s.sales) as TotalAmount , 
count(distinct o.order_id)TotalOrders, 
(sum(s.sales)/count(distinct o.order_id)) as AvgAmount, 
max(o.order_date) as LastOrderDate, 
timestampdiff(day,max(o.order_date),current_date()) as DaysSinceLastOrder from 
orders_data as o inner join sales_data as s on o.order_id = s.order_id 
inner join customers_data as c on s.customer_id = c.customer_id 
where c.customer_id = cid
group by o.order_date,o.ship_date,o.order_id , c.customer_id , c.customer_name;
end //
delimiter ;

delimiter //
create procedure Get_Customer_Orders_Total(IN cid varchar(20))      -- For whole as one detail
BEGIN
with base as (
select  
c.customer_id as customerid ,
c.customer_name as name,
o.order_date  as OrderDate,
sum(s.sales) as TotalAmount , 
count(distinct o.order_id)TotalOrders, 
(sum(s.sales)/count(distinct o.order_id)) as AvgAmount, 
max(o.order_date) as LastOrderDate, 
timestampdiff(day,max(o.order_date),current_date()) as DaysSinceLastOrder from 
orders_data as o inner join sales_data as s on o.order_id = s.order_id 
inner join customers_data as c on s.customer_id = c.customer_id  
group by o.order_date,o.order_id , c.customer_id , c.customer_name),
req as 
( select customerid , name , min(OrderDate) first_order_date, sum(TotalAmount) as total_revenue, 
sum(TotalOrders) as total_orders, 
(sum(TotalAmount)/sum(TotalOrders)) as Avg_amt , max(LastOrderDate)  as last_orderdate,
timestampdiff(day,max(LastOrderDate),current_date()) as DaysSinceLastOrder from base 
group by customerid, name )
select * from req where customerid = cid;
end //
delimiter ;

select * from raw_orders where `Customer ID` = "KM-16720";   
call Get_Customer_Orders("KM-16720");
call Get_Customer_Orders_Total("KM-16720");
-- ==========================================================================================================================






