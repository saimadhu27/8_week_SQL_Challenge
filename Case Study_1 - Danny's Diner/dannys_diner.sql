CREATE TABLE dannys_diner.sales (
  customer_id VARCHAR(1),
  order_date DATE,
  product_id INTEGER
);

INSERT INTO dannys_diner.sales
  (customer_id, order_date, product_id)
VALUES
  ('A', '2021-01-01', '1'),
  ('A', '2021-01-01', '2'),
  ('A', '2021-01-07', '2'),
  ('A', '2021-01-10', '3'),
  ('A', '2021-01-11', '3'),
  ('A', '2021-01-11', '3'),
  ('B', '2021-01-01', '2'),
  ('B', '2021-01-02', '2'),
  ('B', '2021-01-04', '1'),
  ('B', '2021-01-11', '1'),
  ('B', '2021-01-16', '3'),
  ('B', '2021-02-01', '3'),
  ('C', '2021-01-01', '3'),
  ('C', '2021-01-01', '3'),
  ('C', '2021-01-07', '3');
 
 CREATE TABLE dannys_diner.menu (
  product_id INTEGER,
  product_name VARCHAR(5),
  price INTEGER
);

INSERT INTO dannys_diner.menu
  (product_id, product_name, price)
VALUES
  ('1', 'sushi', '10'),
  ('2', 'curry', '15'),
  ('3', 'ramen', '12');
  

CREATE TABLE dannys_diner.members (
  customer_id VARCHAR(1),
  join_date DATE
);

INSERT INTO dannys_diner.members
  (customer_id, join_date)
VALUES
  ('A', '2021-01-07'),
  ('B', '2021-01-09');
  
/* --------------------
   Case Study Questions
   --------------------*/

-- 1. What is the total amount each customer spent at the restaurant?
SELECT customer_id, SUM(price)
FROM dannys_diner.sales as s
LEFT JOIN dannys_diner.menu as m
ON s.product_id=m.product_id
GROUP BY customer_id;

-- 2. How many days has each customer visited the restaurant?
SELECT customer_id, COUNT(DISTINCT(order_date)) as count_visit
FROM dannys_diner.sales
GROUP BY customer_id;

-- 3. What was the first item from the menu purchased by each customer?
WITH first_item as (
SELECT customer_id, product_name, DENSE_RANK() OVER (PARTITION BY customer_id ORDER BY order_date ASC) AS rank_customer
FROM dannys_diner.sales as s
LEFT JOIN dannys_diner.menu as m
ON s.product_id=m.product_id)

SELECT customer_id,product_name
FROM first_item
WHERE rank_customer = 1;

-- 4. What is the most purchased item on the menu and how many times was it purchased by all customers?
SELECT COUNT(s.product_id) as purchased_count, product_name
FROM dannys_diner.sales as s
LEFT JOIN dannys_diner.menu as m
ON s.product_id=m.product_id
GROUP BY s.product_id
ORDER BY purchased_count DESC
LIMIT 1;

-- 5. Which item was the most popular for each customer?
WITH popular_item as (
SELECT customer_id, product_name, COUNT(s.product_id) as total_purchase, RANK() OVER (PARTITION BY customer_id ORDER BY COUNT(product_name) DESC) AS rank_item
FROM dannys_diner.sales as s
LEFT JOIN dannys_diner.menu as m
ON s.product_id=m.product_id
GROUP BY customer_id,product_name)

SELECT customer_id,product_name,rank_item,total_purchase
FROM popular_item
WHERE rank_item = 1;

-- 6. Which item was purchased first by the customer after they became a member?
WITH first_purchased as (
SELECT s.customer_id,s.product_id, DENSE_RANK() OVER(PARTITION BY s.customer_id ORDER BY s.order_date) AS rank_date,s.order_date
FROM dannys_diner.sales as s
INNER JOIN dannys_diner.members as m2
ON s.customer_id=m2.customer_id
WHERE s.order_date>=m2.join_date)

SELECT s.customer_id,s.order_date,product_name
FROM first_purchased as s
INNER JOIN dannys_diner.menu as m
ON s.product_id = m.product_id
WHERE rank_date=1;

-- 7. Which item was purchased just before the customer became a member?
WITH first_purchased as (
SELECT s.customer_id,s.product_id, DENSE_RANK() OVER(PARTITION BY s.customer_id ORDER BY s.order_date DESC) AS rank_date,s.order_date
FROM dannys_diner.sales as s
INNER JOIN dannys_diner.members as m2
ON s.customer_id=m2.customer_id
WHERE s.order_date<m2.join_date)

SELECT s.customer_id,s.order_date,product_name
FROM first_purchased as s
INNER JOIN dannys_diner.menu as m
ON s.product_id = m.product_id
WHERE rank_date=1;

-- 8. What is the total items and amount spent for each member before they became a member?
SELECT s.customer_id,COUNT(distinct s.product_id),SUM(price)
FROM dannys_diner.sales as s
JOIN dannys_diner.members as m2
ON s.customer_id=m2.customer_id
JOIN dannys_diner.menu as m
ON s.product_id=m.product_id
WHERE s.order_date<m2.join_date
GROUP BY s.customer_id;

-- 9.  If each $1 spent equates to 10 points and sushi has a 2x points multiplier - how many points would each customer have?
WITH price_points_cte AS(
	SELECT *, 
		CASE WHEN product_name = 'sushi' THEN price * 20
		ELSE price * 10 END AS points
	FROM dannys_diner.menu)

SELECT s.customer_id, SUM(p.points) AS total_points
FROM price_points_cte AS p
JOIN dannys_diner.sales AS s
ON p.product_id = s.product_id
GROUP BY s.customer_id

-- 10. In the first week after a customer joins the program (including their join date) they earn 2x points on all items, not just sushi - how many points do customer A and B have at the end of January?
WITH dates_cte AS (
   SELECT *, 
      DATE_ADD(join_date,INTERVAL 6 DAY) AS valid_date, 
      LAST_DAY('2021-01-31') AS last_date
   FROM dannys_diner.members AS m)

SELECT d.customer_id, s.order_date, d.join_date, d.valid_date, d.last_date, m.product_name, m.price,
   SUM(CASE
      WHEN m.product_name = 'sushi' THEN 2 * 10 * m.price
      WHEN s.order_date BETWEEN d.join_date AND d.valid_date THEN 2 * 10 * m.price
      ELSE 10 * m.price
      END) AS points
FROM dates_cte AS d
JOIN dannys_diner.sales AS s
   ON d.customer_id = s.customer_id
JOIN dannys_diner.menu AS m
   ON s.product_id = m.product_id
WHERE s.order_date < d.last_date
GROUP BY d.customer_id;