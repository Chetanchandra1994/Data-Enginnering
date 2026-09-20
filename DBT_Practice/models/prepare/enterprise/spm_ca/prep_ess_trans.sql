{{
  config(
    materialized = "view",
    alias = "ess_trans",
    schema='spm_ca'
  )
}}

SELECT
DATA:"entity_code" AS ENTITY_CODE
,DATA:"line_no" AS LINE_NO
,DATA:"no_projet" AS NO_PROJET
,DATA:"trans_code" AS TRANS_CODE
,DATA:"reference" AS REFERENCE
,DATA:"trans_date" AS TRANS_DATE
,DATA:"quantity" AS QUANTITY
,DATA:"trans_amt" AS TRANS_AMT
,DATA:"mnt_revenu" AS MNT_REVENU
,DATA:"mnt_depense" AS MNT_DEPENSE
,DATA:"pourcentage" AS POURCENTAGE
,DATA:"ref_code" AS REF_CODE
,DATA:"prd" AS PRD
,DATA:"no_catg" AS NO_CATG
,DATA:"yr" AS YR
,DATA:"exp_marg" AS EXP_MARG
,DATA:"qty_marg" AS QTY_MARG
,DATA:"status_line" AS STATUS_LINE
,DATA:"calclt_mode" AS CALCLT_MODE
,DATA:"vendor_code" AS VENDOR_CODE
,DATA:"po_no" AS PO_NO
,DATA:"contract_no" AS CONTRACT_NO
,DATA:"office_code" AS OFFICE_CODE
,DATA:"branch_office_code" AS BRANCH_OFFICE_CODE
,DATA:"weight" AS WEIGHT
,DATA:"area" AS AREA
,DATA:"vendor_id" AS VENDOR_ID
,DATA:"vendor_name" AS VENDOR_NAME
,DATA:"ess_trans_uuid" AS ESS_TRANS_UUID
,DATA:"_rowid" AS ROW_ID
,DATA:"src_system_operation" AS SRC_SYSTEM_OPERATION
,DATA:"ipaas_updated_date" AS IPAAS_UPDATED_DATE
,DATA:"CreatedDate" AS CREATED_DATE
,DATA:"ModifiedDate" AS MODIFIED_DATE
,DATA:"CreatedBy" AS CREATED_BY
,DATA:"ModifiedBy" AS MODIFIED_BY
,DATA:"DataEventTimestamp" AS DATA_EVENT_TIMESTAMP
,{{ dbt_utils.generate_surrogate_key(['DATA:"ess_trans_uuid"']) }} as TABLE_SK
,COALESCE(TO_TIMESTAMP_TZ(DATA:"DataEventTimestamp"),TO_TIMESTAMP_NTZ(DATEADD(microsecond, FILE_ROW_NUMBER,TO_TIMESTAMP_NTZ(DATA:"ipaas_updated_date"::string)))) as QUALIFY_TIMESTAMP
from {{ source("landing_spm_ca", "ESS_TRANS") }}
-- to only take the files after the last fullLoad
WHERE 
  split(FILENAME, '_')[array_size(split(FILENAME, '_')) - 2] >=
  (SELECT min_timestamp
  FROM
      (SELECT split(FILENAME, '_')[array_size(split(FILENAME, '_')) - 2] AS min_timestamp, split(FILENAME, '/')[3] AS type_file
      FROM {{ source("landing_spm_ca", "ESS_TRANS") }}
      WHERE type_file LIKE 'fullload%'
      QUALIFY ROW_NUMBER() OVER (ORDER BY min_timestamp DESC) = 1)
  )