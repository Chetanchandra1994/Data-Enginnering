{{
 config(
 materialized = "view",
 alias = "po_line",
 schema='spm_ca'
 )
}}

SELECT
    DATA:"ap_entity" AS AP_ENTITY
    ,DATA:"_rowid" AS ROW_ID
    ,DATA:"in_entity" AS IN_ENTITY
    ,DATA:"whs_code" AS WHS_CODE
    ,DATA:"po_no" AS PO_NO
    ,DATA:"release_no" AS RELEASE_NO
    ,DATA:"vendor_code" AS VENDOR_CODE
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
    ,DATA:"tax_rate" AS TAX_RATE
    ,DATA:"misc_pct" AS MISC_PCT
    ,DATA:"last_rcpt_no" AS LAST_RCPT_NO
    ,DATA:"last_rc_qty" AS LAST_RC_QTY
    ,DATA:"qty_orig_ord" AS QTY_ORIG_ORD
    ,DATA:"qty_received" AS QTY_RECEIVED
    ,DATA:"qty_to_rcve" AS QTY_TO_RCVE
    ,DATA:"status_code" AS STATUS_CODE
    ,DATA:"chang_cancel" AS CHANG_CANCEL
    ,DATA:"seq_no" AS SEQ_NO
    ,DATA:"qty_vb_cod" AS QTY_VB_COD
    ,DATA:"no_projet" AS NO_PROJET
    ,DATA:"jc_line_no" AS JC_LINE_NO
    ,DATA:"vendor_measure" AS VENDOR_MEASURE
    ,DATA:"CreatedBy" AS CREATEDBY
    ,DATA:"CreatedDate" AS CREATED_DATE
    ,DATA:"ModifiedDate" AS MODIFIED_DATE
    ,DATA:"ModifiedBy" AS MODIFIEDBY
    ,DATA:"ipaas_updated_date" AS IPAAS_UPDATED_DATE
    ,DATA:"src_system_operation" AS SRC_SYSTEM_OPERATION
    ,DATA:"DataEventTimestamp" AS DATA_EVENT_TIMESTAMP
    ,{{ dbt_utils.generate_surrogate_key(['DATA:"ap_entity"','DATA:"po_no"','DATA:"release_no"','DATA:"line_no"']) }} as TABLE_SK
    ,COALESCE(TO_TIMESTAMP_TZ(DATA:"DataEventTimestamp"),TO_TIMESTAMP_NTZ(DATEADD(microsecond, FILE_ROW_NUMBER,TO_TIMESTAMP_NTZ(DATA:"ipaas_updated_date"::string)))) as QUALIFY_TIMESTAMP
FROM {{ source("landing_spm_ca", "PO_LINE") }}
-- to only take the files after the last fullLoad
WHERE 
    split(FILENAME, '_')[array_size(split(FILENAME, '_')) - 2] >=
    (SELECT min_timestamp
    FROM
    (SELECT split(FILENAME, '_')[array_size(split(FILENAME, '_')) - 2] AS min_timestamp, split(FILENAME, '/')[3] AS type_file
    FROM {{ source("landing_spm_ca", "PO_LINE") }}
    WHERE type_file LIKE 'fullload%'
    QUALIFY ROW_NUMBER() OVER (ORDER BY min_timestamp DESC) = 1)
    )