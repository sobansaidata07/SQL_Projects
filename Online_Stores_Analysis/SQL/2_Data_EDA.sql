-- lets understand the people dataset 
select * from raw_people ;
describe raw_people;
-- remarks on People table:
-- Everything is Good Only thing is it should be Not Null.

-- lets understand the returns dataset 
select * from raw_returns ;
describe raw_returns;

select count(*) as number_of_rows ,                                                        -- with nulls
count(`Order ID`) as number_of_order_ids,                                                  -- with not nulls
 count(distinct `Order ID`) as number_of_distinct_order_ids from raw_returns;              -- only distinct
-- remarks on Returns table:
-- Everything is Good Only thing is it should be Not Null.
-- No missing or repeated orders.

-- lets understand the orders dataset 
select * from raw_orders;
describe raw_orders;

select count(*) as number_of_rows ,                                    -- checking the nulls and distinct in ordersid 
count(`Row ID`) as number_of_rowids ,
count(distinct `Order ID`) as distinct_rows from raw_orders;           -- Clean data with no nulls.

SELECT `Order ID`, COUNT(*) AS num_items             -- understand whether each order id had multiple rows.
FROM raw_orders
GROUP BY `Order ID`
HAVING COUNT(*) > 1 
order by num_items desc;                             -- Yes each order had multiple rows.

select returned , count(`Order ID`) AS counts from raw_returns group by returned;  -- All returned status is 'YES'

-- lets create a procedure to chck the nulls
select * from raw_orders limit 5;
describe raw_orders;

delimiter //
create procedure check_nulls ()                                               -- check null values
BEGIN	 
select 
count(*) as number_of_rows,
sum(case when `Order ID` is null then 1 else 0 end) as nulls_in_orderid,
sum(case when `Order Date` is null then 1 else 0 end) as nulls_in_OrderDate,
sum(case when `Ship Date` is null then 1 else 0 end) as nulls_in_ShipDate,
sum(case when `Ship Mode` is null then 1 else 0 end) as nulls_in_ShipMode,
sum(case when `Customer ID` is null then 1 else 0 end) as nulls_in_CustomerID,
sum(case when `Customer Name` is null then 1 else 0 end) as nulls_in_CustomerName,
sum(case when `Segment` is null then 1 else 0 end) as nulls_in_Segment,
sum(case when `Country` is null then 1 else 0 end) as nulls_in_Country,
sum(case when `City` is null then 1 else 0 end) as nulls_in_City,
sum(case when `State` is null then 1 else 0 end) as nulls_in_State,
sum(case when `Postal Code` is null then 1 else 0 end) as nulls_in_PostalCode,
sum(case when `Region` is null then 1 else 0 end) as nulls_in_Region,
sum(case when `Product ID` is null then 1 else 0 end) as nulls_in_ProductID,
sum(case when `Category` is null then 1 else 0 end) as nulls_in_Category,
sum(case when `Sub-Category` is null then 1 else 0 end) as nulls_in_SubCategory,
sum(case when `Product Name` is null then 1 else 0 end) as nulls_in_ProductName,
sum(case when `Sales` is null then 1 else 0 end) as nulls_in_Sales,
sum(case when `Quantity` is null then 1 else 0 end) as nulls_in_Quantity,
sum(case when `Discount` is null then 1 else 0 end) as nulls_in_Discount,
sum(case when `Profit` is null then 1 else 0 end) as nulls_in_Profit
from raw_orders;
END //
delimiter ;

call check_nulls();                                                   -- clean data as No null values found.
-- =============================================================================================================================
select `Customer ID` as c , count(*) as counts from raw_orders group by  c ;
select * from raw_orders where `Customer ID` = 'DJ-13420';

-- so we have same customer id with same name , segment , country but different city , state and postal code and region.
-- =============================================================================================================================
-- =============================================================================================================================
select `Product ID` as p , count(*) as counts from raw_orders group by  p ;
select * from raw_orders where `Product ID` = 'FUR-BO-10001798';
select `Order ID` ,`Order Date`,`Ship Date`,`Ship Mode`, count(*) as counts from raw_orders
 group by  `Order ID` ,`Order Date`,`Ship Date`,`Ship Mode` having counts > 1;
select * from raw_orders where `Order ID` = 'CA-2014-115812';

-- so we have same product id with same category , sub category , productname but different sales  , qty , discount , profit.

-- =============================================================================================================================
-- =============================================================================================================================
select `Order ID` as p , count(*) as counts from raw_orders group by  p ;
select * from raw_orders where `Order ID` = 'CA-2014-115812';

-- =============================================================================================================================
select country ,  count(*) from raw_orders group by country ;         -- Only US Data so we can use Default US
select max(character_length(city)) as city_lengths from raw_orders;        -- for varchar datatype
select max(character_length(state)) as state_lengths from raw_orders ;     -- for varchar datatype

select count(`Product ID`) as counts , `Order ID` as orders  , `Order Date` as od ,
`Ship Date` as sd , `Product ID` as products from raw_orders 
group by orders , products , od ,sd  having counts>1;
 

select count(`Product ID`) as counts , `Order ID` as orders  from raw_orders where 
`Order ID` = 'CA-2016-129714' group by orders ;
                                      

WITH base AS (
SELECT `Order ID`, `Product ID`,`Customer ID`,  COUNT(*) AS row_count
FROM raw_orders
GROUP BY `Order ID`, `Product ID`,`Customer ID`
HAVING COUNT(*) > 1
)
SELECT *, 
(SELECT COUNT(*) FROM base) AS total_duplicate_combinations
FROM base; 
                                       -- here same order id with same product id i found 8 entries
select * from raw_orders where `Order ID` = 'CA-2016-129714';   -- row number 351 and 353.
select * from orders_data where order_id = 'CA-2016-129714';   -- why ORDER ID from raw instead of orderdata
select * from sales_data where order_id = 'CA-2016-129714';

