/*
================================================================================
PROJECT: FP&A Financial Performance & Variance Analysis
DATABASE ENGINE: MySQL 8.0+
AUTHOR: Portfolio Repository
DESCRIPTION: End-to-end financial reporting pipeline analyzing Q1 performance,
             budget variances, margins, contribution shares, and MoM trends.
================================================================================
*/

-- =============================================================================
-- MODULE 0: SCHEMA SETUP & DATA INITIALIZATION
-- =============================================================================

CREATE DATABASE IF NOT EXISTS fpa_budget_project;
USE fpa_budget_project;

DROP TABLE IF EXISTS q1_financials;
CREATE TABLE q1_financials (
    id INT AUTO_INCREMENT PRIMARY KEY,
    month_name VARCHAR(15) NOT NULL,
    product_category VARCHAR(25) NOT NULL,
    target_revenue DECIMAL(12,2) NOT NULL, 
    actual_revenue DECIMAL(12,2) NOT NULL,
    actual_cogs DECIMAL(12,2) NOT NULL
);

INSERT INTO q1_financials (month_name, product_category, target_revenue, actual_revenue, actual_cogs)
VALUES 
    ('Jan-2026', 'Apparel',     80000.00,  72000.00, 45000.00),
    ('Jan-2026', 'Accessories', 30000.00,  34000.00, 15000.00),
    ('Jan-2026', 'Footwear',   120000.00, 115000.00, 62000.00),
    ('Feb-2026', 'Footwear',   110000.00, 105000.00, 58000.00),
    ('Feb-2026', 'Apparel',     85000.00,  90000.00, 52000.00),
    ('Feb-2026', 'Accessories', 32000.00,  31000.00, 14000.00);


-- =============================================================================
-- MODULE 1: BASIC PROFITABILITY METRICS
-- =============================================================================

-- Question 1.1: Calculate Dollar Gross Profit
-- Display product_category, actual_revenue, and Gross_profit (actual_revenue - actual_cogs)
-- across all records.
SELECT 
    product_category,
    actual_revenue,
    (actual_revenue - actual_cogs) AS gross_profit
FROM q1_financials;


-- Question 1.2: Filter by Reporting Period
-- Modify Query 1.1 to show product_category, actual_revenue, and gross_profit 
-- strictly for the month of 'Jan-2026'.
SELECT 
    product_category,
    actual_revenue,
    (actual_revenue - actual_cogs) AS gross_profit
FROM q1_financials 
WHERE month_name = 'Jan-2026';


-- Question 1.3: Margin Ratio Calculation
-- Calculate Gross Margin % rounded to 2 decimal places (gross_margin_pct)
-- for 'Jan-2026'.
SELECT 
    product_category,
    actual_revenue,
    (actual_revenue - actual_cogs) AS gross_profit,
    ROUND(((actual_revenue - actual_cogs) / actual_revenue) * 100, 2) AS gross_margin_pct
FROM q1_financials 
WHERE month_name = 'Jan-2026';


-- Question 1.4: Profitability Ranking
-- Sort the 'Jan-2026' profitability results so that the category with the 
-- highest gross_profit appears at the top.
SELECT 
    product_category,
    actual_revenue,
    (actual_revenue - actual_cogs) AS gross_profit,
    ROUND(((actual_revenue - actual_cogs) / actual_revenue) * 100, 2) AS gross_margin_pct
FROM q1_financials 
WHERE month_name = 'Jan-2026'
ORDER BY gross_profit DESC;


-- =============================================================================
-- MODULE 2: BUDGET VARIANCE & PERFORMANCE BENCHMARKING
-- =============================================================================

-- Question 2.1: Variance & Target Achievement
-- For 'Feb-2026', calculate:
-- 1. Dollar variance: actual_revenue - target_revenue (revenue_variance)
-- 2. Target achievement %: (actual_revenue / target_revenue) * 100 (achievement_pct)
-- Sort by revenue_variance descending.
SELECT 
    product_category,
    target_revenue,
    actual_revenue,
    (actual_revenue - target_revenue) AS revenue_variance,
    ROUND((actual_revenue / target_revenue) * 100, 2) AS achievement_pct
FROM q1_financials
WHERE month_name = 'Feb-2026'
ORDER BY revenue_variance DESC;


-- Question 2.2: Conditional Performance Flagging (CASE WHEN)
-- Add an operational status flag 'performance_status':
-- Flag as 'Target_Met' if actual_revenue >= target_revenue, else 'Not_Met'.
SELECT 
    product_category,
    target_revenue,
    actual_revenue,
    (actual_revenue - target_revenue) AS revenue_variance,
    ROUND((actual_revenue / target_revenue) * 100, 2) AS achievement_pct,
    CASE 
        WHEN actual_revenue >= target_revenue THEN 'Target_Met'
        ELSE 'Not_Met'
    END AS performance_status
FROM q1_financials
WHERE month_name = 'Feb-2026'
ORDER BY revenue_variance DESC;


-- =============================================================================
-- MODULE 3: AGGREGATIONS & MULTI-DIMENSIONAL REPORTING
-- =============================================================================

