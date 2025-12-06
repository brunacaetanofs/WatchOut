-- Start fresh: drop and recreate the database
DROP DATABASE IF EXISTS watchout;
CREATE DATABASE watchout;
USE watchout;

-- =========================
-- TABLE 1: Customer
-- =========================
CREATE TABLE Customer (
    customer_id     INT AUTO_INCREMENT PRIMARY KEY,
    first_name      VARCHAR(50) NOT NULL,
    last_name       VARCHAR(50) NOT NULL,
    email           VARCHAR(120) UNIQUE NOT NULL,
    phone           VARCHAR(20),
    created_at      DATETIME DEFAULT CURRENT_TIMESTAMP
);

-- =========================
-- TABLE 2: Brand
-- =========================
CREATE TABLE Brand (
    brand_id    INT AUTO_INCREMENT PRIMARY KEY,
    brand_name  VARCHAR(100) NOT NULL
);

-- =========================
-- TABLE 3: Product
-- =========================
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

-- =========================
-- TABLE 4: StockUnit
-- =========================
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

-- =========================
-- TABLE 5: Employee
-- =========================
CREATE TABLE Employee (
    employee_id     INT AUTO_INCREMENT PRIMARY KEY,
    first_name      VARCHAR(50) NOT NULL,
    last_name       VARCHAR(50) NOT NULL,
    role            ENUM('sales','manager','technician','cashier') NOT NULL,
    hire_date       DATE
);

-- =========================
-- TABLE 6: OrderHeader
-- =========================
CREATE TABLE OrderHeader (
    order_id        INT AUTO_INCREMENT PRIMARY KEY,
    customer_id     INT NOT NULL,
    employee_id     INT NULL,         -- who processed the order
    order_date      DATE NOT NULL,
    total_amount    DECIMAL(12,2),

    CONSTRAINT fk_orderheader_customer
        FOREIGN KEY (customer_id) REFERENCES Customer(customer_id)
        ON UPDATE CASCADE ON DELETE RESTRICT,

    CONSTRAINT fk_orderheader_employee
        FOREIGN KEY (employee_id) REFERENCES Employee(employee_id)
        ON UPDATE CASCADE ON DELETE SET NULL
);

-- =========================
-- TABLE 7: OrderItem
-- =========================
CREATE TABLE OrderItem (
    order_item_id   INT AUTO_INCREMENT PRIMARY KEY,
    order_id        INT NOT NULL,
    product_id      INT NOT NULL,
    stock_unit_id   INT NULL,
    quantity        INT NOT NULL CHECK (quantity > 0),
    unit_price      DECIMAL(10,2) NOT NULL,

    CONSTRAINT fk_orderitem_order
        FOREIGN KEY (order_id) REFERENCES OrderHeader(order_id)
        ON UPDATE CASCADE ON DELETE CASCADE,

    CONSTRAINT fk_orderitem_product
        FOREIGN KEY (product_id) REFERENCES Product(product_id)
        ON UPDATE CASCADE ON DELETE RESTRICT,

    CONSTRAINT fk_orderitem_stockunit
        FOREIGN KEY (stock_unit_id) REFERENCES StockUnit(stock_unit_id)
        ON UPDATE CASCADE ON DELETE SET NULL
);

-- =========================
-- TABLE 8: Review
-- =========================
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

-- =========================
-- TABLE 9: LogPrice (log table for triggers)
-- =========================
CREATE TABLE LogPrice (
    log_id      INT AUTO_INCREMENT PRIMARY KEY,
    operation   VARCHAR(50),
    table_name  VARCHAR(50),
    message     TEXT,
    created_at  DATETIME DEFAULT CURRENT_TIMESTAMP
);

-- =========================
-- TABLE 10: SalaryHistory
-- =========================
CREATE TABLE SalaryHistory (
    salary_id       INT AUTO_INCREMENT PRIMARY KEY,
    employee_id     INT NOT NULL,
    effective_date  DATE NOT NULL,
    salary_amount   DECIMAL(10,2) NOT NULL,

    CONSTRAINT fk_salaryhistory_employee
        FOREIGN KEY (employee_id) REFERENCES Employee(employee_id)
        ON UPDATE CASCADE ON DELETE CASCADE
);
