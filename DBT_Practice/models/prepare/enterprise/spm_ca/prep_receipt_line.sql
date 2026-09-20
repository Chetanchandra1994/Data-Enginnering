{{
  config(
    materialized = "view",
    alias = "receipt_line",
    schema='spm_ca'
  )
}}

SELECT
 DATA:"ap_entity" AS AP_ENTITY
,DATA:"in_entity" AS IN_ENTITY
,DATA:"entity_code" AS ENTITY_CODE
,DATA:"whs_code" AS WHS_CODE
,DATA:"po_no" AS PO_NO
,DATA:"release_no" AS RELEASE_NO
,DATA:"vendor_code" AS VENDOR_CODE
,DATA:"currency_cod" AS CURRENCY_COD
,DATA:"conv_money" AS CONV_MONEY
,DATA:"job_no" AS JOB_NO
,DATA:"line_no" AS LINE_NO
,DATA:"request_date" AS REQUEST_DATE
,DATA:"promise_date" AS PROMISE_DATE
,DATA:"item_no" AS ITEM_NO
,DATA:"description" AS DESCRIPTION
,DATA:"uom_code" AS UOM_CODE
,DATA:"item_vendor" AS ITEM_VENDOR
,DATA:"uom_vendor" AS UOM_VENDOR
,DATA:"conv_uom" AS CONV_UOM
,DATA:"fob_vendor" AS FOB_VENDOR
,DATA:"receipt_code" AS RECEIPT_CODE
,DATA:"line_disc" AS LINE_DISC
,DATA:"duty_code" AS DUTY_CODE
,DATA:"duty_pct" AS DUTY_PCT
,DATA:"tax_rate_1" AS TAX_RATE_1
,DATA:"tax_rate_2" AS TAX_RATE_2
,DATA:"tax_rate_3" AS TAX_RATE_3
,DATA:"misc_pct" AS MISC_PCT
,DATA:"receipt_no" AS RECEIPT_NO
,DATA:"rcpt_line_no" AS RCPT_LINE_NO
,DATA:"receipt_date" AS RECEIPT_DATE
,DATA:"po_disc" AS PO_DISC
,DATA:"lot" AS LOT
,DATA:"net_cost" AS NET_COST
,DATA:"landed_cost" AS LANDED_COST
,DATA:"qty_received" AS QTY_RECEIVED
,DATA:"qty_to_rcve" AS QTY_TO_RCVE
,DATA:"rcpt_value" AS RCPT_VALUE
,DATA:"changed_qty" AS CHANGED_QTY
,DATA:"cost_method" AS COST_METHOD
,DATA:"po_exist" AS PO_EXIST
,DATA:"seq_no" AS SEQ_NO
,DATA:"fr_cost" AS FR_COST
,DATA:"net_extend" AS NET_EXTEND
,DATA:"qty_invoiced" AS QTY_INVOICED
,DATA:"jc_qty" AS JC_QTY
,DATA:"jc_amt" AS JC_AMT
,DATA:"cansis_transf_date" AS CANSIS_TRANSF_DATE
,DATA:"cmg_country" AS CMG_COUNTRY
,DATA:"certif" AS CERTIF
,DATA:"country_code" AS COUNTRY_CODE
,DATA:"CreatedBy" AS CREATED_BY
,DATA:"CreatedDate" AS CREATED_DATE
,DATA:"ModifiedDate" AS MODIFIED_DATE
,DATA:"ModifiedBy" AS MODIFIED_BY
,DATA:"steel_mill_uuid" AS STEEL_MILL_UUID
,DATA:"src_system_operation" AS SRC_SYSTEM_OPERATION
,DATA:"ipaas_updated_date" AS IPAAS_UPDATED_DATE
,DATA:"DataEventTimestamp" AS DATA_EVENT_TIMESTAMP
,FILENAME                            AS METADATA_FILENAME 
,FILE_ROW_NUMBER                     AS METADATA_FILE_ROW_NUMBER
,FILE_LAST_MODIFIED                  AS METADATA_FILE_LAST_MODIFIED
,START_SCAN_TIME                     AS METADATA_START_SCAN_TIME
,{{ dbt_utils.generate_surrogate_key(['DATA:"ap_entity"','DATA:"vendor_code"','DATA:"receipt_no"','DATA:"item_no"','DATA:"rcpt_line_no"']) }} as TABLE_SK
,COALESCE(TO_TIMESTAMP_TZ(DATA:"DataEventTimestamp"),TO_TIMESTAMP_NTZ(DATEADD(microsecond, FILE_ROW_NUMBER,TO_TIMESTAMP_NTZ(DATA:"ipaas_updated_date"::string)))) as QUALIFY_TIMESTAMP

FROM {{ source("landing_spm_ca", "RECEIPT_LINE") }}
WHERE 
  split(FILENAME, '_')[array_size(split(FILENAME, '_')) - 2] >=
  (SELECT min_timestamp
  FROM
      (SELECT split(FILENAME, '_')[array_size(split(FILENAME, '_')) - 2] AS min_timestamp, split(FILENAME, '/')[3] AS type_file
      FROM {{ source("landing_spm_ca", "RECEIPT_LINE") }}
      WHERE type_file LIKE 'fullload%'
      QUALIFY ROW_NUMBER() OVER (ORDER BY min_timestamp DESC) = 1)
  )