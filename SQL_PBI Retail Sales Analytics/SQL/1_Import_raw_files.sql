-- creating Database
create database Sales_Analytics;

-- Using Database
use Sales_Analytics;

-- Importing Raw data
select * from raw_sales;
select * from raw_customer;
select * from raw_products;

-- understand the data
describe raw_sales;
describe raw_customer;
describe raw_products;

-- checking the Raw data
select count(*) from raw_sales;
select count(*) from raw_customer;
select count(*) from raw_products;