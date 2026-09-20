{{
  config(
    materialized = "view",
    alias = "rdm_descriptions",
    schema='enterprise_MANUAL'
  )
}}


select 
APPLICATIONCODE
, DOMAINCODE
, VALUE
, LANGUAGE
, NAME
from {{ source("landing_enterprise", "RDM_DESCRIPTIONS") }}