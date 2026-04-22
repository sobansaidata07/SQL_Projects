-- Operations suspects delivery delays are impacting customer satisfaction.
-- Objective is to validate whether delayed orders are driving lower ratings and higher refunds.

-- case 1 checking the delivery status with avg rating 
select delivery_delay , round(avg(rating),2) as avg_rating from `food_data.orders_clean` group by delivery_delay ;

-- Insight : With delivery delay theres not much impact on the ratings as its almost stable at 3.23 and 3.24 for delivery not delayed and delayed resectively.(as this artificial dataset so the numbers are fabricated.)

-- case 2 check the number of order returned for the delayed status and not delayed status
select delivery_delay , 
sum(case when refund_requested = true then 1 else 0 end) as refunds,
round(sum(case when refund_requested = true then 1 else 0 end)/(select sum(case when refund_requested = true then 1 else 0 end) from `food_data.orders_clean`),2) as refunds_in_percent
 from `food_data.orders_clean` 
group by delivery_delay;
-- insights: As the Delay is not quite impact the returns as with delayed not happend had higher request of returns compare with delayed happened.
-- As it suggests the delay may not be the best driver to explain the Lower rating and higher returnsm we have to deep dig to find.

-- case 3 check the lower rating like 1-2 for the delay status
select rating , 
delayed_orders , round(delayed_orders/orders,4) as delayed_percent,
not_delayed_orders,round(not_delayed_orders/orders,4) as notdelayed_percent,orders from (
select rating, 
sum(case when delivery_delay=true then 1 else 0 end) as delayed_orders,
sum(case when delivery_delay=false then 1 else 0 end) as not_delayed_orders,
count(delivery_delay) as orders
from `food_data.orders_clean` group by rating
) as t ORDER BY rating ASC;
-- insight There is very slight change of Impact on getting lower rating for delayed orders.
-- we can observe out all the orders , the delivery delayed orders got 13.76 % as rating 1 and 13.74 % as rating 2. 
-- so still we cannot confindently say that delivery dalayed is primary aspect or driver for lower rating and higher refunds.

-- Final Observations:
-- Delivery delays do not show a meaningful impact on customer experience or refund behavior in this dataset.
-- Average ratings are nearly identical (3.23 vs 3.24), indicating no practical difference
-- Refund analysis (when normalized) is required, but current evidence does not suggest strong linkage
-- Rating distribution shows delayed orders consistently make up ~13–14% across all rating levels, including low ratings
-- There is no strong signal that delivery delay is a primary driver of poor customer experience.


