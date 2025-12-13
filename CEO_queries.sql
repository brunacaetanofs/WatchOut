-- ==========================================================
-- WATCHOUT PROJECT - SECTION F: BUSINESS QUESTIONS
-- Data Analysis Queries for the CEO
-- ==========================================================

-- 1. REVENUE RANKING BY BRAND
-- CEO Question: "Which brands generate the most revenue for WatchOut?"
-- Business Context: Identifies top-performing brands for marketing strategies.

select 
    b.brand_name as Brand, 
    ROUND(SUM(oi.quantity * oi.unit_price * (1 - oi.discount_percent / 100)), 2) AS Total_revenue,
    SUM(oi.quantity) as Quantity
from product p
join brand b on p.brand_id = b.brand_id
join orderitem oi on p.product_id = oi.product_id
group by b.brand_name
order by Total_revenue desc;
-- ----------------------------------------------------------

-- 2. MONTHLY SALES TREND (SEASONALITY)
-- CEO Question: "What is the sales trend month over month for the last two years?"
-- Business Context: Analyze growth and identify seasonal peaks (e.g., Christmas or Summer ).

select 
    year(oh.order_date) as Sales_year,
    month(oh.order_date) as Sales_month,
	round(sum(oi.quantity * oi.unit_price * (1 - oi.discount_percent / 100)), 2) as Revenue_with_discount,
    round(sum(oi.quantity * oi.unit_price), 2) as Revenue_without_discount,
    round(
        sum(oi.quantity * oi.unit_price) 
        - sum(oi.quantity * oi.unit_price * (1 - oi.discount_percent / 100)), 2
    ) AS Revenue_lost_due_to_discount
from OrderHeader oh
join OrderItem oi on oh.order_id = oi.order_id
join Product p on oi.product_id = p.product_id
group by year(oh.order_date), month(oh.order_date)
order by Sales_year, Sales_month;
-- ----------------------------------------------------------

-- 3. BRAND REPUTATION
-- CEO Question: "What is the average rating (stars) customers give to each brand?"
-- Business Context: Monitors quality control and brand perception.

select b.brand_name as Brand,
	avg(r.rating) as avg_rating
from review as r
join product as p on r.product_id = p.product_id
join brand as b on p.brand_id = b.brand_id
group by Brand
order by avg_rating desc;
-- ----------------------------------------------------------

-- 4. INVENTORY VALUE (STOCK)
-- CEO Question: "How much capital is currently tied up in stock for each brand?"
-- Business Context: Crucial for financial planning and asset management.

select 
    b.brand_name as Brand, 
    SUM(p.price) as Total_stock_value
from StockUnit s
join Product p on s.product_id = p.product_id
join Brand b on p.brand_id = b.brand_id
where s.status = 'IN_STOCK'  
group by b.brand_name
order by Total_stock_value desc;
-- ----------------------------------------------------------

-- 5. CRITICAL STOCK ALERT
-- CEO Question: "Which products have less than 5 units left and need urgent restocking?"
-- Business Context: Prevents stockouts and lost sales opportunities.

SELECT 
    -- 1. NEW WARNING COLUMN (Visual Alert)
    CASE 
        WHEN count(case when s.status = 'IN_STOCK' then 1 end) = 0 THEN '❌ SOLD OUT'
        ELSE '🔴 LOW STOCK' 
    END AS Alert_Status,

    -- 2. Standard Columns
    p.model_name as Watch_name,
    b.brand_name as Brand,
    count(case when s.status = 'IN_STOCK' then 1 end) as Current_stock

FROM Product p
LEFT JOIN StockUnit s on p.product_id = s.product_id
JOIN Brand b on p.brand_id = b.brand_id

GROUP BY Watch_name, Brand
HAVING Current_stock < 5
ORDER BY Current_stock ASC;