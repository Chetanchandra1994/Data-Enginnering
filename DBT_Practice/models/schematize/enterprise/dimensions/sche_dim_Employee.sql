{{
  config(
    full_refresh = true,
    materialized="dynamic_table",
    target_lag="downstream",
    snowflake_warehouse= var('task_warehouse'),
    alias = "dim_Employee",
    schema= "dimensions",
    post_hook = "ALTER DYNAMIC TABLE {{ this }} SET LOG_LEVEL = ERROR"
  )
}}

SELECT
    {{ dbt_utils.generate_surrogate_key(['MAIN_EMPLOYEE_NUMBER',"'mdh-employee'", 'FINANCIAL_COMPANY_CODE', ]) }} as EMPLOYEE_SK,
    MAIN_EMPLOYEE_NUMBER AS EMPLOYEE_NUMBER,
    'mdh-employee' AS ORIGIN_APPLICATION_CODE,
    FINANCIAL_COMPANY_CODE AS FINANCIAL_COMPANY_CODE,
    PROFESSIONAL_EMAIL AS PROFESSIONAL_EMAIL,
    FIRST_NAME AS GIVEN_NAME,
    LAST_NAME AS FAMILY_NAME,
    EMPLOYEE_STATUS AS EMPLOYEE_STATUS
FROM
    {{ref('norm_employee')}}