/*
Dave Walker
05-02-2023
bigquery-budget-tracker/daily_budgets.sql
Version 1
Google Standard SQL

Description: This sql distributes data from the monthly budget sheet across all days in the month. This allows us to
join the daily spend more effectively.
*/

WITH
  monthly_budget AS (
  SELECT
    gcb.date AS budget_month,
    gcb.program,
    gcb.budget AS budget_monthly_by_program,
    gcb.budget / EXTRACT(DAY
    FROM
      LAST_DAY(gcb.date, MONTH)) AS budget_daily_by_program
  FROM
    `budgets.google_campaign_budgets` gcb ),
  calendar_table AS (
  SELECT
    calendar_date
  FROM
    UNNEST(GENERATE_DATE_ARRAY((
        SELECT
          DATE_TRUNC(MIN(budget_month),MONTH)
        FROM
          monthly_budget), (
        SELECT
          LAST_DAY(MAX(budget_month))
        FROM
          monthly_budget), INTERVAL 1 day)) AS calendar_date )
SELECT
  ct.calendar_date AS budget_date,
  mb.program,
  mb.budget_daily_by_program,
  mb.budget_monthly_by_program,
FROM
  monthly_budget AS mb
CROSS JOIN
  calendar_table AS ct
WHERE
  DATE_TRUNC(ct.calendar_date, MONTH) = DATE_TRUNC(mb.budget_month, MONTH)
