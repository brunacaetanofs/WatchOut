USE watchout;

-- =======================================================
-- GROUP 1: AUTOMATION & WORKFLOW
-- =======================================================

-- Trigger 1: Auto-Update Stock Status
-- Description: When an item is added to an order, we designed this trigger to 
-- automatically mark the specific physical unit as 'SOLD'. This ensures our 
-- inventory status remains accurate in real-time without manual input.
DELIMITER $$
DROP TRIGGER IF EXISTS trg_update_stock_status_after_sale $$
CREATE TRIGGER trg_update_stock_status_after_sale
AFTER INSERT ON OrderItem
FOR EACH ROW
BEGIN
    UPDATE StockUnit 
    SET status = 'SOLD' 
    WHERE stock_unit_id = NEW.stock_unit_id;
END$$

-- Trigger 2: Low Stock Warning System
-- Description: We implemented a supply chain alert system. If a sale causes the 
-- stock level of a specific model to drop below 3 units, we automatically 
-- write a warning to the Log table to notify management.
DROP TRIGGER IF EXISTS trg_check_low_stock_warning $$
CREATE TRIGGER trg_check_low_stock_warning
AFTER UPDATE ON StockUnit
FOR EACH ROW
BEGIN
    DECLARE remaining_stock INT;
    DECLARE product_model VARCHAR(150);

    -- Only check if the status actually changed to SOLD
    IF NEW.status = 'SOLD' AND OLD.status != 'SOLD' THEN
        SELECT COUNT(*) INTO remaining_stock
        FROM StockUnit
        WHERE product_id = NEW.product_id AND status = 'IN_STOCK';

        IF remaining_stock < 4 THEN
            SELECT model_name INTO product_model FROM Product WHERE product_id = NEW.product_id;
            INSERT INTO LogPrice (operation, table_name, message)
            VALUES ('WARNING', 'StockUnit', CONCAT('Low Stock Alert! Only ', remaining_stock, ' units left for ', product_model));
        END IF;
    END IF;
END$$

-- ========================================================
-- GROUP 2: BUSINESS LOGIC & FINANCIALS
-- ========================================================

-- Trigger 3: Dynamic Loyalty Tier System
-- Description: To gamify the shopping experience, we created a trigger that 
-- recalculates a customer's total historical spend after every purchase. 
-- If they cross our defined thresholds (€10k or €20k), we automatically upgrade their status.
DROP TRIGGER IF EXISTS trg_update_customer_tier $$
CREATE TRIGGER trg_update_customer_tier
AFTER INSERT ON OrderHeader
FOR EACH ROW
BEGIN
    DECLARE total_spent DECIMAL(12,2);
    SELECT SUM(total_amount) INTO total_spent FROM OrderHeader WHERE customer_id = NEW.customer_id;

    IF total_spent >= 20000 THEN
        UPDATE Customer SET loyalty_tier = 'Platinum' WHERE customer_id = NEW.customer_id;
    ELSEIF total_spent >= 10000 THEN
        UPDATE Customer SET loyalty_tier = 'Gold' WHERE customer_id = NEW.customer_id;
    END IF;
END$$

DELIMITER $$

DROP TRIGGER IF EXISTS trg_apply_vip_discount $$

CREATE TRIGGER trg_apply_vip_discount
BEFORE INSERT ON OrderItem
FOR EACH ROW
BEGIN
    DECLARE customer_tier ENUM('Standard', 'Gold', 'Platinum');
    DECLARE found_customer_id INT;

    -- 1. Get Customer ID
    SELECT customer_id INTO found_customer_id 
    FROM OrderHeader WHERE order_id = NEW.order_id;

    -- 2. Get Tier
    SELECT loyalty_tier INTO customer_tier 
    FROM Customer WHERE customer_id = found_customer_id;

    -- 3. Ensure discount_percent is not NULL (start at 0 if empty)
    IF NEW.discount_percent IS NULL THEN
        SET NEW.discount_percent = 0.00;
    END IF;

    -- 4. STACK the VIP Discount
    IF customer_tier = 'Gold' THEN
        SET NEW.discount_percent = NEW.discount_percent + 10.00; 
    ELSEIF customer_tier = 'Platinum' THEN
        SET NEW.discount_percent = NEW.discount_percent + 20.00; 
    END IF;
END$$


-- ========================================================
-- GROUP 3: SECURITY & INTEGRITY
-- ========================================================

