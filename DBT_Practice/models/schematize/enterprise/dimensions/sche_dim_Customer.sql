{{
  config(
    full_refresh = true,
    materialized="dynamic_table",
    target_lag="downstream",
    snowflake_warehouse= var('task_warehouse'),
    alias = "dim_Customer",
    schema= "dimensions",
    post_hook = "ALTER DYNAMIC TABLE {{ this }} SET LOG_LEVEL = ERROR",
    meta = {
    'table_key': 'CUSTOMER_SK',
    'tests': {
      'unique_sk':{}    
    }
  }
  )
}}

WITH SS_BUSINESS_PARTNER_PARENT AS 
(
	SELECT
		C.ORIG_CUST_NO,
		C.NAME
	FROM {{ref('norm_customer')}} C
	WHERE CUST_NO = ORIG_CUST_NO
), SS_BUSINESS_PARTNER AS 
(
	SELECT
		C_CHILD.CUST_NO AS ORIG_CUST_NO,
		C_PARENT.ORIG_CUST_NO AS PARENT_ORIG_CUST_NO,
		C_PARENT.NAME
	FROM {{ref('norm_customer')}} C_CHILD
		INNER JOIN SS_BUSINESS_PARTNER_PARENT C_PARENT ON C_CHILD.ORIG_CUST_NO = C_PARENT.ORIG_CUST_NO
	WHERE C_CHILD.CUST_NO <> C_CHILD.ORIG_CUST_NO
	UNION ALL
	SELECT
		ORIG_CUST_NO,
		ORIG_CUST_NO AS PARENT_ORIG_CUST_NO,
		NAME
	FROM SS_BUSINESS_PARTNER_PARENT
)

SELECT
  {{ dbt_utils.generate_surrogate_key(['C.CUST_NO']) }} :: VARCHAR(32)  			AS CUSTOMER_SK, -- SURROGATE KEY
	C.CUST_NO :: STRING								                    			AS CUSTOMER_CODE,
	C.NAME :: STRING 										            			AS CUSTOMER_NAME,
	C.RDM_CUSTOMER_CLASS_NAME_FR :: STRING 											AS CUSTOMER_CLASS_NAME_FR,
	C.RDM_CUSTOMER_CLASS_NAME_EN :: STRING 											AS CUSTOMER_CLASS_NAME_EN,
	SBP.PARENT_ORIG_CUST_NO :: STRING						                        AS BUSINESS_PARTNER_CODE,
	SBP.NAME :: STRING									                            AS BUSINESS_PARTNER_NAME
FROM {{ref('norm_customer')}} C
	LEFT JOIN SS_BUSINESS_PARTNER SBP ON C.ORIG_CUST_NO = SBP.ORIG_CUST_NO
WHERE C.PROSPECT = FALSE AND C.CUST_NO IS NOT NULL
