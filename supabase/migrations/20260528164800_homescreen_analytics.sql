-- ########################################################
-- 1. view_current_financial_year_expense_total
-- Brings the total sum of all non-deleted expenses for the current Indian Financial Year.
-- ########################################################
CREATE OR REPLACE VIEW view_current_financial_year_expense_total WITH (security_invoker = true) AS
WITH fy_dates AS (
    SELECT 
        (CASE 
            WHEN EXTRACT(month FROM CURRENT_DATE) >= 4 THEN DATE_TRUNC('year', CURRENT_DATE) + INTERVAL '3 months' 
            ELSE DATE_TRUNC('year', CURRENT_DATE) - INTERVAL '9 months' 
         END)::DATE as fy_start,
        (CASE 
            WHEN EXTRACT(month FROM CURRENT_DATE) >= 4 THEN DATE_TRUNC('year', CURRENT_DATE) + INTERVAL '15 months' - INTERVAL '1 day' 
            ELSE DATE_TRUNC('year', CURRENT_DATE) + INTERVAL '3 months' - INTERVAL '1 day' 
         END)::DATE as fy_end
)
SELECT 
    COALESCE(SUM(amount), 0)::NUMERIC(15, 2) as total_expense
FROM expenses, fy_dates
WHERE expense_date >= fy_start AND expense_date <= fy_end AND soft_deleted_at IS NULL;


-- ########################################################
-- 2. view_active_sites_count
-- Brings the count of all active project sites started in the current Indian Financial Year.
-- ########################################################
CREATE OR REPLACE VIEW view_active_sites_count WITH (security_invoker = true) AS
WITH fy_dates AS (
    SELECT 
        (CASE 
            WHEN EXTRACT(month FROM CURRENT_DATE) >= 4 THEN DATE_TRUNC('year', CURRENT_DATE) + INTERVAL '3 months' 
            ELSE DATE_TRUNC('year', CURRENT_DATE) - INTERVAL '9 months' 
         END)::DATE as fy_start,
        (CASE 
            WHEN EXTRACT(month FROM CURRENT_DATE) >= 4 THEN DATE_TRUNC('year', CURRENT_DATE) + INTERVAL '15 months' - INTERVAL '1 day' 
            ELSE DATE_TRUNC('year', CURRENT_DATE) + INTERVAL '3 months' - INTERVAL '1 day' 
         END)::DATE as fy_end
)
SELECT 
    COUNT(*)::INT as active_sites_count
FROM sites, fy_dates
WHERE status = 'active' AND started_on >= fy_start AND started_on <= fy_end;


-- ########################################################
-- 3. view_missing_bill_expense_total
-- Brings the total currency sum of all financial year expenses missing bill attachments.
-- ########################################################
CREATE OR REPLACE VIEW view_missing_bill_expense_total WITH (security_invoker = true) AS
WITH fy_dates AS (
    SELECT 
        (CASE 
            WHEN EXTRACT(month FROM CURRENT_DATE) >= 4 THEN DATE_TRUNC('year', CURRENT_DATE) + INTERVAL '3 months' 
            ELSE DATE_TRUNC('year', CURRENT_DATE) - INTERVAL '9 months' 
         END)::DATE as fy_start,
        (CASE 
            WHEN EXTRACT(month FROM CURRENT_DATE) >= 4 THEN DATE_TRUNC('year', CURRENT_DATE) + INTERVAL '15 months' - INTERVAL '1 day' 
            ELSE DATE_TRUNC('year', CURRENT_DATE) + INTERVAL '3 months' - INTERVAL '1 day' 
         END)::DATE as fy_end
)
SELECT 
    COALESCE(SUM(amount), 0)::NUMERIC(15, 2) as missing_bill_total
FROM expenses, fy_dates
WHERE expense_date >= fy_start AND expense_date <= fy_end AND attachment_path IS NULL AND soft_deleted_at IS NULL;
