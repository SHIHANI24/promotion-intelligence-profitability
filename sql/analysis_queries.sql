
-- PROJECT: Promotion Intelligence & True Profitability Engine
-- Dataset: Sample - Superstore
-- Purpose: Analyze sales, discounts, and profitability.

-- 1. Check the total number of records
SELECT COUNT(*) AS total_records
FROM superstore;

-- 2. Overall business performance
SELECT
    ROUND(SUM(Sales), 2) AS total_sales,
    ROUND(SUM(Profit), 2) AS total_profit,
    SUM(Quantity) AS total_quantity,
    ROUND(AVG(Discount) * 100, 2) AS avg_discount_pct,
    ROUND(
        100.0 * SUM(Profit) / NULLIF(SUM(Sales), 0), 2
    ) AS profit_margin_pct
FROM superstore;

-- 3. Performance by product category
SELECT
    Category,
    ROUND(SUM(Sales), 2) AS total_sales,
    ROUND(SUM(Profit), 2) AS total_profit,
    SUM(Quantity) AS total_quantity,
    ROUND(AVG(Discount) * 100, 2) AS avg_discount_pct
FROM superstore
GROUP BY Category
ORDER BY total_profit DESC;

-- 4. Profitability by sub-category
SELECT
    Category,
    "Sub-Category",
    ROUND(SUM(Sales), 2) AS total_sales,
    ROUND(SUM(Profit), 2) AS total_profit,
    ROUND(AVG(Discount) * 100, 2) AS avg_discount_pct
FROM superstore
GROUP BY Category, "Sub-Category"
ORDER BY total_profit ASC;

-- 5. Products generating losses
SELECT
    "Product Name",
    ROUND(SUM(Sales), 2) AS total_sales,
    ROUND(SUM(Profit), 2) AS total_profit,
    ROUND(AVG(Discount) * 100, 2) AS avg_discount_pct
FROM superstore
GROUP BY "Product Name"
HAVING SUM(Profit) < 0
ORDER BY total_profit ASC
LIMIT 20;

-- 6. Compare profitability across discount levels
SELECT
    CASE
        WHEN Discount = 0 THEN '0% discount'
        WHEN Discount <= 0.10 THEN '1-10% discount'
        WHEN Discount <= 0.20 THEN '11-20% discount'
        WHEN Discount <= 0.30 THEN '21-30% discount'
        ELSE 'Above 30% discount'
    END AS discount_band,
    COUNT(*) AS order_lines,
    ROUND(SUM(Sales), 2) AS total_sales,
    ROUND(SUM(Profit), 2) AS total_profit,
    ROUND(AVG(Profit), 2) AS avg_profit_per_line
FROM superstore
GROUP BY discount_band
ORDER BY MIN(Discount);

-- 7. Regional performance
SELECT
    Region,
    ROUND(SUM(Sales), 2) AS total_sales,
    ROUND(SUM(Profit), 2) AS total_profit,
    ROUND(
        100.0 * SUM(Profit) / NULLIF(SUM(Sales), 0), 2
    ) AS profit_margin_pct
FROM superstore
GROUP BY Region
ORDER BY total_profit DESC;

-- 8. Customer segment performance
SELECT
    Segment,
    COUNT(DISTINCT "Customer ID") AS unique_customers,
    ROUND(SUM(Sales), 2) AS total_sales,
    ROUND(SUM(Profit), 2) AS total_profit
FROM superstore
GROUP BY Segment
ORDER BY total_profit DESC;
