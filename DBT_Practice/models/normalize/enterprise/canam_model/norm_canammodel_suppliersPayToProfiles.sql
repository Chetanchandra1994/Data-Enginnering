{{
  config(
    materialized = "view",
    alias = "suppliers_paytoprofiles",
    schema='canam_model'
  )
}}


SELECT
--- For data duplicates in the same file
  DISTINCT
      SUPPLIERCODE::NUMBER(38,0)    as SUPPLIERCODE
    , CURRENCYCODE::string          as PT_CURRENCYCODE
    , NAME::string                  as PT_NAME
    , PAYMENTMETHODCODE::string     as PT_PAYMENTMETHODCODE
    , PAYMENTTERMCODE::string       as PT_PAYMENTTERMCODE
    , PROFILECODE::string           as PT_PROFILECODE
    , SITECODE::string              as PT_SITECODE
    , SITEID::number(38,0)          as PT_SITEID
    , STATUSCODE::string            as PT_STATUSCODE
    -- Arrays:
    , LOCATIONS_ARRAY               as PT_LOCATIONS_ARRAY
    , COMMUNICATIONS_ARRAY          as PT_COMMUNICATIONS_ARRAY
from {{ref('prep_canammodel_suppliersPayToProfiles')}}
QUALIFY ROW_NUMBER() OVER (PARTITION BY SUPPLIERCODE, IFF(SUPPLIERCODE=PT_PROFILECODE, PT_SITECODE, PT_PROFILECODE) ORDER BY TO_TIMESTAMP_NTZ(metadata_file_last_modified) desc, METADATA_FILE_ROW_NUMBER desc,IFF(SUPPLIERCODE=PT_PROFILECODE, PT_SITECODE, PT_PROFILECODE)) = 1
--qualify metadata_file_last_modified = max(metadata_file_last_modified) OVER (PARTITION BY suppliercode)
