{{
  config(
    materialized = "view",
    alias = "vendor",
    schema='spm_ca'
  )
}}

SELECT 
     DATA:"vendor_code" AS VENDOR_CODE
    ,DATA:"name" AS NAME
    ,DATA:"address_1" AS ADDRESS_1
    ,DATA:"address_2" AS ADDRESS_2
    ,DATA:"city" AS CITY
    ,DATA:"st" AS ST
    ,DATA:"zip_code" AS ZIP_CODE
    ,DATA:"country" AS COUNTRY
    ,DATA:"telephone" AS TELEPHONE
    ,DATA:"telex_twx" AS TELEX_TWX
    ,DATA:"valid_entity" AS VALID_ENTITY
    ,DATA:"sort_name" AS SORT_NAME
    ,DATA:"contact" AS CONTACT
    ,DATA:"memo" AS MEMO
    ,DATA:"remit_vendor" AS REMIT_VENDOR
    ,DATA:"stats_vendor" AS STATS_VENDOR
    ,DATA:"status_code" AS STATUS_CODE
    ,DATA:"term_code" AS TERM_CODE
    ,DATA:"auto_disburs" AS AUTO_DISBURS
    ,DATA:"class" AS CLASS
    ,DATA:"bank_code" AS BANK_CODE
    ,DATA:"ap_account" AS AP_ACCOUNT
    ,DATA:"description" AS DESCRIPTION
    ,DATA:"currency_cod" AS CURRENCY_COD
    ,DATA:"pay_duty" AS PAY_DUTY
    ,DATA:"via_code" AS VIA_CODE
    ,DATA:"fob_code" AS FOB_CODE
    ,DATA:"buyer_code" AS BUYER_CODE
    ,DATA:"type_fourn" AS TYPE_FOURN
    ,DATA:"check_ill" AS CHECK_ILL
    ,DATA:"language" AS LANGUAGE
    ,DATA:"ap_distribut_1" AS AP_DISTRIBUT_1
    ,DATA:"ap_distribut_2" AS AP_DISTRIBUT_2
    ,DATA:"ap_distribut_3" AS AP_DISTRIBUT_3
    ,DATA:"ap_distribut_4" AS AP_DISTRIBUT_4
    ,DATA:"ap_distribut_5" AS AP_DISTRIBUT_5
    ,DATA:"ap_distribut_6" AS AP_DISTRIBUT_6
    ,DATA:"ap_distribut_7" AS AP_DISTRIBUT_7
    ,DATA:"ap_distribut_8" AS AP_DISTRIBUT_8
    ,DATA:"ap_distribut_9" AS AP_DISTRIBUT_9
    ,DATA:"ap_distribut_10" AS AP_DISTRIBUT_10
    ,DATA:"ap_distribut_11" AS AP_DISTRIBUT_11
    ,DATA:"ap_distribut_12" AS AP_DISTRIBUT_12
    ,DATA:"ap_distribut_13" AS AP_DISTRIBUT_13
    ,DATA:"ap_distribut_14" AS AP_DISTRIBUT_14
    ,DATA:"ap_distribut_15" AS AP_DISTRIBUT_15
    ,DATA:"ap_distribut_16" AS AP_DISTRIBUT_16
    ,DATA:"ap_distribut_17" AS AP_DISTRIBUT_17
    ,DATA:"ap_distribut_18" AS AP_DISTRIBUT_18
    ,DATA:"ap_distribut_19" AS AP_DISTRIBUT_19
    ,DATA:"ap_distribut_20" AS AP_DISTRIBUT_20
    ,DATA:"ap_distribut_21" AS AP_DISTRIBUT_21
    ,DATA:"ap_distribut_22" AS AP_DISTRIBUT_22
    ,DATA:"ap_distribut_23" AS AP_DISTRIBUT_23
    ,DATA:"ap_distribut_24" AS AP_DISTRIBUT_24
    ,DATA:"ap_distribut_25" AS AP_DISTRIBUT_25
    ,DATA:"ap_distribut_26" AS AP_DISTRIBUT_26
    ,DATA:"ap_distribut_27" AS AP_DISTRIBUT_27
    ,DATA:"ap_distribut_28" AS AP_DISTRIBUT_28
    ,DATA:"ap_distribut_29" AS AP_DISTRIBUT_29
    ,DATA:"ap_distribut_30" AS AP_DISTRIBUT_30
    ,DATA:"ap_distribut_31" AS AP_DISTRIBUT_31
    ,DATA:"ap_distribut_32" AS AP_DISTRIBUT_32
    ,DATA:"ap_distribut_33" AS AP_DISTRIBUT_33
    ,DATA:"ap_distribut_34" AS AP_DISTRIBUT_34
    ,DATA:"ap_distribut_35" AS AP_DISTRIBUT_35
    ,DATA:"ap_distribut_36" AS AP_DISTRIBUT_36
    ,DATA:"ap_distribut_37" AS AP_DISTRIBUT_37
    ,DATA:"ap_distribut_38" AS AP_DISTRIBUT_38
    ,DATA:"ap_distribut_39" AS AP_DISTRIBUT_39
    ,DATA:"ap_distribut_40" AS AP_DISTRIBUT_40
    ,DATA:"gst_taxable" AS GST_TAXABLE
    ,DATA:"gst_no" AS GST_NO
    ,DATA:"po_s" AS PO_S
    ,DATA:"tvq_no" AS TVQ_NO
    ,DATA:"mli_valid" AS MLI_VALID
    ,DATA:"cansis_vendor_number" AS CANSIS_VENDOR_NUMBER
    ,DATA:"cansis_vendor_site_name" AS CANSIS_VENDOR_SITE_NAME
    ,DATA:"mesure" AS MESURE
    ,DATA:"affiliated" AS AFFILIATED
    ,DATA:"relationship_code" AS RELATIONSHIP_CODE
    ,DATA:"slitting_prefix_from" AS SLITTING_PREFIX_FROM
    ,DATA:"slitting_prefix_to" AS SLITTING_PREFIX_TO
    ,DATA:"dispatcher_email_address1" AS DISPATCHER_EMAIL_ADDRESS1
    ,DATA:"dispatcher_email_address2" AS DISPATCHER_EMAIL_ADDRESS2
    ,DATA:"Ecologo" AS ECOLOGO
    ,DATA:"CreatedBy" AS CREATED_BY
    ,DATA:"CreatedDate" AS CREATED_DATE
    ,DATA:"ModifiedDate" AS MODIFIED_DATE
    ,DATA:"ModifiedBy" AS MODIFIED_BY
    ,DATA:"ExternalVendorCode" AS EXTERNAL_VENDOR_CODE
    ,DATA:"_rowid" AS ROW_ID
    ,DATA:"src_system_operation" AS SRC_SYSTEM_OPERATION
    ,DATA:"ipaas_updated_date" AS IPAAS_UPDATED_DATE
    ,DATA:"DataEventTimestamp" AS DATA_EVENT_TIMESTAMP
    ,{{ dbt_utils.generate_surrogate_key(['DATA:"vendor_code"']) }} as TABLE_SK
    ,COALESCE(TO_TIMESTAMP_TZ(DATA:"DataEventTimestamp"),TO_TIMESTAMP_NTZ(DATEADD(microsecond, FILE_ROW_NUMBER,TO_TIMESTAMP_NTZ(DATA:"ipaas_updated_date"::string)))) as QUALIFY_TIMESTAMP

FROM {{ source("landing_spm_ca", "VENDOR") }}

-- to only take the files after the last fullLoad
WHERE 
  split(FILENAME, '_')[array_size(split(FILENAME, '_')) - 2] >=
  (SELECT min_timestamp
  FROM
      (SELECT split(FILENAME, '_')[array_size(split(FILENAME, '_')) - 2] AS min_timestamp, split(FILENAME, '/')[3] AS type_file
      FROM {{ source("landing_spm_ca", "VENDOR") }}
      WHERE type_file LIKE 'fullload%'
      QUALIFY ROW_NUMBER() OVER (ORDER BY min_timestamp DESC) = 1)
  )