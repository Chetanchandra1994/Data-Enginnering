{{
  config(
    full_refresh = true,
    materialized="dynamic_table",
    target_lag="downstream",
    snowflake_warehouse= var('task_warehouse'),
    alias = "dim_Prospect",
    schema= "dimensions",
    post_hook = "ALTER DYNAMIC TABLE {{ this }} SET LOG_LEVEL = ERROR",
    meta = {
    'table_key': 'PROSPECT_SK',
    'tests': {
      'unique_sk':{}    
    }
  }
  )
}}

SELECT 
	{{ dbt_utils.generate_surrogate_key(['CUSTOMER_UUID']) }} :: VARCHAR(32) AS PROSPECT_SK,   -- SURROGATE KEY
  CUSTOMER_UUID :: STRING  					    AS PROSPECT_CODE,
	NAME :: STRING										    AS PROSPECT_NAME
FROM {{ref('norm_customer')}}
WHERE PROSPECT = TRUE

