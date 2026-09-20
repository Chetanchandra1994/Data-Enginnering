{{
  config(
    materialized = "view",
    alias = "uom",
    schema='spm_gdm'
  )
}}


SELECT
DATA:"uom-code" AS UOM_CODE
,DATA:"uom_name_id" AS UOM_NAME_ID
,DATA:"unit" AS UNIT
,DATA:"exp-decimal" AS EXP_DECIMAL
,DATA:"max-value" AS MAX_VALUE
,DATA:"mask" AS MASK
,DATA:"type" AS TYPE
,DATA:"base_uom" AS BASE_UOM
,DATA:"cansis_uom" AS CANSIS_UOM
,DATA:"measure_system" AS MEASURE_SYSTEM
,DATA:"src_system_operation" AS SRC_SYSTEM_OPERATION
,DATA:"ipaas_updated_date" AS IPAAS_UPDATED_DATE
,DATA:"DataEventTimestamp" AS DATA_EVENT_TIMESTAMP
,FILENAME                            AS METADATA_FILENAME 
,FILE_ROW_NUMBER                     AS METADATA_FILE_ROW_NUMBER
,FILE_LAST_MODIFIED                  AS METADATA_FILE_LAST_MODIFIED
,START_SCAN_TIME                     AS METADATA_START_SCAN_TIME
,{{ dbt_utils.generate_surrogate_key(['DATA:"uom-code"']) }} as TABLE_SK
,COALESCE(TO_TIMESTAMP_TZ(DATA:"DataEventTimestamp"),TO_TIMESTAMP_NTZ(DATEADD(microsecond, FILE_ROW_NUMBER,TO_TIMESTAMP_NTZ(DATA:"ipaas_updated_date"::string)))) as QUALIFY_TIMESTAMP
from {{ source("landing_spm_gdm", "UOM") }}
-- to only take the files after the last fullLoad
  WHERE 
  split(FILENAME, '_')[array_size(split(FILENAME, '_')) - 2] >=
    (SELECT min_timestamp
  FROM
      (SELECT split(FILENAME, '_')[array_size(split(FILENAME, '_')) - 2] AS min_timestamp, split(FILENAME, '/')[3] AS type_file
      FROM {{ source("landing_spm_gdm", "UOM") }}
      WHERE type_file LIKE 'fullload%'
      QUALIFY ROW_NUMBER() OVER (ORDER BY min_timestamp DESC) = 1)
    )
 