{{
  config(
    full_refresh = true,
    materialized="dynamic_table",
    target_lag="24hour",
    snowflake_warehouse= var('task_warehouse'),
    alias = "employee_timesheet_control",
    schema= "dataproducts_bronze",
    tags=["employee_timesheet_control"],
    post_hook = [
      "ALTER DYNAMIC TABLE {{ this }} SET LOG_LEVEL = ERROR"
      ]
  )
}}

SELECT
employee_code,
employee_first_name,
employee_last_name,
employee_full_name,
employee_location,
working_hours as employee_working_hours,
oracle_employee_number,
employee_type,
visibility_group_1 as employee_visibility_group_1,
visibility_group_2 as employee_visibility_group_2,
visibility_group_3 as employee_visibility_group_3,
visibility_group_4 as employee_visibility_group_4,
visibility_group_5 as employee_visibility_group_5,
working_team as employee_working_team,
employee_approver,
employee_jobsite,
employee_department,
timesheet_timestamp,
period_start_date,
period_end_date,
date_work_performed,
week_ending_date,
timesheet_line_timestamp,
service as timesheet_line_service,
division as timesheet_line_division,
extra as timesheet_line_extra,
project_name,
project_description,
customer_name,
oracle_project_number,
quotation_number,
project_type,
charge_code as project_charge_code,
charge_description as project_charge_description,
charge_category as project_charge_category,
rate_code as project_rate_code,
hours as project_daily_minimum_hours,
sunday_hours,
monday_hours,
tuesday_hours,
wednesday_hours,
thursday_hours,
friday_hours,
saturday_hours
FROM
  {{ ref ('norm_timesheet') }}