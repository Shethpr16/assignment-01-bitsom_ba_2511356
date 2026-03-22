/* ================================================
   DW Analytical Queries
   ================================================ */

-- Q1: Total sales revenue by product category for each month
-- Definition: revenue = SUM(sales_amount)
-- Output columns: year, month, category, revenue
SELECT
    dd.year,
    dd.month,
    dp.category,
    SUM(fs.sales_amount) AS revenue
FROM fact_sales    fs
JOIN dim_date      dd ON fs.date_key   = dd.date_key
JOIN dim_product   dp ON fs.product_key = dp.product_key
GROUP BY dd.year, dd.month, dp.category
ORDER BY dd.year, dd.month, dp.category;


-- Q2: Top 2 performing stores by total revenue
-- If you want ties handled deterministically, add store_name to ORDER BY.
WITH revenue_by_store AS (
    SELECT
        ds.store_key,
        ds.store_name,
        ds.store_city,
        SUM(fs.sales_amount) AS revenue
    FROM fact_sales fs
    JOIN dim_store ds ON fs.store_key = ds.store_key
    GROUP BY ds.store_key, ds.store_name, ds.store_city
)
SELECT
    store_name,
    store_city,
    revenue
FROM revenue_by_store
ORDER BY revenue DESC, store_name
LIMIT 2;


-- Q3: Month-over-month (MoM) sales trend across all stores
-- Shows revenue per month and the MoM delta.
WITH monthly AS (
    SELECT
        dd.year,
        dd.month,
        SUM(fs.sales_amount) AS revenue
    FROM fact_sales fs
    JOIN dim_date dd ON fs.date_key = dd.date_key
    GROUP BY dd.year, dd.month
),
monthly_with_prev AS (
    SELECT
        year,
        month,
        revenue,
        LAG(revenue) OVER (ORDER BY year, month) AS prev_revenue
    FROM monthly
)
SELECT
    year,
    month,
    revenue,
    (revenue - prev_revenue) AS mom_change,
    CASE
        WHEN prev_revenue IS NULL THEN NULL
        WHEN prev_revenue = 0 THEN NULL
        ELSE ROUND(100.0 * (revenue - prev_revenue) / prev_revenue, 2)
    END AS mom_change_pct
FROM monthly_with_prev
ORDER BY year, month;
