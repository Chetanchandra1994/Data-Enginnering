{{
  config(
    materialized = "view",
    alias = "branch_office_business_unit_map",
    schema='enterprise_MANUAL'
  )
}}

SELECT 
    OFFICE_CODE
    ,BRANCH_OFFICE_CODE
    ,BUSINESS_UNIT_CODE
from {{ source("landing_enterprise", "BRANCH_OFFICE_BUSINESS_UNIT_MAP") }}