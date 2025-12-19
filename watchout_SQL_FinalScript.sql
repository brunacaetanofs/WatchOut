-- =========================================
-- SCHEMA: WatchOut database
-- =========================================
DROP DATABASE IF EXISTS watchout;
CREATE DATABASE watchout;
USE watchout;

-- 1) Customer
CREATE TABLE Customer (
    customer_id     INT AUTO_INCREMENT PRIMARY KEY,
    first_name      VARCHAR(50) NOT NULL,
    last_name       VARCHAR(50) NOT NULL,
    email           VARCHAR(120) UNIQUE NOT NULL,
    phone           VARCHAR(20),
    loyalty_tier    ENUM('Standard', 'Gold', 'Platinum') DEFAULT 'Standard',
    created_at      DATETIME DEFAULT CURRENT_TIMESTAMP
);

-- 2) Brand
CREATE TABLE Brand (
    brand_id    INT AUTO_INCREMENT PRIMARY KEY,
    brand_name  VARCHAR(100) NOT NULL
);

-- 3) Product
CREATE TABLE Product (
    product_id      INT AUTO_INCREMENT PRIMARY KEY,
    brand_id        INT NOT NULL,
    model_name      VARCHAR(150) NOT NULL,
    description     TEXT,
    price           DECIMAL(10,2) NOT NULL,
    movement_type   ENUM('automatic','quartz','mechanical') NOT NULL,
    gender          ENUM('men','women','unisex') NOT NULL,
    
    CONSTRAINT fk_product_brand 
        FOREIGN KEY (brand_id) REFERENCES Brand(brand_id)
        ON UPDATE CASCADE ON DELETE RESTRICT
);

-- 4) StockUnit
CREATE TABLE StockUnit (
    stock_unit_id   INT AUTO_INCREMENT PRIMARY KEY,
    product_id      INT NOT NULL,
    acquired_date   DATE,
    `condition`     ENUM('new','refurbished','used') NOT NULL,
    status          ENUM('IN_STOCK','RESERVED','SOLD','DISCARDED') DEFAULT 'IN_STOCK',

    CONSTRAINT fk_stockunit_product
        FOREIGN KEY (product_id) REFERENCES Product(product_id)
        ON UPDATE CASCADE ON DELETE RESTRICT
);

-- 5) Employee
CREATE TABLE Employee (
    employee_id     INT AUTO_INCREMENT PRIMARY KEY,
    first_name      VARCHAR(50) NOT NULL,
    last_name       VARCHAR(50) NOT NULL,
    role            ENUM('sales','manager','technician','cashier') NOT NULL,
    hire_date       DATE
);

-- 6) OrderHeader
CREATE TABLE OrderHeader (
    order_id        INT AUTO_INCREMENT PRIMARY KEY,
    customer_id     INT NOT NULL,
    employee_id     INT NULL,
    order_date      DATE NOT NULL,

    total_amount    DECIMAL(12,2),

    CONSTRAINT fk_orderheader_customer
        FOREIGN KEY (customer_id) REFERENCES Customer(customer_id)
        ON UPDATE CASCADE ON DELETE RESTRICT,

    CONSTRAINT fk_orderheader_employee
        FOREIGN KEY (employee_id) REFERENCES Employee(employee_id)
        ON UPDATE CASCADE ON DELETE SET NULL
);


-- 7) OrderItem
CREATE TABLE OrderItem (
    order_item_id   INT AUTO_INCREMENT PRIMARY KEY,
    order_id        INT NOT NULL,
    product_id      INT NOT NULL,
    stock_unit_id   INT NULL,
    quantity        INT NOT NULL CHECK (quantity > 0),
    unit_price      DECIMAL(10,2) NOT NULL,

    -- NEW COLUMN: percentage discount, 0–100
    discount_percent DECIMAL(5,2) NOT NULL DEFAULT 0.00
        CHECK (discount_percent BETWEEN 0 AND 100),
        
    CONSTRAINT fk_orderitem_order
        FOREIGN KEY (order_id) REFERENCES OrderHeader(order_id)
        ON UPDATE CASCADE ON DELETE CASCADE,

    CONSTRAINT fk_orderitem_product
        FOREIGN KEY (product_id) REFERENCES Product(product_id)
        ON UPDATE CASCADE ON DELETE RESTRICT,

    CONSTRAINT fk_orderitem_stockunit
        FOREIGN KEY (stock_unit_id) REFERENCES StockUnit(stock_unit_id)
        ON UPDATE CASCADE ON DELETE SET NULL,

    CONSTRAINT uq_orderitem_stockunit UNIQUE (stock_unit_id)
    -- Between StockUnit and OrderItem, Workbench shows a 1-N relationship because the tool only looks at the foreign key. 
    -- However, in our code we also added a UNIQUE constraint on OrderItem.stock_unit_id, which in practice means that each physical unit in stock can be linked to at most one order item. 
    -- So, from the business logic point of view, the relationship is 1:1 for sold watches.
);


