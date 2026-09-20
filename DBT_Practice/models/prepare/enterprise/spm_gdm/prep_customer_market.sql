{{
  config(
    materialized = "view",
    alias = "customer_market",
    schema='spm_gdm'
  )
}}


SELECT
DATA:"customer_market_uuid" AS CUSTOMER_MARKET_UUID
,DATA:"customer_uuid" AS CUSTOMER_UUID
,DATA:"ar_entity" AS AR_ENTITY
,DATA:"credit_limit" AS CREDIT_LIMIT
,DATA:"credit_conditional_approval" AS CREDIT_CONDITIONAL_APPROVAL
,DATA:"term_code" AS TERM_CODE
,DATA:"no_coord" AS NO_COORD
,DATA:"cmg_invoice_style" AS CMG_INVOICE_STYLE
,DATA:"currency_cod" AS CURRENCY_COD
,DATA:"slsmn_code" AS SLSMN_CODE
,DATA:"terr_code" AS TERR_CODE
,DATA:"bill_to_transfer_datetime" AS BILL_TO_TRANSFER_DATETIME
,DATA:"active_for_project" AS ACTIVE_FOR_PROJECT
,DATA:"creation_datetime" AS CREATION_DATETIME
,DATA:"creation_by" AS CREATION_BY
,DATA:"last_updated_datetime" AS LAST_UPDATED_DATETIME
,DATA:"last_updated_by" AS LAST_UPDATED_BY
,DATA:"type_appr" AS TYPE_APPR
,DATA:"no_agent_ct" AS NO_AGENT_CT
,DATA:"financial_appl_transfer" AS FINANCIAL_APPL_TRANSFER
,DATA:"financial_appl_customer_number" AS FINANCIAL_APPL_CUSTOMER_NUMBER
,DATA:"accounting_transmission_mode" AS ACCOUNTING_TRANSMISSION_MODE
,DATA:"_rowid" AS ROW_ID
,DATA:"src_system_operation" AS SRC_SYSTEM_OPERATION
,DATA:"ipaas_updated_date" AS IPAAS_UPDATED_DATE
,DATA:"CreatedDate" AS CREATED_DATE
,DATA:"ModifiedDate" AS MODIFIED_DATE
,DATA:"CreatedBy" AS CREATED_BY
,DATA:"ModifiedBy" AS MODIFIED_BY
,DATA:"DataEventTimestamp" AS DATA_EVENT_TIMESTAMP
,FILENAME                            AS METADATA_FILENAME 
,FILE_ROW_NUMBER                     AS METADATA_FILE_ROW_NUMBER
,FILE_LAST_MODIFIED                  AS METADATA_FILE_LAST_MODIFIED
,START_SCAN_TIME                     AS METADATA_START_SCAN_TIME
,{{ dbt_utils.generate_surrogate_key(['DATA:"customer_market_uuid"']) }} as TABLE_SK
,COALESCE(TO_TIMESTAMP_TZ(DATA:"DataEventTimestamp"),TO_TIMESTAMP_NTZ(DATEADD(microsecond, FILE_ROW_NUMBER,TO_TIMESTAMP_NTZ(DATA:"ipaas_updated_date"::string)))) as QUALIFY_TIMESTAMP

from {{ source("landing_spm_gdm", "CUSTOMER_MARKET") }}
-- to only take the files after the last fullLoad
WHERE 
  split(FILENAME, '_')[array_size(split(FILENAME, '_')) - 2] >=
  (SELECT min_timestamp
  FROM
      (SELECT split(FILENAME, '_')[array_size(split(FILENAME, '_')) - 2] AS min_timestamp, split(FILENAME, '/')[3] AS type_file
      FROM {{ source("landing_spm_gdm", "CUSTOMER_MARKET") }}
      WHERE type_file LIKE 'fullload%'
      QUALIFY ROW_NUMBER() OVER (ORDER BY min_timestamp DESC) = 1)
  )