{{
  config(
    full_refresh = true,
    materialized="dynamic_table",
    target_lag="downstream",
    snowflake_warehouse= var('task_warehouse'),
    alias = "dim_Quoted_To_Profile",
    schema= "dimensions",
    post_hook = "ALTER DYNAMIC TABLE {{ this }} SET LOG_LEVEL = ERROR",
    meta = {
    'table_key': 'QUOTED_TO_PROFILE_SK',
    'tests': {
      'unique_sk':{}    
    }
  }
  )
}}

SELECT 
	{{ dbt_utils.generate_surrogate_key(['CUSTOMER_UUID']) }} AS QUOTED_TO_PROFILE_SK,   -- SURROGATE KEY
    CUSTOMER_UUID 					AS QUOTED_TO_PROFILE_CODE,
	-- CUST_NO							AS CUSTOMER_SK, 			-- FOREIGN KEY
	-- CASE WHEN PROSPECT = TRUE 
	-- 	THEN CUSTOMER_UUID
	-- 	ELSE NULL END 				AS PROSPECT_SK				-- FOREIGN KEY
  -- FROM {{ref('norm_customer')}}

  DC.CUSTOMER_SK                                             AS CUSTOMER_SK, 
  DP.PROSPECT_SK                                             AS PROSPECT_SK

FROM {{ ref('norm_customer') }} C
LEFT JOIN {{ ref('sche_dim_Customer') }} DC 
    ON C.CUST_NO = DC.CUSTOMER_CODE
LEFT JOIN {{ ref('sche_dim_Prospect') }} DP 
    ON C.CUSTOMER_UUID = DP.PROSPECT_CODE