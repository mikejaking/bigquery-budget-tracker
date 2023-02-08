/*
Dave Walker
05-02-2023
bigquery-budget-tracker/budgets_view_with_comparisons.sql
Version 1
Google Standard SQL
*/

WITH main as (
		SELECT  COALESCE(spby.spend_date, db.budget_date) as date
    ,       COALESCE(spby.program, db.program) AS program
		,       IFNULL(spby.spend,0) as actual_daily_by_program
		,       SUM(IFNULL(spby.spend,0)) OVER (PARTITION BY spby.program, DATE_TRUNC(spby.spend_date, MONTH) ORDER BY spby.program, spby.spend_date ASC) AS actual_monthly_running_total_by_program
		-- ,       SUM(spby.spend) OVER (PARTITION BY spby.program, DATE_TRUNC(spby.spend_date, MONTH) ORDER BY spby.program, DATE_TRUNC(spby.spend_date, MONTH) ASC) AS monthly_spend_total_by_program
		-- ,       SUM(spby.spend) OVER (PARTITION BY spby.spend_date ORDER BY spby.spend_date ASC) AS actual_daily_total_all_programs
		-- ,       SUM(spby.spend) OVER (PARTITION BY DATE_TRUNC(spby.spend_date, MONTH) ORDER BY spby.spend_date ASC) AS actual_monthly_running_total_all_programs
		,       db.budget_daily_by_program
		-- ,       db.budget_monthly_running_total_by_program
		,       db.budget_monthly_by_program
		-- ,       db.budget_daily_all_programs
		-- ,       db.budget_monthly_running_total_all_programs
		-- ,       db.budget_monthly_all_programs
		FROM    `budgets.daily_spend_by_program` spby
		FULL OUTER JOIN `budgets.daily_budgets` db
		ON      db.budget_date = spby.spend_date
		AND     db.program = spby.program
		WHERE 1=1
		ORDER BY spby.program, spby.spend_date
)
SELECT  date
,       program
,       actual_daily_by_program as actual_spend
,       round(budget_daily_by_program,2) as budget_spend
,       round((budget_daily_by_program - actual_daily_by_program),2) AS budget_vs_actual_spend
,       actual_monthly_running_total_by_program as actual_monthly_running_total
-- ,       budget_monthly_running_total_by_program
-- ,		    (budget_monthly_running_total_by_program - actual_monthly_running_total_by_program) AS budget_vs_actual_monthly_running_total_by_program
-- ,       actual_daily_total_all_programs
-- ,       actual_monthly_running_total_all_programs
-- ,       monthly_spend_total_by_program
,       budget_monthly_by_program
,       round((budget_monthly_by_program - actual_monthly_running_total_by_program),2) as eod_remaining_budget_monthly
,       EXTRACT(DAY FROM LAST_DAY(date, MONTH)) - EXTRACT(DAY from date) as eod_remaining_days_in_month
,       round((budget_monthly_by_program - actual_monthly_running_total_by_program) / (EXTRACT(DAY FROM LAST_DAY(date, MONTH)) - EXTRACT(DAY from date) + 1) ,2) as eod_remaining_daily_budget
-- ,       budget_daily_all_programs
-- ,       budget_monthly_running_total_all_programs
-- ,       budget_monthly_all_programs
FROM    main
where 1=1
and program = 'Brand'
-- and program = 'Campaign Name 1'
and date between '2023-02-01' and '2023-02-28'
order by date, program
