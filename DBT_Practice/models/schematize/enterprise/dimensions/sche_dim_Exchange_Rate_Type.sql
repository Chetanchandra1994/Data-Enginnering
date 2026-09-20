{{
  config(
    full_refresh = true,
    materialized="dynamic_table",
    target_lag="downstream",
    snowflake_warehouse= var('task_warehouse'),
    alias = "dim_Exchange_Rate_Type",
    schema= "dimensions",
    post_hook = "ALTER DYNAMIC TABLE {{ this }} SET LOG_LEVEL = ERROR",
    meta = {
    'table_key': 'EXCHANGE_RATE_TYPE_SK',
    'tests': {
      'unique_sk':{}    
    }
  }
  )
}}


SELECT DISTINCT
{{ dbt_utils.generate_surrogate_key(["STANDARD_APPLICATION_VALUE"]) }}			      AS EXCHANGE_RATE_TYPE_SK,		        -- SURROGATE KEY
STANDARD_APPLICATION_VALUE			                                                  AS EXCHANGE_RATE_TYPE_CODE,		      -- RDM - EXCHANGE RATE TYPE
STANDARD_APPLICATION_VALUE_NAME_FR	                                              AS EXCHANGE_RATE_TYPE_NAME_FR,
STANDARD_APPLICATION_VALUE_NAME_EN	                                              AS EXCHANGE_RATE_TYPE_NAME_EN
FROM {{ref('gov_referencedata_rdm')}}
WHERE UPPER(BUSINESS_APPLICATION_DOMAIN_CODE) = 'EXCHANGERATETYPE'
AND UPPER(STANDARD_DOMAIN_APPLICATION_CODE) = 'EXCHANGERATETYPE'
AND UPPER(STANDARD_APPLICATION_CODE) = 'enterprise'