-- Question 3.1: Category-Level Consolidation
-- Calculate cumulative target revenue, actual revenue, actual COGS, and gross profit 
-- for each product category across all available months.
SELECT 
    product_category,
    SUM(target_revenue) AS total_target,
    SUM(actual_revenue) AS total_actual,
    SUM(actual_cogs) AS total_cogs,
    SUM(actual_revenue - actual_cogs) AS total_gross_profit
FROM q1_financials 
GROUP BY product_category
ORDER BY total_gross_profit DESC;


-- Question 3.2: Aggregated Threshold Filtering (HAVING Clause)
-- Calculate cumulative overall gross margin % per category.
-- Filter out smaller categories where total actual revenue is under 100,000.
SELECT 
    product_category,
    SUM(target_revenue) AS total_target,
    SUM(actual_revenue) AS total_actual,
    SUM(actual_cogs) AS total_cogs,
    SUM(actual_revenue - actual_cogs) AS gross_profit,
    ROUND((SUM(actual_revenue - actual_cogs) / SUM(actual_revenue)) * 100, 2) AS overall_gross_margin_pct
FROM q1_financials 
GROUP BY product_category
HAVING SUM(actual_revenue) >= 100000.00
ORDER BY overall_gross_margin_pct DESC;


-- Question 3.3: Two-Dimensional Matrix (Month x Category)
-- Group data by both month_name and product_category to evaluate monthly gross profit 
-- and gross margin %, sorted chronologically and by margin rank.
SELECT 
    month_name,
    product_category,
    SUM(actual_revenue) AS monthly_actual_revenue,
    SUM(actual_revenue - actual_cogs) AS monthly_gross_profit,
    ROUND((SUM(actual_revenue - actual_cogs) / SUM(actual_revenue)) * 100, 2) AS gross_margin_pct
FROM q1_financials 
GROUP BY month_name, product_category
ORDER BY 
    CASE 
        WHEN month_name = 'Jan-2026' THEN 1
        WHEN month_name = 'Feb-2026' THEN 2
        WHEN month_name = 'Mar-2026' THEN 3
    END ASC,
    gross_margin_pct DESC;


-- =============================================================================
-- MODULE 4: ADVANCED ANALYTICS (WINDOW FUNCTIONS & CTEs)
-- =============================================================================

-- Question 4.1: Grand Total Contribution Share (SUM OVER)
-- For 'Feb-2026', calculate each category's revenue contribution % relative to 
-- total February sales without collapsing rows.
SELECT 
    month_name,
    product_category,
    actual_revenue,
    SUM(actual_revenue) OVER() AS total_feb_revenue,
    ROUND((actual_revenue / SUM(actual_revenue) OVER()) * 100, 2) AS total_feb_pct
FROM q1_financials
WHERE month_name = 'Feb-2026'
ORDER BY total_feb_pct DESC;


-- Question 4.2: Partitioned Monthly Contribution
-- Across all periods, calculate category revenue share relative to its respective month 
-- using SUM() OVER (PARTITION BY month_name).
SELECT 
    month_name,
    product_category,
    actual_revenue,
    SUM(actual_revenue) OVER(PARTITION BY month_name) AS monthly_total,
    ROUND((actual_revenue / SUM(actual_revenue) OVER(PARTITION BY month_name)) * 100, 2) AS monthly_contrib_pct
FROM q1_financials
ORDER BY 
    CASE 
        WHEN month_name = 'Jan-2026' THEN 1
        WHEN month_name = 'Feb-2026' THEN 2
        WHEN month_name = 'Mar-2026' THEN 3
    END ASC,
    monthly_contrib_pct DESC;


-- Question 4.3: Month-over-Month (MoM) Trend & Growth Rate (LAG + CTE)
-- Using a Common Table Expression (CTE) and LAG(), retrieve previous month revenue 
-- partitioned by category, enforce chronological timeline sorting, and calculate:
-- 1. Absolute Dollar Variance: (actual_revenue - prev_month_revenue)
-- 2. MoM Growth Rate %: ((actual_revenue - prev_month_revenue) / prev_month_revenue) * 100
WITH monthly_metrics AS (
    SELECT 
        product_category,
        month_name,
        actual_revenue,
        LAG(actual_revenue, 1) OVER(
            PARTITION BY product_category 
            ORDER BY CASE 
                WHEN month_name = 'Jan-2026' THEN 1
                WHEN month_name = 'Feb-2026' THEN 2
                WHEN month_name = 'Mar-2026' THEN 3
            END
        ) AS prev_month_revenue
    FROM q1_financials
)
SELECT 
    product_category,
    month_name,
    actual_revenue,
    prev_month_revenue,
    (actual_revenue - prev_month_revenue) AS revenue_change,
    ROUND(((actual_revenue - prev_month_revenue) / prev_month_revenue) * 100, 2) AS mom_growth_pct
FROM monthly_metrics
ORDER BY 
    product_category ASC,
    CASE 
        WHEN month_name = 'Jan-2026' THEN 1
        WHEN month_name = 'Feb-2026' THEN 2
        WHEN month_name = 'Mar-2026' THEN 3
    END ASC;