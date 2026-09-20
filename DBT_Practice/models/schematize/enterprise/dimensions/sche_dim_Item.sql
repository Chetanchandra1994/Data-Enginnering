{{
  config(
    full_refresh = true,
    materialized="dynamic_table",
    target_lag="downstream",
    snowflake_warehouse= var('task_warehouse'),
    alias = "dim_Item",
    schema= "dimensions",
    post_hook = "ALTER DYNAMIC TABLE {{ this }} SET LOG_LEVEL = ERROR",
    meta = {
    'table_key': 'ITEM_SK',
    'tests': {
      'unique_sk':{}    
    }
  }
  )
}}


SELECT 
	{{ dbt_utils.generate_surrogate_key(['CT.TASK_NUMBER']) }}    AS ITEM_SK,			-- SURROGATE KEY
  CT.TASK_NUMBER										                            AS ITEM_CODE,
  CT.TASK_NAME_1 										                            AS ITEM_NAME_FR,
	CT.TASK_NAME_2 										                            AS ITEM_NAME_EN,
	UPPER(DN.NAME)										                            AS ITEM_SALES_GROUP_CODE,
	CASE WHEN CT.ACTIVE = 1 THEN 'Active'
	ELSE 'Inactive' END								                            AS ACTIVE_STATUS_CODE	
FROM {{ref('norm_cmg_task')}} CT
LEFT JOIN {{ref('norm_cmg_sales_group')}} CSG ON CT.SALES_GROUP_CODE = CSG.SALES_GROUP_CODE
LEFT JOIN {{ref('norm_data_name')}} DN ON CSG.DESCRIPTION_ID = DN.NAME_ID AND DN.LANGUAGE_CODE = 1