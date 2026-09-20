{{
  config(
    full_refresh = true,
    materialized="dynamic_table",
    target_lag="downstream",
    snowflake_warehouse= var('task_warehouse'),
    alias = "dim_Currency",
    schema= "dimensions",
    post_hook = "ALTER DYNAMIC TABLE {{ this }} SET LOG_LEVEL = ERROR",
    meta = {
    'table_key': 'CURRENCY_SK',
    'tests': {
      'unique_sk':{},
      'null_values':{
                'columns':[
                    'CURRENCY_CODE'
                ]
            }

    }
  }
  )
}}

SELECT DISTINCT 
    {{ dbt_utils.generate_surrogate_key(['RDM.STANDARD_APPLICATION_VALUE']) }} AS CURRENCY_SK,   -- SURROGATE KEY
    RDM.STANDARD_APPLICATION_VALUE                       AS CURRENCY_CODE,
    RDM.STANDARD_APPLICATION_VALUE_NAME_FR 											AS CURRENCY_NAME_FR,
	  RDM.STANDARD_APPLICATION_VALUE_NAME_EN											AS CURRENCY_NAME_EN
FROM {{ref('gov_referencedata_rdm')}} RDM
WHERE UPPER(RDM.BUSINESS_APPLICATION_DOMAIN_CODE) = 'CURRENCY'
	AND UPPER(RDM.STANDARD_DOMAIN_APPLICATION_CODE) = 'CURRENCY'
