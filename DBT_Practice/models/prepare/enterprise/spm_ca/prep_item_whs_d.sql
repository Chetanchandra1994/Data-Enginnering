{{
  config(
    materialized = "view",
    alias = "item_whs_d",
    schema='spm_ca'
  )
}}


SELECT
 DATA:"in_entity" AS IN_ENTITY
,DATA:"item_no" AS ITEM_NO
,DATA:"whs_code" AS WHS_CODE
,DATA:"qty_on_hand" AS QTY_ON_HAND
,DATA:"on_hand_date" AS ON_HAND_DATE
,DATA:"qty_cust_ord" AS QTY_CUST_ORD
,DATA:"qty_alloc" AS QTY_ALLOC
,DATA:"qty_on_pps" AS QTY_ON_PPS
,DATA:"qty_on_po" AS QTY_ON_PO
,DATA:"cost" AS COST
,DATA:"cost_date" AS COST_DATE
,DATA:"last_cost" AS LAST_COST
,DATA:"last_ct_date" AS LAST_CT_DATE
,DATA:"ohu_count" AS OHU_COUNT
,DATA:"computed_min" AS COMPUTED_MIN
,DATA:"opening_qty" AS OPENING_QTY
,DATA:"opening_amt" AS OPENING_AMT
,DATA:"class" AS CLASS
,DATA:"cos_ytd" AS COS_YTD
,DATA:"qty_ytd" AS QTY_YTD
,DATA:"cost_dpv" AS COST_DPV
,DATA:"total_cost" AS TOTAL_COST
,DATA:"old_qty_oh" AS OLD_QTY_OH
,DATA:"qty_on_memo" AS QTY_ON_MEMO
,DATA:"order_level" AS ORDER_LEVEL
,DATA:"qty_on_bundle" AS QTY_ON_BUNDLE
,DATA:"last_pc_date" AS LAST_PC_DATE
,DATA:"CreatedBy" AS CREATEDBY
,DATA:"CreatedDate" AS CREATEDDATE
,DATA:"ModifiedDate" AS MODIFIEDDATE
,DATA:"ModifiedBy" AS MODIFIEDBY
,DATA:"src_system_operation" AS SRC_SYSTEM_OPERATION
,DATA:"ipaas_updated_date" AS IPAAS_UPDATED_DATE
,DATA:"DataEventTimestamp" AS DATA_EVENT_TIMESTAMP
,FILENAME                           AS METADATA_FILENAME 
,FILE_ROW_NUMBER                    AS METADATA_FILE_ROW_NUMBER
,FILE_LAST_MODIFIED                 AS METADATA_FILE_LAST_MODIFIED
,START_SCAN_TIME                    AS METADATA_START_SCAN_TIME
,{{ dbt_utils.generate_surrogate_key(['DATA:"in_entity"','DATA:"item_no"','DATA:"whs_code"']) }} as TABLE_SK
,COALESCE(TO_TIMESTAMP_TZ(DATA:"DataEventTimestamp"),TO_TIMESTAMP_NTZ(DATEADD(microsecond, FILE_ROW_NUMBER,TO_TIMESTAMP_NTZ(DATA:"ipaas_updated_date"::string)))) as QUALIFY_TIMESTAMP
from {{ source("landing_spm_ca", "ITEM_WHS_D") }}
-- to only take the files after the last fullLoad
WHERE 
  split(FILENAME, '_')[array_size(split(FILENAME, '_')) - 2] >=
  (SELECT min_timestamp
  FROM
      (SELECT split(FILENAME, '_')[array_size(split(FILENAME, '_')) - 2] AS min_timestamp, split(FILENAME, '/')[3] AS type_file
      FROM {{ source("landing_spm_ca", "ITEM_WHS_D") }}
      WHERE type_file LIKE 'fullload%'
      QUALIFY ROW_NUMBER() OVER (ORDER BY min_timestamp DESC) = 1)
  )