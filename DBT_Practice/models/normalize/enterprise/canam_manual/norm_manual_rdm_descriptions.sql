{{
  config(
    materialized = "view",
    alias = "rdm_descriptions",
    schema='enterprise_MANUAL'
  )
}}

select 
APPLICATIONCODE::string as APPLICATIONCODE
, DOMAINCODE::string as DOMAINCODE
, VALUE::string as VALUE
, LANGUAGE::string as LANGUAGE
, NAME::string as NAME
from {{ ref ('prep_manual_rdm_descriptions') }} 