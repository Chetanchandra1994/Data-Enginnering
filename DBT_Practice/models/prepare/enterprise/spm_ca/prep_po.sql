{{
 config(
 materialized = "view",
 alias = "po",
 schema='spm_ca'
 )
}}

SELECT
    DATA:"CreatedDate" AS CREATED_DATE
    ,DATA:"ModifiedDate" AS MODIFIED_DATE
    ,DATA:"ap_entity" AS AP_ENTITY
    ,DATA:"_rowid" AS ROW_ID
    ,DATA:"in_entity" AS IN_ENTITY
    ,DATA:"entity_code" AS ENTITY_CODE
    ,DATA:"whs_code" AS WHS_CODE
    ,DATA:"po_no" AS PO_NO
    ,DATA:"release_no" AS RELEASE_NO
    ,DATA:"vendor_code" AS VENDOR_CODE
    ,DATA:"name" AS NAME
    ,DATA:"remit_vendor" AS REMIT_VENDOR
    ,DATA:"ship_to" AS SHIP_TO
    ,DATA:"ship_name" AS SHIP_NAME
    ,DATA:"ship_address" AS SHIP_ADDRESS
    ,DATA:"ship_city" AS SHIP_CITY
    ,DATA:"ship_st" AS SHIP_ST
    ,DATA:"ship_zip" AS SHIP_ZIP
    ,DATA:"ship_country" AS SHIP_COUNTRY
    ,DATA:"department" AS DEPARTMENT
    ,DATA:"vendor_refer" AS VENDOR_REFER
    ,DATA:"po_date" AS PO_DATE
    ,DATA:"request_date" AS REQUEST_DATE
    ,DATA:"promise_date" AS PROMISE_DATE
    ,DATA:"control_qty" AS CONTROL_QTY
    ,DATA:"receipt_code" AS RECEIPT_CODE
    ,DATA:"memo" AS MEMO
    ,DATA:"term_code" AS TERM_CODE
    ,DATA:"fob_desc" AS FOB_DESC
    ,DATA:"via_desc" AS VIA_DESC
    ,DATA:"buyer_code" AS BUYER_CODE
    ,DATA:"tax_code" AS TAX_CODE
    ,DATA:"ppd_coll" AS PPD_COLL
    ,DATA:"po_disc" AS PO_DISC
    ,DATA:"currency_cod" AS CURRENCY_COD
    ,DATA:"last_rcpt_no" AS LAST_RCPT_NO
    ,DATA:"last_rc_date" AS LAST_RC_DATE
    ,DATA:"open_value" AS OPEN_VALUE
    ,DATA:"chang_cancel" AS CHANG_CANCEL
    ,DATA:"status_code" AS STATUS_CODE
    ,DATA:"job_no" AS JOB_NO
    ,DATA:"seq_no" AS SEQ_NO
    ,DATA:"terminal_no" AS TERMINAL_NO
    ,DATA:"user" AS USER
    ,DATA:"contact" AS CONTACT
    ,DATA:"jc_genert" AS JC_GENERT
    ,DATA:"yr" AS YR
    ,DATA:"prd" AS PRD
    ,DATA:"vendor_measure" AS VENDOR_MEASURE
    ,DATA:"creation_datetime" AS CREATION_DATETIME
    ,DATA:"CreatedBy" AS CREATEDBY
    ,DATA:"ModifiedBy" AS MODIFIEDBY
    ,DATA:"ipaas_updated_date" AS IPAAS_UPDATED_DATE
    ,DATA:"src_system_operation" AS SRC_SYSTEM_OPERATION
    ,DATA:"DataEventTimestamp" AS DATA_EVENT_TIMESTAMP
    ,{{ dbt_utils.generate_surrogate_key(['DATA:"ap_entity"','DATA:"po_no"','DATA:"release_no"']) }} as TABLE_SK
    ,COALESCE(TO_TIMESTAMP_TZ(DATA:"DataEventTimestamp"),TO_TIMESTAMP_NTZ(DATEADD(microsecond, FILE_ROW_NUMBER,TO_TIMESTAMP_NTZ(DATA:"ipaas_updated_date"::string)))) as QUALIFY_TIMESTAMP

FROM {{ source("landing_spm_ca", "PO") }}
-- to only take the files after the last fullLoad
WHERE 
    split(FILENAME, '_')[array_size(split(FILENAME, '_')) - 2] >=
    (SELECT min_timestamp
    FROM
    (SELECT split(FILENAME, '_')[array_size(split(FILENAME, '_')) - 2] AS min_timestamp, split(FILENAME, '/')[3] AS type_file
    FROM {{ source("landing_spm_ca", "PO") }}
    WHERE type_file LIKE 'fullload%'
    QUALIFY ROW_NUMBER() OVER (ORDER BY min_timestamp DESC) = 1)
    )