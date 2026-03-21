-- create tables
show tables;

-- New customer table

create table customers (
customer_id varchar(20) primary key,
email varchar(50) ,
signup_date date,
gender enum('Female','Male','Unknown'),
region enum('North','South','East','West','Central','Unknown'),
loyalty_tier enum('Gold','Silver','Bronze','Unknown')
);

-- New Product table

create table products(
product_id varchar(20) primary key,
product_name varchar(50) ,
category enum('Storage','Cleaning','Kitchen','Personal Care','Outdoors','Unknown'),
launch_date date,
base_price decimal(10,2),
supplier_code varchar(5)
);

-- New Sales Table

create table sales (
order_id varchar(20) primary key,
customer_id varchar(20),
product_id varchar(20),
quantity int,
unit_price decimal(10,2),
order_date date,
delivery_status enum ('Delivered','Delayed','Cancelled','Unknown'),
payment_method ENUM('Credit Card','Bank Transfer','PayPal','Unknown'),
region enum('North','South','East','West','Central','Unknown'),
discount_applied decimal(10,2)
);

-- inserting values

-- Into Customer table 

INSERT INTO customers(customer_id, email, signup_date, gender, region, loyalty_tier)
SELECT TRIM(customer_id),TRIM(email),STR_TO_DATE(NULLIF(TRIM(signup_date), ''), '%d-%m-%y'),
CASE 
WHEN LOWER(TRIM(gender)) in ('female','femle') THEN 'Female'
WHEN LOWER(TRIM(gender)) = 'male' THEN 'Male'
ELSE 'Unknown'
END,
CASE 
WHEN LOWER(TRIM(region)) in ('north','nrth') THEN 'North'
WHEN LOWER(TRIM(region)) = 'south' THEN 'South'
WHEN LOWER(TRIM(region)) = 'east' THEN 'East'
WHEN LOWER(TRIM(region)) = 'west' THEN 'West'
WHEN LOWER(TRIM(region)) = 'central' THEN 'Central'
WHEN LOWER(TRIM(region)) like 'n%' THEN 'North'
WHEN LOWER(TRIM(region)) like 's%' THEN 'South'
WHEN LOWER(TRIM(region)) like 'e%' THEN 'East'
WHEN LOWER(TRIM(region)) like 'w%' THEN 'West'
WHEN LOWER(TRIM(region)) like 'c%' THEN 'Central'
ELSE 'Unknown'
END,
CASE
WHEN LOWER(TRIM(loyalty_tier)) IN ('gold','gld','gol') THEN 'Gold'
WHEN LOWER(TRIM(loyalty_tier)) IN ('silver','sllver','slvr') THEN 'Silver'
WHEN LOWER(TRIM(loyalty_tier)) IN ('bronze','brnze','bronz') THEN 'Bronze'
WHEN LOWER(TRIM(loyalty_tier)) LIKE 'g%' THEN 'Gold'
WHEN LOWER(TRIM(loyalty_tier)) LIKE 's%' THEN 'Silver'
WHEN LOWER(TRIM(loyalty_tier)) LIKE 'b%' THEN 'Bronze'
ELSE 'Unknown' 
END
FROM raw_customer where trim(customer_id) <> '';

-- Into Products table

insert into products (product_id, product_name, category, launch_date, base_price, supplier_code)
select 
trim(product_id),upper(trim(product_name)),
CASE
WHEN LOWER(TRIM(category))='storage' THEN 'Storage'
WHEN LOWER(TRIM(category))='cleaning' THEN 'Cleaning'
WHEN LOWER(TRIM(category))='kitchen' THEN 'Kitchen'
WHEN LOWER(TRIM(category))='personal care' THEN 'Personal Care'
WHEN LOWER(TRIM(category))='outdoors' THEN 'Outdoors'
ELSE 'Unknown'
END,
STR_TO_DATE(NULLIF(TRIM(launch_date), ''), '%d-%m-%y'),
CAST(TRIM(base_price) AS DECIMAL(10,2)),
trim(supplier_code) 
from raw_products;


-- Into Sales table

insert Ignore into sales (order_id, customer_id, product_id, quantity, unit_price, order_date, 
delivery_status, payment_method, region, discount_applied) 
select 
trim(order_id),trim(customer_id),trim(product_id),quantity,cast(trim(unit_price)as decimal(10,2)),
STR_TO_DATE(NULLIF(TRIM(order_date), ''), '%d-%m-%y'),
CASE
WHEN LOWER(TRIM(delivery_status)) IN ('delayed','delayd') THEN 'Delayed'
WHEN LOWER(TRIM(delivery_status)) IN ('delivered','delrd') THEN 'Delivered'
WHEN LOWER(TRIM(delivery_status)) = 'cancelled' THEN 'Cancelled'
ELSE 'Unknown'
END, 
CASE
WHEN LOWER(TRIM(payment_method)) IN ('bank transfr','bank transfer') THEN 'Bank Transfer'
WHEN LOWER(TRIM(payment_method)) = 'credit card' THEN 'Credit Card'
WHEN LOWER(TRIM(payment_method)) = 'paypal' THEN 'PayPal'
WHEN LOWER(TRIM(payment_method)) LIKE 'b%' THEN 'Bank Transfer'
WHEN LOWER(TRIM(payment_method)) LIKE 'c%' THEN 'Credit Card'
WHEN LOWER(TRIM(payment_method)) LIKE 'p%' THEN 'PayPal'
ELSE 'Unknown'
END,
CASE 
WHEN LOWER(TRIM(region)) in ('north','nrth') THEN 'North'
WHEN LOWER(TRIM(region)) = 'south' THEN 'South'
WHEN LOWER(TRIM(region)) = 'east' THEN 'East'
WHEN LOWER(TRIM(region)) = 'west' THEN 'West'
WHEN LOWER(TRIM(region)) = 'central' THEN 'Central'
WHEN LOWER(TRIM(region)) like 'n%' THEN 'North'
WHEN LOWER(TRIM(region)) like 's%' THEN 'South'
WHEN LOWER(TRIM(region)) like 'e%' THEN 'East'
WHEN LOWER(TRIM(region)) like 'w%' THEN 'West'
WHEN LOWER(TRIM(region)) like 'c%' THEN 'Central'
ELSE 'Unknown'
END,
cast(trim(discount_applied) as decimal(10,2))from raw_sales 
where trim(order_id) <> '';

-- checking the structure
describe sales;
describe customers;
describe products;


-- checking the tables
select * from sales;
select * from products;
select* from customers;


