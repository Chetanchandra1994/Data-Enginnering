{{
  config(
    materialized = "view",
    alias = "qc_competitor",
    schema='spm_ca'
  )
}}


SELECT
DATA:"compt_no" AS COMPT_NO
,DATA:"active" AS ACTIVE
,DATA:"name" AS NAME
,DATA:"contct" AS CONTCT
,DATA:"office_addrss1" AS OFFICE_ADDRSS1
,DATA:"office_city" AS OFFICE_CITY
,DATA:"office_st" AS OFFICE_ST
,DATA:"office_country" AS OFFICE_COUNTRY
,DATA:"office_zip_code" AS OFFICE_ZIP_CODE
,DATA:"office_phone" AS OFFICE_PHONE
,DATA:"office_fax" AS OFFICE_FAX
,DATA:"prefix" AS PREFIX
,DATA:"dummy" AS DUMMY
,DATA:"office_addrss2" AS OFFICE_ADDRSS2
,DATA:"email" AS EMAIL
,DATA:"memo" AS MEMO
,DATA:"web_addrss" AS WEB_ADDRSS
,DATA:"shop_addrss1" AS SHOP_ADDRSS1
,DATA:"shop_addrss2" AS SHOP_ADDRSS2
,DATA:"shop_city" AS SHOP_CITY
,DATA:"shop_country" AS SHOP_COUNTRY
,DATA:"shop_fax" AS SHOP_FAX
,DATA:"shop_like_office" AS SHOP_LIKE_OFFICE
,DATA:"shop_phone" AS SHOP_PHONE
,DATA:"shop_st" AS SHOP_ST
,DATA:"shop_zip_code" AS SHOP_ZIP_CODE
,DATA:"_rowid" AS ROW_ID
,DATA:"CreatedBy" AS CREATED_BY
,DATA:"CreatedDate" AS CREATED_DATE
,DATA:"ModifiedDate" AS MODIFIED_DATE
,DATA:"ModifiedBy" AS MODIFIED_BY
,DATA:"src_system_operation" AS SRC_SYSTEM_OPERATION
,DATA:"ipaas_updated_date" AS IPAAS_UPDATED_DATE
,DATA:"DataEventTimestamp" AS DATA_EVENT_TIMESTAMP
,FILENAME                            AS METADATA_FILENAME 
,FILE_ROW_NUMBER                     AS METADATA_FILE_ROW_NUMBER
,FILE_LAST_MODIFIED                  AS METADATA_FILE_LAST_MODIFIED
,START_SCAN_TIME                     AS METADATA_START_SCAN_TIME
,{{ dbt_utils.generate_surrogate_key(['DATA:"compt_no"']) }} as TABLE_SK
,COALESCE(TO_TIMESTAMP_TZ(DATA:"DataEventTimestamp"),TO_TIMESTAMP_NTZ(DATEADD(microsecond, FILE_ROW_NUMBER,TO_TIMESTAMP_NTZ(DATA:"ipaas_updated_date"::string)))) as QUALIFY_TIMESTAMP

from {{ source("landing_spm_ca", "QC_COMPETITOR") }}
-- to only take the files after the last fullLoad
WHERE 
  split(FILENAME, '_')[array_size(split(FILENAME, '_')) - 2] >=
  (SELECT min_timestamp
  FROM
      (SELECT split(FILENAME, '_')[array_size(split(FILENAME, '_')) - 2] AS min_timestamp, split(FILENAME, '/')[3] AS type_file
      FROM {{ source("landing_spm_ca", "QC_COMPETITOR") }}
      WHERE type_file LIKE 'fullload%'
      QUALIFY ROW_NUMBER() OVER (ORDER BY min_timestamp DESC) = 1)
  )