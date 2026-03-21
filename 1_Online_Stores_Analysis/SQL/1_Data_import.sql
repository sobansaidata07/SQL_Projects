show databases;
create database Analytics_project_lb_1 ;   -- Creatting Database
use Analytics_project_lb_1;                -- Using the same Database


-- Check the Data 
select * from raw_orders ;
select * from raw_people;
select * from raw_returns ;

-- check the structure 
describe raw_orders;
describe raw_people;
describe raw_returns;

