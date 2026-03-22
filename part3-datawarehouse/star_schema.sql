/* ===========================================================
   STAR SCHEMA for Retail Transactions → Business Intelligence
   Dimensions: dim_date, dim_store, dim_product
   Fact:       fact_sales (measures: units_sold, unit_price, sales_amount)
   Notes on standardization:
     - Dates normalized to ISO (YYYY-MM-DD)
     - Category values conformed to: Electronics | Clothing | Grocery
     - Only transactions with non-blank store_city are loaded
   Source examples used (cleaned): TXN5002, 5012, 5011, 5031, 5036, 5041,
                                   5055, 5060, 5061, 5072, 5074, 5081, 5102
   =========================================================== */

-- (Optional) create schema
-- CREATE SCHEMA dw;
-- SET search_path TO dw;

-- =========================
-- Dimension: Date
-- =========================
-- Use integer surrogate key formatted as YYYYMMDD for fast joins/partitioning.
DROP TABLE IF EXISTS fact_sales CASCADE;
DROP TABLE IF EXISTS dim_product CASCADE;
DROP TABLE IF EXISTS dim_store CASCADE;
DROP TABLE IF EXISTS dim_date CASCADE;

CREATE TABLE dim_date (
    date_key   INT PRIMARY KEY,        -- e.g., 20230521
    full_date  DATE NOT NULL,          -- 2023-05-21
    year       INT  NOT NULL,
    month      INT  NOT NULL,          -- 1-12
    day        INT  NOT NULL           -- 1-31
    -- You can add: month_name, weekday_name, quarter, etc.
);

-- =========================
-- Dimension: Store
-- =========================
CREATE TABLE dim_store (
    store_key   SERIAL PRIMARY KEY,
    store_name  VARCHAR(100) NOT NULL,
    store_city  VARCHAR(100) NOT NULL,
    -- Optional: state, region, country
    UNIQUE (store_name, store_city)
);

-- =========================
-- Dimension: Product
-- =========================
CREATE TABLE dim_product (
    product_key   SERIAL PRIMARY KEY,
    product_name  VARCHAR(100) NOT NULL,
    category      VARCHAR(50)  NOT NULL CHECK (category IN ('Electronics','Clothing','Grocery')),
    -- Optional: brand, size, etc.
    UNIQUE (product_name, category)
);

-- =========================
-- Fact: Sales
-- =========================
-- Grain: one row per transaction line (transaction_id × product)
-- Measures: units_sold, unit_price, sales_amount
CREATE TABLE fact_sales (
    fact_id        SERIAL PRIMARY KEY,
    date_key       INT         NOT NULL REFERENCES dim_date(date_key),
    store_key      INT         NOT NULL REFERENCES dim_store(store_key),
    product_key    INT         NOT NULL REFERENCES dim_product(product_key),
    transaction_id VARCHAR(20) NOT NULL,
    units_sold     INT         NOT NULL CHECK (units_sold >= 0),
    unit_price     DECIMAL(12,2) NOT NULL CHECK (unit_price >= 0),
    sales_amount   DECIMAL(14,2) NOT NULL,  -- units_sold * unit_price
    UNIQUE (transaction_id, product_key)    -- avoid double loading the same line
);

-- ===========================================================
-- Load conformed dimensions (derived from selected transactions)
-- ===========================================================

-- --------
-- dim_date
-- --------
INSERT INTO dim_date (date_key, full_date, year, month, day) VALUES
(20230102, '2023-01-02', 2023, 1,  2),
(20230110, '2023-01-10', 2023, 1, 10),
(20230205, '2023-02-05', 2023, 2,  5),
(20230520, '2023-05-20', 2023, 5, 20),
(20230521, '2023-05-21', 2023, 5, 21),
(20230527, '2023-05-27', 2023, 5, 27),
(20230604, '2023-06-04', 2023, 6,  4),
(20230820, '2023-08-20', 2023, 8, 20),
(20230829, '2023-08-29', 2023, 8, 29),
(20231014, '2023-10-14', 2023,10, 14),
(20231020, '2023-10-20', 2023,10, 20),
(20231130, '2023-11-30', 2023,11, 30);

