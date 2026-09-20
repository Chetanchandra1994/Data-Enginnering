{{
  config(
    materialized = "view",
    alias = "project_event_detail",
    schema='spm_ca'
  )
}}

SELECT
	DATA:"project_event_detail_uuid" AS PROJECT_EVENT_DETAIL_UUID
	,DATA:"project_event_uuid" AS PROJECT_EVENT_UUID
	,DATA:"event_uuid" AS EVENT_UUID
	,DATA:"cost" AS COST
	,DATA:"provision_amount" AS PROVISION_AMOUNT
	,DATA:"credit_payment_amount" AS CREDIT_PAYMENT_AMOUNT
	,DATA:"entity_code" AS ENTITY_CODE
	,DATA:"creation_datetime" AS CREATION_DATETIME
	,DATA:"validated_datetime" AS VALIDATED_DATETIME
	,DATA:"validated_by_people_id" AS VALIDATED_BY_PEOPLE_ID
	,DATA:"cancellation_datetime" AS CANCELLATION_DATETIME
	,DATA:"cancellation_comment" AS CANCELLATION_COMMENT
	,DATA:"canceled_by_people_id" AS CANCELED_BY_PEOPLE_ID
	,DATA:"last_update_action" AS LAST_UPDATE_ACTION
	,DATA:"ProjectEventQuickRemarkUUID" AS PROJECT_EVENT_QUICK_REMARK_UUID
	,DATA:"ProjectEventManualRemark" AS PROJECT_EVENT_MANUAL_REMARK
	,DATA:"_rowid" AS ROW_ID
	,DATA:"src_system_operation" AS SRC_SYSTEM_OPERATION
	,DATA:"ipaas_updated_date" AS IPAAS_UPDATED_DATE
	,DATA:"CreatedBy" AS CREATED_BY
	,DATA:"ModifiedBy" AS MODIFIED_BY
	,DATA:"ModifiedDate" AS MODIFIED_DATE
	,DATA:"DataEventTimestamp" AS DATA_EVENT_TIMESTAMP
	,{{ dbt_utils.generate_surrogate_key(['DATA:"project_event_detail_uuid"']) }} as TABLE_SK
    ,COALESCE(TO_TIMESTAMP_TZ(DATA:"DataEventTimestamp"),TO_TIMESTAMP_NTZ(DATEADD(microsecond, FILE_ROW_NUMBER,TO_TIMESTAMP_NTZ(DATA:"ipaas_updated_date"::string)))) as QUALIFY_TIMESTAMP

FROM 
	{{ source("landing_spm_ca", "PROJECT_EVENT_DETAIL") }}
-- to only take the files after the last fullLoad
WHERE 
  split(FILENAME, '_')[array_size(split(FILENAME, '_')) - 2] >=
  (SELECT min_timestamp
  FROM
      (SELECT split(FILENAME, '_')[array_size(split(FILENAME, '_')) - 2] AS min_timestamp, split(FILENAME, '/')[3] AS type_file
      FROM {{ source("landing_spm_ca", "PROJECT_EVENT_DETAIL") }}
      WHERE type_file LIKE 'fullload%'
      QUALIFY ROW_NUMBER() OVER (ORDER BY min_timestamp DESC) = 1)
  )