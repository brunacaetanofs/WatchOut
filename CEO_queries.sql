-- ==========================================================
-- WATCHOUT PROJECT - SECTION F: BUSINESS QUESTIONS
-- Data Analysis Queries for the CEO
-- ==========================================================

-- 1. REVENUE RANKING BY BRAND
-- CEO Question: "Which brands generate the most revenue for WatchOut?"
-- Business Context: Identifies top-performing brands for marketing strategies.

select b.brand_name as Brand, 
sum(o.quantity*p.price) as Total_revenue,
sum(o.quantity) as Quantity
from product as p
join brand as b on p.brand_id = b.brand_id
join orderitem as o on p.product_id = o.product_id
group by b.brand_name
order by Total_revenue desc;
-- ----------------------------------------------------------

-- 2. MONTHLY SALES TREND (SEASONALITY)
-- CEO Question: "What is the sales trend month over month for the last two years?"
-- Business Context: Analyze growth and identify seasonal peaks (e.g., Christmas or Summer ).

select year(oh.order_date) as Sales_year,
month(oh.order_date) as Sales_month,
sum(oi.quantity * p.price) as Total_revenue
from OrderHeader oh
JOIN OrderItem oi on oh.order_id = oi.order_id
JOIN Product p on oi.product_id = p.product_id
group by year(oh.order_date), month(oh.order_date)
order by Sales_year, Sales_month;
-- ----------------------------------------------------------

-- 3. BRAND REPUTATION
-- CEO Question: "What is the average rating (stars) customers give to each brand?"
-- Business Context: Monitors quality control and brand perception.

select b.brand_name as Brand,
avg(r.rating)
from review as r
join product as p on r.product_id = p.product_id
join brand as b on p.brand_id = b.brand_id
group by Brand;
-- ----------------------------------------------------------

-- 4. INVENTORY VALUE (STOCK)
-- CEO Question: "How much capital is currently tied up in stock for each brand?"
-- Business Context: Crucial for financial planning and asset management.

select b.brand_name as Brand, 
sum(p.price) as Total_stock_value 
from stockunit as s
join product as p on s.product_id = p.product_id
join brand as b on p.brand_id = b.brand_id
group by Brand
order by Total_stock_value DESC;
-- ----------------------------------------------------------

-- 5. CRITICAL STOCK ALERT
-- CEO Question: "Which products have less than 5 units left and need urgent restocking?"
-- Business Context: Prevents stockouts and lost sales opportunities.

select p.model_name as Watch_name,
b.brand_name as Brand,
count(s.stock_unit_id) AS Current_stock
from product as p
left join stockunit as s on p.product_id = s.product_id
join brand as b on p.brand_id = b.brand_id
group by Watch_name, Brand
having Current_stock < 5
order by Current_stock ASC;