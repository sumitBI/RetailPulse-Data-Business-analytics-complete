-- RetailPulse | Retail sales analysis
-- Run this file in PostgreSQL after creating the database.
-- The CSV import commands below are meant for psql, not pgAdmin's Query Tool.

-- 1. Create the lookup tables first. The sales table uses their keys.

CREATE TABLE dim_date (
    datekey       INTEGER PRIMARY KEY,
    date          DATE NOT NULL UNIQUE,
    year          SMALLINT NOT NULL,
    quarter       VARCHAR(2) NOT NULL,
    monthnumber   SMALLINT NOT NULL,
    monthname     VARCHAR(12) NOT NULL,
    monthyear     VARCHAR(12) NOT NULL,
    yearmonth     CHAR(7) NOT NULL,
    weeknumber    SMALLINT NOT NULL,
    dayname       VARCHAR(12) NOT NULL,
    isweekend     BOOLEAN NOT NULL
);

CREATE TABLE dim_product (
    productkey   VARCHAR(10) PRIMARY KEY,
    productname  VARCHAR(100) NOT NULL,
    category     VARCHAR(40) NOT NULL,
    producttier  VARCHAR(20) NOT NULL,
    listprice    NUMERIC(12, 2) NOT NULL,
    unitcost     NUMERIC(12, 2) NOT NULL
);

CREATE TABLE dim_customer (
    customerkey   VARCHAR(10) PRIMARY KEY,
    customername  VARCHAR(100) NOT NULL,
    segment       VARCHAR(30) NOT NULL,
    city          VARCHAR(50) NOT NULL,
    region        VARCHAR(20) NOT NULL,
    customersince DATE
);

CREATE TABLE dim_store (
    storekey       VARCHAR(10) PRIMARY KEY,
    storename      VARCHAR(100) NOT NULL,
    city           VARCHAR(50) NOT NULL,
    region         VARCHAR(20) NOT NULL,
    salesterritory VARCHAR(30) NOT NULL
);

-- One row in fact_sales represents one product line in an order.
-- An OrderID can therefore appear more than once.

CREATE TABLE fact_sales (
    saleslinekey  VARCHAR(20) PRIMARY KEY,
    orderid       VARCHAR(20) NOT NULL,
    datekey       INTEGER NOT NULL REFERENCES dim_date(datekey),
    customerkey   VARCHAR(10) NOT NULL REFERENCES dim_customer(customerkey),
    productkey    VARCHAR(10) NOT NULL REFERENCES dim_product(productkey),
    storekey      VARCHAR(10) NOT NULL REFERENCES dim_store(storekey),
    units         INTEGER NOT NULL CHECK (units > 0),
    unitprice     NUMERIC(12, 2) NOT NULL,
    discountpct   NUMERIC(6, 4) NOT NULL,
    grosssales    NUMERIC(14, 2) NOT NULL,
    discountamount NUMERIC(14, 2) NOT NULL,
    netsales      NUMERIC(14, 2) NOT NULL,
    costamount    NUMERIC(14, 2) NOT NULL,
    profit        NUMERIC(14, 2) NOT NULL,
    shippingdays  SMALLINT NOT NULL,
    shipmode      VARCHAR(20) NOT NULL,
    orderstatus   VARCHAR(20) NOT NULL,
    isreturned    SMALLINT NOT NULL,
    iscancelled   SMALLINT NOT NULL
);

-- 2. Import the CSV files from the project folder.
-- Open psql in the project root, then run these commands one by one.

-- \copy dim_date FROM 'Dataset/dim_date.csv' CSV HEADER
-- \copy dim_product FROM 'Dataset/dim_product.csv' CSV HEADER
-- \copy dim_customer FROM 'Dataset/dim_customer.csv' CSV HEADER
-- \copy dim_store FROM 'Dataset/dim_store.csv' CSV HEADER
-- \copy fact_sales FROM 'Dataset/fact_sales.csv' CSV HEADER

-- 3. Add indexes to columns used often in joins and filters.

CREATE INDEX idx_sales_date ON fact_sales(datekey);
CREATE INDEX idx_sales_customer ON fact_sales(customerkey);
CREATE INDEX idx_sales_product ON fact_sales(productkey);
CREATE INDEX idx_sales_store ON fact_sales(storekey);
CREATE INDEX idx_sales_order ON fact_sales(orderid);

-- 4. Quick checks before starting the analysis.

SELECT COUNT(*) AS sales_lines FROM fact_sales;
SELECT COUNT(DISTINCT orderid) AS total_orders FROM fact_sales;
SELECT COUNT(*) AS products FROM dim_product;
SELECT COUNT(*) AS customers FROM dim_customer;

-- BUSINESS QUESTIONS

