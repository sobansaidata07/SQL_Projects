CREATE TABLE `food-delivery-data-493607.food_data.orders_clean` AS
SELECT
  `Order ID` AS order_id,
  `Customer ID` AS customer_id,
  Platform AS platform,
  `Order Date & Time` AS order_datetime,
  `Delivery Time _Minutes_` AS delivery_time_minutes,
  `Product Category` AS category,
  `Order Value _INR_` AS order_value,
  `Customer Feedback` AS customer_feedback,
  `Service Rating` AS rating,
  `Delivery Delay` AS delivery_delay,
  `Refund Requested` AS refund_requested
FROM `food-delivery-data-493607.food_data.orders`;

SELECT *
FROM `food-delivery-data-493607.food_data.orders_clean`
LIMIT 10;