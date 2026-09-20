{{
  config(
    materialized = "view",
    alias = "purchasing_agreement_register",
    schema='GOOGLESHEET'
  )
}}

with raw_data_dedupplicated as (
      SELECT *
  FROM {{ref('prep_purchasing_agreement_register')}}
  QUALIFY ROW_NUMBER() OVER (PARTITION BY START_DATE,END_DATE,VENDOR_ID,CONTRACT_TYPE ORDER BY TO_TIMESTAMP_NTZ(HORODATAGE) DESC) = 1 
)


SELECT
TO_TIMESTAMP(raw_data_dedupplicated.HORODATAGE) as HORODATAGE
, raw_data_dedupplicated.VENDOR_ID::string as VENDOR_ID
, raw_data_dedupplicated.VENDOR_NAME::string as VENDOR_NAME
, raw_data_dedupplicated.START_DATE::date as START_DATE
, raw_data_dedupplicated.END_DATE::date as  END_DATE
, raw_data_dedupplicated.PAYMENT_TERMS::string as PAYMENT_TERMS
, raw_data_dedupplicated.DISCOUNT::string as DISCOUNT
, raw_data_dedupplicated.INCOTERMS::string as INCOTERMS
, raw_data_dedupplicated.VOLUME_DISCOUNT::string as VOLUME_DISCOUNT
, raw_data_dedupplicated.NEGOCIATED_BY::string as NEGOCIATED_BY
, raw_data_dedupplicated.CONTRACT_ORIGIN::string as CONTRACT_ORIGIN
, raw_data_dedupplicated.CONTRACT_TYPE::string as CONTRACT_TYPE
, raw_data_dedupplicated.ARCHIVED as ARCHIVED
, raw_data_dedupplicated.LINK::string as LINK
from raw_data_dedupplicated WHERE raw_data_dedupplicated.VENDOR_ID IS NOT NULL AND raw_data_dedupplicated.VENDOR_NAME IS NOT NULL
