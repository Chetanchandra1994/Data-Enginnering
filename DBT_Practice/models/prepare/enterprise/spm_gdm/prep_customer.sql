{{
  config(
    materialized = "view",
    alias = "customer",
    schema='spm_gdm'
  )
}}


SELECT
DATA:"customer_uuid" AS CUSTOMER_UUID
,DATA:"cust_no" AS CUST_NO
,DATA:"name" AS NAME
,DATA:"sort_name" AS SORT_NAME
,DATA:"cust_type" AS CUST_TYPE
,DATA:"prospect" AS PROSPECT
,DATA:"address1" AS ADDRESS1
,DATA:"address2" AS ADDRESS2
,DATA:"city" AS CITY
,DATA:"county" AS COUNTY
,DATA:"st" AS ST
,DATA:"country" AS COUNTRY
,DATA:"zip_code" AS ZIP_CODE
,DATA:"telephone" AS TELEPHONE
,DATA:"telex_twx" AS TELEX_TWX
,DATA:"language_code" AS LANGUAGE_CODE
,DATA:"orig_cust_no" AS ORIG_CUST_NO
,DATA:"affiliated" AS AFFILIATED
,DATA:"affiliation_code" AS AFFILIATION_CODE
,DATA:"contact" AS CONTACT
,DATA:"invoicing_type" AS INVOICING_TYPE
,DATA:"memo" AS MEMO
,DATA:"fst_license" AS FST_LICENSE
,DATA:"pst_license" AS PST_LICENSE
,DATA:"fst_exempt" AS FST_EXEMPT
,DATA:"pst_exempt" AS PST_EXEMPT
,DATA:"buyer_name" AS BUYER_NAME
,DATA:"royalty" AS ROYALTY
,DATA:"on_hold" AS ON_HOLD
,DATA:"orig_bill_to" AS ORIG_BILL_TO
,DATA:"max_deck_bundl_weight" AS MAX_DECK_BUNDL_WEIGHT
,DATA:"max_deck_bundl_pieces" AS MAX_DECK_BUNDL_PIECES
,DATA:"deck_bundl_pieces_tolerance" AS DECK_BUNDL_PIECES_TOLERANCE
,DATA:"shop_city" AS SHOP_CITY
,DATA:"shop_st" AS SHOP_ST
,DATA:"shop_country" AS SHOP_COUNTRY
,DATA:"shop_zip_code" AS SHOP_ZIP_CODE
,DATA:"shop_phone" AS SHOP_PHONE
,DATA:"shop_fax" AS SHOP_FAX
,DATA:"spn_member" AS SPN_MEMBER
,DATA:"shop_address1" AS SHOP_ADDRESS1
,DATA:"shop_address2" AS SHOP_ADDRESS2
,DATA:"sun_builder_authorized" AS SUN_BUILDER_AUTHORIZED
,DATA:"web_address" AS WEB_ADDRESS
,DATA:"shop_like_office" AS SHOP_LIKE_OFFICE
,DATA:"email_address" AS EMAIL_ADDRESS
,DATA:"quotation_transmission_mode" AS QUOTATION_TRANSMISSION_MODE
,DATA:"lump_sum" AS LUMP_SUM
,DATA:"sales_fax" AS SALES_FAX
,DATA:"sales_email_address" AS SALES_EMAIL_ADDRESS
,DATA:"shop_county_code" AS SHOP_COUNTY_CODE
,DATA:"active" AS ACTIVE
,DATA:"erector_privilege" AS ERECTOR_PRIVILEGE
,DATA:"CounterSaleCustomer" AS COUNTERSALECUSTOMER
,DATA:"SAPTransfer" AS SAPTRANSFER
,DATA:"last_updated_datetime" AS LAST_UPDATED_DATETIME
,DATA:"ods_id" AS ODS_ID
,DATA:"_rowid" AS ROW_ID
,DATA:"src_system_operation" AS SRC_SYSTEM_OPERATION
,DATA:"ipaas_updated_date" AS IPAAS_UPDATED_DATE
,DATA:"CreatedDate" AS CREATED_DATE
,DATA:"ModifiedDate" AS MODIFIED_DATE
,DATA:"CreatedBy" AS CREATED_BY
,DATA:"ModifiedBy" AS MODIFIED_BY
,DATA:"DataEventTimestamp" AS DATA_EVENT_TIMESTAMP
,FILENAME                            AS METADATA_FILENAME 
,FILE_ROW_NUMBER                     AS METADATA_FILE_ROW_NUMBER
,FILE_LAST_MODIFIED                  AS METADATA_FILE_LAST_MODIFIED
,START_SCAN_TIME                     AS METADATA_START_SCAN_TIME
,{{ dbt_utils.generate_surrogate_key(['DATA:"customer_uuid"']) }} as TABLE_SK
,COALESCE(TO_TIMESTAMP_TZ(DATA:"DataEventTimestamp"),TO_TIMESTAMP_NTZ(DATEADD(microsecond, FILE_ROW_NUMBER,TO_TIMESTAMP_NTZ(DATA:"ipaas_updated_date"::string)))) as QUALIFY_TIMESTAMP

from {{ source("landing_spm_gdm", "CUSTOMER") }}
-- to only take the files after the last fullLoad
  WHERE 
  split(FILENAME, '_')[array_size(split(FILENAME, '_')) - 2] >=
    (SELECT min_timestamp
  FROM
      (SELECT split(FILENAME, '_')[array_size(split(FILENAME, '_')) - 2] AS min_timestamp, split(FILENAME, '/')[3] AS type_file
      FROM {{ source("landing_spm_gdm", "CUSTOMER") }}
      WHERE type_file LIKE 'fullload%'
      QUALIFY ROW_NUMBER() OVER (ORDER BY min_timestamp DESC) = 1)
    )
 