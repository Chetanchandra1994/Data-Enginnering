{{
  config(
    full_refresh = true,
    materialized="dynamic_table",
    target_lag="downstream",
    snowflake_warehouse= var('task_warehouse'),
    alias = "dim_Financial_Company",
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

SELECT DISTINCT
	{{ dbt_utils.generate_surrogate_key(['RDM.STANDARD_APPLICATION_VALUE']) }} :: VARCHAR(32)   AS FINANCIAL_COMPANY_SK,
	RDM.STANDARD_APPLICATION_VALUE :: STRING                                                    AS FINANCIAL_COMPANY_CODE,
  RDM.STANDARD_APPLICATION_VALUE_NAME_FR ::  STRING                                           AS FINANCIAL_COMPANY_NAME_FR,
  RDM.STANDARD_APPLICATION_VALUE_NAME_EN :: STRING                                            AS FINANCIAL_COMPANY_NAME_EN
FROM 
  {{ref('gov_referencedata_rdm')}} RDM
WHERE UPPER(RDM.BUSINESS_APPLICATION_DOMAIN_CODE) = 'FINANCIALCOMPANY' 
AND UPPER(RDM.STANDARD_DOMAIN_APPLICATION_CODE) = 'FINANCIALCOMPANY'