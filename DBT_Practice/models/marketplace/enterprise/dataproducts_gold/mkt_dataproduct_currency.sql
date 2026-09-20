{{
  config(
    full_refresh = true,
    materialized="dynamic_table",
    target_lag="24 hour",
    snowflake_warehouse= var('task_warehouse'),
    alias = "Currency",
    schema= "dataproducts_gold",
    post_hook = "ALTER DYNAMIC TABLE {{ this }} SET LOG_LEVEL = ERROR"
  
  )
}}

with Customer AS (
    SELECT CURRENCY_CODE,
    CURRENCY_NAME_FR,
    CURRENCY_NAME_EN FROM {{ref('sche_dim_Currency') }}
)

SELECT * FROM Customer