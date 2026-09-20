{{
  config(
    full_refresh = true,
    materialized="dynamic_table",
    target_lag="24 hour",
    snowflake_warehouse= var('task_warehouse'),
    alias = "Business_Unit",
    schema= "dataproducts_gold",
    post_hook = "ALTER DYNAMIC TABLE {{ this }} SET LOG_LEVEL = ERROR"
  
  )
}}

with  Business_Unit AS (
    SELECT BUSINESS_UNIT_CODE,
    BUSINESS_UNIT_NAME_FR,
    BUSINESS_UNIT_NAME_EN,
    BUSINESS_UNIT_GROUP_NAME_FR,
    BUSINESS_UNIT_GROUP_NAME_EN,
    ACTIVE_STATUS_CODE
    FROM {{ref('sche_dim_Business_Unit') }}
)

SELECT * FROM Business_Unit