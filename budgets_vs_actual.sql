/*
Dave Walker
05-02-2023
bigquery-budget-tracker/budgets_vs_actual.sql
Version 1
Google Standard SQL

Description: This view joins the above views for budget and spend and generates a dataset that contains additional
information such as a daily running total for spend as well as a dynamic budget for each day that is based on the
amount of underspend/overspend in relation to the current budget.
*/

WITH
  main AS (
  SELECT
    COALESCE(spby.spend_date, db.budget_date) AS date,
    COALESCE(spby.program, db.program) AS program,
    IFNULL(spby.spend,0) AS actual_daily,
    SUM(IFNULL(spby.spend,0)) OVER (PARTITION BY spby.program, DATE_TRUNC(spby.spend_date, MONTH)
    ORDER BY
      spby.program,
      spby.spend_date ASC) AS actual_monthly_running_total,
    IFNULL(db.budget_daily_by_program,0) AS budget_daily,
    IFNULL(db.budget_monthly_by_program,0) AS budget_monthly
  FROM
    `budgets.daily_spend_by_program` spby
  FULL OUTER JOIN
    `budgets.daily_budgets` db
  ON
    db.budget_date = spby.spend_date
    AND db.program = spby.program
  WHERE
    1=1
  ORDER BY
    spby.program,
    spby.spend_date )
SELECT
  date,
  program,
  (actual_monthly_running_total - actual_daily) AS actual_rt_sod,
  actual_daily AS actual,
  actual_monthly_running_total AS actual_rt_eod,
  GREATEST(0, ROUND((budget_monthly - (actual_monthly_running_total - actual_daily)) / (EXTRACT(DAY
        FROM
          LAST_DAY(date, MONTH)) - EXTRACT(DAY
        FROM
          CASE
            WHEN date <= CURRENT_DATE() THEN date
          ELSE
          CURRENT_DATE
        END
          ) + 1),2)) AS budget_dynamic,
  CASE
    WHEN date > CURRENT_DATE() THEN 0
  ELSE
  ROUND((budget_monthly - (actual_monthly_running_total - actual_daily)) / (EXTRACT(DAY
      FROM
        LAST_DAY(date, MONTH)) - EXTRACT(DAY
      FROM
        date) + 1) - actual_daily,2)
END
  AS underspend_dynamic,
  ROUND(budget_daily,2) AS budget_crude,
  ROUND(budget_daily - actual_daily,2) AS underspend_crude,
  budget_monthly AS target_budget_monthly
FROM
  main
ORDER BY
  date,
  program
