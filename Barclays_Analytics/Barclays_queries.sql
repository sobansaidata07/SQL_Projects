select * from `sql-prac-interviews.all_datas.barclays`;
-- 1. Which was the busiest period/which saw the most incidents?
select 
extract(date from `Opened on date`) as period ,
count(*) as incidents from `sql-prac-interviews.all_datas.barclays` group by period order by period, incidents desc ;
-- 2. Which category of incidents had the highest volume?
select `Incident Description` as category , count(*) as incidents from `sql-prac-interviews.all_datas.barclays`
group by category order by incidents desc limit 2;
-- 3. Were there any repeat offenders (agents reporting incidents more than once?)
select `Caller ID` as callers , count(`Incident Description`) as incidents 
from `sql-prac-interviews.all_datas.barclays` group by callers having incidents > 1 ;