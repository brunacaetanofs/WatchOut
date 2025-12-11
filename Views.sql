USE watchout;

-- =================================================================
-- VIEW 1: INVOICE HEADER (Financial Summary)
-- =================================================================
CREATE OR REPLACE VIEW v_invoice_header AS
SELECT 
    oh.order_id AS 'Invoice_ID',
    oh.order_date AS 'Date',
    
    -- Customer & Employee
    CONCAT(c.first_name, ' ', c.last_name) AS 'Customer',
    c.loyalty_tier AS 'Tier',
    IFNULL(CONCAT(e.first_name, ' ', e.last_name), 'Online/Kiosk') AS 'Salesperson',
    
    -- 1. CATALOG PRICE (Sum of original unit prices)
    SUM(oi.quantity * oi.unit_price) AS 'Total_Catalog_Price',

    -- 2. FINAL PRICE (Rounded to 2 decimals)
    ROUND(
        SUM(oi.quantity * oi.unit_price * (1 - oi.discount_percent / 100.0)), 
        2
    ) AS 'Total_Paid',

    -- 3. SAVINGS (Money saved)
    -- This is the most important metric now
    ROUND(
        (SUM(oi.quantity * oi.unit_price) - SUM(oi.quantity * oi.unit_price * (1 - oi.discount_percent / 100.0))), 
        2
    ) AS 'Total_Saved'

FROM OrderHeader oh
JOIN Customer c ON oh.customer_id = c.customer_id
LEFT JOIN Employee e ON oh.employee_id = e.employee_id
JOIN OrderItem oi ON oh.order_id = oi.order_id
GROUP BY oh.order_id;

-- =================================================================
-- VIEW 2: INVOICE DETAILS (Line Items)
-- =================================================================
CREATE OR REPLACE VIEW v_invoice_details AS
SELECT 
    oi.order_id AS 'Invoice_ID',
    b.brand_name AS 'Brand',
    p.model_name AS 'Model',
    
    -- Price Info
    oi.unit_price AS 'Original_Price',
    
    -- Here we KEEP the percentage because it refers to the specific item
    CONCAT(oi.discount_percent, '%') AS 'Discount',
    
    -- Final Price per unit (Rounded)
    ROUND(
        oi.unit_price * (1 - oi.discount_percent / 100.0), 
        2
    ) AS 'Final_Price',
    
    oi.quantity AS 'Qty',
    
    -- Line Total (Rounded)
    ROUND(
        oi.quantity * (oi.unit_price * (1 - oi.discount_percent / 100.0)), 
        2
    ) AS 'Subtotal'

FROM OrderItem oi
JOIN Product p ON oi.product_id = p.product_id
JOIN Brand b ON p.brand_id = b.brand_id
ORDER BY oi.order_id ASC;