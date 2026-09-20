{{
  config(
    materialized = "view",
    alias = "item_category",
    schema='spm_gdm'
  )
}}
SELECT
 DATA:"item_category_uuid" AS ITEM_CATEGORY_UUID
,DATA:"item_category_code" AS ITEM_CATEGORY_CODE
,DATA:"item_category_name_id" AS ITEM_CATEGORY_NAME_ID
,DATA:"origin_required" AS ORIGIN_REQUIRED
,DATA:"active" AS ACTIVE
,DATA:"CreatedDate" AS CREATED_DATE
,DATA:"ModifiedDate" AS MODIFIED_DATE
,DATA:"ModifiedBy" AS MODIFIED_BY
,DATA:"CreatedBy" AS CREATED_BY
,DATA:"src_system_operation" AS SRC_SYSTEM_OPERATION
,DATA:"ipaas_updated_date" AS IPAAS_UPDATED_DATE
,DATA:"DataEventTimestamp" AS DATA_EVENT_TIMESTAMP
,FILENAME                            AS METADATA_FILENAME 
,FILE_ROW_NUMBER                     AS METADATA_FILE_ROW_NUMBER
,FILE_LAST_MODIFIED                  AS METADATA_FILE_LAST_MODIFIED
,START_SCAN_TIME                     AS METADATA_START_SCAN_TIME
,{{ dbt_utils.generate_surrogate_key(['DATA:"item_category_uuid"']) }} as TABLE_SK
,COALESCE(TO_TIMESTAMP_TZ(DATA:"DataEventTimestamp"),TO_TIMESTAMP_NTZ(DATEADD(microsecond, FILE_ROW_NUMBER,TO_TIMESTAMP_NTZ(DATA:"ipaas_updated_date"::string)))) as QUALIFY_TIMESTAMP

FROM {{ source("landing_spm_gdm", "ITEM_CATEGORY") }}
WHERE 
  split(FILENAME, '_')[array_size(split(FILENAME, '_')) - 2] >=
  (SELECT min_timestamp
  FROM
      (SELECT split(FILENAME, '_')[array_size(split(FILENAME, '_')) - 2] AS min_timestamp, split(FILENAME, '/')[3] AS type_file
      FROM {{ source("landing_spm_gdm", "ITEM_CATEGORY") }}
      WHERE type_file LIKE 'fullload%'
      QUALIFY ROW_NUMBER() OVER (ORDER BY min_timestamp DESC) = 1)
  )