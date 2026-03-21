-- ============================
-- CUSTOMER ANALYSIS QUESTIONS
-- ============================
-- How many customers exist by country and state?
select country , state , count(distinct customerkey) as customer_counts from 
customers group by country , state order by customer_counts desc;

-- What is the gender distribution of customers?
select gender , count(distinct customerkey) as customer_counts , 
ROUND((COUNT(DISTINCT CustomerKey) / (SELECT COUNT(*) FROM customers)) * 100,2) AS customer_percentage from 
customers group by gender order by customer_counts desc;

-- How many customers fall into different age groups?
-- Pivot age groups into columns
WITH base AS (SELECT COUNT(DISTINCT CustomerKey) AS customer_counts,TIMESTAMPDIFF(YEAR, Birthday, CURDATE()) AS years
FROM customers GROUP BY years
),
req AS (SELECT
SUM(CASE WHEN years < 30 THEN customer_counts ELSE 0 END) AS `Under 30 Years`,
SUM(CASE WHEN years BETWEEN 30 AND 50 THEN customer_counts ELSE 0 END) AS `30-50 Years`,
SUM(CASE WHEN years BETWEEN 51 AND 70 THEN customer_counts ELSE 0 END) AS `51-70 Years`,
SUM(CASE WHEN years >= 71 THEN customer_counts ELSE 0 END) AS `Over 70 Years` FROM base
)
SELECT * from req;

-- Which cities have the highest number of customers?
select city ,count(distinct customerkey) as customer_counts from customers group by city order by customer_counts desc limit 5;

-- Oldest and youngest customers
WITH base AS (
SELECT CustomerKey,Name,TIMESTAMPDIFF(YEAR, Birthday, CURDATE()) AS Age FROM customers )
SELECT CustomerKey, Name, Age FROM base
WHERE Age = (SELECT MAX(Age) FROM base)
   OR Age = (SELECT MIN(Age) FROM base)
ORDER BY Age DESC;

-- How many customers were born before a certain year using a procedure ?
delimiter //
create procedure customers_before_year(IN years int)
begin
select (select count(*) from customers) as total_customer_counts , 
count(distinct CustomerKey) as customer_counts from customers 
where year(birthday) < years;
end //
delimiter ;
start transaction ;
call customers_before_year(1955);                      -- enter the year
commit ;
rollback;
-- ============================
-- SALES ANALYSIS QUESTIONS
-- ============================

-- What is the total number of orders?
SELECT COUNT(OrderNumber) AS total_rows,COUNT(DISTINCT OrderNumber) AS total_orders FROM sales;

-- What is the total quantity sold?
select sum(Quantity) as qty_sold from sales;

-- How many orders are delayed vs not delayed?
-- ?

-- Which dates have the highest number of orders?
select orderdate , (count(distinct ordernumber)) as orders 
from sales group by orderdate order by orders desc limit 5 ;

-- What is the average quantity per order?
select avg(total_qty) as avg_qty from 
(select ordernumber,sum(quantity) as total_qty from sales group by ordernumber) as t;                           -- 7.5119
select avg(quantity) from sales;                                                                                -- 3.1448

-- Which currency is most used?
select CurrencyCode , count(distinct ordernumber) as orders
 from sales group by CurrencyCode order by orders desc limit 5;

-- ============================
-- PRODUCT ANALYSIS QUESTIONS
-- ============================

-- Which products are sold the most (by quantity)?
select p.ProductName ,sum(s.quantity) as total_qty  from sales as s 
inner join products as p on p.ProductKey = s.ProductKey
group by p.ProductName order by total_qty desc limit 10;

-- Which products generate the highest revenue?
SELECT p.ProductName,round(SUM(p.UnitPriceUSD*s.Quantity * e.Exchange)) AS highest_rev
FROM products AS p INNER JOIN sales AS s ON p.ProductKey = s.ProductKey INNER JOIN exchange_rates AS e 
ON e.Currency = s.CurrencyCode AND e.Date = s.OrderDate
GROUP BY p.ProductName
ORDER BY highest_rev DESC
LIMIT 5;

