-- ===============================================================
--                  WITH RAW DATA FOR GIVEN QUERIES
-- ===============================================================
-- Identify customers whose total sales are above the average sales of all customers

select  `Customer ID` , `Customer Name` , sum(Sales) as total_sales from raw_orders
group by `Customer ID` , `Customer Name`
having  sum(Sales) > 
(select avg(totals) as avg_sale from 
(select sum(Sales) as totals from raw_orders group by  `Customer ID`) as t )
order by `Customer ID` ;

-- Find the customer who has made the maximum number of  orders in each category:
WITH base AS 
(select `Customer ID`,`Customer Name`,category,COUNT(DISTINCT `Order ID`) AS total_orders
FROM raw_orders GROUP BY `Customer ID`, `Customer Name`, category
),
reqq as  (Select *,RANK() over (partition by category Order by total_orders desc) AS rank_orders FROM base
)
select * from reqq WHERE rank_orders = 1 ORDER BY category;

-- Find the top 3 products in each category based on their sales.

select * from (select * , 
row_number () over (partition by `Category` order by total_sales desc) as rownums from 
(select `Product ID`, `Product Name` , `Category` , sum(Sales) as total_sales from raw_orders 
group by `Product ID`, `Product Name` , `Category` order by total_sales desc) as t)
 as tt where rownums in (1,2,3) order by `Category` ;

-- Calculate year-over-year (YoY) sales growth  
select * , 
round((current_year_sales-prev_year_sales),2) as impact_on_sales,
case
when current_year_sales > prev_year_sales then "Increase" 
when current_year_sales < prev_year_sales then "Decrease"
else "No Change" end as growth_check from (
select years , 
lag(total_sales) over (order by years) as prev_year_sales ,
total_sales as current_year_sales from (
select year(str_to_date(`Order Date`,'%d-%m-%Y')) as years , round(sum(Sales),2)as total_sales 
from raw_orders group by years) as t) as tt ;

-- Find the most profitable shipping mode for each region
with base as (
select `Region` , `Ship Mode` , round(sum(Sales),2) as total_sales , round(sum(Profit),2) as total_profit
from raw_orders
group by  `Region` , `Ship Mode` 
),
req as (
select * , 
dense_rank() over(partition by `Region` order by total_sales desc, total_profit desc) as rankings from base)
select * from req ;

-- lets create a table orders with following details
-- In the table Orders with columns OrderID, CustomerID, OrderDate, TotalAmount, and Status.
create table 
Table_orders_RAW (
TORAW_Order_id varchar(20) primary key , 
TORAW_Customer_id varchar(20),
TORAW_order_date date ,
TORAW_total_amount decimal(15,4) ,
TORAW_status varchar(5));

insert into Table_orders_RAW (TORAW_Order_id , TORAW_Customer_id ,TORAW_order_date , TORAW_total_amount , TORAW_status)
select o.`Order ID` , o.`Customer ID` , str_to_date(o.`Order Date`,"%d-%m-%Y")  , sum(o.Sales) as sales , 
case when r.Returned = "Yes" then "Yes" else "NO" end as Returned_status from  
raw_orders as o
left join raw_returns as r on o.`Order ID` = r.`Order ID` 
group by o.`Order ID` , o.`Customer ID` , o.`Order Date` , r.Returned ;

select count(*) from Table_orders_RAW ;

-- You need to create a stored procedure Get_Customer_Orders that takes a CustomerID as input and returns a table with
-- the following columns, you will need to create a function also that calculates the number of days between two dates
-- OrderDate , TotalAmount , TotalOrders, AvgAmount, LastOrderDate, DaysSinceLastOrder: 

-- lets create a function 
delimiter //
create function function_days_between_Raw(Order_date date , Ship_date date) 
returns int 
deterministic
begin
declare days int ;
set days = timestampdiff(day,order_date , ship_date);
return days ;
end //
delimiter ;

drop function function_days_between;
select function_days_between_Raw("2014-03-12","2014-03-18") as daysbetween;

-- lets create the procedure  

delimiter //
create procedure Get_Customer_Orders_RAW(IN cid varchar(20))      -- For Individual details
BEGIN
select  
`Customer ID` as customerid ,
`Customer Name` as name,
`Order ID` as orderid,
str_to_date(`Order Date`,"%d-%m-%Y") as OrderDate,
str_to_date(`Ship Date`,"%d-%m-%Y") as shipdate,
(select function_days_between_Raw(str_to_date(`Order Date`,"%d-%m-%Y"),str_to_date(`Ship Date`,"%d-%m-%Y"))) as days_between,
sum(Sales) as TotalAmount , 
count(distinct `Order ID`)TotalOrders, 
(sum(Sales)/count(distinct `Order ID`)) as AvgAmount, 
max(str_to_date(`Order Date`,"%d-%m-%Y")) as LastOrderDate, 
timestampdiff(day,max(str_to_date(`Order Date`,"%d-%m-%Y")),current_date()) as DaysSinceLastOrder from 
raw_orders 
where `Customer ID` = cid
group by`Customer ID` ,`Customer Name` ,`Order ID` ,`Order Date` ,`Ship Date`;
end //
delimiter ;

delimiter //
create procedure Get_Customer_Orders_RAW_Total(IN cid varchar(20))      -- For whole as one detail
BEGIN
with base as (
select  
`Customer ID` as customerid ,
`Customer Name` as name,
str_to_date(`Order Date`,"%d-%m-%Y") as OrderDate,
sum(Sales) as TotalAmount , 
count(distinct `Order ID`)TotalOrders,  
(sum(Sales)/count(distinct `Order ID`)) as AvgAmount, 
max(str_to_date(`Order Date`,"%d-%m-%Y")) as LastOrderDate,  
timestampdiff(day,max(str_to_date(`Order Date`,"%d-%m-%Y")),current_date()) as DaysSinceLastOrder from 
raw_orders 
group by `Customer ID` ,`Customer Name` ,`Order ID` ,`Order Date` ,`Ship Date`),
req as 
( select customerid , name , min(OrderDate) first_order_date, sum(TotalAmount) as total_revenue, 
sum(TotalOrders) as total_orders, 
(sum(TotalAmount)/sum(TotalOrders)) as Avg_amt , max(LastOrderDate)  as last_orderdate,
timestampdiff(day,max(LastOrderDate),current_date()) as DaysSinceLastOrder from base 
group by customerid, name )
select * from req where customerid = cid;
end //
delimiter ;


call Get_Customer_Orders_RAW('AB-10060');                     -- To check for all orders related to customer
call Get_Customer_Orders_RAW_Total('AB-10060');               --  To check for whole info about the customer