-- =================
--  INVENTORY VALUE 
-- =================

SELECT 
    b.brand_name AS Brand, 
    -- Sum of price for all items currently 'IN_STOCK'
    SUM(p.price) AS Total_Stock_Value
FROM StockUnit s
JOIN Product p ON s.product_id = p.product_id
JOIN Brand b ON p.brand_id = b.brand_id
WHERE s.status = 'IN_STOCK'  
GROUP BY b.brand_name
ORDER BY Total_Stock_Value DESC;In