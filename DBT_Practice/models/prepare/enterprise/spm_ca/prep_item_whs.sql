{{
  config(
    materialized = "view",
    alias = "item_whs",
    schema='spm_ca'
  )
}}


SELECT
DATA:"in_entity" AS IN_ENTITY
,DATA:"item_no" AS ITEM_NO
,DATA:"whs_code" AS WHS_CODE
,DATA:"bin_location" AS BIN_LOCATION
,DATA:"entity_inv" AS ENTITY_INV
,DATA:"entity_wip" AS ENTITY_WIP
,DATA:"lead_time" AS LEAD_TIME
,DATA:"reorder_lev" AS REORDER_LEV
,DATA:"econ_ord_qty" AS ECON_ORD_QTY
,DATA:"prd_of_stock" AS PRD_OF_STOCK
,DATA:"prd_research" AS PRD_RESEARCH
,DATA:"reorder_pct" AS REORDER_PCT
,DATA:"allow_bo" AS ALLOW_BO
,DATA:"misc_code" AS MISC_CODE
,DATA:"pri_rev_date" AS PRI_REV_DATE
,DATA:"price_10" AS PRICE_10
,DATA:"price_1" AS PRICE_1
,DATA:"price_8" AS PRICE_8
,DATA:"price_9" AS PRICE_9
,DATA:"price_5" AS PRICE_5
,DATA:"price_4" AS PRICE_4
,DATA:"price_6" AS PRICE_6
,DATA:"price_7" AS PRICE_7
,DATA:"price_3" AS PRICE_3
,DATA:"price_2" AS PRICE_2
,DATA:"dollar_pct_9" AS DOLLAR_PCT_9
,DATA:"dollar_pct_10" AS DOLLAR_PCT_10
,DATA:"dollar_pct_7" AS DOLLAR_PCT_7
,DATA:"dollar_pct_6" AS DOLLAR_PCT_6
,DATA:"dollar_pct_8" AS DOLLAR_PCT_8
,DATA:"dollar_pct_5" AS DOLLAR_PCT_5
,DATA:"dollar_pct_1" AS DOLLAR_PCT_1
,DATA:"dollar_pct_4" AS DOLLAR_PCT_4
,DATA:"dollar_pct_3" AS DOLLAR_PCT_3
,DATA:"dollar_pct_2" AS DOLLAR_PCT_2
,DATA:"pst_exempt" AS PST_EXEMPT
,DATA:"fst_exempt" AS FST_EXEMPT
,DATA:"fst_code" AS FST_CODE
,DATA:"taxable" AS TAXABLE
,DATA:"cost_method" AS COST_METHOD
,DATA:"prod_group" AS PROD_GROUP
,DATA:"last_vendor" AS LAST_VENDOR
,DATA:"automt_release" AS AUTOMT_RELEASE
,DATA:"hist_trans" AS HIST_TRANS
,DATA:"std_time" AS STD_TIME
,DATA:"order_level" AS ORDER_LEVEL
,DATA:"production_cost" AS PRODUCTION_COST
,DATA:"active" AS ACTIVE
,DATA:"DeactivationDateTime" AS DEACTIVATION_DATETIME
,DATA:"DeactivationBy" AS DEACTIVATION_BY
,DATA:"_rowid" AS ROW_ID
,DATA:"CreatedBy" AS CREATED_BY
,DATA:"CreatedDate" AS CREATED_DATE
,DATA:"ModifiedDate" AS MODIFIED_DATE
,DATA:"ModifiedBy" AS MODIFIED_BY
,DATA:"src_system_operation" AS SRC_SYSTEM_OPERATION
,DATA:"ipaas_updated_date" AS IPAAS_UPDATED_DATE
,DATA:"DataEventTimestamp" AS DATA_EVENT_TIMESTAMP
,FILENAME                           AS METADATA_FILENAME 
,FILE_ROW_NUMBER                    AS METADATA_FILE_ROW_NUMBER
,FILE_LAST_MODIFIED                 AS METADATA_FILE_LAST_MODIFIED
,START_SCAN_TIME                    AS METADATA_START_SCAN_TIME
,{{ dbt_utils.generate_surrogate_key(['DATA:"in_entity"','DATA:"item_no"','DATA:"whs_code"']) }} as TABLE_SK
,COALESCE(TO_TIMESTAMP_TZ(DATA:"DataEventTimestamp"),TO_TIMESTAMP_NTZ(DATEADD(microsecond, FILE_ROW_NUMBER,TO_TIMESTAMP_NTZ(DATA:"ipaas_updated_date"::string)))) as QUALIFY_TIMESTAMP
from {{ source("landing_spm_ca", "ITEM_WHS") }}
-- to only take the files after the last fullLoad
WHERE 
  split(FILENAME, '_')[array_size(split(FILENAME, '_')) - 2] >=
  (SELECT min_timestamp
  FROM
      (SELECT split(FILENAME, '_')[array_size(split(FILENAME, '_')) - 2] AS min_timestamp, split(FILENAME, '/')[3] AS type_file
      FROM {{ source("landing_spm_ca", "ITEM_WHS") }}
      WHERE type_file LIKE 'fullload%'
      QUALIFY ROW_NUMBER() OVER (ORDER BY min_timestamp DESC) = 1)
  )