-- 8) Review
CREATE TABLE Review (
    review_id       INT AUTO_INCREMENT PRIMARY KEY,
    customer_id     INT NOT NULL,
    product_id      INT NOT NULL,
    rating          INT NOT NULL CHECK (rating BETWEEN 1 AND 5),
    review_text     TEXT,
    created_at      DATETIME DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT fk_review_customer
        FOREIGN KEY (customer_id) REFERENCES Customer(customer_id)
        ON UPDATE CASCADE ON DELETE CASCADE,

    CONSTRAINT fk_review_product
        FOREIGN KEY (product_id) REFERENCES Product(product_id)
        ON UPDATE CASCADE ON DELETE CASCADE
);

-- 9) LogPrice (for triggers)
CREATE TABLE LogPrice (
    log_id      INT AUTO_INCREMENT PRIMARY KEY,
    operation   VARCHAR(50),
    table_name  VARCHAR(50),
    message     TEXT,
    created_at  DATETIME DEFAULT CURRENT_TIMESTAMP
);

-- 10) SalaryHistory
CREATE TABLE SalaryHistory (
    salary_id       INT AUTO_INCREMENT PRIMARY KEY,
    employee_id     INT NOT NULL,
    effective_date  DATE NOT NULL,
    salary_amount   DECIMAL(10,2) NOT NULL,

    CONSTRAINT fk_salaryhistory_employee
        FOREIGN KEY (employee_id) REFERENCES Employee(employee_id)
        ON UPDATE CASCADE ON DELETE CASCADE
);


USE watchout;

-- =========================
-- BRANDS
-- =========================
INSERT INTO Brand (brand_name) VALUES
  ('Rolex'),
  ('Omega'),
  ('Tag Heuer'),
  ('Seiko'),
  ('Casio'),
  ('Tissot');

-- =========================
-- PRODUCTS (18 products)
-- =========================
INSERT INTO Product (brand_id, model_name, description, price, movement_type, gender) VALUES
  -- Brand 1: Rolex
  (1, 'Submariner Date',         'Diver watch, steel, black dial',              9500.00, 'automatic',  'men'),
  (1, 'Datejust 36',             'Classic steel and gold bracelet',             7800.00, 'automatic',  'unisex'),
  (1, 'Explorer I',              'Robust field watch, black dial',              7200.00, 'automatic',  'men'),

  -- Brand 2: Omega
  (2, 'Speedmaster Professional','Moonwatch chronograph',                       6500.00, 'mechanical', 'men'),
  (2, 'Seamaster Aqua Terra',    'Sporty elegant watch',                        5200.00, 'automatic',  'unisex'),
  (2, 'Constellation Globemaster','Dress watch with fluted bezel',              6000.00, 'automatic',  'unisex'),

  -- Brand 3: Tag Heuer
  (3, 'Carrera Calibre 5',       'Sport chronograph',                           3200.00, 'automatic',  'men'),
  (3, 'Monaco',                  'Square chronograph, blue dial',               4500.00, 'automatic',  'men'),
  (3, 'Aquaracer Professional',  'Diver watch with ceramic bezel',              2800.00, 'automatic',  'unisex'),

  -- Brand 4: Seiko
  (4, 'Presage Cocktail Time',   'Dress watch automatic',                         550.00,'automatic',  'men'),
  (4, 'Seiko 5 Sports',          'Everyday automatic watch',                      300.00,'automatic',  'unisex'),
  (4, 'Prospex Turtle',          'Professional diver automatic',                  650.00,'automatic',  'men'),

  -- Brand 5: Casio
  (5, 'G-Shock GA-2100',         'Shock resistant digital-analog',               150.00,'quartz',     'unisex'),
  (5, 'Casio F-91W',             'Digital classic',                                25.00,'quartz',     'unisex'),
  (5, 'Edifice Chronograph',     'Steel chronograph with tachymeter',            180.00,'quartz',     'men'),

  -- Brand 6: Tissot
  (6, 'Le Locle Powermatic 80',  'Dress automatic watch',                         750.00,'automatic',  'men'),
  (6, 'PRX Powermatic 80',       'Integrated bracelet sport watch',               800.00,'automatic',  'unisex'),
  (6, 'Seastar 1000',            'Dive watch 300m, rubber strap',                 900.00,'automatic',  'men');

