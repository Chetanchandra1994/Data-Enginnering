{{
  config(
    materialized = "view",
    alias = "warehouse",
    schema='spm_ca'
  )
}}

SELECT
 DATA:"whs_code" AS WHS_CODE
,DATA:"description" AS DESCRIPTION
,DATA:"name" AS NAME
,DATA:"address_1" AS ADDRESS_1
,DATA:"address_2" AS ADDRESS_2
,DATA:"city" AS CITY
,DATA:"st" AS ST
,DATA:"zip_code" AS ZIP_CODE
,DATA:"country" AS COUNTRY
,DATA:"telephone" AS TELEPHONE
,DATA:"telex_twx" AS TELEX_TWX
,DATA:"tax_code" AS TAX_CODE
,DATA:"s_contrc" AS S_CONTRC
,DATA:"mult_inv" AS MULT_INV
,DATA:"ext_whs" AS EXT_WHS
,DATA:"track_heat_no" AS TRACK_HEAT_NO
,DATA:"pct_perte" AS PCT_PERTE
,DATA:"item_no" AS ITEM_NO
,DATA:"ind_reserve" AS IND_RESERVE
,DATA:"ctrl_inv_job" AS CTRL_INV_JOB
,DATA:"used" AS USED
,DATA:"receipt_code" AS RECEIPT_CODE
,DATA:"epix_maintn" AS EPIX_MAINTN
,DATA:"epix_used_whs" AS EPIX_USED_WHS
,DATA:"track_b_location" AS TRACK_B_LOCATION
,DATA:"master_entity" AS MASTER_ENTITY
,DATA:"project_no" AS PROJECT_NO
,DATA:"deck_type" AS DECK_TYPE
,DATA:"bar_code_follow" AS BAR_CODE_FOLLOW
,DATA:"vendor_id" AS VENDOR_ID
,DATA:"vendor_name" AS VENDOR_NAME
,DATA:"inv_conciliation_usages_formula" AS INV_CONCILIATION_USAGES_FORMULA
,DATA:"OptimizationManageHeatNo" AS OPTIMIZATION_MANAGE_HEAT_NO
,DATA:"ManageSurfaceItemInWeight" AS MANAGE_SURFACE_ITEM_MIN_WEIGHT
,DATA:"LinkedABMProjectNumber" AS LINKED_ABM_PROJECT_NUMBER
,DATA:"IgnoreFinancialRawMatCost" AS IGNORE_FINANCIAL_RAW_MAT_COST
,DATA:"CreatedBy" AS CREATED_BY
,DATA:"CreatedDate" AS CREATED_DATE
,DATA:"ModifiedDate" AS MODIFIED_DATE
,DATA:"ModifiedBy" AS MODIFIED_BY
,DATA:"src_system_operation" AS SRC_SYSTEM_OPERATION
,DATA:"ipaas_updated_date" AS IPAAS_UPDATED_DATE
,DATA:"DataEventTimestamp" AS DATA_EVENT_TIMESTAMP
,FILENAME AS METADATA_FILENAME 
,FILE_ROW_NUMBER AS METADATA_FILE_ROW_NUMBER
,FILE_LAST_MODIFIED AS METADATA_FILE_LAST_MODIFIED
,START_SCAN_TIME AS METADATA_START_SCAN_TIME
,{{ dbt_utils.generate_surrogate_key(['DATA:"whs_code"']) }} as TABLE_SK
,COALESCE(TO_TIMESTAMP_TZ(DATA:"DataEventTimestamp"),TO_TIMESTAMP_NTZ(DATEADD(microsecond, FILE_ROW_NUMBER,TO_TIMESTAMP_NTZ(DATA:"ipaas_updated_date"::string)))) as QUALIFY_TIMESTAMP

FROM {{ source("landing_spm_ca", "WAREHOUSE") }}

-- to only take the files after the last fullLoad
WHERE 
  split(FILENAME, '_')[array_size(split(FILENAME, '_')) - 2] >=
  (SELECT min_timestamp
  FROM
      (SELECT split(FILENAME, '_')[array_size(split(FILENAME, '_')) - 2] AS min_timestamp, split(FILENAME, '/')[3] AS type_file
      FROM {{ source("landing_spm_ca", "WAREHOUSE") }}
      WHERE type_file LIKE 'fullload%'
      QUALIFY ROW_NUMBER() OVER (ORDER BY min_timestamp DESC) = 1)
  )