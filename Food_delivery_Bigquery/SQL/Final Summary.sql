-- Final request from leadership for a consolidated business summary.
-- Objective is to present key insights on revenue, delivery performance,customer satisfaction,refund behavior.
-- Output will support strategic decision-making at leadership level.


CREATE PROCEDURE `food_data.simple_summary`(category STRING)
BEGIN
EXECUTE IMMEDIATE FORMAT("""
  SELECT 
    `%s`,platform,
    SUM(order_value) AS revenue,
    COUNT(DISTINCT order_value) AS orders,
    ROUND(SUM(CASE WHEN refund_requested THEN 1 ELSE 0 END) / COUNT(*), 2) AS refund_rate,
    ROUND(SUM(CASE WHEN delivery_delay THEN 1 ELSE 0 END) / COUNT(*), 2) AS delayed_rate
  FROM `food_data.orders_clean`
  GROUP BY `%s`,platform order by platform 
""", category, category);
END;

-- Rating analysis
CALL `food_data.simple_summary`('rating');

-- Insights
-- Revenue is highest at rating 5 and also strong at rating 2, while rating 3 is the weakest across all platforms.
-- All three platforms (Blinkit, JioMart, Swiggy Instamart) show almost identical performance, so no clear winner.
-- Refunds are strictly linked to low ratings (1–2 = 100% refunds), showing strong dissatisfaction signals.
-- Delivery delay is stable across all groups, so ratings are driven more by customer satisfaction than logistics.

-- Category analysis
CALL `food_data.simple_summary`('category');

-- Insights
-- Revenue is consistently highest in Personal Care and Grocery across all platforms, showing strong category demand.
-- Blinkit, JioMart, and Swiggy Instamart perform almost equally, with no major platform advantage per category.
-- Refund rates are high and stable (~0.45–0.47) across all categories, indicating a systemic quality or expectation gap.
-- Delivery delay is also stable (~0.13–0.15), so performance differences are driven more by category behavior than logistics.

-- Delivery time analysis
CALL `food_data.simple_summary`('delivery_time_minutes');

-- Insights
-- Delivery performance is clearly split into two clusters: fast deliveries (5–21 mins) and slow deliveries (40–76 mins), with slow ones showing extreme delayed_rate = 1.0.
-- Revenue is highest in the mid-fast range (10–20 mins), where order volume is also strongest, indicating optimal operational efficiency.
-- Fast deliveries (≤20 mins) show moderate refund rates (~0.43–0.49) but no delivery delay issues, making them the most stable segment.
-- Very slow deliveries (40+ mins) consistently show delayed_rate = 1.0 with similar or lower revenue efficiency, indicating a clear operational bottleneck zone.

-- ------------------------------------------- views ------------------------------------------

-- Rating Summary View

CREATE OR REPLACE VIEW `food_data.rating_summary` AS
SELECT 
  rating,
  SUM(order_value) AS revenue,
  COUNT(DISTINCT order_value) AS orders,
  ROUND(SUM(CASE WHEN refund_requested THEN 1 ELSE 0 END) / COUNT(*), 2) AS refund_rate,
  ROUND(SUM(CASE WHEN delivery_delay THEN 1 ELSE 0 END) / COUNT(*), 2) AS delayed_rate
FROM `food_data.orders_clean`
GROUP BY rating;

-- Category Summary View

CREATE OR REPLACE VIEW `food_data.category_summary` AS
SELECT 
  category,
  SUM(order_value) AS revenue,
  COUNT(DISTINCT order_value) AS orders,
  ROUND(SUM(CASE WHEN refund_requested THEN 1 ELSE 0 END) / COUNT(*), 2) AS refund_rate,
  ROUND(SUM(CASE WHEN delivery_delay THEN 1 ELSE 0 END) / COUNT(*), 2) AS delayed_rate
FROM `food_data.orders_clean`
GROUP BY category;


-- Delivery Time Summary View

CREATE OR REPLACE VIEW `food_data.delivery_time_summary` AS
SELECT 
  delivery_time_minutes,
  SUM(order_value) AS revenue,
  COUNT(DISTINCT order_value) AS orders,
  ROUND(SUM(CASE WHEN refund_requested THEN 1 ELSE 0 END) / COUNT(*), 2) AS refund_rate,
  ROUND(SUM(CASE WHEN delivery_delay THEN 1 ELSE 0 END) / COUNT(*), 2) AS delayed_rate
FROM `food_data.orders_clean`
GROUP BY delivery_time_minutes;