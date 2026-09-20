{{
  config(
    materialized = "view",
    alias = "entity_d",
    schema='spm_gen'
  )
}}


SELECT
 DATA:"entity_code" AS ENTITY_CODE
,DATA:"nom_abrege" AS NOM_ABREGE
,DATA:"message_gen_1" AS MESSAGE_GEN_1
,DATA:"message_gen_2" AS MESSAGE_GEN_2
,DATA:"message_gen_3" AS MESSAGE_GEN_3
,DATA:"message_gen_4" AS MESSAGE_GEN_4
,DATA:"message_gen_5" AS MESSAGE_GEN_5
,DATA:"message_gen_6" AS MESSAGE_GEN_6
,DATA:"message_gen_7" AS MESSAGE_GEN_7
,DATA:"message_gen_8" AS MESSAGE_GEN_8
,DATA:"message_gen_9" AS MESSAGE_GEN_9
,DATA:"message_gen_10" AS MESSAGE_GEN_10
,DATA:"message_gen_11" AS MESSAGE_GEN_11
,DATA:"message_gen_12" AS MESSAGE_GEN_12
,DATA:"message_gen_13" AS MESSAGE_GEN_13
,DATA:"no_banque" AS NO_BANQUE
,DATA:"no_enr_np" AS NO_ENR_NP
,DATA:"no_enr_p" AS NO_ENR_P
,DATA:"no_enr_prov" AS NO_ENR_PROV
,DATA:"flag_ass_1" AS FLAG_ASS_1
,DATA:"flag_ass_2" AS FLAG_ASS_2
,DATA:"flag_ass_3" AS FLAG_ASS_3
,DATA:"flag_ass_4" AS FLAG_ASS_4
,DATA:"flag_ass_5" AS FLAG_ASS_5
,DATA:"flag_ass_6" AS FLAG_ASS_6
,DATA:"flag_ass_7" AS FLAG_ASS_7
,DATA:"flag_ass_8" AS FLAG_ASS_8
,DATA:"flag_ass_9" AS FLAG_ASS_9
,DATA:"flag_ass_10" AS FLAG_ASS_10
,DATA:"flag_ass_11" AS FLAG_ASS_11
,DATA:"flag_ass_12" AS FLAG_ASS_12
,DATA:"flag_ass_13" AS FLAG_ASS_13
,DATA:"flag_ass_14" AS FLAG_ASS_14
,DATA:"flag_ass_15" AS FLAG_ASS_15
,DATA:"flag_ass_16" AS FLAG_ASS_16
,DATA:"flag_ass_17" AS FLAG_ASS_17
,DATA:"flag_ass_18" AS FLAG_ASS_18
,DATA:"flag_ass_19" AS FLAG_ASS_19
,DATA:"flag_ass_20" AS FLAG_ASS_20
,DATA:"flag_ass_21" AS FLAG_ASS_21
,DATA:"flag_ass_22" AS FLAG_ASS_22
,DATA:"flag_ass_23" AS FLAG_ASS_23
,DATA:"flag_ass_24" AS FLAG_ASS_24
,DATA:"entity_ass" AS ENTITY_ASS
,DATA:"rrq_share" AS RRQ_SHARE
,DATA:"asgr_share" AS ASGR_SHARE
,DATA:"cnt_share" AS CNT_SHARE
,DATA:"cansis_syst" AS CANSIS_SYST
,DATA:"ramq_share" AS RAMQ_SHARE
,DATA:"OHIP_share" AS OHIP_SHARE
,DATA:"csst_shared_1" AS CSST_SHARED_1
,DATA:"csst_shared_2" AS CSST_SHARED_2
,DATA:"csst_shared_3" AS CSST_SHARED_3
,DATA:"csst_shared_4" AS CSST_SHARED_4
,DATA:"csst_shared_5" AS CSST_SHARED_5
,DATA:"csst_shared_6" AS CSST_SHARED_6
,DATA:"csst_shared_7" AS CSST_SHARED_7
,DATA:"csst_shared_8" AS CSST_SHARED_8
,DATA:"taux_vac_h" AS TAUX_VAC_H
,DATA:"taux_vac_s" AS TAUX_VAC_S
,DATA:"ahc_share" AS AHC_SHARE
,DATA:"ass_gr_share" AS ASS_GR_SHARE
,DATA:"Mesure" AS MESURE
,DATA:"wcb_share_on_1" AS WCB_SHARE_ON_1
,DATA:"wcb_share_on_2" AS WCB_SHARE_ON_2
,DATA:"wcb_share_on_3" AS WCB_SHARE_ON_3
,DATA:"wcb_share_ab_1" AS WCB_SHARE_AB_1
,DATA:"wcb_share_ab_2" AS WCB_SHARE_AB_2
,DATA:"wcb_share_ab_3" AS WCB_SHARE_AB_3
,DATA:"wcb_share_cb_1" AS WCB_SHARE_CB_1
,DATA:"wcb_share_cb_2" AS WCB_SHARE_CB_2
,DATA:"wcb_share_cb_3" AS WCB_SHARE_CB_3
,DATA:"wcb_share_nb_1" AS WCB_SHARE_NB_1
,DATA:"wcb_share_nb_2" AS WCB_SHARE_NB_2
,DATA:"wcb_share_nb_3" AS WCB_SHARE_NB_3
,DATA:"pour_vac" AS POUR_VAC
,DATA:"taux_vac_h1" AS TAUX_VAC_H1
,DATA:"taux_vac_s1" AS TAUX_VAC_S1
,DATA:"Gsp_entity" AS GSP_ENTITY
,DATA:"Whs_code" AS WHS_CODE
,DATA:"rqap_yeur" AS RQAP_YEUR
,DATA:"bolt_whs_code" AS BOLT_WHS_CODE
,DATA:"Langue" AS LANGUE
,DATA:"hole_number_man" AS HOLE_NUMBER_MAN
,DATA:"slogan_name_id" AS SLOGAN_NAME_ID
,DATA:"StructuralWarehouseCode" AS STRUCTURAL_WAREHOUSE_CODE
,DATA:"rollbar_whs_code" AS ROLLBAR_WHS_CODE
,DATA:"tvq_taxable" AS TVQ_TAXABLE
,DATA:"deck_whs_code" AS DECK_WHS_CODE
,DATA:"cansis_company" AS CANSIS_COMPANY
,DATA:"cansis_location" AS CANSIS_LOCATION
,DATA:"cansis_organization" AS CANSIS_ORGANIZATION
,DATA:"cansis_po_preparer" AS CANSIS_PO_PREPARER
,DATA:"short_code" AS SHORT_CODE
,DATA:"naturl_langg" AS NATURL_LANGG
,DATA:"cmg_conv_phase" AS CMG_CONV_PHASE
,DATA:"cmg_trf_invc" AS CMG_TRF_INVC
,DATA:"desgo_versant" AS DESGO_VERSANT
,DATA:"office_code" AS OFFICE_CODE
,DATA:"measure_used" AS MEASURE_USED
,DATA:"girts_vertical_man" AS GIRTS_VERTICAL_MAN
,DATA:"sub_assembly_whs_code" AS SUB_ASSEMBLY_WHS_CODE
,DATA:"requisition_draw_deck_accessory" AS REQUISITION_DRAW_DECK_ACCESSORY
,DATA:"shop_documents_measure" AS SHOP_DOCUMENTS_MEASURE
,DATA:"ipaas_updated_date" AS IPAAS_UPDATED_DATE
,DATA:"src_system_operation" AS SRC_SYSTEM_OPERATION
,DATA:"DataEventTimestamp" AS DATA_EVENT_TIMESTAMP
,{{ dbt_utils.generate_surrogate_key(['DATA:"entity_code"']) }} as TABLE_SK
,COALESCE(TO_TIMESTAMP_TZ(DATA:"DataEventTimestamp"),TO_TIMESTAMP_NTZ(DATEADD(microsecond, FILE_ROW_NUMBER,TO_TIMESTAMP_NTZ(DATA:"ipaas_updated_date"::string)))) as QUALIFY_TIMESTAMP
from {{ source("landing_spm_gen", "ENTITY_D") }}
-- to only take the files after the last fullLoad
  WHERE 
  split(FILENAME, '_')[array_size(split(FILENAME, '_')) - 2] >=
    (SELECT min_timestamp
  FROM
      (SELECT split(FILENAME, '_')[array_size(split(FILENAME, '_')) - 2] AS min_timestamp, split(FILENAME, '/')[3] AS type_file
      FROM {{ source("landing_spm_gen", "ENTITY_D") }}
      WHERE type_file LIKE 'fullload%'
      QUALIFY ROW_NUMBER() OVER (ORDER BY min_timestamp DESC) = 1)
    )
 