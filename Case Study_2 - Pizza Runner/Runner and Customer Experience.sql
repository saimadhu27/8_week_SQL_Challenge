/* Case Study Questions
       Runner and Customer Experience */

-- 1. How many runners signed up for each 1 week period? (i.e. week starts 2021-01-01)
SELECT WEEK(date_add(registration_date,INTERVAL 3 DAY)), COUNT(runner_id)
FROM pizza_runner.runners
GROUP BY WEEK(date_add(registration_date,INTERVAL 3 DAY));

-- 2. What was the average time in minutes it took for each runner to arrive at the Pizza Runner HQ to pickup the order?
SELECT r.runner_id, ROUND(AVG(minute(pickup_time)))
FROM pizza_runner.runners as r
JOIN runner_orders_temp as o
ON r.runner_id = o.runner_id
WHERE o.distance != 0
GROUP BY r.runner_id;

-- 3. Is there any relationship between the number of pizzas and how long the order takes to prepare?
WITH prep_time_cte AS
(SELECT c.order_id, COUNT(c.pizza_id) AS num_of_pizzas, timestampdiff(MINUTE, c.order_time, r.pickup_time) AS time_taken_per_order, timestampdiff(MINUTE, c.order_time, r.pickup_time) / COUNT(c.pizza_id) AS time_taken_per_pizza
FROM  runner_orders_temp as r, customer_orders_temp as c
WHERE c.order_id = r.order_id
GROUP BY c.order_id, c.order_time, r.pickup_time)

SELECT num_of_pizzas, AVG(time_taken_per_order) AS avg_total_time_taken, AVG(time_taken_per_pizza) AS avg_time_taken_per_pizza
FROM prep_time_cte
GROUP BY num_of_pizzas;

-- 4. What was the average distance travelled for each customer?
SELECT customer_id, AVG(distance) as avg_distance
FROM customer_orders_temp as c
JOIN runner_orders_temp as r
ON c.order_id = r.order_id
WHERE distance != 0
GROUP BY customer_id;

-- 5. What was the difference between the longest and shortest delivery times for all orders?
SELECT MAX(duration) AS max_delivery_time,
	MIN(duration) AS min_delivery_time,
	MAX(duration) - MIN(duration) AS time_difference
FROM runner_orders_temp
WHERE distance >0;

-- 6. What was the average speed for each runner for each delivery and do you notice any trend for these values?
SELECT order_id, runner_id, AVG((distance/duration) *60) as avg_speed
FROM runner_orders_temp
WHERE distance >0
GROUP BY order_id,runner_id
ORDER BY order_id;

-- 7. What is the successful delivery percentage for each runner?
SELECT 
  runner_id, 
  ROUND(100 * SUM(
    CASE WHEN distance = 0 THEN 0
    ELSE 1 END) / COUNT(*), 0) AS success_perc
FROM runner_orders_temp
GROUP BY runner_id;