-- --------
-- dim_store
-- --------
INSERT INTO dim_store (store_name, store_city) VALUES
('Chennai Anna',   'Chennai'),
('Bangalore MG',   'Bangalore'),
('Mumbai Central', 'Mumbai'),
('Pune FC Road',   'Pune'),
('Delhi South',    'Delhi');

-- --------
-- dim_product
-- --------
-- Categories standardized to title case: Electronics, Clothing, Grocery
INSERT INTO dim_product (product_name, category) VALUES
('Phone',     'Electronics'),
('Laptop',    'Electronics'),
('Jeans',     'Clothing'),
('Speaker',   'Electronics'),
('T-Shirt',   'Clothing'),
('Biscuits',  'Grocery'),
('Tablet',    'Electronics');

-- ===========================================================
-- Map natural keys to surrogate keys for facts
-- (In many RDBMS you could do this with CTEs + joins. Here we do it
--  in two steps for clarity: get the keys, then insert facts.)
-- ===========================================================

-- Store surrogate keys
WITH s AS (
  SELECT store_key, store_name, store_city FROM dim_store
),
p AS (
  SELECT product_key, product_name, category FROM dim_product
),
d AS (
  SELECT date_key, full_date FROM dim_date
)
-- Sample facts (>=10 rows) from the cleaned source rows noted above:
INSERT INTO fact_sales
(date_key, store_key, product_key, transaction_id, units_sold, unit_price, sales_amount)
VALUES
-- TXN5031: 02/01/2023 → 2023-01-02 | Bangalore MG, Bangalore | Speaker | electronics→Electronics | 20 × 49262.78
((SELECT date_key FROM d WHERE full_date='2023-01-02'),
 (SELECT store_key FROM s WHERE store_name='Bangalore MG' AND store_city='Bangalore'),
 (SELECT product_key FROM p WHERE product_name='Speaker' AND category='Electronics'),
 'TXN5031', 20, 49262.78, 20*49262.78),

-- TXN5061: 10/01/2023 → 2023-01-10 | Chennai Anna, Chennai | Phone | 14 × 48703.39
((SELECT date_key FROM d WHERE full_date='2023-01-10'),
 (SELECT store_key FROM s WHERE store_name='Chennai Anna' AND store_city='Chennai'),
 (SELECT product_key FROM p WHERE product_name='Phone' AND category='Electronics'),
 'TXN5061', 14, 48703.39, 14*48703.39),

-- TXN5002: 2023-02-05 | Chennai Anna, Chennai | Phone | 20 × 48703.39
((SELECT date_key FROM d WHERE full_date='2023-02-05'),
 (SELECT store_key FROM s WHERE store_name='Chennai Anna' AND store_city='Chennai'),
 (SELECT product_key FROM p WHERE product_name='Phone' AND category='Electronics'),
 'TXN5002', 20, 48703.39, 20*48703.39),

-- TXN5055: 2023-05-20 | Pune FC Road, Pune | Biscuits | Groceries→Grocery | 14 × 27469.99
((SELECT date_key FROM d WHERE full_date='2023-05-20'),
 (SELECT store_key FROM s WHERE store_name='Pune FC Road' AND store_city='Pune'),
 (SELECT product_key FROM p WHERE product_name='Biscuits' AND category='Grocery'),
 'TXN5055', 14, 27469.99, 14*27469.99),

-- TXN5012: 2023-05-21 | Bangalore MG, Bangalore | Laptop | 13 × 42343.15
((SELECT date_key FROM d WHERE full_date='2023-05-21'),
 (SELECT store_key FROM s WHERE store_name='Bangalore MG' AND store_city='Bangalore'),
 (SELECT product_key FROM p WHERE product_name='Laptop' AND category='Electronics'),
 'TXN5012', 13, 42343.15, 13*42343.15),

