-- Leadership is concerned about loss of high-value customers.
-- Objective is to identify customers at risk based on spending behavior, delays, refunds, and rating patterns.
-- Focus on early detection of churn indicators.

-- case 1 checking the total_value of customer spend and compare the top 5 with bottom 5 on the delays and refunds and rating patterns as the data dont have date related so we cant do the time analysis to check the churn or growth decline analysis.

WITH base AS (
  SELECT 
    customer_id,
    SUM(order_value) AS total_spend,round(AVG(order_value),2) AS avg_spend_per_order,COUNT(DISTINCT order_id) AS orders,
    COUNTIF(refund_requested = TRUE) AS refunds,round(AVG(rating),2) AS avg_rating,round(AVG(delivery_time_minutes),2) AS avg_delivery_time
  FROM `food_data.orders_clean` GROUP BY customer_id
),
secondbase AS (
  SELECT *,DENSE_RANK() OVER (ORDER BY total_spend DESC, orders DESC) AS highrankings,
    DENSE_RANK() OVER (ORDER BY total_spend ASC, orders ASC) AS lowrankings
  FROM base
)

SELECT *
FROM secondbase
WHERE highrankings <= 5 OR lowrankings <= 5;

-- case 2 checking the top 10 with avg of the platforms and compare with drivers
with base as (  -- top 10 customers with high spend and high volume.
  select customer_id,SUM(order_value) AS total_spend,COUNT(DISTINCT order_id) AS orders,
  round(AVG(rating),2) AS avg_rating,round(AVG(delivery_time_minutes),2) AS avg_delivery_time,
  round(COUNTIF(refund_requested = true)/count(*),2) as refund_rate , round(countif(delivery_delay = true)/count(*),2) as delayed_rate from      
  `food_data.orders_clean` group by customer_id order by total_spend desc , orders desc limit 10
),
second_base as (
  select round(avg(order_value),2) AS avg_spend, round(AVG(rating),2) AS avg_rating,round(AVG(delivery_time_minutes),2) AS avg_delivery_time,
  round(COUNTIF(refund_requested = true)/count(*),2) as refund_rate , round(countif(delivery_delay = true)/count(*),2) as delayed_rate from      
  `food_data.orders_clean`
)
select b.customer_id , b.total_spend,sd.avg_spend ,b.avg_rating , sd.avg_rating ,b.avg_delivery_time , sd.avg_delivery_time,
b.refund_rate ,sd.refund_rate , b.delayed_rate , sd.delayed_rate
  FROM 
base as b cross join second_base as sd 
where 
  b.avg_rating < sd.avg_rating
  or b.refund_rate > sd.refund_rate
  or b.delayed_rate > sd.delayed_rate
  or b.avg_delivery_time > sd.avg_delivery_time ;

-- case 3 
WITH customer_base AS (
  SELECT customer_id,
    SUM(order_value) AS total_spend,
    COUNT(DISTINCT order_id) AS orders,
    ROUND(AVG(rating), 2) AS avg_rating,
    ROUND(AVG(delivery_time_minutes), 2) AS avg_delivery_time,
    ROUND(COUNTIF(refund_requested = TRUE) * 1.0 / COUNT(*), 2) AS refund_rate,
    ROUND(COUNTIF(delivery_delay = TRUE) * 1.0 / COUNT(*), 2) AS delayed_rate
  FROM `food_data.orders_clean`
  GROUP BY customer_id
),
ranked_customers AS (
  SELECT *,NTILE(10) OVER (ORDER BY total_spend DESC) AS spend_decile FROM customer_base
),
vip_customers AS (
  SELECT * FROM ranked_customers WHERE spend_decile = 1
),
baseline AS (
  SELECT 
    ROUND(AVG(avg_rating), 2) AS base_rating,ROUND(AVG(avg_delivery_time), 2) AS base_delivery_time,
    ROUND(AVG(refund_rate), 2) AS base_refund_rate,ROUND(AVG(delayed_rate), 2) AS base_delay_rate
  FROM customer_base
),

vip_scored AS (
  SELECT 
    v.*,
    CASE WHEN avg_rating < b.base_rating THEN 1 ELSE 0 END AS rating_risk,
    CASE WHEN refund_rate > b.base_refund_rate THEN 1 ELSE 0 END AS refund_risk,
    CASE WHEN delayed_rate > b.base_delay_rate THEN 1 ELSE 0 END AS delay_risk,
    CASE WHEN avg_delivery_time > b.base_delivery_time THEN 1 ELSE 0 END AS delivery_risk,

    (
      CASE WHEN avg_rating < b.base_rating THEN 1 ELSE 0 END +
      CASE WHEN refund_rate > b.base_refund_rate THEN 1 ELSE 0 END +
      CASE WHEN delayed_rate > b.base_delay_rate THEN 1 ELSE 0 END +
      CASE WHEN avg_delivery_time > b.base_delivery_time THEN 1 ELSE 0 END
    ) AS risk_score

  FROM vip_customers v
  CROSS JOIN baseline b
)

SELECT *
FROM vip_scored
WHERE risk_score >= 2
ORDER BY risk_score DESC, total_spend DESC;

-- Observations
-- VIP customers show consistently higher operational friction than the overall customer base across refunds, delays, delivery time, and slightly lower ratings.
-- However, all VIPs in this segment exhibit similar risk scores, meaning there is no clear prioritization within the VIP group.
-- This indicates a segment-level issue rather than identification of specific high-risk customers.
-- Further segmentation within VIPs is needed to isolate truly at-risk customers for churn prevention.