-- What is the average price per category?
select p.Category , round(avg(e.Exchange * s.Quantity * p.UnitPriceUSD)) as avg_price from 
products as p inner join sales as s on s.ProductKey = p.ProductKey
inner join exchange_rates as e on e.Currency = s.CurrencyCode and e.Date = s.OrderDate
group by p.Category order by avg_price desc; 

-- Which brand has the highest sales?
select p.Brand , round(sum(e.Exchange * p.UnitPriceUSD * s.Quantity)) as total_sales from 
products as p inner join sales as s on s.ProductKey = p.ProductKey
inner join exchange_rates as e on e.Currency = s.CurrencyCode and e.Date = s.OrderDate
group by p.Brand order by total_sales desc ;

-- Which product color is most popular?
select p.Color , count(distinct s.ordernumber) as orders , count(s.quantity) as total_qty from 
products as p inner join sales as s on s.ProductKey = p.ProductKey 
group by p.color order by orders desc ,total_qty desc;

-- Which category performs the best?
select p.Category , count(distinct s.ordernumber) as orders , count(s.quantity) as total_qty from 
products as p inner join sales as s on s.ProductKey = p.ProductKey 
group by p.Category order by orders desc ,total_qty desc;


-- ============================
-- REVENUE & PROFIT QUESTIONS
-- ============================

-- What is total revenue in USD?
select round(sum(e.Exchange * p.UnitPriceUSD * s.Quantity)) as total_revenue from products as p 
inner join sales as s on p.ProductKey = s.ProductKey
inner join exchange_rates as e on e.Currency = s.CurrencyCode and e.Date = s.OrderDate ; 

-- What is profit per product?
SELECT p.ProductName,round(SUM( (p.UnitPriceUSD*s.Quantity - p.UnitCostUSD*s.Quantity) * e.Exchange )) AS Profit
FROM products AS p INNER JOIN sales AS s ON s.ProductKey = p.ProductKey
INNER JOIN exchange_rates AS e ON e.Currency = s.CurrencyCode AND e.Date = s.OrderDate
GROUP BY p.ProductName ORDER BY Profit desc LIMIT 10;

-- Which products have the highest profit margin?
SELECT p.ProductName,round(((p.UnitPriceUSD - p.UnitCostUSD)* e.Exchange )) AS Profit
FROM products AS p INNER JOIN sales AS s ON s.ProductKey = p.ProductKey
INNER JOIN exchange_rates AS e ON e.Currency = s.CurrencyCode AND e.Date = s.OrderDate ORDER BY Profit desc LIMIT 10;


-- What is revenue trend by date/month?
with base as (
select month(s.orderdate) as months , 
round(sum(p.UnitPriceUSD*s.Quantity * e.Exchange )) as revenue from products as p inner join sales as s on s.ProductKey = p.ProductKey
inner join exchange_rates as e on e.Currency = s.CurrencyCode and s.OrderDate = e.Date group by months),
req as (
select months , revenue as current_revenue , 
lag(revenue) over(order by months) as previous_revenue from base )
select *,
case when current_revenue < previous_revenue then 'Decline' else 'Growth' end as growth_decline_analysis from req; 

-- Which currency contributes most after conversion?
select e.currency , round(sum(p.UnitPriceUSD*s.Quantity * e.Exchange )) as revenue from 
products as p inner join sales as s on s.ProductKey = p.ProductKey
inner join exchange_rates as e on e.Currency = s.CurrencyCode and s.OrderDate = e.Date
group by e.currency order by revenue desc;
-- ============================
-- STORE ANALYSIS QUESTIONS
-- ============================

-- Which store has the highest number of orders?
select ss.storekey ,ss.country , ss.state , count(distinct s.ordernumber) as orders 
from sales as s inner join stores as ss on ss.StoreKey = s.StoreKey
group by  ss.storekey ,ss.country , ss.state 
order by orders desc;

-- Which store sells the most quantity?
select ss.storekey ,ss.country , ss.state , count(s.quantity) as qtys 
from sales as s inner join stores as ss on ss.StoreKey = s.StoreKey
group by  ss.storekey ,ss.country , ss.state 
order by qtys desc;

