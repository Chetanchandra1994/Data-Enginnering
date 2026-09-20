{{
  config(
    materialized = "view",
    alias = "eis_office_name_map",
    schema='CANAM_MANUAL'
  )
}}

SELECT 
    BRANCH_OFFICE_CODE
    ,OFFICE_CODE
    ,OFFICE_NAME
from {{ source("landing_canam", "EIS_OFFICE_NAME_MAP") }}