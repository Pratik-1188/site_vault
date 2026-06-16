-- ########################################################
-- 1. view_firm_analytics
-- RESULTSET: Group-wide aggregated metrics grouped by firm_id.
--   Provides total spending and transaction count
--   for executive top-level dashboards.
-- ########################################################
CREATE OR REPLACE VIEW view_firm_analytics AS
SELECT 
    firm_id,
    COALESCE(SUM(amount), 0) as total_spend,
    COUNT(id) as expense_count
FROM expenses
WHERE soft_deleted_at IS NULL
GROUP BY firm_id;

-- ########################################################
-- 2. view_site_analytics
-- RESULTSET: Site-specific aggregated metrics grouped by site_id and firm_id.
--   Provides total spending and transaction count
--   for project detail dashboards.
-- ########################################################
CREATE OR REPLACE VIEW view_site_analytics AS
SELECT 
    site_id,
    firm_id,
    COALESCE(SUM(amount), 0) as total_spend,
    COUNT(id) as expense_count
FROM expenses
WHERE soft_deleted_at IS NULL
GROUP BY site_id, firm_id;

-- ########################################################
-- 3. view_category_analytics
-- RESULTSET: Spending aggregates grouped by category_id, site_id, and firm_id.
--   Provides the spending breakdown by operational business categories, allowing
--   queries to retrieve splits globally, by firm, or for a single site.
-- ########################################################
CREATE OR REPLACE VIEW view_category_analytics AS
SELECT 
    site_id,
    firm_id,
    category_id,
    c.name as category_name,
    COALESCE(SUM(amount), 0) as total_spend
FROM expenses e
LEFT JOIN expense_categories c ON e.category_id = c.id
WHERE e.soft_deleted_at IS NULL
GROUP BY site_id, firm_id, category_id, c.name;

-- ########################################################
-- 4. view_monthly_analytics
-- RESULTSET: Month-over-month spending cashflow trends grouped by month, site_id, and firm_id.
--   Provides the chronological spending history, truncated to the first day of each month,
--   allowing both global and project-specific timeline comparisons.
-- ########################################################
CREATE OR REPLACE VIEW view_monthly_analytics AS
SELECT 
    site_id,
    firm_id,
    DATE_TRUNC('month', expense_date)::DATE as month_date,
    COALESCE(SUM(amount), 0) as total_spend
FROM expenses
WHERE soft_deleted_at IS NULL
GROUP BY site_id, firm_id, DATE_TRUNC('month', expense_date);

-- ########################################################
-- 5. view_vendor_analytics
-- RESULTSET: Spending splits per vendor grouped by vendor_id and site_id.
--   Provides the supplier cost breakdown for a specific project site, sorting
--   which vendors received the most funds.
-- ########################################################
CREATE OR REPLACE VIEW view_vendor_analytics AS
SELECT 
    site_id,
    vendor_id,
    v.name as vendor_name,
    COALESCE(SUM(amount), 0) as total_spend
FROM expenses e
LEFT JOIN vendors v ON e.vendor_id = v.id
WHERE e.soft_deleted_at IS NULL
GROUP BY site_id, vendor_id, v.name;