-- Does store size impact sales?                                                                      -- yes
select ss.StoreKey, ss.Country, ss.State, ss.SquareMeters,sum(s.quantity) as qty from stores as ss 
inner join sales as s on s.StoreKey = ss.StoreKey
group by ss.StoreKey, ss.Country, ss.State, ss.SquareMeters
order by qty desc ;

-- Which country and state has the most stores?
with base as (select country,state ,count(storekey) as stores 
from stores group by country,state )
select * , count(Stores) over(partition by country) as cummulative_stores 
from base order by cummulative_stores desc;

-- What is average sales per store?
select avg(qty) as avg_sales_per_store from (select ss.storekey , sum(s.quantity) as qty from stores as ss 
inner join sales as s on s.StoreKey = ss.StoreKey 
group by ss.storekey) as t;

-- ============================
-- TIME-BASED ANALYSIS QUESTIONS
-- ============================
-- What is monthly sales trend?
with base as (
select month(s.orderdate) as months , 
round(sum(p.UnitPriceUSD*s.Quantity * e.Exchange )) as revenue from products as p inner join sales as s on s.ProductKey = p.ProductKey
inner join exchange_rates as e on e.Currency = s.CurrencyCode and s.OrderDate = e.Date group by months),
req as (
select months , revenue as current_revenue , 
lag(revenue) over(order by months) as previous_revenue from base )
select *,
case when current_revenue < previous_revenue then 'Decline' else 'Growth' end as growth_decline_analysis from req; 

-- Which day of the week has highest sales?
with base as (
select dayname(s.orderdate) as weekdays , 
round(sum(p.UnitPriceUSD*s.Quantity * e.Exchange )) as revenue from products as p inner join sales as s on s.ProductKey = p.ProductKey
inner join exchange_rates as e on e.Currency = s.CurrencyCode and s.OrderDate = e.Date group by weekdays),
req as (
select weekdays , revenue as current_revenue , 
lag(revenue) over(order by weekdays) as previous_revenue from base )
select *,
case when current_revenue < previous_revenue then 'Decline' else 'Growth' end as growth_decline_analysis from req; 

-- What is average delivery time?
select avg(timestampdiff(day,OrderDate,DeliveryDate)) as avg_delivery_time from sales;

-- Are sales increasing over time?
with base as (
select month(s.orderdate) as months , 
round(sum(p.UnitPriceUSD*s.Quantity * e.Exchange )) as revenue from products as p inner join sales as s on s.ProductKey = p.ProductKey
inner join exchange_rates as e on e.Currency = s.CurrencyCode and s.OrderDate = e.Date group by months),
req as (
select months , revenue as current_revenue , 
lag(revenue) over(order by months) as previous_revenue from base )
select *,
case when current_revenue < previous_revenue then 'Decline' else 'Growth' end as growth_decline_analysis from req; 

-- ============================
-- DATA QUALITY QUESTIONS
-- ============================

-- How many records have missing delivery dates?
 select DeliveryDateMissing , count(*) from sales group by DeliveryDateMissing ;
 
-- Are there duplicate order numbers?
select ordernumber , count(ordernumber) as orders from sales 
group by ordernumber having count(ordernumber) > 1 order by orders desc;

-- Are there products with missing price or cost?
select count(*) from (select ProductKey, ProductName ,UnitCostUSD, UnitPriceUSD from products 
where UnitCostUSD is null or UnitPriceUSD is null) as t;
-- cost missing  = 14 rows , price missing = 144 rows
 
-- Are there invalid or null customer birthdates?
select birthday from customers where birthday is null;
--  no nulls


-- ============================
-- ADVANCED JOIN QUESTIONS
-- ============================

-- Which customers bought the most expensive products?
select c.Name from customers as c 
inner join sales as s on s.CustomerKey = c.CustomerKey
inner join products as p on p.ProductKey = s.ProductKey
where p.UnitPriceUSD = (select max(UnitPriceUSD) from products); 

