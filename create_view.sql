SELECT  dsbp.spend_date
,       dsbp.program
,       dsbp.spend
,       ROUND(SUM(dsbp.spend) OVER (PARTITION BY dsbp.program, DATE_TRUNC(dsbp.spend_date, MONTH) ORDER BY dsbp.program, dsbp.spend_date ASC)) AS monthly_spend_running_total_by_program
,       ROUND(SUM(dsbp.spend) OVER (PARTITION BY dsbp.program, DATE_TRUNC(dsbp.spend_date, MONTH) ORDER BY dsbp.program, DATE_TRUNC(dsbp.spend_date, MONTH) ASC)) AS monthly_spend_total_by_program
,       ROUND(SUM(dsbp.spend) OVER (PARTITION BY dsbp.spend_date ORDER BY dsbp.spend_date ASC),2) AS daily_spend_total_by_program
,       ROUND(SUM(dsbp.spend) OVER (PARTITION BY dsbp.program, DATE_TRUNC(dsbp.spend_date, MONTH) ORDER BY dsbp.program, DATE_TRUNC(dsbp.spend_date, MONTH) ASC)) AS monthly_spend_running_total_all_program
,       pb.budget_daily_by_program
,       pb.budget_monthly_running_total_by_program
,       pb.budget_monthly_by_program
,       pb.budget_daily_all_programs
,       pb.budget_monthly_running_total_all_programs
,       pb.budget_monthly_all_programs
FROM    `budgets.daily_spend_by_program` dsbp
LEFT JOIN `budgets.daily_budgets` pb
ON      pb.budget_date = dsbp.spend_date
AND     pb.program = dsbp.program
WHERE 1=1
ORDER BY dsbp.program, dsbp.spend_date
