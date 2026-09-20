{{
 config(
 materialized = "view",
 alias = "item_tech",
 schema='spm_ca'
 )
}}

SELECT
 DATA:"in_entity" AS IN_ENTITY
,DATA:"no_article" AS NO_ARTICLE
,DATA:"code_ref" AS CODE_REF
,DATA:"hauteur" AS HAUTEUR
,DATA:"largeur" AS LARGEUR
,DATA:"epaisseur" AS EPAISSEUR
,DATA:"aire" AS AIRE
,DATA:"long_deploye" AS LONG_DEPLOYE
,DATA:"utilisation" AS UTILISATION
,DATA:"fabrication" AS FABRICATION
,DATA:"no_item_num" AS NO_ITEM_NUM
,DATA:"surf_peint" AS SURF_PEINT
,DATA:"ep_oreille" AS EP_OREILLE
,DATA:"item_alt_no" AS ITEM_ALT_NO
,DATA:"master_item" AS MASTER_ITEM
,DATA:"holes_qty" AS HOLES_QTY
,DATA:"gage" AS GAGE
,DATA:"width_tolerance" AS WIDTH_TOLERANCE
,DATA:"thickness_tolerance_min" AS THICKNESS_TOLERANCE_MIN
,DATA:"thickness_tolerance_max" AS THICKNESS_TOLERANCE_MAX
,DATA:"item_finishing_uuid" AS ITEM_FINISHING_UUID
,DATA:"CreatedDate" AS CREATED_DATE
,DATA:"ModifiedDate" AS MODIFIED_DATE
,DATA:"CreatedBy" AS CREATED_BY
,DATA:"ModifiedBy" AS MODIFIED_BY
,DATA:"src_system_operation" AS SRC_SYSTEM_OPERATION
,DATA:"ipaas_updated_date" AS IPAAS_UPDATED_DATE
,DATA:"DataEventTimestamp" AS DATA_EVENT_TIMESTAMP
,FILENAME AS METADATA_FILENAME 
,FILE_ROW_NUMBER AS METADATA_FILE_ROW_NUMBER
,FILE_LAST_MODIFIED AS METADATA_FILE_LAST_MODIFIED
,START_SCAN_TIME AS METADATA_START_SCAN_TIME
,{{ dbt_utils.generate_surrogate_key(['DATA:"in_entity"','DATA:"no_article"']) }} as TABLE_SK
,COALESCE(TO_TIMESTAMP_TZ(DATA:"DataEventTimestamp"),TO_TIMESTAMP_NTZ(DATEADD(microsecond, FILE_ROW_NUMBER,TO_TIMESTAMP_NTZ(DATA:"ipaas_updated_date"::string)))) as QUALIFY_TIMESTAMP
FROM {{ source("landing_spm_ca", "ITEM_TECH") }}
-- to only take the files after the last fullLoad
WHERE 
 split(FILENAME, '_')[array_size(split(FILENAME, '_')) - 2] >=
 (SELECT min_timestamp
 FROM
 (SELECT split(FILENAME, '_')[array_size(split(FILENAME, '_')) - 2] AS min_timestamp, split(FILENAME, '/')[3] AS type_file
 FROM {{ source("landing_spm_ca", "ITEM_TECH") }}
 WHERE type_file LIKE 'fullload%'
 QUALIFY ROW_NUMBER() OVER (ORDER BY min_timestamp DESC) = 1)
 )