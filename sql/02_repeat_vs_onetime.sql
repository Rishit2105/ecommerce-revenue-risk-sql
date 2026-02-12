-- Purpose:
-- Compare revenue contribution from repeat customers vs one-time buyers
-- to inform retention vs acquisition strategy.

WITH orders_per_customer AS (
  SELECT
    c.customer_unique_id,
    COUNT(DISTINCT o.order_id) AS order_count
  FROM orders o
  JOIN customers c
    ON o.customer_id = c.customer_id
  GROUP BY c.customer_unique_id
),
customer_revenue AS (
  SELECT
    c.customer_unique_id,
    SUM(oi.price * oi.quantity) AS total_revenue
  FROM orders o
  JOIN order_items oi
    ON o.order_id = oi.order_id
  JOIN customers c
    ON o.customer_id = c.customer_id
  GROUP BY c.customer_unique_id
)
SELECT
  CASE 
    WHEN opc.order_count > 1 THEN 'Repeat'
    ELSE 'One-time'
  END AS customer_type,
  COUNT(DISTINCT cr.customer_unique_id) AS customers,
  SUM(cr.total_revenue) AS revenue
FROM orders_per_customer opc
JOIN customer_revenue cr
  ON opc.customer_unique_id = cr.customer_unique_id
GROUP BY customer_type
ORDER BY revenue DESC;
