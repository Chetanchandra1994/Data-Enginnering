{{
  config(
    materialized = "view",
    alias = "suppliers_invoicefromprofiles",
    schema='canam_model'
  )
}}

select 
    
      DATA:SupplierCode             as SupplierCode
    , DATA:src_system_operation     as src_system_operation
    , f.VALUE:CurrencyCode            as CurrencyCode
    , f.VALUE:Name                    as Name
    , f.VALUE:PaymentMethodCode       as PaymentMethodCode
    , f.VALUE:PaymentTermCode         as PaymentTermCode
    , f.VALUE:ProfileCode             as ProfileCode
    , f.VALUE:SiteCode                as SiteCode
    , f.VALUE:SiteID                  as SiteID
    , f.VALUE:StatusCode              as StatusCode
    -- Arrays:
    , f.VALUE:Locations               as Locations_ARRAY
    , f.VALUE:Communications          as Communications_ARRAY
    -- GCP file metadata:
    , FILENAME                      as METADATA_FILENAME 
    , FILE_ROW_NUMBER               as METADATA_FILE_ROW_NUMBER
    , FILE_LAST_MODIFIED            as METADATA_FILE_LAST_MODIFIED
    , START_SCAN_TIME               as METADATA_START_SCAN_TIME

from {{ source("landing_canam_model", "SUPPLIER") }},
TABLE(FLATTEN(INPUT => DATA:InvoiceFromProfile)) f
WHERE 
  split(FILENAME, '_')[array_size(split(FILENAME, '_')) - 2] >=
  (SELECT min_timestamp
  FROM
      (SELECT split(FILENAME, '_')[array_size(split(FILENAME, '_')) - 2] AS min_timestamp, split(FILENAME, '/')[3] AS type_file
      FROM {{ source("landing_canam_model", "SUPPLIER") }}
      WHERE type_file LIKE 'fullload%'
      QUALIFY ROW_NUMBER() OVER (ORDER BY min_timestamp DESC) = 1)
  )