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

select 
    p.model_name as Watch_name,
    b.brand_name as Brand,
    count(case when s.status = 'IN_STOCK' then 1 end) as Current_stock
from Product p
left join StockUnit s on p.product_id = s.product_id
join Brand b on p.brand_id = b.brand_id
group by Watch_name, Brand
having Current_stock < 5
order by Current_stock desc;

-- 6. TOP CUSTOMERS (LIFETIME VALUE)
-- CEO Question: "Who are our top 10 customers by total spending, and do their tiers match?"
-- Business Context: Identify VIPs for exclusive offers and validate the Logic of 'Loyalty Tier'.

SELECT 
    c.first_name, 
    c.last_name, 
    c.loyalty_tier, 
    COUNT(DISTINCT oh.order_id) AS Total_orders,
    ROUND(SUM(oi.quantity * oi.unit_price * (1 - oi.discount_percent / 100)), 2) AS Lifetime_value
FROM Customer c
JOIN OrderHeader oh ON c.customer_id = oh.customer_id
JOIN OrderItem oi ON oh.order_id = oi.order_id
GROUP BY c.customer_id, c.first_name, c.last_name, c.loyalty_tier
ORDER BY Lifetime_value DESC
LIMIT 10;
-- ----------------------------------------------------------

-- 7. EMPLOYEE SALES PERFORMANCE & DISCOUNT BEHAVIOR
-- CEO Question: "Who are our best sellers, and are they relying too much on discounts to close deals?"
-- Business Context: Balances revenue generation against margin erosion. High revenue with high discounts is suspicious.

SELECT 
    CONCAT(e.first_name, ' ', e.last_name) AS Sales_rep,
    COUNT(DISTINCT oh.order_id) AS Deals_closed,
    ROUND(SUM(oi.quantity * oi.unit_price * (1 - oi.discount_percent / 100)), 2) AS Total_revenue,
    ROUND(AVG(oi.discount_percent), 2) AS Avg_discount_given
FROM Employee e
JOIN OrderHeader oh ON e.employee_id = oh.employee_id
JOIN OrderItem oi ON oh.order_id = oi.order_id
WHERE e.role = 'sales'
GROUP BY e.employee_id
ORDER BY Total_revenue DESC;
-- ----------------------------------------------------------

-- 8. AGED INVENTORY ("DEAD STOCK")
-- CEO Question: "Which specific watches have been sitting in stock for more than 1 year?"
-- Business Context: Identifies assets that are losing value and liquidity (candidates for clearance sales).

SELECT 
    b.brand_name AS Brand,
    p.model_name AS Model,
    s.acquired_date,
    DATEDIFF(CURRENT_DATE, s.acquired_date) AS Days_in_stock,
    p.price AS Locked_capital
FROM StockUnit s
JOIN Product p ON s.product_id = p.product_id
JOIN Brand b ON p.brand_id = b.brand_id
WHERE s.status = 'IN_STOCK' 
  AND s.acquired_date < DATE_SUB(CURRENT_DATE, INTERVAL 1 YEAR)
ORDER BY Days_in_stock DESC;
-- ----------------------------------------------------------

-- 9. PREFERENCE ANALYSIS (MOVEMENT & GENDER)
-- CEO Question: "What technical specifications (Movement type and Gender) are driving the most sales?"
-- Business Context: Guides future purchasing decisions from manufacturers.

SELECT 
    p.gender,
    p.movement_type,
    SUM(oi.quantity) AS Units_sold,
    ROUND(SUM(oi.quantity * oi.unit_price * (1 - oi.discount_percent / 100)), 2) AS Revenue
FROM Product p
JOIN OrderItem oi ON p.product_id = oi.product_id
GROUP BY p.gender, p.movement_type
ORDER BY Revenue DESC;
-- ----------------------------------------------------------

-- 10. AVERAGE ORDER VALUE (AOV) BY TIER
-- CEO Question: "Do Gold and Platinum customers actually spend more per transaction than Standard customers?"
-- Business Context: Measures the effectiveness of the upsell strategy within loyalty tiers.

SELECT 
    c.loyalty_tier,
    COUNT(DISTINCT oh.order_id) AS Total_transactions,
    ROUND(SUM(oi.quantity * oi.unit_price * (1 - oi.discount_percent / 100)), 2) AS Total_revenue,
    ROUND(
        SUM(oi.quantity * oi.unit_price * (1 - oi.discount_percent / 100)) / COUNT(DISTINCT oh.order_id), 2
    ) AS Average_Order_Value
FROM Customer c
JOIN OrderHeader oh ON c.customer_id = oh.customer_id
JOIN OrderItem oi ON oh.order_id = oi.order_id
GROUP BY c.loyalty_tier
ORDER BY Average_Order_Value DESC;