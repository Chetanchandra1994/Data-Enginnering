{{
  config(
    materialized = "view",
    alias = "BUSINESS_UNIT",
    schema='spm_gdm'
  )
}}

SELECT
DATA:"business_unit_id" AS BUSINESS_UNIT_ID
,DATA:"business_unit_code" AS BUSINESS_UNIT_CODE
,DATA:"business_unit_name_id" AS BUSINESS_UNIT_NAME_ID
,DATA:"is_active" AS IS_ACTIVE
,DATA:"company_reference_name_id" AS COMPANY_REFERENCE_NAME_ID
,DATA:"logo_file_name_id" AS LOGO_FILE_NAME_ID
,DATA:"business_unit_short_name_id" AS BUSINESS_UNIT_SHORT_NAME_ID
,DATA:"req_sent_out_target_delay" AS REQ_SENT_OUT_TARGET_DELAY
,DATA:"allow_dsms_transfer" AS ALLOW_DSMS_TRANSFER
,DATA:"business_unit_tag_name_id" AS BUSINESS_UNIT_TAG_NAME_ID
,DATA:"bol_description_name_id" AS BOL_DESCRIPTION_NAME_ID
,DATA:"revenue_quantity_type_uuid" AS REVENUE_QUANTITY_TYPE_UUID
,DATA:"project_event_manage_by_projcoor" AS PROJECT_EVENT_MANAGE_BY_PROJCOOR
,DATA:"performance_ind_calculation" AS PERFORMANCE_IND_CALCULATION
,DATA:"pcx_logo_file_name_id" AS PCX_LOGO_FILE_NAME_ID
,DATA:"allow_link_to_cms" AS ALLOW_LINK_TO_CMS
,DATA:"cms_global_approval" AS CMS_GLOBAL_APPROVAL
,DATA:"ipaas_updated_date" AS IPAAS_UPDATED_DATE
,DATA:"DataEventTimestamp" AS DATA_EVENT_TIMESTAMP
,FILENAME                           AS METADATA_FILENAME 
,FILE_ROW_NUMBER                    AS METADATA_FILE_ROW_NUMBER
,FILE_LAST_MODIFIED                 AS METADATA_FILE_LAST_MODIFIED
,START_SCAN_TIME                    AS METADATA_START_SCAN_TIME
,{{ dbt_utils.generate_surrogate_key(['DATA:"business_unit_id"']) }} as TABLE_SK
,COALESCE(TO_TIMESTAMP_TZ(DATA:"DataEventTimestamp"),TO_TIMESTAMP_NTZ(DATEADD(microsecond, FILE_ROW_NUMBER,TO_TIMESTAMP_NTZ(DATA:"ipaas_updated_date"::string)))) as QUALIFY_TIMESTAMP

FROM {{ source("landing_spm_gdm", "BUSINESS_UNIT") }}

WHERE 
  split(FILENAME, '_')[array_size(split(FILENAME, '_')) - 2] >=
  (SELECT min_timestamp
  FROM
      (SELECT split(FILENAME, '_')[array_size(split(FILENAME, '_')) - 2] AS min_timestamp, split(FILENAME, '/')[3] AS type_file
      FROM {{ source("landing_spm_gdm", "BUSINESS_UNIT") }}
      WHERE type_file LIKE 'fullload%'
       QUALIFY ROW_NUMBER() OVER (ORDER BY min_timestamp DESC) = 1)
  )