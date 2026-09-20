{{
  config(
    materialized = "view",
    alias = "eis_office_name_map",
    schema='enterprise_MANUAL'
  )
}}

SELECT 
    UPPER(TRIM(BRANCH_OFFICE_CODE::string)) AS BRANCH_OFFICE_CODE
    ,UPPER(TRIM(OFFICE_CODE::string)) AS OFFICE_CODE
    ,UPPER(TRIM(OFFICE_NAME::string)) AS OFFICE_NAME
from {{ ref ('prep_manual_eis_office_name_map') }} 