select * from raw_orders where `Order ID` = 'CA-2016-137043';   -- row number 1301 and 1302
select * from raw_orders where `Order ID` = 'US-2016-123750';   -- row number 431 and 432
select * from raw_orders where `Order ID` = 'CA-2017-152912';   -- row number 3184 and 3185
select * from raw_orders where `Order ID` = 'US-2014-150119';   -- row number 3406 and 3407  - True Duplicate
select * from raw_orders where `Order ID` = 'CA-2015-103135';   -- row number 6499 and 6501
select * from raw_orders where `Order ID` = 'CA-2017-118017';   -- row number 7882 and 7883
select * from raw_orders where `Order ID` ='CA-2016-140571';   -- row number 9169 and 9170

   
-- remarks on Orders table:
-- Order date , ship date should change to date type.
-- Postal code also changed to text as it is a identifier.
-- Sales , discount , profit should alos changed to decimal (20,4)from double.

-- Clean data with no nulls.
-- obviously each order had multiple rows.
-- No Null values found in any columns.
-- Duplicates:we have fount 8 rows where same order id and same product id appears.

-- =============================================================================================================================
-- FINAL REMARKS
-- =============================================================================================================================
-- we have duplicates in the customer id
-- so we have same customer id with same name , segment , country but different city , state and postal code and region.
-- so we have same product id with same category , sub category , productname but different sales  , qty , discount , profit.
-- it was obvious that order id is same as for each product id it is different except for 8 rows.

select * from raw_orders;
with base as (select `Product ID` , `Category` , `Sub-Category` , `Product Name` , count(*) as counts from raw_orders
group by `Product ID` , `Category` , `Sub-Category` , `Product Name` having count(*) >=1) , 
req as (select count(*),(select count(distinct `Product ID`) from raw_orders)as t from base)
select * from req
;
select `Product ID` , `Category` , `Sub-Category` , `Product Name`  from raw_orders where 
`Product ID`='FUR-BO-10002213';

select count(*), `Customer ID` , `Customer Name` ,`Segment`,
`Country`,`City`,`State`,`Postal Code`,`Region` from raw_orders
group by  `Customer ID` , `Customer Name` ,`Segment`,
`Country`,`City`,`State`,`Postal Code`,`Region` ;

select `Customer ID` , `Customer Name` ,`Segment`,
`Country`,`City`,`State`,`Postal Code`,`Region` from raw_orders where `Customer ID` = 'BH-11710';


with das as (SELECT
    `Customer ID`,`Customer Name`,`Segment`,`Country`,`City`,`State`,`Postal Code`,`Region`
FROM raw_orders)
select count(*) ,`Customer ID`,`Customer Name`,`Segment`,`Country`,`City`,`State`,`Postal Code`,`Region`
from das group by `Customer ID`,`Customer Name`,`Segment`,`Country`,`City`,`State`,`Postal Code`,`Region`
;
    
select * from das;
select count(*),`Product ID` , `Category` , `Sub-Category` , `Product Name`  from raw_orders 
group by `Product ID` , `Category` , `Sub-Category` , `Product Name`  ;

with sim as (SELECT DISTINCT
    `Product ID` , `Category` , `Sub-Category` , `Product Name` 
FROM raw_orders)
select count(`Product Name`) ,`Product ID` , `Category` , `Sub-Category` , `Product Name` 
from sim group by `Product ID` , `Category` , `Sub-Category` , `Product Name` 
having count(`Product Name`) =1;

select count(*),`Order ID` ,`Order Date`,`Ship Date`,`Ship Mode` from raw_orders
 group by `Order ID` ,`Order Date`,`Ship Date`,`Ship Mode`;
 
 with abc as (SELECT DISTINCT
     `Order ID` ,`Order Date`,`Ship Date`,`Ship Mode` 
FROM raw_orders)
select count(*) , `Order ID` ,`Order Date`,`Ship Date`,`Ship Mode` 
from abc group by  `Order ID` ,`Order Date`,`Ship Date`,`Ship Mode` 
having count(*) =1;

select * from raw_orders;
SELECT `Order ID`, `Product ID`,`Customer ID`,  COUNT(*) AS row_count
FROM raw_orders group by `Order ID`, `Product ID`,`Customer ID` having count(*) > 1;


SELECT * 
FROM raw_orders where `Order ID` = 'US-2016-123750';

SELECT count(*),
    `Product ID` , `Category` , `Sub-Category` , `Product Name` 
FROM raw_orders group by `Product ID` , `Category` , `Sub-Category` , `Product Name` having count(*) >1;

SELECT * 
FROM raw_orders where `Product ID`= 'FUR-BO-10001798';
SELECT * 
FROM raw_orders where `Row ID` in (341 , 6302);
describe raw_orders;

-- ==============================Poducts table change ==================================================
with base as (
SELECT DISTINCT
    `Product ID` , `Category` , `Sub-Category` , `Product Name` 
FROM raw_orders),
re as (select count(*), (select count( distinct `Product ID`) from raw_orders) as uniques  from base )
select * from re;

-- i Have to let go of 30 rows with slight change .
with base as (select `Product ID`, count(*) from (select DISTINCT 
`Product ID` , `Category` , `Sub-Category` , `Product Name` 
FROM raw_orders ) as t  group by `Product ID` having count(*) > 1 ),
re as (select count(*)from base )
select * from base ;
select * from re;
select Distinct
`Product ID` , `Category` , `Sub-Category` , `Product Name` 
FROM raw_orders where `Product ID`in ('FUR-FU-10004848','FUR-CH-10001146','OFF-PA-10000659','TEC-AC-10002049') ;

select * from raw_orders;