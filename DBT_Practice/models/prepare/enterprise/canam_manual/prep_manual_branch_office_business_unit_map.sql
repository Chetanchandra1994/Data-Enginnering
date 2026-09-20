{{
  config(
    materialized = "view",
    alias = "branch_office_business_unit_map",
    schema='CANAM_MANUAL'
  )
}}

SELECT 
    OFFICE_CODE
    ,BRANCH_OFFICE_CODE
    ,BUSINESS_UNIT_CODE
from {{ source("landing_canam", "BRANCH_OFFICE_BUSINESS_UNIT_MAP") }}