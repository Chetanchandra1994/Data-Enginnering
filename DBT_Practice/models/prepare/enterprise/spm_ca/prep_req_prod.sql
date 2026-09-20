{{
 config(
 materialized = "view",
 alias = "req_prod",
 schema='spm_ca'
 )
}}

SELECT
 DATA:"entity_code" AS ENTITY_CODE
,DATA:"no_poids" AS NO_POIDS
,DATA:"ind_calcul" AS IND_CALCUL
,DATA:"no_projet" AS NO_PROJET
,DATA:"no_poids_lie" AS NO_POIDS_LIE
,DATA:"no_produit" AS NO_PRODUIT
,DATA:"real_time_1" AS REAL_TIME_1
,DATA:"real_time_2" AS REAL_TIME_2
,DATA:"real_time_3" AS REAL_TIME_3
,DATA:"real_time_4" AS REAL_TIME_4
,DATA:"real_time_5" AS REAL_TIME_5
,DATA:"real_time_6" AS REAL_TIME_6
,DATA:"d_creation" AS D_CREATION
,DATA:"mesure" AS MESURE
,DATA:"division" AS DIVISION
,DATA:"complete" AS COMPLETE
,DATA:"stats_prod_1" AS STATS_PROD_1
,DATA:"stats_prod_2" AS STATS_PROD_2
,DATA:"stats_prod_3" AS STATS_PROD_3
,DATA:"stats_prod_4" AS STATS_PROD_4
,DATA:"mise_en_prod" AS MISE_EN_PROD
,DATA:"d_prod" AS D_PROD
,DATA:"no_peinture" AS NO_PEINTURE
,DATA:"no_detailer" AS NO_DETAILER
,DATA:"no_trou" AS NO_TROU
,DATA:"date_cal_tps" AS DATE_CAL_TPS
,DATA:"type_req" AS TYPE_REQ
,DATA:"printed" AS PRINTED
,DATA:"code_fin_t" AS CODE_FIN_T
,DATA:"code_fin_c" AS CODE_FIN_C
,DATA:"shop_order" AS SHOP_ORDER
,DATA:"d_shop" AS D_SHOP
,DATA:"seq_paint" AS SEQ_PAINT
,DATA:"seq_no" AS SEQ_NO
,DATA:"sel_mep" AS SEL_MEP
,DATA:"seq_shop" AS SEQ_SHOP
,DATA:"shop_no" AS SHOP_NO
,DATA:"no_job_shop" AS NO_JOB_SHOP
,DATA:"end_ass" AS END_ASS
,DATA:"end_weld" AS END_WELD
,DATA:"rem_1" AS REM_1
,DATA:"rem_2" AS REM_2
,DATA:"eng_rel_date" AS ENG_REL_DATE
,DATA:"det_enable" AS DET_ENABLE
,DATA:"prodct_status" AS PRODCT_STATUS
,DATA:"delivr_status" AS DELIVR_STATUS
,DATA:"finish_status" AS FINISH_STATUS
,DATA:"paint_instr_no" AS PAINT_INSTR_NO
,DATA:"paint_color" AS PAINT_COLOR
,DATA:"seq_no_list" AS SEQ_NO_LIST
,DATA:"remark_1" AS REMARK_1
,DATA:"remark_2" AS REMARK_2
,DATA:"remark_3" AS REMARK_3
,DATA:"remark_4" AS REMARK_4
,DATA:"remark_5" AS REMARK_5
,DATA:"remark_6" AS REMARK_6
,DATA:"revisn" AS REVISN
,DATA:"original_entity" AS ORIGINAL_ENTITY
,DATA:"kronos_trf_date" AS KRONOS_TRF_DATE
,DATA:"deck_notes_id_list" AS DECK_NOTES_ID_LIST
,DATA:"prioritized" AS PRIORITIZED
,DATA:"dummy" AS DUMMY
,DATA:"bridging_grouped_date" AS BRIDGING_GROUPED_DATE
,DATA:"bridging_grouped_time" AS BRIDGING_GROUPED_TIME
,DATA:"bridging_grouped_by" AS BRIDGING_GROUPED_BY
,DATA:"requisition_received_date" AS REQUISITION_RECEIVED_DATE
,DATA:"urgent" AS URGENT
,DATA:"transfer_status" AS TRANSFER_STATUS
,DATA:"machn_no" AS MACHN_NO
,DATA:"fabrication_dropdead_date" AS FABRICATION_DROPDEAD_DATE
,DATA:"fabrication_dropdead_time" AS FABRICATION_DROPDEAD_TIME
,DATA:"fob_code" AS FOB_CODE
,DATA:"delivery_comment" AS DELIVERY_COMMENT
,DATA:"fabrication_shop_time" AS FABRICATION_SHOP_TIME
,DATA:"deck_grouped_requisition" AS DECK_GROUPED_REQUISITION
,DATA:"bin_location" AS BIN_LOCATION
,DATA:"bin_location_upd_by" AS BIN_LOCATION_UPD_BY
,DATA:"rollbar_use" AS ROLLBAR_USE
,DATA:"print_information_on_item" AS PRINT_INFORMATION_ON_ITEM
,DATA:"structural_bolt_assembly_loc" AS STRUCTURAL_BOLT_ASSEMBLY_LOC
,DATA:"marking_color_uuid" AS MARKING_COLOR_UUID
,DATA:"multi_destination" AS MULTI_DESTINATION
,DATA:"pre_assembled" AS PRE_ASSEMBLED
,DATA:"pre_assembled_bolt_requisition" AS PRE_ASSEMBLED_BOLT_REQUISITION
,DATA:"panel_bundle_number" AS PANEL_BUNDLE_NUMBER
,DATA:"CreatedBy" AS CREATEDBY
,DATA:"importation_datetime" AS IMPORTATION_DATETIME
,DATA:"ModifiedDate" AS MODIFIEDDATE
,DATA:"additional_planning_date" AS ADDITIONAL_PLANNING_DATE
,DATA:"project_purchase_order_uuid" AS PROJECT_PURCHASE_ORDER_UUID
,DATA:"application_transfer_uuid" AS APPLICATION_TRANSFER_UUID
,DATA:"production_shipping_delay" AS PRODUCTION_SHIPPING_DELAY
,DATA:"sequenced_preparation" AS SEQUENCED_PREPARATION
,DATA:"CratingWeight" AS CRATINGWEIGHT
,DATA:"ExpectedAssemblyShopUUID" AS EXPECTEDASSEMBLYSHOPUUID
,DATA:"ExpectedAssemblyDateTime" AS EXPECTEDASSEMBLYDATETIME
,DATA:"BundledRequisition" AS BUNDLEDREQUISITION
,DATA:"ExternalId" AS EXTERNALID
,DATA:"ErectionLabel" AS ERECTIONLABEL
,DATA:"CreatedDate" AS CREATEDDATE
,DATA:"ModifiedBy" AS MODIFIEDBY
,DATA:"req_prod_uuid" AS REQ_PROD_UUID
,DATA:"src_system_operation" AS SRC_SYSTEM_OPERATION
,DATA:"ipaas_updated_date" AS IPAAS_UPDATED_DATE
,DATA:"DataEventTimestamp" AS DATA_EVENT_TIMESTAMP
,FILENAME AS METADATA_FILENAME 
,FILE_ROW_NUMBER AS METADATA_FILE_ROW_NUMBER
,FILE_LAST_MODIFIED AS METADATA_FILE_LAST_MODIFIED
,START_SCAN_TIME AS METADATA_START_SCAN_TIME
,{{ dbt_utils.generate_surrogate_key(['DATA:"entity_code"','DATA:"no_poids"']) }} as TABLE_SK
,COALESCE(TO_TIMESTAMP_TZ(DATA:"DataEventTimestamp"),TO_TIMESTAMP_NTZ(DATEADD(microsecond, FILE_ROW_NUMBER,TO_TIMESTAMP_NTZ(DATA:"ipaas_updated_date"::string)))) as QUALIFY_TIMESTAMP

FROM {{ source("landing_spm_ca", "REQ_PROD") }}
-- to only take the files after the last fullLoad
WHERE 
 split(FILENAME, '_')[array_size(split(FILENAME, '_')) - 2] >=
 (SELECT min_timestamp
 FROM
 (SELECT split(FILENAME, '_')[array_size(split(FILENAME, '_')) - 2] AS min_timestamp, split(FILENAME, '/')[3] AS type_file
 FROM {{ source("landing_spm_ca", "REQ_PROD") }}
 WHERE type_file LIKE 'fullload%'
 QUALIFY ROW_NUMBER() OVER (ORDER BY min_timestamp DESC) = 1)
 )