-- =========================
-- CUSTOMERS (30 customers)
-- =========================
INSERT INTO Customer (first_name, last_name, email, phone) VALUES
  ('Ana',      'Silva',       'ana.silva@gmail.com',         '912345678'),
  ('Bruno',    'Costa',       'bruno.costa@outlook.com',     '913456789'),
  ('Carla',    'Ferreira',    'carla.ferreira@gmail.com',    '914567890'),
  ('David',    'Santos',      'david.santos@hotmail.com',    '915678901'),
  ('Eva',      'Oliveira',    'eva.oliveira@gmail.com',      '916789012'),
  ('Filipe',   'Ramos',       'filipe.ramos@outlook.com',    '917890123'),
  ('Inês',     'Marques',     'ines.marques@gmail.com',      '918901234'),
  ('João',     'Pereira',     'joao.pereira@gmail.com',      '919012345'),
  ('Luisa',    'Lopes',       'luisa.lopes@outlook.com',     '910123456'),
  ('Miguel',   'Rocha',       'miguel.rocha@gmail.com',      '930123456'),
  ('Rui',      'Carvalho',    'rui.carvalho@hotmail.com',    '931112233'),
  ('Sofia',    'Gomes',       'sofia.gomes@gmail.com',       '932223344'),
  ('Tiago',    'Fonseca',     'tiago.fonseca@outlook.com',   '933334455'),
  ('Mariana',  'Pinto',       'mariana.pinto@gmail.com',     '934445566'),
  ('André',    'Morais',      'andre.morais@yahoo.com',      '935556677'),
  ('Beatriz',  'Correia',     'beatriz.correia@gmail.com',   '936667788'),
  ('Hugo',     'Figueiredo',  'hugo.figueiredo@outlook.com', '937778899'),
  ('Rita',     'Moura',       'rita.moura@gmail.com',        '938889900'),
  ('Pedro',    'Nogueira',    'pedro.nogueira@hotmail.com',  '939990011'),
  ('Cláudia',  'Barros',      'claudia.barros@gmail.com',    '961234567'),
  ('Ricardo',  'Esteves',     'ricardo.esteves@outlook.com', '962345678'),
  ('Vera',     'Machado',     'vera.machado@gmail.com',      '963456789'),
  ('Nuno',     'Cardoso',     'nuno.cardoso@hotmail.com',    '964567890'),
  ('Patrícia', 'Sousa',       'patricia.sousa@gmail.com',    '965678901'),
  ('Carlos',   'Henriques',   'carlos.henriques@outlook.com','966789012'),
  ('Helena',   'Reis',        'helena.reis@gmail.com',       '967890123'),
  ('Diogo',    'Tavares',     'diogo.tavares@sapo.pt',       '968901234'),
  ('Joana',    'Borges',      'joana.borges@gmail.com',      '969012345'),
  ('Artur',    'Medeiros',    'artur.medeiros@outlook.com',  '921234567'),
  ('Susana',   'Alves',       'susana.alves@gmail.com',      '922345678');

-- =========================
-- EMPLOYEES
-- =========================
INSERT INTO Employee (first_name, last_name, role, hire_date) VALUES
  ('Rita',  'Mendes',  'manager',    '2022-03-15'),
  ('Paulo', 'Nunes',   'sales',      '2023-01-10'),
  ('Sara',  'Almeida', 'sales',      '2023-06-01'),
  ('Tiago', 'Correia', 'technician', '2021-11-20'),
  ('Helena','Dias',    'cashier',    '2024-02-05');

