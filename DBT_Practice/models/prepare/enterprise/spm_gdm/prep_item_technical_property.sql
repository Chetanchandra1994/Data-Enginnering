{{
  config(
    materialized = "view",
    alias = "item_technical_property",
    schema='spm_gdm'
  )
}}

SELECT
 DATA:"item_technical_property_uuid" AS ITEM_TECHNICAL_PROPERTY_UUID
,DATA:"global_item_uuid" AS GLOBAL_ITEM_UUID
,DATA:"technical_description_name_id" AS TECHNICAL_DESCRIPTION_NAME_ID
,DATA:"nominal_height" AS NOMINAL_HEIGHT
,DATA:"nominal_width" AS NOMINAL_WIDTH
,DATA:"nominal_thickness" AS NOMINAL_THICKNESS
,DATA:"nominal_surface" AS NOMINAL_SURFACE
,DATA:"unfolded_length" AS UNFOLDED_LENGTH
,DATA:"painting_surface" AS PAINTING_SURFACE
,DATA:"master_item_uuid" AS MASTER_ITEM_UUID
,DATA:"item_finishing_uuid" AS ITEM_FINISHING_UUID
,DATA:"width_tolerance" AS WIDTH_TOLERANCE
,DATA:"thickness_tolerance_min" AS THICKNESS_TOLERANCE_MIN
,DATA:"thickness_tolerance_max" AS THICKNESS_TOLERANCE_MAX
,DATA:"fabrication_code" AS FABRICATION_CODE
,DATA:"src_system_operation" AS SRC_SYSTEM_OPERATION
,DATA:"ipaas_updated_date" AS IPAAS_UPDATED_DATE
,FILENAME                            AS METADATA_FILENAME 
,FILE_ROW_NUMBER                     AS METADATA_FILE_ROW_NUMBER
,FILE_LAST_MODIFIED                  AS METADATA_FILE_LAST_MODIFIED
,START_SCAN_TIME                     AS METADATA_START_SCAN_TIME
FROM {{ source("landing_spm_gdm", "ITEM_TECHNICAL_PROPERTY") }}
-- to only take the files after the last fullLoad
  WHERE 
  split(FILENAME, '_')[array_size(split(FILENAME, '_')) - 2] >=
    (SELECT min_timestamp
  FROM
      (SELECT split(FILENAME, '_')[array_size(split(FILENAME, '_')) - 2] AS min_timestamp, split(FILENAME, '/')[3] AS type_file
      FROM {{ source("landing_spm_gdm", "ITEM_TECHNICAL_PROPERTY") }}
      WHERE type_file LIKE 'fullload%'
      QUALIFY ROW_NUMBER() OVER (ORDER BY min_timestamp DESC) = 1)
    )