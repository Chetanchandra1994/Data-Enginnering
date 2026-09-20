{{
  config(
    materialized = "view",
    alias = "cmg_sales_group",
    schema='spm_ca'
  )
}}


SELECT
DATA:"sales_group_code" AS SALES_GROUP_CODE
,DATA:"description_id" AS DESCRIPTION_ID
,DATA:"uom_code" AS UOM_CODE
,DATA:"performance_ind_calculation" AS PERFORMANCE_IND_CALCULATION
,DATA:"cmg_sales_group_uuid" AS CMG_SALES_GROUP_UUID
,DATA:"_rowid" AS ROW_ID
,DATA:"CreatedBy" AS CREATED_BY
,DATA:"CreatedDate" AS CREATED_DATE
,DATA:"ModifiedDate" AS MODIFIED_DATE
,DATA:"ModifiedBy" AS MODIFIED_BY
,DATA:"src_system_operation" AS SRC_SYSTEM_OPERATION
,DATA:"ipaas_updated_date" AS IPAAS_UPDATED_DATE
,FILENAME                           AS METADATA_FILENAME 
,FILE_ROW_NUMBER                    AS METADATA_FILE_ROW_NUMBER
,FILE_LAST_MODIFIED                 AS METADATA_FILE_LAST_MODIFIED
,START_SCAN_TIME                    AS METADATA_START_SCAN_TIME
,DATA:"DataEventTimestamp" AS DATA_EVENT_TIMESTAMP
,{{ dbt_utils.generate_surrogate_key(['DATA:"cmg_sales_group_uuid"']) }} as TABLE_SK
,COALESCE(TO_TIMESTAMP_TZ(DATA:"DataEventTimestamp"),TO_TIMESTAMP_NTZ(DATEADD(microsecond, FILE_ROW_NUMBER,TO_TIMESTAMP_NTZ(DATA:"ipaas_updated_date"::string)))) as QUALIFY_TIMESTAMP
from
(
   SELECT OBJECT_INSERT(OBJECT_INSERT(PARSE_JSON(PARSE_JSON(DATA):Body), 'ipaas_updated_date', PARSE_JSON(DATA):ipaas_updated_date::string),'src_system_operation',PARSE_JSON(DATA):Action::string) AS DATA
    ,FILENAME, FILE_ROW_NUMBER, FILE_LAST_MODIFIED, START_SCAN_TIME
    FROM  {{ source("landing_spm_gdm", "DATAEVENTS") }}
    WHERE PARSE_JSON(DATA):TableName = 'acctg.cmg_sales_group'
    UNION (SELECT * FROM  {{ source("landing_spm_ca", "CMG_SALES_GROUP") }}
))
-- to only take the files after the last fullLoad
WHERE  
split(FILENAME, '_')[array_size(split(FILENAME, '_')) - 2] >=
(SELECT min_timestamp
FROM
  (SELECT split(FILENAME, '_')[array_size(split(FILENAME, '_')) - 2] AS min_timestamp, split(FILENAME, '/')[3] AS type_file
  FROM  {{ source("landing_spm_ca", "CMG_SALES_GROUP") }}
  WHERE type_file LIKE 'fullload%'
  QUALIFY ROW_NUMBER() OVER (ORDER BY min_timestamp DESC) = 1)
)