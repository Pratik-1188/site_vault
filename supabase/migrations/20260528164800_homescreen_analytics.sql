-- ########################################################
-- 1. view_homescreen_analytics
-- RESULTSET: Global KK Group corporate dashboard overview metrics.
--   Aggregates total expenses, active sites count, and total sum of missing bill
--   expenses for the current Indian Financial Year (starts April 1st).
-- ########################################################

CREATE OR REPLACE VIEW view_homescreen_analytics AS
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
    (SELECT COALESCE(SUM(amount), 0) 
     FROM expenses, fy_dates 
     WHERE expense_date >= fy_start AND expense_date <= fy_end AND soft_deleted_at IS NULL)::NUMERIC(15, 2) as current_year_expense_total,
     
    (SELECT COUNT(*)::INT 
     FROM sites 
     WHERE status = 'active') as active_sites_count,
     
    (SELECT COALESCE(SUM(amount), 0) 
     FROM expenses, fy_dates 
     WHERE expense_date >= fy_start AND expense_date <= fy_end AND attachment_path IS NULL AND soft_deleted_at IS NULL)::NUMERIC(15, 2) as missing_bill_expense_total;
