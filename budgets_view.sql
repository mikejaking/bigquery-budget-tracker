/*
Dave Walker
05-02-2023
bigquery-budget-tracker/budgets_view.sql
Version 1
Google Standard SQL
*/

select  COALESCE(spby.spend_date, db.budget_date) as date
,       COALESCE(spby.program, db.program) AS program
,       spby.spend
,       SUM(spby.spend) OVER (PARTITION BY spby.program, DATE_TRUNC(spby.spend_date, MONTH) ORDER BY spby.program, spby.spend_date ASC) AS monthly_spend_running_total_by_program
,       SUM(spby.spend) OVER (PARTITION BY spby.program, DATE_TRUNC(spby.spend_date, MONTH) ORDER BY spby.program, DATE_TRUNC(spby.spend_date, MONTH) ASC) AS monthly_spend_total_by_program
,       SUM(spby.spend) OVER (PARTITION BY spby.spend_date ORDER BY spby.spend_date ASC) AS daily_spend_total_by_program
,       SUM(spby.spend) OVER (PARTITION BY DATE_TRUNC(spby.spend_date, MONTH) ORDER BY spby.spend_date ASC) AS monthly_spend_running_total_all_programs
,       db.budget_daily_by_program
,       db.budget_monthly_running_total_by_program
,       db.budget_monthly_by_program
,       db.budget_daily_all_programs
,       db.budget_monthly_running_total_all_programs
,       db.budget_monthly_all_programs
FROM    `budgets.daily_spend_by_program` spby
FULL OUTER JOIN `budgets.daily_budgets` db
ON      db.budget_date = spby.spend_date
AND     db.program = spby.program
WHERE 1=1
ORDER BY spby.program, spby.spend_date
