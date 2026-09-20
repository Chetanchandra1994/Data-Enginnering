{{
  config(
    full_refresh = true,
    materialized="dynamic_table",
    target_lag="downstream",
    snowflake_warehouse= var('task_warehouse'),
    alias = "dim_Business_Unit",
    schema= "dimensions",
    post_hook = "ALTER DYNAMIC TABLE {{ this }} SET LOG_LEVEL = ERROR",
    meta = {
    'table_key': 'BUSINESS_UNIT_SK',
    'tests': {
      'unique_sk':{}    
    }
  }
  )
}}


SELECT 
{{ dbt_utils.generate_surrogate_key(["BU.BUSINESS_UNIT_CODE"]) }}	AS BUSINESS_UNIT_SK,					-- SURROGATE KEY
	BU.BUSINESS_UNIT_CODE		    AS BUSINESS_UNIT_CODE,
  DN.NAME						          AS BUSINESS_UNIT_NAME_FR,
	DN1.NAME					          AS BUSINESS_UNIT_NAME_EN,
	IFNULL(DN2.NAME,DN.NAME)	  AS BUSINESS_UNIT_GROUP_NAME_FR, --added
	IFNULL(DN3.NAME,DN.NAME)	  AS BUSINESS_UNIT_GROUP_NAME_EN,
	BU.RDM_ACTIVE_STATUS_CODE 	AS ACTIVE_STATUS_CODE		-- RDM - ACTIVE STATUS
FROM {{ref('norm_business_unit')}} BU
	LEFT JOIN {{ref('norm_data_name')}} DN ON BU.BUSINESS_UNIT_NAME_ID = DN.NAME_ID AND DN.LANGUAGE_CODE = 2
  LEFT JOIN {{ref('norm_data_name')}} DN1 ON BU.BUSINESS_UNIT_NAME_ID = DN1.NAME_ID AND DN1.LANGUAGE_CODE = 1
	LEFT JOIN {{ref('norm_data_name')}} DN2 ON BU.COMPANY_REFERENCE_NAME_ID = DN2.NAME_ID AND DN2.LANGUAGE_CODE = 2
	LEFT JOIN {{ref('norm_data_name')}} DN3 ON BU.COMPANY_REFERENCE_NAME_ID = DN3.NAME_ID AND DN3.LANGUAGE_CODE = 1
