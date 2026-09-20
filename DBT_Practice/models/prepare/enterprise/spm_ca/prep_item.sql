{{
 config(
 materialized = "view",
 alias = "item",
 schema='spm_ca'
 )
}}

SELECT
 DATA:"in_entity" AS IN_ENTITY
,DATA:"item_no" AS ITEM_NO
,DATA:"sort_name" AS SORT_NAME
,DATA:"uom_code" AS UOM_CODE
,DATA:"stats_code" AS STATS_CODE
,DATA:"break_code" AS BREAK_CODE
,DATA:"pricing_grp" AS PRICING_GRP
,DATA:"vendor_code" AS VENDOR_CODE
,DATA:"volume" AS VOLUME
,DATA:"weight" AS WEIGHT
,DATA:"status_code" AS STATUS_CODE
,DATA:"active" AS ACTIVE
,DATA:"duty_code" AS DUTY_CODE
,DATA:"last_po_no" AS LAST_PO_NO
,DATA:"last_rel_no" AS LAST_REL_NO
,DATA:"udm_alt" AS UDM_ALT
,DATA:"facteur" AS FACTEUR
,DATA:"mesure" AS MESURE
,DATA:"mill_cost" AS MILL_COST
,DATA:"whs_rate" AS WHS_RATE
,DATA:"rev_cost_date" AS REV_COST_DATE
,DATA:"est_cost" AS EST_COST
,DATA:"epix_seq" AS EPIX_SEQ
,DATA:"CreatedDate" AS CREATED_DATE
,DATA:"ModifiedDate" AS MODIFIED_DATE
,DATA:"global_item_uuid" AS GLOBAL_ITEM_UUID
,DATA:"item_uuid" AS ITEM_UUID
,DATA:"steel_grade_uuid" AS STEEL_GRADE_UUID
,DATA:"CreatedBy" AS CREATED_BY
,DATA:"ModifiedBy" AS MODIFIED_BY
,DATA:"src_system_operation" AS SRC_SYSTEM_OPERATION
,DATA:"ipaas_updated_date" AS IPAAS_UPDATED_DATE
,DATA:"DataEventTimestamp" AS DATA_EVENT_TIMESTAMP
,FILENAME AS METADATA_FILENAME 
,FILE_ROW_NUMBER AS METADATA_FILE_ROW_NUMBER
,FILE_LAST_MODIFIED AS METADATA_FILE_LAST_MODIFIED
,START_SCAN_TIME AS METADATA_START_SCAN_TIME
,{{ dbt_utils.generate_surrogate_key(['DATA:"item_uuid"']) }} as TABLE_SK
,COALESCE(TO_TIMESTAMP_TZ(DATA:"DataEventTimestamp"),TO_TIMESTAMP_NTZ(DATEADD(microsecond, FILE_ROW_NUMBER,TO_TIMESTAMP_NTZ(DATA:"ipaas_updated_date"::string)))) as QUALIFY_TIMESTAMP
FROM {{ source("landing_spm_ca", "ITEM") }}
-- to only take the files after the last fullLoad
WHERE 
 split(FILENAME, '_')[array_size(split(FILENAME, '_')) - 2] >=
 (SELECT min_timestamp
 FROM
 (SELECT split(FILENAME, '_')[array_size(split(FILENAME, '_')) - 2] AS min_timestamp, split(FILENAME, '/')[3] AS type_file
 FROM {{ source("landing_spm_ca", "ITEM") }}
 WHERE type_file LIKE 'fullload%'
 QUALIFY ROW_NUMBER() OVER (ORDER BY min_timestamp DESC) = 1)
 )