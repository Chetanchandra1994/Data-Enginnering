{{
  config(
    full_refresh = true,
    materialized="dynamic_table",
    target_lag="downstream",
    snowflake_warehouse= var('task_warehouse'),
    alias = "dim_Sales_Quote",
    schema= "dimensions",
    post_hook = "ALTER DYNAMIC TABLE {{ this }} SET LOG_LEVEL = ERROR",
    meta = {
    'table_key': 'SALES_QUOTE_SK',
    'tests': {
      'unique_sk':{}    
    }
  }
  )
}}

SELECT
	{{ dbt_utils.generate_surrogate_key(['MASTER_JOB_NO','JOB_NO','OFFICE_CODE',"'spm'"]) }} AS SALES_QUOTE_SK,   -- SURROGATE KEY
	MASTER_JOB_NO										  AS SALES_QUOTE_CODE,
	JOB_NO												    AS SALES_QUOTE_ALTERNATIVE_CODE,
	OFFICE_CODE											  AS SRC_OFFICE_CODE,
	'spm'												      AS ORIGIN_APPLICATION_CODE,						-- RDM - APPLICATION
  RDM_SALES_OFFICE_DEPARTMENT_CODE  AS SALES_OFFICE_DEPARTMENT_CODE,			-- RDM - SALES OFFICE DEPARTMENT
	INSCRP_DATE											  AS SALES_QUOTE_INSCRIPTION_DATE,
	BID_DATE											    AS SALES_QUOTE_CLOSING_DATE,
	RDM_PROJECT_STEP 									AS SALES_QUOTE_STATUS_CODE,						-- RDM - PROJECT STEP
	UPPER(CONCAT(IFNULL(TRIM(ADRESSE_LIV_1),''),' ',
		IFNULL(TRIM(ADRESSE_LIV_2),''),' ',
		IFNULL(TRIM(ADRESSE_LIV_3),''))) 				AS SALES_QUOTE_SHIPPING_ADDRESS,
	UPPER(ZIP_CODE) 									AS SALES_QUOTE_SHIPPING_POSTAL_CODE,
	UPPER(CITY)											AS SALES_QUOTE_SHIPPING_CITY_CODE,			-- RDM - CITY
	UPPER(COUNTY_CODE)									AS SALES_QUOTE_SHIPPING_COUNTY_CODE,		-- RDM - COUNTY
	UPPER(COUNTRY)										AS SALES_QUOTE_SHIPPING_COUNTRY_CODE,		-- RDM - COUNTRY	
  RDM_ACTIVE_STATUS_CODE							AS SALES_QUOTE_ACTIVE_STATUS_CODE	     	-- RDM - ACTIVE STATUS
FROM {{ref('norm_qc_quotation')}}
WHERE PROJCT_STEP IS NOT NULL