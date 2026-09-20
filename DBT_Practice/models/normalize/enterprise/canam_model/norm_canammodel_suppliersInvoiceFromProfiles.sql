{{
  config(
    materialized = "view",
    alias = "suppliers_invoicefromprofiles",
    schema='enterprise_model'
  )
}}


SELECT
--- For data duplicates in the same file
  DISTINCT
      SUPPLIERCODE::NUMBER(38,0)    as SUPPLIERCODE
    , CURRENCYCODE::string          as IF_CURRENCYCODE
    , NAME::string                  as IF_NAME
    , PAYMENTMETHODCODE::string     as IF_PAYMENTMETHODCODE
    , PAYMENTTERMCODE::string       as IF_PAYMENTTERMCODE
    , PROFILECODE::string           as IF_PROFILECODE
    , SITECODE::string              as IF_SITECODE
    , SITEID::number(38,0)          as IF_SITEID
    , STATUSCODE::string            as IF_STATUSCODE
    -- Arrays:
    , LOCATIONS_ARRAY               as IF_LOCATIONS_ARRAY
    , COMMUNICATIONS_ARRAY          as IF_COMMUNICATIONS_ARRAY
from {{ref('prep_enterprisemodel_suppliersInvoiceFromProfiles')}}
QUALIFY ROW_NUMBER() OVER (PARTITION BY SUPPLIERCODE, IFF(SUPPLIERCODE=IF_PROFILECODE, IF_SITECODE, IF_PROFILECODE) ORDER BY TO_TIMESTAMP_NTZ(metadata_file_last_modified) desc, METADATA_FILE_ROW_NUMBER desc,IFF(SUPPLIERCODE=IF_PROFILECODE, IF_SITECODE, IF_PROFILECODE)) = 1
--qualify metadata_file_last_modified = max(metadata_file_last_modified) OVER (PARTITION BY suppliercode)


