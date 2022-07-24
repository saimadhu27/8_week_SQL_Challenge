-- Cleaning null values in customer orders table
DROP TABLE IF EXISTS customer_orders_temp;
CREATE TEMPORARY TABLE customer_orders_temp AS
SELECT order_id,customer_id,pizza_id,
CASE 
WHEN exclusions IS null THEN ''
WHEN exclusions LIKE 'null' THEN ''
ELSE exclusions
END AS exclusions,
CASE 
WHEN extras IS null THEN ''
WHEN extras LIKE 'null' THEN ''
ELSE extras
END AS extras,
order_time
FROM pizza_runner.customer_orders;


-- Cleaning null values in runner orders table
DROP TABLE IF EXISTS runner_orders_temp;
CREATE TEMPORARY TABLE runner_orders_temp AS
SELECT order_id, runner_id,
CASE 
WHEN pickup_time LIKE '' THEN '0000-00-00 00:00:00'
ELSE pickup_time
END AS pickup_time,
CASE 
WHEN distance LIKE 'null' THEN '0' 
WHEN distance LIKE '%km' THEN TRIM('km' from distance)
ELSE distance
END AS distance,
CASE
WHEN duration LIKE 'null' THEN '0'
WHEN duration LIKE '%mins' THEN TRIM('mins' from duration)
WHEN duration LIKE '%minute' THEN TRIM('minute' from duration)
WHEN duration LIKE '%minutes' THEN TRIM('minutes' from duration)
ELSE duration
END AS duration,
CASE
WHEN cancellation IS NULL or cancellation LIKE 'null' THEN ' '
ELSE cancellation
END AS cancellation
FROM pizza_runner.runner_orders;


ALTER TABLE runner_orders_temp MODIFY pickup_time DATETIME;
ALTER TABLE runner_orders_temp MODIFY distance decimal(4,2);
ALTER TABLE runner_orders_temp MODIFY duration INT;



