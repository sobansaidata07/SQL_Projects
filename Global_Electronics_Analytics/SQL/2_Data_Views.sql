select * from customers limit 5 ;                                -- 15266 rows
select * from sales limit 5 ;                                    -- 62884 rows
select * from exchange_rates limit 5 ;                           -- 11215 rows
select * from stores limit 5 ;                                   -- 66 rows
select * from products limit 5 ;                                 -- 2517 rows

-- views

-- Create view customer_age_view
-- Columns: CustomerKey, Name, Age, AgeGroup, Country, State
-- Dimension: Customer
CREATE VIEW dim_customer_age_group AS
SELECT CustomerKey,Name,Gender,Birthday,TIMESTAMPDIFF(YEAR, Birthday, CURDATE()) AS Age,
CASE 
WHEN TIMESTAMPDIFF(YEAR, Birthday, CURDATE()) < 30 THEN 'Under 30 Years'
WHEN TIMESTAMPDIFF(YEAR, Birthday, CURDATE()) BETWEEN 30 AND 50 THEN '30-50 Years'
WHEN TIMESTAMPDIFF(YEAR, Birthday, CURDATE()) BETWEEN 51 AND 70 THEN '51-70 Years'
ELSE 'Over 70 Years' END AS Age_Group
FROM customers;
-- Dimension: Geography
CREATE VIEW dim_customer_geography AS
SELECT CustomerKey,City,StateCode,State,ZipCode,Country,Continent
FROM customers;

select * from dim_customer_age_group;
select * from dim_customer_geography;

-- Create view sales_summary_view
-- Columns: OrderNumber,LineItems, TotalQuantity, CurrencyCode
create or replace view sales_summary_view as 
select OrderNumber,LineItem,sum(Quantity) as TotalQuantity , CurrencyCode from sales 
group by OrderNumber,LineItem, CurrencyCode;

select * from sales_summary_view;

-- Create view product_performance_view
-- Columns: ProductKey, ProductName, TotalQuantitySold, TotalRevenue
create or replace view product_details_view as
select ProductKey, ProductName, Brand, Color, Subcategory, Category from products as p ;

create or replace view product_performance_view as
select s.OrderNumber ,p.ProductKey, p.ProductName,sum(s.Quantity) as TotalQuantitySold ,
round(sum(p.UnitCostUSD*s.Quantity*e.Exchange)) as Total_cost,
round(sum(p.UnitPriceUSD*s.Quantity*e.Exchange)) as Total_sale , 
round(sum((p.UnitPriceUSD*s.Quantity*e.Exchange)-(p.UnitCostUSD*s.Quantity*e.Exchange)))as profit_loss
from products as p inner join sales as s on s.ProductKey = p.ProductKey
inner join exchange_rates as e on e.currency = s.currencycode and e.Date = s.OrderDate
group by s.OrderNumber, p.ProductKey, p.ProductName;

select * from product_details_view;
select * from product_performance_view ;

-- Create view revenue_view
-- Columns: OrderNumber, ProductKey, Revenue, Profit, CurrencyCode
create or replace view revenue_view as 
select s.OrderNumber , p.ProductKey , s.CurrencyCode,
round(sum(s.Quantity*p.UnitPriceUSD*e.Exchange)) as Revenue , 
round(sum(((s.Quantity*p.UnitPriceUSD) - (s.Quantity*p.UnitCostUSD)) * e.Exchange)) as profit_loss 
from products as p inner join sales as s on p.ProductKey = s.ProductKey 
inner join exchange_rates as e on e.Currency = s.CurrencyCode and s.OrderDate = e.Date
group by s.OrderNumber , p.ProductKey , s.CurrencyCode ;

select * from revenue_view;


-- Create view store_sales_view
-- Columns: StoreKey, TotalOrders, TotalQuantity, TotalRevenue
create or replace view store_sales_view as 
select ss.StoreKey ,ss.Country, ss.State, ss.SquareMeters,
count(distinct s.OrderNumber) as TotalOrders , sum(s.Quantity) as TotalQuantity,
round(sum(s.Quantity*p.UnitPriceUSD*e.Exchange)) as TotalRevenue from 
products as p inner join sales as s on s.ProductKey = p.ProductKey 
inner join exchange_rates as e on e.Currency = s.CurrencyCode and s.OrderDate = e.Date
inner join stores as ss on ss.StoreKey = s.StoreKey
group by ss.StoreKey ,ss.Country, ss.State, ss.SquareMeters;

