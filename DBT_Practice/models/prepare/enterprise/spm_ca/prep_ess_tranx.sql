{{
  config(
    materialized = "view",
    alias = "ess_tranx",
    schema='spm_ca'
  )
}}
SELECT
DATA:"entity_code" AS ENTITY_CODE
,DATA:"line_no" AS LINE_NO
,DATA:"mnt_depense" AS MNT_DEPENSE
,DATA:"mnt_revenu" AS MNT_REVENU
,DATA:"no_projet" AS NO_PROJET
,DATA:"prd" AS PRD
,DATA:"quantity" AS QUANTITY
,DATA:"trans_date" AS TRANS_DATE
,DATA:"yr" AS YR
,DATA:"seq_no" AS SEQ_NO
,DATA:"contract_no" AS CONTRACT_NO
,DATA:"office_code" AS OFFICE_CODE
,DATA:"branch_office_code" AS BRANCH_OFFICE_CODE
,DATA:"weight" AS WEIGHT
,DATA:"area" AS AREA
,DATA:"vendor_id" AS VENDOR_ID
,DATA:"vendor_name" AS VENDOR_NAME
,DATA:"exp_marg" AS EXP_MARG
,DATA:"CreatedDate" AS CREATED_DATE
,DATA:"ModifiedDate" AS MODIFIED_DATE
,DATA:"CreatedBy" AS CREATED_BY
,DATA:"ModifiedBy" AS MODIFIED_BY
,DATA:"ess_tranx_uuid" AS ESS_TRANX_UUID
,DATA:"_rowid" AS ROW_ID
,DATA:"src_system_operation" AS SRC_SYSTEM_OPERATION
,DATA:"ipaas_updated_date" AS IPAAS_UPDATED_DATE
,DATA:"DataEventTimestamp" AS DATA_EVENT_TIMESTAMP
,FILENAME                           AS METADATA_FILENAME 
,FILE_ROW_NUMBER                    AS METADATA_FILE_ROW_NUMBER
,FILE_LAST_MODIFIED                 AS METADATA_FILE_LAST_MODIFIED
,START_SCAN_TIME                    AS METADATA_START_SCAN_TIME
,{{ dbt_utils.generate_surrogate_key(['DATA:"ess_tranx_uuid"']) }} as TABLE_SK
,COALESCE(TO_TIMESTAMP_TZ(DATA:"DataEventTimestamp"),TO_TIMESTAMP_NTZ(DATEADD(microsecond, FILE_ROW_NUMBER,TO_TIMESTAMP_NTZ(DATA:"ipaas_updated_date"::string)))) as QUALIFY_TIMESTAMP
FROM {{ source("landing_spm_ca", "ESS_TRANX") }}
-- to only take the files after the last fullLoad
WHERE 
  split(FILENAME, '_')[array_size(split(FILENAME, '_')) - 2] >=
  (SELECT min_timestamp
  FROM
      (SELECT split(FILENAME, '_')[array_size(split(FILENAME, '_')) - 2] AS min_timestamp, split(FILENAME, '/')[3] AS type_file
      FROM {{ source("landing_spm_ca", "ESS_TRANX") }}
      WHERE type_file LIKE 'fullload%'
      QUALIFY ROW_NUMBER() OVER (ORDER BY min_timestamp DESC) = 1)
  )