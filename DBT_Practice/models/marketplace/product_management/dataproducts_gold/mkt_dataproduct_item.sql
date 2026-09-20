{{
  config(
    full_refresh = true,
    materialized="dynamic_table",
    target_lag="24hour",
    snowflake_warehouse= var('task_warehouse'),
    alias = "item",
    schema= "dataproducts_gold",
    post_hook = "ALTER DYNAMIC TABLE {{ this }} SET LOG_LEVEL = ERROR"
  )
}}

Select 
  ITEM_CODE,
  ITEM_NAME_FR,
  ITEM_NAME_EN,
  ITEM_SALES_GROUP_CODE,
  ACTIVE_STATUS_CODE
from {{ref('sche_dim_Item')}}



