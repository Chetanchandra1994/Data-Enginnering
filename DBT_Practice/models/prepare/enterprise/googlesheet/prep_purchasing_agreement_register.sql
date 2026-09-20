{{
  config(
    materialized = "view",
    alias = "purchasing_agreement_register",
    schema='GOOGLESHEET'
  )
}}


SELECT
  data:input_timestamp as HORODATAGE
, data:supplier_number as VENDOR_ID
, data:supplier_name as VENDOR_NAME
, data:effectivity_date as START_DATE
, data:expiration_date as END_DATE
, data:payment_terms as PAYMENT_TERMS
, data:early_discount_if_applicable as DISCOUNT
, data:incoterms as INCOTERMS
, data:volume_rebate_included as VOLUME_DISCOUNT
, data:negociated_by as NEGOCIATED_BY
, data:contract_origin as CONTRACT_ORIGIN
, data:type_of_contract as CONTRACT_TYPE
, data:link as LINK
, CASE UPPER(TRIM(data:archived::string)) WHEN 'X' THEN TRUE ELSE FALSE END as ARCHIVED
, data:exported_datetime_utc as EXPORTED_DATETIME_UTC
, FILENAME                           AS METADATA_FILENAME 
, FILE_ROW_NUMBER                    AS METADATA_FILE_ROW_NUMBER
, FILE_LAST_MODIFIED                 AS METADATA_FILE_LAST_MODIFIED
, START_SCAN_TIME                    AS METADATA_START_SCAN_TIME
from {{ source("landing_googlesheet", "PURCHASING_AGREEMENT_REGISTER") }}
WHERE 
  split(FILENAME, '_')[array_size(split(FILENAME, '_')) - 2] >=
  (SELECT min_timestamp
  FROM
      (SELECT split(FILENAME, '_')[array_size(split(FILENAME, '_')) - 2] AS min_timestamp, split(FILENAME, '/')[3] AS type_file
      FROM {{ source("landing_googlesheet", "PURCHASING_AGREEMENT_REGISTER") }}
      WHERE type_file LIKE 'fullload%'
      QUALIFY ROW_NUMBER() OVER (ORDER BY min_timestamp DESC) = 1)
  )