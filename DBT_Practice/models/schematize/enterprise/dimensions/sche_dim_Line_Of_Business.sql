{{
  config(
    full_refresh = true,
    materialized="dynamic_table",
    target_lag="downstream",
    snowflake_warehouse= var('task_warehouse'),
    alias = "dim_Line_Of_Business",
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
  {{dbt_utils.generate_surrogate_key(['BU.BUSINESS_UNIT_CODE']) }} :: VARCHAR(32)               AS BUSINESS_UNIT_SK,               -- SURROGATE KEY
  'spm' :: STRING                                                                               AS ORIGIN_APPLICATION_CODE,
  BU.BUSINESS_UNIT_CODE :: STRING                                                               AS ORIGIN_BUSINESS_UNIT_CODE,
  BU.RDM_LINE_OF_BUSINESS_CODE :: STRING                                                        AS LINE_OF_BUSINESS_CODE, 
  BU.RDM_LINE_OF_BUSINESS_NAME_FR :: STRING                                                     AS LINE_OF_BUSINESS_NAME_FR,
  BU.RDM_LINE_OF_BUSINESS_NAME_EN :: STRING                                                     AS LINE_OF_BUSINESS_NAME_EN,
  BU.RDM_ACTIVE_STATUS_CODE :: STRING                                                           AS ACTIVE_STATUS_CODE
FROM {{ref('norm_business_unit')}} BU
WHERE BU.RDM_LINE_OF_BUSINESS_CODE <> 'Not Found'