-- Trigger 5: Price Change Audit
-- Description: For security and accountability, we ensure that any change to a 
-- product's base price is logged in the LogPrice table, preserving the 
-- history of the old value and the new value.
DROP TRIGGER IF EXISTS trg_audit_price_change $$
CREATE TRIGGER trg_audit_price_change
AFTER UPDATE ON Product
FOR EACH ROW
BEGIN
    IF OLD.price <> NEW.price THEN
        INSERT INTO LogPrice (operation, table_name, message)
        VALUES ('UPDATE', 'Product', CONCAT('Price change for Model ', OLD.model_name, '. Old: ', OLD.price, ', New: ', NEW.price));
    END IF;
END$$

-- Trigger 6: Prevent Double Selling
-- Description: We enforce data integrity by blocking sales of stock units 
-- that are not currently marked as 'IN_STOCK'. This prevents the logical error 
-- of selling the same physical watch to two different customers.
DROP TRIGGER IF EXISTS trg_prevent_selling_unavailable_stock $$
CREATE TRIGGER trg_prevent_selling_unavailable_stock
BEFORE INSERT ON OrderItem
FOR EACH ROW
BEGIN
    DECLARE current_status VARCHAR(20);
    SELECT status INTO current_status FROM StockUnit WHERE stock_unit_id = NEW.stock_unit_id;

    IF current_status != 'IN_STOCK' THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Error: This specific stock unit is not available for sale.';
    END IF;
END$$

-- Trigger 7: Verified Review Enforcement
-- Description: To maintain the reputation of our brand, we added a validation layer 
-- that prevents users from submitting reviews for products they have never purchased.
DROP TRIGGER IF EXISTS trg_verify_reviewer_bought_product $$
CREATE TRIGGER trg_verify_reviewer_bought_product
BEFORE INSERT ON Review
FOR EACH ROW
BEGIN
    DECLARE purchase_count INT;
    SELECT COUNT(*) INTO purchase_count
    FROM OrderHeader oh
    JOIN OrderItem oi ON oh.order_id = oi.order_id
    WHERE oh.customer_id = NEW.customer_id AND oi.product_id = NEW.product_id;

    IF purchase_count = 0 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Error: You can only review products you have purchased.';
    END IF;
END$$

-- ========================================================
-- GROUP 4: INTERNAL MANAGEMENT & HR
-- ========================================================

-- Trigger 8: Salary Raise Guardrail (HR Control)
-- Description: From a financial management perspective, we implemented a safety 
-- mechanism to prevent unauthorized budget spikes. This trigger blocks any new 
-- salary entry that is more than 20% higher than the employee's previous salary.
DROP TRIGGER IF EXISTS trg_prevent_excessive_salary_raise $$
CREATE TRIGGER trg_prevent_excessive_salary_raise
BEFORE INSERT ON SalaryHistory
FOR EACH ROW
BEGIN
    DECLARE current_salary DECIMAL(10,2);
    SELECT salary_amount INTO current_salary FROM SalaryHistory 
    WHERE employee_id = NEW.employee_id ORDER BY effective_date DESC LIMIT 1;

    IF current_salary IS NOT NULL THEN
        IF NEW.salary_amount > (current_salary * 1.20) THEN
            SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Error: Salary raises cannot exceed 20% in a single adjustment.';
        END IF;
    END IF;
END$$

-- Trigger 9: Dead Stock Clearance Log (Inventory Efficiency)
-- Description: To assist with inventory analysis, we track "slow-moving" assets. 
-- If a watch is sold more than 365 days after it was acquired, we log a special 
-- "Dead Stock" entry to help management identify low-turnover products.
DROP TRIGGER IF EXISTS trg_log_dead_stock_sale $$
CREATE TRIGGER trg_log_dead_stock_sale
AFTER INSERT ON OrderItem
FOR EACH ROW
BEGIN
    DECLARE acquisition_date DATE;
    DECLARE sale_date DATE;
    DECLARE days_in_stock INT;
    DECLARE model_info VARCHAR(150);

    SELECT acquired_date INTO acquisition_date FROM StockUnit WHERE stock_unit_id = NEW.stock_unit_id;
    SELECT order_date INTO sale_date FROM OrderHeader WHERE order_id = NEW.order_id;
    SET days_in_stock = DATEDIFF(sale_date, acquisition_date);

    IF days_in_stock > 365 THEN
        SELECT model_name INTO model_info FROM Product WHERE product_id = NEW.product_id;
        INSERT INTO LogPrice (operation, table_name, message)
        VALUES ('INFO', 'Inventory', CONCAT('Dead Stock Clearance: ', model_info, ' sold after ', days_in_stock, ' days in warehouse.'));
    END IF;
END$$

DELIMITER ;