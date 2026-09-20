{{
 config(
    materialized = "view",
    alias = "item_alt_po",
    schema='spm_ca'
    )
}}



SELECT
 DATA:"in_entity" AS IN_ENTITY
,DATA:"no_projet_fr" AS NO_PROJET_FR
,DATA:"line_no" AS LINE_NO
,DATA:"item_no" AS ITEM_NO
,DATA:"mesure_alt" AS MESURE_ALT
,DATA:"udm_alt" AS UDM_ALT
,DATA:"whs_code" AS WHS_CODE
,DATA:"no_projet_to" AS NO_PROJET_TO
,DATA:"type_ref" AS TYPE_REF
,DATA:"reference" AS REFERENCE
,DATA:"fathr_no" AS FATHR_NO
,DATA:"upd_date" AS UPD_DATE
,DATA:"upd_time" AS UPD_TIME
,DATA:"user" AS USER
,DATA:"mli" AS MLI
,DATA:"seq_no_list" AS SEQ_NO_LIST
,DATA:"seq_no" AS SEQ_NO
,DATA:"mesure1" AS MESURE1
,DATA:"mesure2" AS MESURE2
,DATA:"detail" AS DETAIL
,DATA:"oper_code" AS OPER_CODE
,DATA:"item_alt_id" AS ITEM_ALT_ID
,DATA:"abm_status" AS ABM_STATUS
,DATA:"heat_no" AS HEAT_NO
,DATA:"plate_no" AS PLATE_NO
,DATA:"piece_id" AS PIECE_ID
,DATA:"material_reference_list" AS MATERIAL_REFERENCE_LIST
,DATA:"CommentStatus" AS COMMENTSTATUS
,DATA:"CommentSolution" AS COMMENTSOLUTION
,DATA:"CommentPurchase" AS COMMENTPURCHASE
,DATA:"src_system_operation" AS SRC_SYSTEM_OPERATION
,DATA:"ipaas_updated_date" AS IPAAS_UPDATED_DATE
,FILENAME AS METADATA_FILENAME 
,FILE_ROW_NUMBER AS METADATA_FILE_ROW_NUMBER
,FILE_LAST_MODIFIED AS METADATA_FILE_LAST_MODIFIED
,START_SCAN_TIME AS METADATA_START_SCAN_TIME
FROM {{ source("landing_spm_ca", "ITEM_ALT_PO") }}
-- to only take the files after the last fullLoad
WHERE 
 split(FILENAME, '_')[array_size(split(FILENAME, '_')) - 2] >=
 (SELECT min_timestamp
 FROM
 (SELECT split(FILENAME, '_')[array_size(split(FILENAME, '_')) - 2] AS min_timestamp, split(FILENAME, '/')[3] AS type_file
 FROM {{ source("landing_spm_ca", "ITEM_ALT_PO") }}
 WHERE type_file LIKE 'fullload%'
 QUALIFY ROW_NUMBER() OVER (ORDER BY min_timestamp DESC) = 1)
 )