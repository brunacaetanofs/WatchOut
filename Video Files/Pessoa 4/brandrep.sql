-- ===================
--  BRAND REPUTATION 
-- ===================

SELECT 
    b.brand_name AS Brand,
    -- Calculate average rating from the Review table
    ROUND(AVG(r.rating), 1) AS Avg_Rating
FROM review r
JOIN product p ON r.product_id = p.product_id
JOIN brand b ON p.brand_id = b.brand_id
GROUP BY b.brand_name
ORDER BY Avg_Rating DESC;