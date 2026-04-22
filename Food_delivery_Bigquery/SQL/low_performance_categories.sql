-- Business requires identification of problematic product categories contributing to poor customer experience.
-- Objective is to analyze category-wise performance across delivery time, ratings, and refund rates for each platform
-- Goal is to identify high-risk categories affecting overall platform quality.

--case 1 check the category with lower ratings and higher refunds
select * from (select row_number()over(partition by platform ) as rownumber,platform , category,round(avg(rating),2) as avg_rating ,
sum(case when refund_requested = true then 1 else 0 end) as refunds,round(avg(delivery_time_minutes),2) as avg_delivery , count(order_id) as orders
from `food_data.orders_clean` group by platform, category order by refunds desc,avg_rating) as t where rownumber <=3 order by platform;


-- insights:
-- For Blink it the Top 3 categories with higher refunds and lower ratings were fruits and veges filloed by snacks and personal care.
-- For swiggy instamart it is personal care with higher refunds and bit better avg rating over other two category like beverages and grocery.
-- for jiomart the personal care followed by snacks and beverages.
-- For all the platforms the avgdelyaed time is almost in between 29-30 minutes which might not be significant difference and the avgrating has to consider as it is significantly differentiated.

-- Observations:
-- Across platforms, refund volume is concentrated in high-volume categories like Fruits & Vegetables, Snacks, and Personal Care. However, without normalizing for order volume, refund counts alone do not indicate higher risk.
-- When controlling for scale, no category shows a clearly dominant deviation in rating performance (all cluster ~3.2–3.27), suggesting customer satisfaction is structurally similar across categories.
-- Delivery time (~29–30 mins) is also highly consistent, indicating it is not a differentiating factor across categories or platforms.