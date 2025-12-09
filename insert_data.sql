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

-- =========================
-- OPTIONAL: recompute totals just to be safe
-- =========================
UPDATE OrderHeader oh
JOIN (
  SELECT order_id, SUM(quantity * unit_price) AS total
  FROM OrderItem
  GROUP BY order_id
) t ON oh.order_id = t.order_id
SET oh.total_amount = t.total;

-- =========================
-- UPDATE LOYALTY STATUS 
-- =========================
-- We recalculate statuses based on the orders we just inserted 
-- to ensure data consistency (Single Source of Truth).
UPDATE Customer c
JOIN (
    SELECT customer_id, SUM(total_amount) as total_spent
    FROM OrderHeader
    GROUP BY customer_id
) sales ON c.customer_id = sales.customer_id
SET c.loyalty_tier = 
    CASE 
        WHEN sales.total_spent >= 20000 THEN 'Platinum'
        WHEN sales.total_spent >= 10000 THEN 'Gold'
        ELSE 'Standard'
    END;
