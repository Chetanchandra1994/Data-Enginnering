{{
  config(
    materialized = "view",
    alias = "technical_category",
    schema='spm_gdm'
  )
}}

SELECT
 DATA:"technical_category_uuid" AS TECHNICAL_CATEGORY_UUID
,DATA:"technical_category_code" AS TECHNICAL_CATEGORY_CODE
,DATA:"technical_category_name_id" AS TECHNICAL_CATEGORY_NAME_ID
,DATA:"item_prefix" AS ITEM_PREFIX
,DATA:"perforation_cost_input_allowed" AS PERFORATION_COST_INPUT_ALLOWED
,DATA:"allow_duplicate_abm_item_no" AS ALLOW_DUPLICATE_ABM_ITEM_NO
,DATA:"active" AS ACTIVE
,DATA:"src_system_operation" AS SRC_SYSTEM_OPERATION
,DATA:"ipaas_updated_date" AS IPAAS_UPDATED_DATE
,FILENAME                            AS METADATA_FILENAME 
,FILE_ROW_NUMBER                     AS METADATA_FILE_ROW_NUMBER
,FILE_LAST_MODIFIED                  AS METADATA_FILE_LAST_MODIFIED
,START_SCAN_TIME                     AS METADATA_START_SCAN_TIME
FROM {{ source("landing_spm_gdm", "TECHNICAL_CATEGORY") }}
-- -- to only take the files after the last fullLoad
  WHERE 
  split(FILENAME, '_')[array_size(split(FILENAME, '_')) - 2] >=
    (SELECT min_timestamp
  FROM
      (SELECT split(FILENAME, '_')[array_size(split(FILENAME, '_')) - 2] AS min_timestamp, split(FILENAME, '/')[3] AS type_file
      FROM {{ source("landing_spm_gdm", "TECHNICAL_CATEGORY") }}
      WHERE type_file LIKE 'fullload%'
      QUALIFY ROW_NUMBER() OVER (ORDER BY min_timestamp DESC) = 1)
    )