-- 1.revenue and profit changing month by month
SELECT
    d.year,
    d.monthnumber,
    d.monthname,
    SUM(f.netsales) AS revenue,
    SUM(f.profit) AS profit,
    ROUND(100.0 * SUM(f.profit) / NULLIF(SUM(f.netsales), 0), 2) AS profit_margin_pct
FROM fact_sales AS f
JOIN dim_date AS d ON f.datekey = d.datekey
GROUP BY d.year, d.monthnumber, d.monthname
ORDER BY d.year, d.monthnumber;

-- 2. Which product categories bring in the most revenue?
SELECT
    p.category,
    SUM(f.netsales) AS revenue,
    SUM(f.profit) AS profit,
    SUM(f.units) AS units_sold
FROM fact_sales AS f
JOIN dim_product AS p ON f.productkey = p.productkey
GROUP BY p.category
ORDER BY revenue DESC;

-- 3. Which ten products have the highest sales?
SELECT
    p.productname,
    p.category,
    SUM(f.netsales) AS revenue,
    SUM(f.profit) AS profit
FROM fact_sales AS f
JOIN dim_product AS p ON f.productkey = p.productkey
GROUP BY p.productname, p.category
ORDER BY revenue DESC
LIMIT 10;

-- 4. Which customer segment contributes the most?
SELECT
    c.segment,
    COUNT(DISTINCT f.orderid) AS orders,
    COUNT(DISTINCT f.customerkey) AS customers,
    SUM(f.netsales) AS revenue,
    SUM(f.profit) AS profit
FROM fact_sales AS f
JOIN dim_customer AS c ON f.customerkey = c.customerkey
GROUP BY c.segment
ORDER BY revenue DESC;

-- 5. Compare store performance by region.
SELECT
    s.region,
    s.storename,
    COUNT(DISTINCT f.orderid) AS orders,
    SUM(f.netsales) AS revenue,
    SUM(f.profit) AS profit
FROM fact_sales AS f
JOIN dim_store AS s ON f.storekey = s.storekey
GROUP BY s.region, s.storename
ORDER BY revenue DESC;

-- 6. Check whether higher discounts are affecting profit.
SELECT
    CASE
        WHEN discountpct < 0.05 THEN '0-5%'
        WHEN discountpct < 0.15 THEN '5-15%'
        WHEN discountpct < 0.25 THEN '15-25%'
        ELSE '25%+'
    END AS discount_band,
    COUNT(*) AS sales_lines,
    SUM(netsales) AS revenue,
    SUM(profit) AS profit,
    ROUND(AVG(discountpct) * 100, 2) AS average_discount_pct
FROM fact_sales
GROUP BY 1
ORDER BY MIN(discountpct);

-- 7. Which categories have more returned or cancelled sales lines?
SELECT
    p.category,
    COUNT(*) AS sales_lines,
    SUM(f.isreturned) AS returned_lines,
    ROUND(100.0 * SUM(f.isreturned) / NULLIF(COUNT(*), 0), 2) AS return_rate_pct,
    SUM(f.iscancelled) AS cancelled_lines
FROM fact_sales AS f
JOIN dim_product AS p ON f.productkey = p.productkey
GROUP BY p.category
ORDER BY return_rate_pct DESC;

-- 8. How long does delivery take for completed orders?
SELECT
    shipmode,
    ROUND(AVG(shippingdays)::NUMERIC, 2) AS average_shipping_days,
    COUNT(*) AS sales_lines
FROM fact_sales
WHERE orderstatus = 'Completed'
GROUP BY shipmode
ORDER BY average_shipping_days;

-- 9. Who are the top twenty customers by revenue?
SELECT
    c.customerkey,
    c.customername,
    c.segment,
    c.city,
    SUM(f.netsales) AS lifetime_revenue,
    COUNT(DISTINCT f.orderid) AS orders
FROM fact_sales AS f
JOIN dim_customer AS c ON f.customerkey = c.customerkey
GROUP BY c.customerkey, c.customername, c.segment, c.city
ORDER BY lifetime_revenue DESC
LIMIT 20;

-- 10. Compare each month's revenue with the previous month.
WITH monthly_sales AS (
    SELECT
        d.year,
        d.monthnumber,
        d.monthyear,
        SUM(f.netsales) AS revenue
    FROM fact_sales AS f
    JOIN dim_date AS d ON f.datekey = d.datekey
    GROUP BY d.year, d.monthnumber, d.monthyear
),
previous_month AS (
    SELECT
        *,
        LAG(revenue) OVER (ORDER BY year, monthnumber) AS previous_month_revenue
    FROM monthly_sales
)
SELECT
    year,
    monthnumber,
    monthyear,
    revenue,
    previous_month_revenue,
    ROUND(
        100.0 * (revenue - previous_month_revenue)
        / NULLIF(previous_month_revenue, 0),
        2
    ) AS month_over_month_pct
FROM previous_month
ORDER BY year, monthnumber;
