{{
  config(
    full_refresh = true,
    materialized="dynamic_table",
    target_lag="downstream",
    snowflake_warehouse= var('task_warehouse'),
    alias = "dim_Pay_By_Profile",
    schema= "dimensions",
    post_hook = "ALTER DYNAMIC TABLE {{ this }} SET LOG_LEVEL = ERROR"
  )
}}

SELECT
    {{ dbt_utils.generate_surrogate_key(["CONCAT(CUST_NO, '-PB1')", dbt_utils.generate_surrogate_key(['CUST_NO']) ]) }} as PB_PROFILE_SK
   ,{{ dbt_utils.generate_surrogate_key(['CUST_NO']) }} AS CUSTOMER_SK
   ,CONCAT(CUST_NO, '-PB1') AS PB_PROFILE_CODE   
   ,NAME AS PROFILE_NAME

FROM {{ref('norm_customer')}} 
    WHERE PROSPECT = false

