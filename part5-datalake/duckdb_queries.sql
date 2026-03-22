/* ============================================================
   Part 5 — DuckDB Cross-Format Queries (reads raw files only)
   Files:
     - datasets/customers.csv        (flat CSV; known header)      <-- customer_id,name,city,…  (from your upload)
     - datasets/orders.json          (JSON; may be flat or nested items[])
     - datasets/products.parquet     (Parquet; product attributes)
   ============================================================ */

/* ---------- Common CTEs: read files directly ---------- */

WITH
customers AS (
  SELECT *
  FROM read_csv_auto('datasets/customers.csv', HEADER := TRUE)
  -- Expected columns from your CSV: customer_id, name, city, signup_date, email  (verified from your file)
  -- If your path differs, adjust the relative path accordingly.
),

orders_raw AS (
  SELECT *
  FROM read_json_auto('datasets/orders.json')
  -- If orders.json is deeply nested (e.g., items array), see the orders_flat CTE below (OPTION B).
),

products AS (
  SELECT *
  FROM parquet_scan('datasets/products.parquet')
  -- Expected to contain product_id, product_name, category, unit_price (adjust names if needed).
),

/* ---------- Normalize orders.json to a line-item grain ----------

   OPTION A (flat): orders.json already has one row per line item with product_id, quantity, unit_price
   Uncomment this block if your JSON is FLAT.

orders_flat AS (
  SELECT
    CAST(order_id   AS VARCHAR)            AS order_id,
    CAST(order_date AS DATE)               AS order_date,
    CAST(customer_id AS VARCHAR)           AS customer_id,
    CAST(product_id  AS VARCHAR)           AS product_id,
    CAST(quantity    AS INT)               AS quantity,
    CAST(unit_price  AS DOUBLE)            AS unit_price
  FROM orders_raw
  WHERE product_id IS NOT NULL
),
*/

/*   OPTION B (nested): orders.json has an items[] array with objects {product_id, quantity, unit_price}
     Keep this block uncommented if your JSON is NESTED.
*/
orders_flat AS (
  SELECT
    CAST(o.order_id    AS VARCHAR)         AS order_id,
    CAST(o.order_date  AS DATE)            AS order_date,
    CAST(o.customer_id AS VARCHAR)         AS customer_id,
    CAST(i.product_id  AS VARCHAR)         AS product_id,
    CAST(i.quantity    AS INT)             AS quantity,
    CAST(i.unit_price  AS DOUBLE)          AS unit_price
  FROM orders_raw o,
  UNNEST(o.items) AS i
),

/* ---------- (Optional) Conform product names/categories if needed ----------
prod_clean AS (
  SELECT
    CAST(product_id AS VARCHAR) AS product_id,
    product_name,
    INITCAP(TRIM(category))     AS category,
    unit_price
  FROM products
)
*/

/* ============================================================
   Q1: List all customers along with the total number of orders
   - Count DISTINCT order_id per customer
   - Include customers with zero orders (LEFT JOIN)
   ============================================================ */
SELECT
  c.customer_id,
  c.name            AS customer_name,
  c.city,
  COUNT(DISTINCT o.order_id) AS total_orders
FROM customers c
LEFT JOIN orders_flat o
  ON o.customer_id = c.customer_id
GROUP BY c.customer_id, c.name, c.city
ORDER BY total_orders DESC, customer_name;

/* ============================================================
   Q2: Top 3 customers by total order value
   - order_value = SUM(quantity * unit_price)
   ============================================================ */
WITH spend AS (
  SELECT
    o.customer_id,
    SUM(o.quantity * o.unit_price) AS total_value
  FROM orders_flat o
  GROUP BY o.customer_id
)
SELECT
  c.customer_id,
  c.name  AS customer_name,
  c.city,
  ROUND(s.total_value, 2) AS total_order_value
FROM spend s
JOIN customers c ON c.customer_id = s.customer_id
ORDER BY total_order_value DESC, customer_name
LIMIT 3;

/* ============================================================
   Q3: List all products purchased by customers from Bangalore
   - Distinct product names for customers where city = 'Bangalore'
   ============================================================ */
SELECT DISTINCT
  p.product_name
FROM customers c
JOIN orders_flat o  ON o.customer_id = c.customer_id
JOIN products   p   ON p.product_id  = o.product_id
WHERE LOWER(TRIM(c.city)) = 'bangalore'
ORDER BY p.product_name;

/* ============================================================
   Q4: Join all three files to show:
       customer name, order date, product name, quantity
   ============================================================ */
SELECT
  c.name       AS customer_name,
  o.order_date,
  p.product_name,
  o.quantity
FROM customers c
JOIN orders_flat o  ON o.customer_id = c.customer_id
JOIN products   p   ON p.product_id  = o.product_id
ORDER BY o.order_date, customer_name, p.product_name;
