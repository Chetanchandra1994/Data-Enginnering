{{
  config(
    materialized = "view",
    alias = "heat_no_country",
    schema='spm_ca'
  )
}}

SELECT
 DATA:"heat_no" AS HEAT_NO
,DATA:"certif" AS CERTIF
,DATA:"path_mill_test" AS PATH_MILL_TEST
,DATA:"dummy" AS DUMMY
,DATA:"country_code" AS COUNTRY_CODE
,DATA:"receipt_no" AS RECEIPT_NO
,DATA:"_rowid" AS ROW_ID
,DATA:"src_system_operation" AS SRC_SYSTEM_OPERATION
,DATA:"ipaas_updated_date" AS IPAAS_UPDATED_DATE
,FILENAME                           AS METADATA_FILENAME 
,FILE_ROW_NUMBER                    AS METADATA_FILE_ROW_NUMBER
,FILE_LAST_MODIFIED                 AS METADATA_FILE_LAST_MODIFIED
,START_SCAN_TIME                    AS METADATA_START_SCAN_TIME
FROM {{ source("landing_spm_ca", "HEAT_NO_COUNTRY") }}
WHERE 
  split(FILENAME, '_')[array_size(split(FILENAME, '_')) - 2] >=
  (SELECT min_timestamp
  FROM
      (SELECT split(FILENAME, '_')[array_size(split(FILENAME, '_')) - 2] AS min_timestamp, split(FILENAME, '/')[3] AS type_file
      FROM {{ source("landing_spm_ca", "HEAT_NO_COUNTRY") }}
      WHERE type_file LIKE 'fullload%'
      QUALIFY ROW_NUMBER() OVER (ORDER BY min_timestamp DESC) = 1)
  )