{{
  config(
    full_refresh = true,
    materialized="dynamic_table",
    target_lag="24 hour",
    snowflake_warehouse= var('task_warehouse'),
    alias = "customer",
    schema= "dataproducts_gold",
    post_hook = "ALTER DYNAMIC TABLE {{ this }} SET LOG_LEVEL = ERROR"
  
  )
}}

SELECT
    CUSTOMER_CODE,
    CUSTOMER_NAME,
    CUSTOMER_CLASS_CODE,
    BUSINESS_PARTNER_CODE,
    BUSINESS_PARTNER_NAME
FROM
    {{ref('sche_dim_Customer')}}