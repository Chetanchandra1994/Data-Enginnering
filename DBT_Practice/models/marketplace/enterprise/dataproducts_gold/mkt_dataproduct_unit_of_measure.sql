{{
  config(
    full_refresh = true,
    materialized="dynamic_table",
    target_lag="24 hour",
    snowflake_warehouse= var('task_warehouse'),
    alias = "Unit_Of_Measure",
    schema= "dataproducts_gold",
    post_hook = "ALTER DYNAMIC TABLE {{ this }} SET LOG_LEVEL = ERROR"
  
  )
}}

with UNIT_OF_MEASURE AS (
    SELECT
    UOM_CODE,
    UOM_TYPE_NAME_EN,
    UOM_SYSTEM_NAME_EN
    FROM {{ref('sche_dim_Unit_Of_Measure') }}
)

SELECT * FROM UNIT_OF_MEASURE