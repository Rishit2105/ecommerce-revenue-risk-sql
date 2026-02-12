-- Purpose:
-- Quantify revenue concentration among top customers to assess
-- the risk of revenue being dependent on a small group.

WITH customer_revenue AS (
  SELECT
    c.customer_unique_id,
    SUM(oi.price * oi.quantity) AS total_revenue
  FROM orders o
  JOIN order_items oi ON o.order_id = oi.order_id
  JOIN customers c ON o.customer_id = c.customer_id
  GROUP BY c.customer_unique_id
),
ranked AS (
  SELECT
    customer_unique_id,
    total_revenue,
    NTILE(10) OVER (ORDER BY total_revenue DESC) AS revenue_decile
  FROM customer_revenue
)
SELECT
  revenue_decile,
  COUNT(*) AS customers_in_decile,
  SUM(total_revenue) AS revenue_by_decile,
  ROUND(SUM(total_revenue) / SUM(SUM(total_revenue)) OVER (), 4) AS revenue_share
FROM ranked
GROUP BY revenue_decile
ORDER BY revenue_decile;
