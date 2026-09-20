{{
  config(
    materialized = "view",
    alias = "TIMESHEET",
    schema='TIMECONTROL',
    tags=["employee_timesheet_control"]
  )
}}

SELECT
    emp_code as employee_code,
    emp_first as employee_first_name,
    emp_last as employee_last_name,
    emp_name as employee_full_name,
    emp_fld1 as employee_location,
    emp_fld2 as working_hours,
    emp_fld3 as oracle_employee_number,
    emp_fld4 as employee_type,
    emp_fld5 as visibility_group_1,
    emp_fld6 as visibility_group_2,
    emp_fld7 as visibility_group_3,
    emp_fld8 as visibility_group_4,
    emp_fld9 as visibility_group_5,
    emp_fld10 as working_team,
    emp_fld11 as employee_approver,
    emp_fld12 as employee_jobsite,
    emp_fld15 as employee_department,
    psh_tstmp as timesheet_timestamp,
    psh_psdate as period_start_date,
    psh_pedate as period_end_date,
    psd_date as date_work_performed,
    psd_wedate as week_ending_date,
    psl_tstmp as timesheet_line_timestamp,
    psl_fld1 as service,
    psl_fld2 as division,
    psl_fld3 as extra,
    prj_name as project_name,
    prj_desc as project_description,
    cac_desc as customer_name,
    prj_fld2 as oracle_project_number,
    prj_fld5 as quotation_number,
    prj_fld6 as project_type,
    chh_code as charge_code,
    chh_desc as charge_description,
    chh_fld3 as charge_category,
    psl_rat_cd as rate_code,
    hours as hours,
    psd_sunday as sunday_hours,
    psd_monday as monday_hours,
    psd_tuesday as tuesday_hours,
    psd_wednesday as wednesday_hours,
    psd_thursday as thursday_hours,
    psd_firday as friday_hours,
    psd_saturday as saturday_hours
FROM
  {{ ref ('prep_timesheet') }} 
QUALIFY ROW_NUMBER() OVER (PARTITION BY psh_key, psl_key, psd_key ORDER BY metadata_file_last_modified DESC) = 1