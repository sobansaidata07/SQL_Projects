-- Management requested a neutral comparison between Blinkit and JioMart and Swiggy before partner review meeting.
-- Objective is to evaluate platform efficiency using revenue, order volume, ratings, delays, and refund metrics.
-- Goal is to identify underperforming platform and performance gaps.
with platform_performance_analysis as (
  select platform , sum(order_value) as revenue , count(order_id) as order_volume ,round(avg(order_value))
  as avg_order_value, 
  round(avg(rating),2) as avg_rating , round(avg(delivery_time_minutes),2) as avg_delay , 
  sum(case when refund_requested = true then 1 else 0 end) as refunds,
  ROUND(SUM(CASE WHEN refund_requested = true THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2) AS refund_rate,
  ROUND(SUM(CASE WHEN delivery_delay = true THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2) AS delay_rate
  from `food-delivery-data-493607.food_data.orders_clean`
  group by platform
) 

select * from platform_performance_analysis;

                                                                                           