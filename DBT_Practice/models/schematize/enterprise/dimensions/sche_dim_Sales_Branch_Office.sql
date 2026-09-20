{{
  config(
    full_refresh = true,
    materialized="dynamic_table",
    target_lag="downstream",
    snowflake_warehouse= var('task_warehouse'),
    alias = "DIM_SALES_BRANCH_OFFICE",
    schema= "dimensions",
    post_hook = "ALTER DYNAMIC TABLE {{ this }} SET LOG_LEVEL = ERROR",
    meta = {
    'table_key': 'SALES_BRANCH_OFFICE_SK',
    'tests': {
      'unique_sk':{}    
    }
  }
  )
}}

SELECT 
    CAST({{dbt_utils.generate_surrogate_key(['QBO.OFFICE_CODE','QBO.BRANCH_OFFICE_CODE']) }} AS VARCHAR(32)) AS SALES_BRANCH_OFFICE_SK,
    'spm'::STRING                                              AS ORIGIN_APPLICATION_CODE,
    QBO.OFFICE_CODE::STRING                                    AS ORIGIN_OFFICE_CODE,
    QBO.BRANCH_OFFICE_CODE::STRING                             AS ORIGIN_BRANCH_OFFICE_CODE,
    EONM.OFFICE_NAME::STRING                                   AS ORIGIN_EIS_OFFICE_NAME,
    BOBUM.BUSINESS_UNIT_CODE::STRING                           AS ORIGIN_BUSINESS_UNIT_CODE,
    BOBUM.RDM_LINE_OF_BUSINESS_CODE::STRING                    AS LINE_OF_BUSINESS_CODE,
    BOBUM.RDM_LINE_OF_BUSINESS_NAME_FR::STRING                 AS LINE_OF_BUSINESS_NAME_FR,
    BOBUM.RDM_LINE_OF_BUSINESS_NAME_EN::STRING                 AS LINE_OF_BUSINESS_NAME_EN,
    QBO.RDM_SALES_OFFICE_DEPARTMENT_CODE::STRING               AS SALES_OFFICE_DEPARTMENT_CODE,
    QBO.RDM_SALES_BRANCH_OFFICE_DEPARTMENT_CODE::STRING        AS SALES_BRANCH_OFFICE_DEPARTMENT_CODE,
    QBO.RDM_SALES_BRANCH_OFFICE_DEPARTMENT_NAME_FR::STRING     AS SALES_BRANCH_OFFICE_DEPARTMENT_NAME_FR,
    QBO.RDM_SALES_BRANCH_OFFICE_DEPARTMENT_NAME_EN::STRING     AS SALES_BRANCH_OFFICE_DEPARTMENT_NAME_EN
FROM 
    {{ ref('norm_qc_branch_office') }} QBO
LEFT JOIN 
    {{ ref('norm_manual_eis_office_name_map') }} EONM
    ON QBO.OFFICE_CODE = EONM.OFFICE_CODE 
    AND QBO.BRANCH_OFFICE_CODE = EONM.BRANCH_OFFICE_CODE
LEFT JOIN 
    {{ ref('norm_branch_office_business_unit_map') }} BOBUM 
    ON QBO.OFFICE_CODE = BOBUM.OFFICE_CODE 
    AND QBO.BRANCH_OFFICE_CODE = BOBUM.BRANCH_OFFICE_CODE
WHERE QBO.RDM_SALES_OFFICE_DEPARTMENT_CODE <> 'Not Found' 
AND QBO.RDM_SALES_BRANCH_OFFICE_DEPARTMENT_CODE <> 'Not Found'     