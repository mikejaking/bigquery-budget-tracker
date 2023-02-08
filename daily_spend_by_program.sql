/*
Dave Walker
05-02-2023
bigquery-budget-tracker/daily_budgets.sql
Version 1
Google Standard SQL
*/


SELECT gcs.accountid
,      gcs.account
,      gcs.currency
,      DATE_TRUNC(gcs.date, DAY) AS spend_date
,      split(gcs.campaign, ' |')[offset(0)] as program
,      ROUND(SUM(gcs.spend)) as spend
FROM   `budgets.google_campaign_spend` AS gcs
GROUP BY gcs.accountid
,      gcs.account
,      gcs.currency
,      spend_date
,      program
