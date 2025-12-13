-- =============
--  SEASONALITY 
-- =============

SELECT 
    YEAR(oh.order_date) AS Sales_Year,
    MONTH(oh.order_date) AS Sales_Month,
    -- We calculate the real revenue (after discounts)
    ROUND(SUM(oi.quantity * oi.unit_price * (1 - oi.discount_percent / 100)), 2) AS Revenue
FROM OrderHeader oh
JOIN OrderItem oi ON oh.order_id = oi.order_id
GROUP BY YEAR(oh.order_date), MONTH(oh.order_date)
ORDER BY Sales_Year ASC, Sales_Month ASC;