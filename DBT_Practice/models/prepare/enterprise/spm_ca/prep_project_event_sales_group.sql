{{
  config(
    materialized = "view",
    alias = "project_event_sales_group",
    schema='spm_ca'
  )
}}

SELECT
DATA:"project_event_sales_group_uuid" AS PROJECT_EVENT_SALES_GROUP_UUID
,DATA:"project_event_uuid" AS PROJECT_EVENT_UUID
,DATA:"sales_group_code" AS SALES_GROUP_CODE
,DATA:"backcharge_percentage" AS BACKCHARGE_PERCENTAGE
,DATA:"_rowid" AS ROW_ID
,DATA:"src_system_operation" AS SRC_SYSTEM_OPERATION
,DATA:"ipaas_updated_date" AS IPAAS_UPDATED_DATE
,DATA:"CreatedDate" AS CREATED_DATE
,DATA:"ModifiedDate" AS MODIFIED_DATE
,DATA:"CreatedBy" AS CREATED_BY
,DATA:"ModifiedBy" AS MODIFIED_BY
,DATA:"DataEventTimestamp" AS DATA_EVENT_TIMESTAMP
,{{ dbt_utils.generate_surrogate_key(['DATA:"project_event_sales_group_uuid"']) }} as TABLE_SK
,COALESCE(TO_TIMESTAMP_TZ(DATA:"DataEventTimestamp"),TO_TIMESTAMP_NTZ(DATEADD(microsecond, FILE_ROW_NUMBER,TO_TIMESTAMP_NTZ(DATA:"ipaas_updated_date"::string)))) as QUALIFY_TIMESTAMP

from {{ source("landing_spm_ca", "PROJECT_EVENT_SALES_GROUP") }}
-- to only take the files after the last fullLoad
WHERE 
  split(FILENAME, '_')[array_size(split(FILENAME, '_')) - 2] >=
  (SELECT min_timestamp
  FROM
      (SELECT split(FILENAME, '_')[array_size(split(FILENAME, '_')) - 2] AS min_timestamp, split(FILENAME, '/')[3] AS type_file
      FROM {{ source("landing_spm_ca", "PROJECT_EVENT_SALES_GROUP") }}
      WHERE type_file LIKE 'fullload%'
      QUALIFY ROW_NUMBER() OVER (ORDER BY min_timestamp DESC) = 1)
  )