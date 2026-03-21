-- lets create cleaned data structure 

-- People table
create table Peoples_data 
(Person varchar(20) not null,
Region varchar(10) not null);

insert into Peoples_data 
select trim(Person) as Person , trim(Region) as Region from raw_people ; 

select * from peoples_data;
-- ==========================================================================================================================
-- Returns table 
create table Returns_data 
(Order_ID varchar(20) not null primary key,
 Returned varchar(10) not null default 'Yes');

delimiter //
create procedure insert_to_returns()
BEGIN
insert ignore into Returns_data
select trim(`Order ID`) as Order_id , trim(`Returned`) as Returned from raw_returns;
END//
delimiter ;

call insert_to_returns();

select * from returns_data;
select count(*) from raw_returns;                               -- 296 rows on raw return data
select count(*) from returns_data;                              -- 296 rows on final return data 
-- ---------------------------------------------------------------------------------------------------------------------------
-- from Orders table creating multiple tables
show tables;
create table raw_orders_cleaned as select distinct * from raw_orders;   -- created a copy of raw_orders with distinct

create table customers_data 
(
customer_id varchar(25) primary key ,
customer_name varchar(30) not null , 
segment varchar(20) not null );

-- ---------------------------------------------------------------------------------------------------------------------------
create table products_data 
(
product_id varchar(25) primary key, 
category varchar(20) not null , 
subcategory varchar(20) not null ,
product_name varchar(250) not null
);
-- ---------------------------------------------------------------------------------------------------------------------------
create table orders_data (
order_id varchar(25) primary key,
customer_id varchar(25),
order_date date not null,
ship_date date not null,
ship_mode varchar(20) not null,
country varchar(30) not null,
city varchar(30) not null,
state varchar(30) not null,
postal_code varchar(10) not null,
region varchar(20) not null,
foreign key (customer_id) references customers_data(customer_id),
check (ship_date >= order_date)
);
-- ---------------------------------------------------------------------------------------------------------------------------
create table sales_data 
(order_id varchar(25) , 
product_id varchar(25), 
customer_id varchar(25),
sales    DECIMAL(15,2) NOT NULL,                         -- Changed from double to decimal as i need exact not approx
quantity int not null default 0, 
discount DECIMAL(5,4) NOT NULL DEFAULT 0,                -- Changed from double to decimal as it is for Financial not scientific
profit   DECIMAL(12,4) ,                                 -- Changed from double to decimal for better understanding
primary key (order_id, product_id,customer_id),
foreign key (order_id) references orders_data(order_id), 
foreign key (product_id) REFERENCES products_data(product_id) ,
 foreign key (customer_id) REFERENCES customers_data(customer_id) 
);                              
-- ---------------------------------------------------------------------------------------------------------------------------
-- ---------------------------------------------------------------------------------------------------------------------------
-- insertion into four tables 

delimiter //
create procedure rawdata_to_customer_data()
BEGIN
insert into customers_data (customer_id ,customer_name , segment ) 
select Distinct 
trim(`Customer ID`) ,trim(`Customer Name`) , trim(`Segment`)from raw_orders_cleaned;
END //
delimiter ;
call rawdata_to_customer_data();                                                    -- call 1
-- ---------------------------------------------------------------------------------------------------------------------------
delimiter //
create procedure rawdata_to_product()
BEGIN
insert ignore into products_data (product_id , category , subcategory , product_name)
select distinct
 trim(`Product ID`) , trim(`Category`) , trim(`Sub-Category`) , trim(`Product Name`) from raw_orders_cleaned ;
END //
delimiter ;
call rawdata_to_product();                                                         -- call 2
-- ------------------------------------------- --------------------------------------------------------------------------------
delimiter //
create procedure rawdata_to_orders()
BEGIN
insert into orders_data (order_id,customer_id,order_date,ship_date,ship_mode,country,
city,state,postal_code,region)
select distinct
trim(`Order ID`),trim(`Customer ID`),STR_TO_DATE(`Order Date`, '%d-%m-%Y'),STR_TO_DATE(`Ship Date`, '%d-%m-%Y'),
trim(`Ship Mode`),trim(`Country`),trim(`City`),trim(`State`),trim(`Postal Code`),trim(`Region`)
from raw_orders_cleaned;
END //
delimiter ;
call rawdata_to_orders();                                                         --  call3
-- ---------------------------------------------------------------------------------------------------------------------------
delimiter //
create procedure rawdata_to_salesdata()
BEGIN
insert into sales_data (order_id,product_id,customer_id,sales,quantity,discount,profit)
select ro.`Order ID`, (p.product_id) ,(c.customer_id),
ROUND(SUM(ro.Sales), 2),SUM(ro.Quantity),ROUND(avg(ro.Discount), 4),ROUND(SUM(ro.Profit), 4)
from raw_orders_cleaned as ro inner join products_data as p on ro.`Product ID` = p.product_id 
inner join customers_data as c on ro.`Customer ID` = c.customer_id 
group by ro.`Order ID`,p.product_id,customer_id;
END //
delimiter ;

call rawdata_to_salesdata();                                                       -- call 4

-- ---------------------------------------------------------------------------------------------------------------------------
select * from customers_data;
select * from products_data ;
select * from orders_data ;
select * from sales_data;
select * from peoples_data;
select * from returns_data;

show tables;

select count(*) from raw_orders;                                 -- 9694 rows
select count(*) from customers_data;                             -- 793 rows
select count(*) from products_data ;                             -- 1812 rows   ( lost 30 rows due variations in name with same id)
select count(*) from orders_data ;                               -- 4931 rows
select count(*) from sales_data;                                 -- 9686 rows 
                                            -- you can see 9694 - 9686 = 8 rows where we see same data ids so did aggregations.



-- uncomment and run when we need to update the procedure

-- drop procedure rawdata_to_salesdata;
-- drop procedure rawdata_to_orders;
-- drop procedure rawdata_to_product;
-- drop procedure rawdata_to_customer_data;