-- =========================
-- SALARY HISTORY
-- =========================
INSERT INTO SalaryHistory (employee_id, effective_date, salary_amount) VALUES
  (1, '2023-01-01', 2500.00),
  (1, '2024-01-01', 2700.00),
  (2, '2023-01-15', 1200.00),
  (2, '2024-01-15', 1300.00),
  (3, '2023-06-01', 1200.00),
  (4, '2022-01-01', 1400.00),
  (5, '2024-02-05', 1100.00);

-- =========================
-- STOCK UNITS (3 per product → 54 units)
-- =========================
INSERT INTO StockUnit (product_id, acquired_date, `condition`, status) VALUES
  (1, '2024-01-10', 'new', 'IN_STOCK'),
  (1, '2024-02-05', 'new', 'IN_STOCK'),
  (1, '2024-03-01', 'new', 'IN_STOCK'),

  (2, '2024-01-15', 'new', 'IN_STOCK'),
  (2, '2024-02-20', 'new', 'IN_STOCK'),
  (2, '2024-03-10', 'new', 'IN_STOCK'),

  (3, '2024-01-18', 'new', 'IN_STOCK'),
  (3, '2024-02-22', 'new', 'IN_STOCK'),
  (3, '2024-03-15', 'new', 'IN_STOCK'),

  (4, '2024-01-12', 'new', 'IN_STOCK'),
  (4, '2024-02-08', 'new', 'IN_STOCK'),
  (4, '2024-03-05', 'new', 'IN_STOCK'),

  (5, '2024-01-20', 'new', 'IN_STOCK'),
  (5, '2024-02-18', 'new', 'IN_STOCK'),
  (5, '2024-03-12', 'new', 'IN_STOCK'),

  (6, '2024-01-25', 'new', 'IN_STOCK'),
  (6, '2024-02-25', 'new', 'IN_STOCK'),
  (6, '2024-03-18', 'new', 'IN_STOCK'),

  (7, '2024-01-14', 'new', 'IN_STOCK'),
  (7, '2024-02-10', 'new', 'IN_STOCK'),
  (7, '2024-03-08', 'new', 'IN_STOCK'),

  (8, '2024-01-28', 'new', 'IN_STOCK'),
  (8, '2024-02-26', 'new', 'IN_STOCK'),
  (8, '2024-03-20', 'new', 'IN_STOCK'),

  (9, '2024-01-30', 'new', 'IN_STOCK'),
  (9, '2024-02-15', 'new', 'IN_STOCK'),
  (9, '2024-03-22', 'new', 'IN_STOCK'),

  (10, '2024-01-11', 'new', 'IN_STOCK'),
  (10, '2024-02-03', 'new', 'IN_STOCK'),
  (10, '2024-03-02', 'new', 'IN_STOCK'),

  (11, '2024-01-17', 'new', 'IN_STOCK'),
  (11, '2024-02-14', 'new', 'IN_STOCK'),
  (11, '2024-03-11', 'new', 'IN_STOCK'),

  (12, '2024-01-22', 'new', 'IN_STOCK'),
  (12, '2024-02-21', 'new', 'IN_STOCK'),
  (12, '2024-03-17', 'new', 'IN_STOCK'),

  (13, '2024-01-09', 'new', 'IN_STOCK'),
  (13, '2024-02-06', 'new', 'IN_STOCK'),
  (13, '2024-03-04', 'new', 'IN_STOCK'),

  (14, '2024-01-08', 'new', 'IN_STOCK'),
  (14, '2024-02-01', 'new', 'IN_STOCK'),
  (14, '2024-03-06', 'new', 'IN_STOCK'),

  (15, '2024-01-19', 'new', 'IN_STOCK'),
  (15, '2024-02-17', 'new', 'IN_STOCK'),
  (15, '2024-03-14', 'new', 'IN_STOCK'),

  (16, '2024-01-16', 'new', 'IN_STOCK'),
  (16, '2024-02-09', 'new', 'IN_STOCK'),
  (16, '2024-03-09', 'new', 'IN_STOCK'),

  (17, '2024-01-24', 'new', 'IN_STOCK'),
  (17, '2024-02-19', 'new', 'IN_STOCK'),
  (17, '2024-03-19', 'new', 'IN_STOCK'),

  (18, '2024-01-27', 'new', 'IN_STOCK'),
  (18, '2024-02-23', 'new', 'IN_STOCK'),
  (18, '2024-03-21', 'new', 'IN_STOCK');

