{{
  config(
    full_refresh = true,
    materialized="dynamic_table",
    target_lag="downstream",
    snowflake_warehouse= var('task_warehouse'),
    alias = "bridge_customer",
    schema= "bridges",
    post_hook = "ALTER DYNAMIC TABLE {{ this }} SET LOG_LEVEL = ERROR"
  )
}}

    SELECT DISTINCT
      CUST_NO			    AS CUSTOMER_SK, 				      -- Foreign Key
      'spm'		        AS ORIGIN_APPLICATION_CODE, 	-- RDM - APPLICATION
      CUST_NO 		    AS CUSTOMER_CODE
      FROM {{ref('norm_customer')}}
      WHERE PROSPECT = FALSE AND CUST_NO IS NOT NULL
  UNION ALL
    SELECT DISTINCT
      CUST_NO			    AS CUSTOMER_SK,               -- Foreign Key
      'oracle-ebs'	  AS ORIGIN_APPLICATION_CODE,
      ORIG_CUST_NO 	  AS CUSTOMER_CODE
      FROM {{ref('norm_customer')}}
      WHERE PROSPECT = FALSE AND ORIG_CUST_NO IS NOT NULL