-- TXN5072: 2023-05-27 | Mumbai Central, Mumbai | Phone | 12 × 48703.39
((SELECT date_key FROM d WHERE full_date='2023-05-27'),
 (SELECT store_key FROM s WHERE store_name='Mumbai Central' AND store_city='Mumbai'),
 (SELECT product_key FROM p WHERE product_name='Phone' AND category='Electronics'),
 'TXN5072', 12, 48703.39, 12*48703.39),

-- TXN5036: 2023-06-04 | Pune FC Road, Pune | Phone | 17 × 48703.39
((SELECT date_key FROM d WHERE full_date='2023-06-04'),
 (SELECT store_key FROM s WHERE store_name='Pune FC Road' AND store_city='Pune'),
 (SELECT product_key FROM p WHERE product_name='Phone' AND category='Electronics'),
 'TXN5036', 17, 48703.39, 17*48703.39),

-- TXN5041: 2023-08-20 | Pune FC Road, Pune | T-Shirt | Clothing | 14 × 29770.19
((SELECT date_key FROM d WHERE full_date='2023-08-20'),
 (SELECT store_key FROM s WHERE store_name='Pune FC Road' AND store_city='Pune'),
 (SELECT product_key FROM p WHERE product_name='T-Shirt' AND category='Clothing'),
 'TXN5041', 14, 29770.19, 14*29770.19),

-- TXN5102: 2023-08-29 | Mumbai Central, Mumbai | Laptop | 13 × 42343.15
((SELECT date_key FROM d WHERE full_date='2023-08-29'),
 (SELECT store_key FROM s WHERE store_name='Mumbai Central' AND store_city='Mumbai'),
 (SELECT product_key FROM p WHERE product_name='Laptop' AND category='Electronics'),
 'TXN5102', 13, 42343.15, 13*42343.15),

-- TXN5060: 14-10-2023 → 2023-10-14 | Chennai Anna, Chennai | Jeans | 17 × 2317.47
((SELECT date_key FROM d WHERE full_date='2023-10-14'),
 (SELECT store_key FROM s WHERE store_name='Chennai Anna' AND store_city='Chennai'),
 (SELECT product_key FROM p WHERE product_name='Jeans' AND category='Clothing'),
 'TXN5060', 17, 2317.47, 17*2317.47),

-- TXN5081: 14/10/2023 → 2023-10-14 | Delhi South, Delhi | Tablet | 10 × 23226.12
((SELECT date_key FROM d WHERE full_date='2023-10-14'),
 (SELECT store_key FROM s WHERE store_name='Delhi South' AND store_city='Delhi'),
 (SELECT product_key FROM p WHERE product_name='Tablet' AND category='Electronics'),
 'TXN5081', 10, 23226.12, 10*23226.12),

-- TXN5011: 20/10/2023 → 2023-10-20 | Mumbai Central, Mumbai | Jeans | 13 × 2317.47
((SELECT date_key FROM d WHERE full_date='2023-10-20'),
 (SELECT store_key FROM s WHERE store_name='Mumbai Central' AND store_city='Mumbai'),
 (SELECT product_key FROM p WHERE product_name='Jeans' AND category='Clothing'),
 'TXN5011', 13, 2317.47, 13*2317.47),

-- TXN5074: 2023-11-30 | Mumbai Central, Mumbai | Biscuits | Groceries→Grocery | 19 × 27469.99
((SELECT date_key FROM d WHERE full_date='2023-11-30'),
 (SELECT store_key FROM s WHERE store_name='Mumbai Central' AND store_city='Mumbai'),
 (SELECT product_key FROM p WHERE product_name='Biscuits' AND category='Grocery'),
 'TXN5074', 19, 27469.99, 19*27469.99);