-- =========================
-- ORDERHEADER (50 orders, all customer_id <= 30)
-- =========================
INSERT INTO OrderHeader (customer_id, employee_id, order_date, total_amount) VALUES
  ( 1, 1, '2024-04-05', 9500.00),
  ( 2, 2, '2024-04-10', 9500.00),
  ( 3, 3, '2024-04-15', 9500.00),

  ( 4, 4, '2024-05-02', 7800.00),
  ( 5, 5, '2024-05-08', 7800.00),
  ( 6, 1, '2024-05-20', 7800.00),

  ( 7, 2, '2024-06-03', 7200.00),
  ( 8, 3, '2024-06-10', 7200.00),
  ( 9, 4, '2024-06-18', 7200.00),

  (10, 5, '2024-07-01', 6500.00),
  (11, 1, '2024-07-12', 6500.00),
  (12, 2, '2024-07-25', 6500.00),

  (13, 3, '2024-08-05', 5200.00),
  (14, 4, '2024-08-15', 5200.00),
  (15, 5, '2024-08-28', 5200.00),

  (16, 1, '2024-09-04', 6000.00),
  (17, 2, '2024-09-12', 6000.00),
  (18, 3, '2024-09-27', 6000.00),

  (19, 4, '2024-10-03', 3200.00),
  (20, 5, '2024-10-14', 3200.00),
  (21, 1, '2024-10-29', 3200.00),

  (22, 2, '2024-11-05', 4500.00),
  (23, 3, '2024-11-16', 4500.00),
  (24, 4, '2024-11-28', 4500.00),

  (25, 5, '2024-12-09', 2800.00),
  (26, 1, '2025-01-07', 2800.00),
  (27, 2, '2025-01-18', 2800.00),

  (28, 3, '2025-02-03',  550.00),
  (29, 4, '2025-02-14',  550.00),
  (30, 5, '2025-02-26',  550.00),

  (16, 1, '2025-03-05',  300.00),
  (17, 2, '2025-03-19',  300.00),
  (18, 3, '2025-04-02',  300.00),

  (19, 4, '2025-04-17',  650.00),
  (20, 5, '2025-05-06',  650.00),
  (21, 1, '2025-05-21',  650.00),

  (22, 2, '2025-06-04',  150.00),
  (23, 3, '2025-06-18',  150.00),
  (24, 4, '2025-07-03',  150.00),

  (25, 5, '2025-07-19',   25.00),
  (26, 1, '2025-08-01',   25.00),
  (27, 2, '2025-08-20',   25.00),

  (28, 3, '2025-09-05',  180.00),
  (29, 4, '2025-09-17',  180.00),
  (30, 5, '2025-10-01',  180.00),

  ( 1, 1, '2025-10-15',  750.00),
  ( 2, 2, '2025-11-03',  750.00),
  ( 3, 3, '2025-11-14',  750.00),

  ( 4, 4, '2025-11-25',  800.00),
  ( 5, 5, '2025-12-05',  800.00);

-- =========================
-- ORDERITEM (1 line per order, matches products + stock units)
-- =========================
INSERT INTO OrderItem (order_id, product_id, stock_unit_id, quantity, unit_price) VALUES
  ( 1,  1,  1, 1, 9500.00),
  ( 2,  1,  2, 1, 9500.00),
  ( 3,  1,  3, 1, 9500.00),

  ( 4,  2,  4, 1, 7800.00),
  ( 5,  2,  5, 1, 7800.00),
  ( 6,  2,  6, 1, 7800.00),

  ( 7,  3,  7, 1, 7200.00),
  ( 8,  3,  8, 1, 7200.00),
  ( 9,  3,  9, 1, 7200.00),

  (10,  4, 10, 1, 6500.00),
  (11,  4, 11, 1, 6500.00),
  (12,  4, 12, 1, 6500.00),

  (13,  5, 13, 1, 5200.00),
  (14,  5, 14, 1, 5200.00),
  (15,  5, 15, 1, 5200.00),

  (16,  6, 16, 1, 6000.00),
  (17,  6, 17, 1, 6000.00),
  (18,  6, 18, 1, 6000.00),

  (19,  7, 19, 1, 3200.00),
  (20,  7, 20, 1, 3200.00),
  (21,  7, 21, 1, 3200.00),

  (22,  8, 22, 1, 4500.00),
  (23,  8, 23, 1, 4500.00),
  (24,  8, 24, 1, 4500.00),

  (25,  9, 25, 1, 2800.00),
  (26,  9, 26, 1, 2800.00),
  (27,  9, 27, 1, 2800.00),

  (28, 10, 28, 1,  550.00),
  (29, 10, 29, 1,  550.00),
  (30, 10, 30, 1,  550.00),

  (31, 11, 31, 1,  300.00),
  (32, 11, 32, 1,  300.00),
  (33, 11, 33, 1,  300.00),

  (34, 12, 34, 1,  650.00),
  (35, 12, 35, 1,  650.00),
  (36, 12, 36, 1,  650.00),

  (37, 13, 37, 1,  150.00),
  (38, 13, 38, 1,  150.00),
  (39, 13, 39, 1,  150.00),

  (40, 14, 40, 1,   25.00),
  (41, 14, 41, 1,   25.00),
  (42, 14, 42, 1,   25.00),

  (43, 15, 43, 1,  180.00),
  (44, 15, 44, 1,  180.00),
  (45, 15, 45, 1,  180.00),

  (46, 16, 46, 1,  750.00),
  (47, 16, 47, 1,  750.00),
  (48, 16, 48, 1,  750.00),

  (49, 17, 49, 1,  800.00),
  (50, 17, 50, 1,  800.00);