-- Which products are frequently bought together?
SELECT p1.ProductName AS Product1,p2.ProductName AS Product2,COUNT(*) AS frequency
FROM sales as s1 JOIN sales as s2 ON s1.OrderNumber = s2.OrderNumber AND s1.ProductKey < s2.ProductKey
INNER JOIN products as p1 ON p1.ProductKey = s1.ProductKey
INNER JOIN products as p2 ON p2.ProductKey = s2.ProductKey
GROUP BY p1.ProductName, p2.ProductName
ORDER BY frequency DESC;

-- Which customer generated the highest revenue?
SELECT c.name, ROUND(SUM(e.exchange * p.UnitPriceUSD * s.Quantity)) AS revenue
FROM products AS p INNER JOIN sales AS s ON s.ProductKey = p.ProductKey
INNER JOIN customers AS c ON c.CustomerKey = s.CustomerKey
INNER JOIN exchange_rates AS e ON e.Date = s.OrderDate AND e.Currency = s.CurrencyCode
GROUP BY c.name ORDER BY revenue DESC LIMIT 1;

-- Which state generates the most revenue?
SELECT c.State, ROUND(SUM(e.exchange * p.UnitPriceUSD * s.Quantity)) AS revenue
FROM products AS p INNER JOIN sales AS s ON s.ProductKey = p.ProductKey
INNER JOIN customers AS c ON c.CustomerKey = s.CustomerKey
INNER JOIN exchange_rates AS e ON e.Date = s.OrderDate AND e.Currency = s.CurrencyCode
GROUP BY c.State ORDER BY revenue DESC LIMIT 1;

-- Which brand is most popular in each country?
with base as (select c.Country,p.Brand,count(distinct s.OrderNumber) as orders from 
customers as c inner join sales as s on s.CustomerKey = c.CustomerKey 
inner join products as p on p.ProductKey = s.ProductKey
group by c.Country , p.Brand), req as (
select * , 
dense_rank() over (partition by Country order by orders desc) as rankings from base )
select Country ,Brand, orders from req where rankings = 1 ;
-- ============================
-- BUSINESS INSIGHT QUESTIONS
-- ============================

-- Who are the top 10 customers by revenue?
select c.name , round(sum(e.exchange * p.UnitPriceUSD* s.Quantity)) as revenue from 
products as p inner join sales as s on s.ProductKey = p.ProductKey
inner join customers as c on c.CustomerKey = s.CustomerKey
inner join exchange_rates as e on e.Date = s.OrderDate and e.Currency = s.CurrencyCode
group by c.name 
order by revenue desc limit 10;

-- What are the top 5 best-selling products?
select p.ProductName , round(sum(e.exchange * p.UnitPriceUSD* s.Quantity)) as revenue from 
products as p inner join sales as s on s.ProductKey = p.ProductKey
inner join customers as c on c.CustomerKey = s.CustomerKey
inner join exchange_rates as e on e.Date = s.OrderDate and e.Currency = s.CurrencyCode
group by p.ProductName 
order by revenue desc limit 5;

-- Which category should be focused on?
select p.Category , 
round(count(distinct s.ordernumber)) as orders , 
round(sum(e.exchange * p.UnitPriceUSD)) as revenue ,
round(sum((p.UnitPriceUSD - p.UnitCostUSD)*(e.exchange))) as profit
from 
products as p inner join sales as s on s.ProductKey = p.ProductKey
inner join exchange_rates as e on e.Date = s.OrderDate and e.Currency = s.CurrencyCode
group by p.Category 
order by revenue desc , orders desc ,profit desc  limit 5;

-- Which stores are underperforming?
select  ss.StoreKey ,ss.Country, ss.State ,
round(count(distinct s.ordernumber)) as orders , 
round(sum(e.exchange * p.UnitPriceUSD * s.Quantity)) as revenue ,
round(sum((p.UnitPriceUSD*s.Quantity - p.UnitCostUSD*s.Quantity)*(e.exchange))) as profit
from 
products as p inner join sales as s on s.ProductKey = p.ProductKey
inner join stores as ss on ss.StoreKey = s.StoreKey
inner join exchange_rates as e on e.Date = s.OrderDate and e.Currency = s.CurrencyCode
group by ss.StoreKey , ss.State , ss.Country 
order by revenue asc , orders asc ,profit asc  limit 5;

