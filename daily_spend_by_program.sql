/*
Dave Walker
05-02-2023
bigquery-budget-tracker/daily_spend_by_program.sql
Version 1
Google Standard SQL
*/


SELECT
  gcs.accountid,
  gcs.account,
  gcs.currency,
  DATE_TRUNC(gcs.date, DAY) AS spend_date,
  SPLIT(gcs.campaign, ' |')[
OFFSET
  (0)] AS program,
  ROUND(SUM(gcs.spend)) AS spend
FROM
  `budgets.google_campaign_spend` AS gcs
GROUP BY
  gcs.accountid,
  gcs.account,
  gcs.currency,
  spend_date,
  program
