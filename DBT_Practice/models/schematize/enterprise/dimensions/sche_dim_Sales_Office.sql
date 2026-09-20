{{
  config(
    full_refresh = true,
    materialized="dynamic_table",
    target_lag="downstream",
    snowflake_warehouse= var('task_warehouse'),
    alias = "dim_Sales_Office",
    schema= "dimensions",
    post_hook = "ALTER DYNAMIC TABLE {{ this }} SET LOG_LEVEL = ERROR",
    meta = {
    'table_key': 'SALES_OFFICE_SK',
    'tests': {
      'unique_sk':{}    
    }
  }
  )
}}

SELECT 
  {{dbt_utils.generate_surrogate_key(['QO.OFFICE_CODE']) }} :: VARCHAR(32)               AS SALES_OFFICE_SK,               -- SURROGATE KEY
  'spm' :: STRING                                                                        AS ORIGIN_APPLICATION_CODE,
  QO.OFFICE_CODE :: STRING                                                               AS ORIGIN_OFFICE_CODE,
  QO.RDM_SALES_OFFICE_DEPARTMENT_CODE :: STRING                                          AS SALES_OFFICE_DEPARTMENT_CODE,  -- RDM - SALES OFFICE DEPARTMENT
  QO.RDM_SALES_OFFICE_DEPARTMENT_NAME_FR :: STRING                                       AS SALES_OFFICE_DEPARTMENT_NAME_FR,
  QO.RDM_SALES_OFFICE_DEPARTMENT_NAME_EN :: STRING                                       AS SALES_OFFICE_DEPARTMENT_NAME_EN,
  QO.RDM_COUNTRY_CODE :: STRING                                                          AS SALES_OFFICE_DEPARTMENT_COUNTRY_CODE,
  QO.RDM_COUNTRY_NAME_FR :: STRING                                                       AS SALES_OFFICE_DEPARTMENT_COUNTRY_NAME_FR,
  QO.RDM_COUNTRY_NAME_EN :: STRING                                                       AS SALES_OFFICE_DEPARTMENT_COUNTRY_NAME_EN,
  QO.RDM_ACTIVE_STATUS_CODE :: STRING                                                    AS ACTIVE_STATUS_CODE
  FROM {{ref('norm_qc_office')}} QO
  WHERE QO.RDM_SALES_OFFICE_DEPARTMENT_CODE <> 'Not Found'