-- =========================
-- REVIEWS
-- =========================
INSERT INTO Review (customer_id, product_id, rating, review_text) VALUES
  (1, 1, 5, 'Amazing watch, worth the price.'),
  (2, 3, 4, 'Great chronograph, but a bit heavy.'),
  (3, 8, 5, 'Perfect everyday watch.'),
  (4, 9, 4, 'Cheap and reliable.'),
  (5, 2, 5, 'Beautiful and versatile.'),
  (6, 4, 3, 'Good watch but too big for my wrist.');
  
  
-- Some orders with 5% discount
UPDATE OrderItem
SET discount_percent = 5.00
WHERE order_id IN (1, 10, 25);

-- Some orders with 10% discount
UPDATE OrderItem
SET discount_percent = 10.00
WHERE order_id IN (2, 11);


-- =========================
-- RECOMPUTE TOTALS (With Item-Level Discounts)
-- =========================
UPDATE OrderHeader oh
JOIN (
  SELECT 
    order_id, 
    -- Calculate discount for each item individually, then sum them up
    SUM(quantity * unit_price * (1 - IFNULL(discount_percent, 0) / 100.0)) AS final_total
  FROM OrderItem
  GROUP BY order_id
) t ON oh.order_id = t.order_id
SET oh.total_amount = t.final_total;

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

USE watchout;

-- =================================================================
-- VIEW 1: INVOICE HEADER (Financial Summary)
-- =================================================================
CREATE OR REPLACE VIEW v_invoice_header AS
SELECT 
    oh.order_id AS 'Invoice_ID',
    oh.order_date AS 'Date',
    
    -- Customer Info (Adicionei aqui o email e o telemóvel)
    CONCAT(c.first_name, ' ', c.last_name) AS 'Customer',
    c.email AS 'Customer_Email',
    c.phone AS 'Customer_Phone',
    c.loyalty_tier AS 'Tier',

    -- Salesperson Info
    IFNULL(CONCAT(e.first_name, ' ', e.last_name), 'Online/Kiosk') AS 'Salesperson',

    -- 1. TOTAL SAVED (Discounts)
    ROUND(
        (SUM(oi.quantity * oi.unit_price) - SUM(oi.quantity * oi.unit_price * (1 - oi.discount_percent / 100.0))), 
        2
    ) AS 'Total_Saved',

    -- 2. TAX BASE (Value without VAT)
    ROUND(
        oh.total_amount / 1.23, 
        2
    ) AS 'Subtotal_no_IVA',

    -- 3. VAT AMOUNT (The tax itself)
    ROUND(
        oh.total_amount - (oh.total_amount / 1.23), 
        2
    ) AS 'IVA_23',

    -- 4. TOTAL PAID (Final value with VAT included)
    oh.total_amount AS 'Total_Paid'

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
    
    -- New Product Details
    p.description AS 'Description',
    p.movement_type AS 'Movement',
    p.gender AS 'Gender',
    
    -- Price Info
    oi.unit_price AS 'Original_Price',
    
    -- Discount Info
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