select * from store_sales_view;

-- Create view time_analysis_view
-- Columns: OrderDate, Year, Month, TotalSales, TotalOrders

create or replace view time_analysis_view as 
select s.OrderNumber ,s.OrderDate , year(s.OrderDate) as Years , month(s.OrderDate) as month_number, 
monthname(s.OrderDate) as month_name , quarter(s.OrderDate) as Quarters , dayname(s.OrderDate) as day_of_week , 
count(distinct s.OrderNumber) as TotalOrders ,
round(sum(s.Quantity*p.UnitPriceUSD*e.Exchange)) as TotalSales from 
products as p inner join sales as s on s.ProductKey = p.ProductKey 
inner join exchange_rates as e on e.Currency = s.CurrencyCode and s.OrderDate = e.Date
group by OrderNumber,OrderDate,Years,month_number,month_name,Quarters ;

select * from time_analysis_view;

-- Create view customer_sales_view
-- Join: customers + sales + products
-- Columns: CustomerKey, Name, ProductKey, ProductName, Quantity, Revenue
create or replace view customer_sales_view as 
select c.CustomerKey , c.Name,p.ProductKey , p.ProductName , s.Quantity , 
round(sum(s.Quantity*p.UnitPriceUSD*e.Exchange)) as Revenue 
from customers as c inner join sales as s on s.CustomerKey = c.CustomerKey 
inner join products as p on p.ProductKey = s.ProductKey 
inner join exchange_rates as e on e.Currency = s.CurrencyCode and s.OrderDate = e.Date
group by c.CustomerKey , c.Name,p.ProductKey , p.ProductName , s.Quantity ;

select * from customer_sales_view;
-- Create view currency_converted_sales_view
-- Join sales with exchange_rates for converted revenue
CREATE OR REPLACE VIEW currency_converted_sales_view AS
SELECT ROUND(SUM(s.Quantity * p.UnitPriceUSD)) AS initial_sales,
ROUND(SUM(s.Quantity * p.UnitPriceUSD * e.Exchange)) AS exchanged_sales
FROM sales as s  INNER JOIN products as p ON p.ProductKey = s.ProductKey
INNER JOIN exchange_rates as e ON e.Currency = s.CurrencyCode AND s.OrderDate = e.Date;

select * from currency_converted_sales_view;
-- Create view top_products_per_category_view
-- Rank products within each category

create or replace view top_products_per_category_view as
WITH base AS (
SELECT p.Category,p.ProductKey,p.ProductName,ROUND(SUM(e.Exchange * p.UnitPriceUSD * s.Quantity)) AS revenue 
FROM products as p INNER JOIN sales as s ON s.ProductKey = p.ProductKey
INNER JOIN exchange_rates as e ON e.Currency = s.CurrencyCode AND e.Date = s.OrderDate 
GROUP BY p.Category, p.ProductName,p.ProductKey),
ranked AS (
SELECT *,
DENSE_RANK() OVER (PARTITION BY Category ORDER BY revenue DESC) AS rank_in_category FROM base)
SELECT * FROM ranked where rank_in_category <=10 ;

create or replace view Bottom_products_per_category_view as
WITH base AS (
SELECT p.Category,p.ProductKey,p.ProductName,ROUND(SUM(e.Exchange * p.UnitPriceUSD * s.Quantity)) AS revenue 
FROM products as p INNER JOIN sales as s ON s.ProductKey = p.ProductKey
INNER JOIN exchange_rates as e ON e.Currency = s.CurrencyCode AND e.Date = s.OrderDate 
GROUP BY p.Category, p.ProductName,p.ProductKey HAVING revenue IS NOT NULL),
ranked AS (
SELECT *,
DENSE_RANK() OVER (PARTITION BY Category ORDER BY revenue ASC) AS rank_in_category FROM base)
SELECT * FROM ranked where rank_in_category <=10 ;

select * from Bottom_products_per_category_view;
select * from Top_products_per_category_view;

-- Create view customer_lifetime_value_view
-- Total revenue per customer
create or replace view customer_lifetime_value_view as 
select  c.CustomerKey , c.Name , ROUND(SUM(e.Exchange * p.UnitPriceUSD * s.Quantity)) AS revenue 
FROM products as p INNER JOIN sales as s ON s.ProductKey = p.ProductKey
INNER JOIN exchange_rates as e ON e.Currency = s.CurrencyCode AND e.Date = s.OrderDate
INNER JOIN customers as c on c.CustomerKey = s.CustomerKey 
group by c.CustomerKey , c.Name;

