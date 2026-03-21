-- create Database 
show databases;

-- drop database global_electronics_db;

create database global_electronics_db;
use global_electronics_db;



show tables;
SET GLOBAL local_infile = 1;

show variables;
-- =========================================================================================================================
CREATE TABLE customers (
    CustomerKey INT PRIMARY KEY,
    Gender VARCHAR(15),
    Name VARCHAR(100),
    City VARCHAR(100),
    StateCode VARCHAR(100),
    State VARCHAR(100),
    ZipCode VARCHAR(25),
    Country VARCHAR(50),
    Continent VARCHAR(50),
    Birthday DATE
);

LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/CLEANED_DATASETS/Cleaned_Customer_Data.csv'
INTO TABLE customers
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS
(CustomerKey, Gender, Name, City, StateCode, State, ZipCode, Country, Continent, Birthday);

select count(*) from customers;
select * from customers limit 5;
-- =========================================================================================================================
CREATE TABLE products (
    ProductKey INT PRIMARY KEY,
    ProductName VARCHAR(255),
    Brand VARCHAR(100),
    Color VARCHAR(50),
	UnitCostUSD DECIMAL(12,2),
    UnitPriceUSD DECIMAL(12,2),
    SubcategoryKey INT,
    Subcategory VARCHAR(100),
    CategoryKey INT,
    Category VARCHAR(100)
);

LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/CLEANED_DATASETS/Cleaned_Product_Data.csv'
INTO TABLE products
FIELDS TERMINATED BY ',' ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS
(ProductKey, ProductName, Brand, Color, @UnitCostUSD, @UnitPriceUSD, SubcategoryKey, Subcategory, CategoryKey, Category)
SET UnitCostUSD = NULLIF(@UnitCostUSD,''),
    UnitPriceUSD = NULLIF(@UnitPriceUSD,'');
    
select count(*) from products;
select * from products limit 5;
-- =========================================================================================================================
CREATE TABLE exchange_rates (
    Date DATE,
    Currency VARCHAR(10),
    Exchange FLOAT
);
LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/CLEANED_DATASETS/Cleaned_Exchange_rates_Data.csv'
INTO TABLE exchange_rates
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS(Date, Currency, Exchange);

select count(*) from exchange_rates;
select * from exchange_rates limit 5;
-- =========================================================================================================================
CREATE TABLE stores (
    StoreKey INT PRIMARY KEY,
    Country VARCHAR(50),
    State VARCHAR(100),
    SquareMeters FLOAT,
    OpenDate DATE
);

LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/CLEANED_DATASETS/Cleaned_Stores_Data.csv'
INTO TABLE stores
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS
(StoreKey, Country, State, SquareMeters, OpenDate);

select count(*) from stores;
select * from stores limit 5;

INSERT INTO stores (StoreKey, Country, State, SquareMeters, OpenDate)
VALUES (0, 'Online', 'Online', NULL, NULL);
-- =========================================================================================================================
CREATE TABLE sales (
    OrderNumber INT,
    LineItem INT,
    OrderDate DATE,
    DeliveryDate DATE,
    CustomerKey INT,
    StoreKey INT,
    ProductKey INT,
    Quantity INT,
    CurrencyCode VARCHAR(10),
    DeliveryDateMissing ENUM('True','False'),
    PRIMARY KEY (OrderNumber, LineItem),
    CONSTRAINT fk_sales_customer FOREIGN KEY (CustomerKey) REFERENCES customers(CustomerKey),
    CONSTRAINT fk_sales_store FOREIGN KEY (StoreKey) REFERENCES stores(StoreKey),
    CONSTRAINT fk_sales_product FOREIGN KEY (ProductKey) REFERENCES products(ProductKey)
);

LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/CLEANED_DATASETS/Cleaned_Sales_Data.csv'
INTO TABLE sales
FIELDS TERMINATED BY ','  
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS
(OrderNumber, LineItem, OrderDate, DeliveryDate, CustomerKey, StoreKey, ProductKey,
 Quantity, CurrencyCode, DeliveryDateMissing);
 
select count(*) from sales;
select * from sales limit 5;
-- =========================================================================================================================
CREATE INDEX idx_sales_customer ON sales(CustomerKey);
CREATE INDEX idx_sales_product ON sales(ProductKey);
CREATE INDEX idx_sales_store ON sales(StoreKey);
CREATE INDEX idx_sales_date ON sales(OrderDate);
