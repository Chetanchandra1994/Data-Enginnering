{{
  config(
    materialized = "view",
    alias = "global_item",
    schema='spm_gdm'
  )
}}

SELECT
 DATA:"global_item_uuid" AS GLOBAL_ITEM_UUID
,DATA:"global_item_code" AS GLOBAL_ITEM_CODE
,DATA:"global_item_name_id" AS GLOBAL_ITEM_NAME_ID
,DATA:"global_item_short_code" AS GLOBAL_ITEM_SHORT_CODE
,DATA:"measure" AS MEASURE
,DATA:"equivalent_item_uuid" AS EQUIVALENT_ITEM_UUID
,DATA:"uom_code" AS UOM_CODE
,DATA:"alternative_uom_code" AS ALTERNATIVE_UOM_CODE
,DATA:"item_subcategory_uuid" AS ITEM_SUBCATEGORY_UUID
,DATA:"weight" AS WEIGHT
,DATA:"shape_aisc_uuid" AS SHAPE_AISC_UUID
,DATA:"shape_cisc_uuid" AS SHAPE_CISC_UUID
,DATA:"sds_code" AS SDS_CODE
,DATA:"teckla_structures_code" AS TECKLA_STRUCTURES_CODE
,DATA:"estimating_software_code" AS ESTIMATING_SOFTWARE_CODE
,DATA:"bim_code" AS BIM_CODE
,DATA:"default_r_marque" AS DEFAULT_R_MARQUE
,DATA:"active" AS ACTIVE
,DATA:"technical_information_available" AS TECHNICAL_INFORMATION_AVAILABLE
,DATA:"item_gage_uuid" AS ITEM_GAGE_UUID
,DATA:"technical_category_uuid" AS TECHNICAL_CATEGORY_UUID
,DATA:"CreatedBy" AS CREATEDBY
,DATA:"CreatedDate" AS CREATEDDATE
,DATA:"ModifiedDate" AS MODIFIEDDATE
,DATA:"ModifiedBy" AS MODIFIEDBY
,DATA:"src_system_operation" AS SRC_SYSTEM_OPERATION
,DATA:"ipaas_updated_date" AS IPAAS_UPDATED_DATE
,DATA:"DataEventTimestamp" AS DATA_EVENT_TIMESTAMP
,{{ dbt_utils.generate_surrogate_key(['DATA:"global_item_uuid"']) }} as TABLE_SK
,COALESCE(TO_TIMESTAMP_TZ(DATA:"DataEventTimestamp"),TO_TIMESTAMP_NTZ(DATEADD(microsecond, FILE_ROW_NUMBER,TO_TIMESTAMP_NTZ(DATA:"ipaas_updated_date"::string)))) as QUALIFY_TIMESTAMP
,FILENAME                            AS METADATA_FILENAME 
,FILE_ROW_NUMBER                     AS METADATA_FILE_ROW_NUMBER
,FILE_LAST_MODIFIED                  AS METADATA_FILE_LAST_MODIFIED
,START_SCAN_TIME                     AS METADATA_START_SCAN_TIME
FROM {{ source("landing_spm_gdm", "GLOBAL_ITEM") }}
-- to only take the files after the last fullLoad
  WHERE 
  split(FILENAME, '_')[array_size(split(FILENAME, '_')) - 2] >=
    (SELECT min_timestamp
  FROM
      (SELECT split(FILENAME, '_')[array_size(split(FILENAME, '_')) - 2] AS min_timestamp, split(FILENAME, '/')[3] AS type_file
      FROM {{ source("landing_spm_gdm", "GLOBAL_ITEM") }}
      WHERE type_file LIKE 'fullload%'
      QUALIFY ROW_NUMBER() OVER (ORDER BY min_timestamp DESC) = 1)
    )
 