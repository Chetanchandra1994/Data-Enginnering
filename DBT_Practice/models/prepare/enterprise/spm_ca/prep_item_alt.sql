{{
 config(
    materialized = "view",
    alias = "item_alt",
    schema='spm_ca'
 )
}}

SELECT
 DATA:"in_entity" AS IN_ENTITY
,DATA:"whs_code" AS WHS_CODE
,DATA:"item_no" AS ITEM_NO
,DATA:"mesure_alt" AS MESURE_ALT
,DATA:"udm_alt" AS UDM_ALT
,DATA:"no_reser" AS NO_RESER
,DATA:"prod_date" AS PROD_DATE
,DATA:"mli" AS MLI
,DATA:"heat_no" AS HEAT_NO
,DATA:"bin_location" AS BIN_LOCATION
,DATA:"type_ref" AS TYPE_REF
,DATA:"reference" AS REFERENCE
,DATA:"no_projet_to" AS NO_PROJET_TO
,DATA:"line_no" AS LINE_NO
,DATA:"user" AS USER
,DATA:"fathr_no" AS FATHR_NO
,DATA:"seq_no_list" AS SEQ_NO_LIST
,DATA:"seq_no" AS SEQ_NO
,DATA:"work_order" AS WORK_ORDER
,DATA:"mesure1" AS MESURE1
,DATA:"mesure2" AS MESURE2
,DATA:"detail" AS DETAIL
,DATA:"oper_code" AS OPER_CODE
,DATA:"item_alt_id" AS ITEM_ALT_ID
,DATA:"abm_status" AS ABM_STATUS
,DATA:"drop_project" AS DROP_PROJECT
,DATA:"drop_division" AS DROP_DIVISION
,DATA:"plate_no" AS PLATE_NO
,DATA:"po_no" AS PO_NO
,DATA:"po_line_no" AS PO_LINE_NO
,DATA:"parent_id" AS PARENT_ID
,DATA:"sketch" AS SKETCH
,DATA:"piece_id" AS PIECE_ID
,DATA:"procss_vendor_code" AS PROCSS_VENDOR_CODE
,DATA:"procss_send_date" AS PROCSS_SEND_DATE
,DATA:"procss_back_date" AS PROCSS_BACK_DATE
,DATA:"transf_date" AS TRANSF_DATE
,DATA:"charpy_test" AS CHARPY_TEST
,DATA:"material_reference_list" AS MATERIAL_REFERENCE_LIST
,DATA:"cost" AS COST
,DATA:"GantryRequestedDateTime" AS GANTRYREQUESTEDDATETIME
,DATA:"GantryConfirmedDateTime" AS GANTRYCONFIRMEDDATETIME
,DATA:"CommentPurchase" AS COMMENTPURCHASE
,DATA:"CommentStatus" AS COMMENTSTATUS
,DATA:"CommentSolution" AS COMMENTSOLUTION
,DATA:"BackgroundHexadecimalColor" AS BACKGROUNDHEXADECIMALCOLOR
,DATA:"src_system_operation" AS SRC_SYSTEM_OPERATION
,DATA:"ipaas_updated_date" AS IPAAS_UPDATED_DATE
,FILENAME AS METADATA_FILENAME 
,FILE_ROW_NUMBER AS METADATA_FILE_ROW_NUMBER
,FILE_LAST_MODIFIED AS METADATA_FILE_LAST_MODIFIED
,START_SCAN_TIME AS METADATA_START_SCAN_TIME
FROM {{ source("landing_spm_ca", "ITEM_ALT") }}
-- to only take the files after the last fullLoad
WHERE 
 split(FILENAME, '_')[array_size(split(FILENAME, '_')) - 2] >=
 (SELECT min_timestamp
 FROM
 (SELECT split(FILENAME, '_')[array_size(split(FILENAME, '_')) - 2] AS min_timestamp, split(FILENAME, '/')[3] AS type_file
 FROM {{ source("landing_spm_ca", "ITEM_ALT") }}
 WHERE type_file LIKE 'fullload%'
 QUALIFY ROW_NUMBER() OVER (ORDER BY min_timestamp DESC) = 1)
 )