select * from customer_lifetime_value_view ;
-- Create view store_performance_rank_view
-- Rank stores based on performance
create or replace view store_performance_rank_view as 
with base as (
select  ss.StoreKey ,ss.Country, ss.State ,
round(count(distinct s.ordernumber)) as orders , 
round(sum(e.exchange * p.UnitPriceUSD * s.Quantity)) as revenue ,
round(sum((p.UnitPriceUSD*s.Quantity - p.UnitCostUSD*s.Quantity)*(e.exchange))) as profit
from products as p inner join sales as s on s.ProductKey = p.ProductKey
inner join stores as ss on ss.StoreKey = s.StoreKey
inner join exchange_rates as e on e.Date = s.OrderDate and e.Currency = s.CurrencyCode
group by ss.StoreKey , ss.State , ss.Country ), 
req as (
select * , 
dense_rank() over (order by orders desc) as ranks_on_orders , 
dense_rank() over (order by revenue desc) as ranks_on_revenue , 
dense_rank() over (order by profit desc) as ranks_on_profit from base)
select * from req;

select * from store_performance_rank_view;

-- Create view monthly_growth_view
-- Month-over-month revenue growth

create or replace view monthly_growth_view as
with base as (
select s.OrderNumber , month(s.orderdate) as month_number,monthname(s.orderdate) as month_name, 
round(sum(p.UnitPriceUSD*s.Quantity * e.Exchange )) as revenue from products as p inner join sales as s on s.ProductKey = p.ProductKey
inner join exchange_rates as e on e.Currency = s.CurrencyCode and s.OrderDate = e.Date group by OrderNumber,month_number, month_name),
req as (
select OrderNumber,month_number,month_name , revenue as current_revenue , 
lag(revenue) over(order by month_number) as previous_revenue from base )
select *,
case when current_revenue < previous_revenue then 'Decline' else 'Growth' end as growth_decline_analysis from req; 

select * from monthly_growth_view;



drop view powerbi_view_for_global_stores;
create or replace view powerbi_view_for_global_stores as
select c.CustomerKey, c.Gender, c.Name, c.City, c.StateCode, c.State as customerstate, c.ZipCode, c.Country as customerCountry,
 c.Continent, c.Birthday
 ,e.Date, e.Currency, e.Exchange , ss.StoreKey, ss.Country as storecountry, ss.State as storestate, ss.SquareMeters,
 p.ProductKey, p.ProductName, p.Brand, p.Color, p.UnitCostUSD, p.UnitPriceUSD,p.Subcategory,p.Category,
s.OrderNumber, s.LineItem, s.OrderDate, s.DeliveryDate, s.Quantity, s.CurrencyCode, s.DeliveryDateMissing
from 
products as p inner join sales as s on s.ProductKey = p.ProductKey 
inner join customers as c on c.CustomerKey = s.CustomerKey 
inner join Stores as ss on ss.Storekey = s.Storekey 
inner join exchange_rates as e on e.currency = s.CurrencyCode and e.Date = s.OrderDate;

select * from powerbi_view_for_global_stores;




-- Views

select * from dim_customer_age_group;
select * from dim_customer_geography;
select * from sales_summary_view;
select * from product_details_view;
select * from product_performance_view;
select * from revenue_view;
select * from store_sales_view;
select * from time_analysis_view;
select * from customer_sales_view;
select * from currency_converted_sales_view;
select * from Bottom_products_per_category_view;
select * from Top_products_per_category_view;
select * from customer_lifetime_value_view ;
select * from store_performance_rank_view;
select * from monthly_growth_view;

select * from powerbi_view_for_global_stores;

with base as (
select month(s.orderdate) as month_number,monthname(s.orderdate) as month_name, 
round(sum(p.UnitPriceUSD*s.Quantity * e.Exchange )) as revenue from products as p inner join sales as s on s.ProductKey = p.ProductKey
inner join exchange_rates as e on e.Currency = s.CurrencyCode and s.OrderDate = e.Date group by month_number, month_name),
req as (
select month_number,month_name , revenue as current_revenue , 
lag(revenue) over(order by month_number) as previous_revenue from base )
select *,
case when current_revenue < previous_revenue then 'Decline' else 'Growth' end as growth_decline_analysis from req; 

select * from monthly_growth_view;
