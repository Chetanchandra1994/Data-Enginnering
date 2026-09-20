{{
  config(
    materialized = "view",
    alias = "rdm_descriptions",
    schema='CANAM_MANUAL'
  )
}}


select 
APPLICATIONCODE
, DOMAINCODE
, VALUE
, LANGUAGE
, NAME
from {{ source("landing_canam", "RDM_DESCRIPTIONS") }}