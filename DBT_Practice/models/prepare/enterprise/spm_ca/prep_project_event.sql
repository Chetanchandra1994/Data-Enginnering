{{
  config(
    materialized = "view",
    alias = "project_event",
    schema='spm_ca'
  )
}}

SELECT 
DATA:"_rowid" AS ROW_ID
,DATA:"project_event_uuid" AS PROJECT_EVENT_UUID
,DATA:"no_projet" AS NO_PROJET
,DATA:"sequence" AS SEQUENCE
,DATA:"vendor_code" AS VENDOR_CODE
,DATA:"description" AS DESCRIPTION
,DATA:"total_cost" AS TOTAL_COST
,DATA:"provision_total_amount" AS PROVISION_TOTAL_AMOUNT
,DATA:"provision_transfer_datetime" AS PROVISION_TRANSFER_DATETIME
,DATA:"provision_status" AS PROVISION_STATUS
,DATA:"credit_payment_total_amount" AS CREDIT_PAYMENT_TOTAL_AMOUNT
,DATA:"credit_payment_transfer_datetime" AS CREDIT_PAYMENT_TRANSFER_DATETIME
,DATA:"credit_payment_status" AS CREDIT_PAYMENT_STATUS
,DATA:"amount_to_release" AS AMOUNT_TO_RELEASE
,DATA:"creation_datetime" AS CREATION_DATETIME
,DATA:"credit_payment_includes_taxes" AS CREDIT_PAYMENT_INCLUDES_TAXES
,DATA:"seq_no" AS SEQ_NO
,DATA:"entity_code" AS ENTITY_CODE
,DATA:"no_poids" AS NO_POIDS
,DATA:"no_memo" AS NO_MEMO
,DATA:"material_missing" AS MATERIAL_MISSING
,DATA:"not_produced_correctly" AS NOT_PRODUCED_CORRECTLY
,DATA:"submitted_by_people_id" AS SUBMITTED_BY_PEOPLE_ID
,DATA:"complaint_by_customer_type_uuid" AS COMPLAINT_BY_CUSTOMER_TYPE_UUID
,DATA:"projct_event_entry_by_people_id" AS PROJCT_EVENT_ENTRY_BY_PEOPLE_ID
,DATA:"payment_to_vendor_code" AS PAYMENT_TO_VENDOR_CODE
,DATA:"project_event_trans_type_uuid" AS PROJECT_EVENT_TRANS_TYPE_UUID
,DATA:"payment_to_customer_uuid" AS PAYMENT_TO_CUSTOMER_UUID
,DATA:"ModifiedBy" AS MODIFIED_BY
,DATA:"ModifiedDate" AS MODIFIED_DATE
,DATA:"CreatedBy" AS CREATED_BY
,DATA:"src_system_operation" AS SRC_SYSTEM_OPERATION
,DATA:"ipaas_updated_date" AS IPAAS_UPDATED_DATE
,DATA:"DataEventTimestamp" AS DATA_EVENT_TIMESTAMP
,{{ dbt_utils.generate_surrogate_key(['DATA:"project_event_uuid"']) }} as TABLE_SK
,COALESCE(TO_TIMESTAMP_TZ(DATA:"DataEventTimestamp"),TO_TIMESTAMP_NTZ(DATEADD(microsecond, FILE_ROW_NUMBER,TO_TIMESTAMP_NTZ(DATA:"ipaas_updated_date"::string)))) as QUALIFY_TIMESTAMP

FROM {{ source("landing_spm_ca", "PROJECT_EVENT") }}
-- to only take the files after the last fullLoad
WHERE 
  split(FILENAME, '_')[array_size(split(FILENAME, '_')) - 2] >=
  (SELECT min_timestamp
  FROM
      (SELECT split(FILENAME, '_')[array_size(split(FILENAME, '_')) - 2] AS min_timestamp, split(FILENAME, '/')[3] AS type_file
      FROM {{ source("landing_spm_ca", "PROJECT_EVENT") }}
      WHERE type_file LIKE 'fullload%'
      QUALIFY ROW_NUMBER() OVER (ORDER BY min_timestamp DESC) = 1)
  )