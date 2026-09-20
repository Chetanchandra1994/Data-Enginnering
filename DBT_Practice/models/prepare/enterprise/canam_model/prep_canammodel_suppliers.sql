{{
  config(
    materialized = "view",
    alias = "suppliers",
    schema='enterprise_model'
  )
}}

SELECT 
      DATA:CompanyCode                        as CompanyCode
    , DATA:NatureOfSupply.NatureOfSupplyCode  as NatureOfSupplyCode
    , DATA:OurCustomerNumber                  as OurCustomerNumber
    , DATA:SourceSystem                       as SourceSystem
    , DATA:SupplierCode                       as SupplierCode
    , DATA:SupplierTypeCode                   as SupplierTypeCode
    , BFP.VALUE:Name                          as SupplierName
    , DATA:SupplierStatusCode                 as SupplierStatusCode
    , DATA:src_system_operation               as src_system_operation
    -- ARRAYS:
    , DATA:BusinessPartnerIdentifiers         as BusinessPartnerIdentifiers_ARRAY
    , DATA:BuyFromProfiles                    as BuyFromProfiles_ARRAY
    , DATA:Communications                     as Communications_ARRAY
    , DATA:InvoiceFromProfile                 as InvoiceFromProfile_ARRAY
    , DATA:Locations                          as Locations_ARRAY
    , DATA:PayToProfiles                      as PayToProfiles_ARRAY
    , DATA:ShipFromProfiles                   as ShipFromProfiles_ARRAY
    -- GCP file metadata:
    , FILENAME                                as METADATA_FILENAME 
    , FILE_ROW_NUMBER                         as METADATA_FILE_ROW_NUMBER
    , FILE_LAST_MODIFIED                      as METADATA_FILE_LAST_MODIFIED
    , START_SCAN_TIME                         as METADATA_START_SCAN_TIME
FROM {{ source("landing_enterprise_model", "SUPPLIER") }} S
LEFT JOIN LATERAL FLATTEN(INPUT => S.DATA:BuyFromProfiles, OUTER => true) BFP
WHERE 
  split(FILENAME, '_')[array_size(split(FILENAME, '_')) - 2] >=
  (SELECT min_timestamp
  FROM
      (SELECT split(FILENAME, '_')[array_size(split(FILENAME, '_')) - 2] AS min_timestamp, split(FILENAME, '/')[3] AS type_file
      FROM {{ source("landing_enterprise_model", "SUPPLIER") }}
      WHERE type_file LIKE 'fullload%'
      QUALIFY ROW_NUMBER() OVER (ORDER BY min_timestamp DESC) = 1)
  )
QUALIFY ROW_NUMBER() OVER (PARTITION BY DATA:SupplierCode, metadata_file_last_modified, FILE_ROW_NUMBER ORDER BY DATA:SupplierCode, metadata_file_last_modified, FILE_ROW_NUMBER ) = 1