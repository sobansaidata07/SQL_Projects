-- Received escalation from Operations team regarding increasing customer complaints and refunds.
-- Objective is to identify whether issue is driven by platform, category, or delivery performance.

-- SOLUTION
-- Refund rates are similar across all platforms (~45%–47%), so no platform is clearly worse or better.
-- Product categories also show almost the same refund behavior, so category is not a key issue.
-- Delivery time has only small fluctuations (~42%–49%) and no clear pattern with refunds.
-- Ratings show a strong pattern: rating 1–2 = 100% refunds, rating 3–5 = 0% refunds.
-- Overall, refunds seem more linked to rating logic than platform, category, or delivery performance.
-- 
with platform_category_refunds as (
select platform , category ,
count(order_id) as orders,
sum(case when refund_requested = true then 1 else 0 end) as refunds from 
`food_data.orders_clean` 
group by platform , category)
select platform,category,orders,refunds,round((refunds/orders),2) as refund_rate from platform_category_refunds;

with delivery_refund as (
  select delivery_time_minutes ,  
  count(order_id) as orders,
  sum(case when refund_requested = true then 1 else 0 end) as refunds
  from `food_data.orders_clean` group by delivery_time_minutes)
select * , round((refunds/orders),2) as refund_rate from delivery_refund;

with ratings_refund as (
  select rating , 
  count(order_id) as orders,
  sum(case when refund_requested = true then 1 else 0 end) as refunds
  from `food_data.orders_clean` group by rating)
select * , round((refunds/orders),2) as refund_rate from ratings_refund;

with delivery_ratings_refund as 
( select delivery_time_minutes , rating , count(order_id) as orders,
 sum(case when refund_requested = true then 1 else 0 end) as refunds 
 from food_data.orders_clean group by delivery_time_minutes,rating) select * , round((refunds/orders),2) 
 as refund_rate from delivery_ratings_refund;




