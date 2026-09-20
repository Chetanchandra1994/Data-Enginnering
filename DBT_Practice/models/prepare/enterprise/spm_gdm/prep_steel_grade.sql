{{
  config(
    materialized = "view",
    alias = "steel_grade",
    schema='spm_gdm'
  )
}}

SELECT 
 DATA:"steel_grade_uuid" AS STEEL_GRADE_UUID
,DATA:"steel_grade_code" AS STEEL_GRADE_CODE
,DATA:"description" AS DESCRIPTION
,DATA:"ksi" AS KSI
,DATA:"CreatedBy" AS CREATEDBY
,DATA:"active" AS ACTIVE
,DATA:"ModifiedDate" AS MODIFIEDDATE
,DATA:"ModifiedBy" AS MODIFIEDBY
,DATA:"CreatedDate" AS CREATEDDATE
,DATA:"src_system_operation" AS SRC_SYSTEM_OPERATION
,DATA:"ipaas_updated_date" AS IPAAS_UPDATED_DATE
,DATA:"DataEventTimestamp" AS DATA_EVENT_TIMESTAMP
,FILENAME                            AS METADATA_FILENAME 
,FILE_ROW_NUMBER                     AS METADATA_FILE_ROW_NUMBER
,FILE_LAST_MODIFIED                  AS METADATA_FILE_LAST_MODIFIED
,START_SCAN_TIME                     AS METADATA_START_SCAN_TIME
,{{ dbt_utils.generate_surrogate_key(['DATA:"steel_grade_uuid"']) }} as TABLE_SK
,COALESCE(TO_TIMESTAMP_TZ(DATA:"DataEventTimestamp"),TO_TIMESTAMP_NTZ(DATEADD(microsecond, FILE_ROW_NUMBER,TO_TIMESTAMP_NTZ(DATA:"ipaas_updated_date"::string)))) as QUALIFY_TIMESTAMP

FROM {{ source("landing_spm_gdm", "STEEL_GRADE") }}