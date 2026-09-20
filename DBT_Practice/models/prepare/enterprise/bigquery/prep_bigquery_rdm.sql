{{
  config(
    materialized = "view",
    alias = "rdm",
    schema='BIGQUERY'
  )
}}

with 

raw_data as (
  
  SELECT 
    f.VALUE:DomainCode              as BUSINESS_APPLICATION_DOMAIN_CODE
    , f.VALUE:Value                 as BUSINESS_APPLICATION_VALUE
    , DATA:BUSINESS_APPLICATION_CODE  as BUSINESS_APPLICATION_CODE
    , DATA:EffectiveOn              as EffectiveOn
    , g.VALUE:DomainCode            as STANDARD_DOMAIN_APPLICATION_CODE
    , g.VALUE:Value                 as STANDARD_APPLICATION_VALUE
    , DATA:exported_datetime_utc    as exported_datetime_utc
  
  from {{ source("landing_bigquery", "RDM") }},
  TABLE(FLATTEN(INPUT => DATA:BusinessApplication)) f, 
  TABLE(FLATTEN(INPUT => DATA:StandardApplication)) g
)

SELECT * from raw_data
