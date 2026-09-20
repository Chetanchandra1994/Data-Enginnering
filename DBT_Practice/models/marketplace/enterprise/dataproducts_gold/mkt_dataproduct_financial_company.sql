{{
  config(
    full_refresh = true,
    materialized="dynamic_table",
    target_lag="24 hour",
    snowflake_warehouse= var('task_warehouse'),
    alias = "Financial_Company",
    schema= "dataproducts_gold",
    post_hook = "ALTER DYNAMIC TABLE {{ this }} SET LOG_LEVEL = ERROR"
  
  )
}}

with FINANCIAL_COMPANY AS (
    SELECT FINANCIAL_COMPANY_CODE,
    CURRENCY_CODE FROM {{ref('sche_dim_Financial_Company') }}
)

SELECT * FROM FINANCIAL_COMPANY