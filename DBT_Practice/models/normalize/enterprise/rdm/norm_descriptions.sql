{{
  config(
    materialized = "view",
    alias = "descriptions",
    schema='RDM'
  )
}}
WITH
raw_data_deduplicated as (

    SELECT *
    from {{ref('prep_descriptions')}}
    QUALIFY TO_TIMESTAMP_NTZ(exported_datetime_utc) = MAX(TO_TIMESTAMP_NTZ(exported_datetime_utc)) OVER()
)
select 
  APPLICATIONCODE::STRING AS APPLICATIONCODE
, DOMAINCODE::STRING AS DOMAINCODE
, VALUE::STRING AS VALUE
, LANGUAGE::STRING AS LANGUAGE
, NAME::STRING AS NAME
, TO_TIMESTAMP_NTZ(exported_datetime_utc::STRING) AS exported_datetime_utc
from raw_data_deduplicated