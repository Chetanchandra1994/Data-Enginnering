{{
  config(
    materialized = "view",
    alias = "produit_s",
    schema='spm_ca'
  )
}}


SELECT
DATA:"entity_code" AS ENTITY_CODE
,DATA:"no_produit" AS NO_PRODUIT
,DATA:"nom_produit" AS NOM_PRODUIT
,DATA:"nom_abrege" AS NOM_ABREGE
,DATA:"no_usine" AS NO_USINE
,DATA:"cout_std_min" AS COUT_STD_MIN
,DATA:"drw_std_cost" AS DRW_STD_COST
,DATA:"no_gl" AS NO_GL
,DATA:"poids_theor" AS POIDS_THEOR
,DATA:"cout_acier" AS COUT_ACIER
,DATA:"cout_fabr" AS COUT_FABR
,DATA:"base_taxe" AS BASE_TAXE
,DATA:"distr_fact" AS DISTR_FACT
,DATA:"taxable_1" AS TAXABLE_1
,DATA:"taxable_2" AS TAXABLE_2
,DATA:"taxable_4" AS TAXABLE_4
,DATA:"taxable_3" AS TAXABLE_3
,DATA:"fst_applic" AS FST_APPLIC
,DATA:"impr_qtes" AS IMPR_QTES
,DATA:"taux_fed" AS TAUX_FED
,DATA:"largeur" AS LARGEUR
,DATA:"cout_histo" AS COUT_HISTO
,DATA:"furn_cost" AS FURN_COST
,DATA:"item_no" AS ITEM_NO
,DATA:"type_prod" AS TYPE_PROD
,DATA:"sous_contrat" AS SOUS_CONTRAT
,DATA:"create_auto" AS CREATE_AUTO
,DATA:"royaute" AS ROYAUTE
,DATA:"ind_rebut" AS IND_REBUT
,DATA:"length_min" AS LENGTH_MIN
,DATA:"stats_depth" AS STATS_DEPTH
,DATA:"shoe_length" AS SHOE_LENGTH
,DATA:"util_tx" AS UTIL_TX
,DATA:"stats_unites" AS STATS_UNITES
,DATA:"stats_poids" AS STATS_POIDS
,DATA:"stats_tmps" AS STATS_TMPS
,DATA:"nom_prod_ang" AS NOM_PROD_ANG
,DATA:"code_aisi" AS CODE_AISI
,DATA:"no_colon_carn" AS NO_COLON_CARN
,DATA:"maj_res_inv" AS MAJ_RES_INV
,DATA:"upd_util" AS UPD_UTIL
,DATA:"girts_prodc" AS GIRTS_PRODC
,DATA:"follow_mark" AS FOLLOW_MARK
,DATA:"ext_fab" AS EXT_FAB
,DATA:"follow_div" AS FOLLOW_DIV
,DATA:"raw_material" AS RAW_MATERIAL
,DATA:"dept_id" AS DEPT_ID
,DATA:"prodct_compnt" AS PRODCT_COMPNT
,DATA:"use_std_cost" AS USE_STD_COST
,DATA:"efficacite_5" AS EFFICACITE_5
,DATA:"efficacite_3" AS EFFICACITE_3
,DATA:"efficacite_2" AS EFFICACITE_2
,DATA:"efficacite_1" AS EFFICACITE_1
,DATA:"efficacite_6" AS EFFICACITE_6
,DATA:"efficacite_4" AS EFFICACITE_4
,DATA:"category_2" AS CATEGORY_2
,DATA:"category_1" AS CATEGORY_1
,DATA:"id_factor_1" AS ID_FACTOR_1
,DATA:"id_factor_5" AS ID_FACTOR_5
,DATA:"id_factor_2" AS ID_FACTOR_2
,DATA:"id_factor_4" AS ID_FACTOR_4
,DATA:"id_factor_3" AS ID_FACTOR_3
,DATA:"dept_no_5" AS DEPT_NO_5
,DATA:"dept_no_6" AS DEPT_NO_6
,DATA:"dept_no_4" AS DEPT_NO_4
,DATA:"dept_no_3" AS DEPT_NO_3
,DATA:"dept_no_2" AS DEPT_NO_2
,DATA:"dept_no_1" AS DEPT_NO_1
,DATA:"furn_cost_2" AS FURN_COST_2
,DATA:"furn_cost_3" AS FURN_COST_3
,DATA:"furn_cost_1" AS FURN_COST_1
,DATA:"furn_cost_4" AS FURN_COST_4
,DATA:"overhead_cost" AS OVERHEAD_COST
,DATA:"task_number" AS TASK_NUMBER
,DATA:"cout_fabr_3" AS COUT_FABR_3
,DATA:"cout_fabr_2" AS COUT_FABR_2
,DATA:"cout_fabr_1" AS COUT_FABR_1
,DATA:"dept_time_2" AS DEPT_TIME_2
,DATA:"dept_time_3" AS DEPT_TIME_3
,DATA:"dept_time_6" AS DEPT_TIME_6
,DATA:"dept_time_5" AS DEPT_TIME_5
,DATA:"dept_time_4" AS DEPT_TIME_4
,DATA:"dept_time_1" AS DEPT_TIME_1
,DATA:"cmg_revenue_method" AS CMG_REVENUE_METHOD
,DATA:"cmg_transf_cost" AS CMG_TRANSF_COST
,DATA:"eng_required" AS ENG_REQUIRED
,DATA:"bolt_product" AS BOLT_PRODUCT
,DATA:"standard_product" AS STANDARD_PRODUCT
,DATA:"deck_logos" AS DECK_LOGOS
,DATA:"use_std_rate" AS USE_STD_RATE
,DATA:"fringe_benefits_pct" AS FRINGE_BENEFITS_PCT
,DATA:"valid_item_no" AS VALID_ITEM_NO
,DATA:"max_bundl_pieces" AS MAX_BUNDL_PIECES
,DATA:"bundl_pieces_tolerance" AS BUNDL_PIECES_TOLERANCE
,DATA:"is_active" AS IS_ACTIVE
,DATA:"deck_coolant_code" AS DECK_COOLANT_CODE
,DATA:"deck_edge_detector_max" AS DECK_EDGE_DETECTOR_MAX
,DATA:"deck_edge_detector_high" AS DECK_EDGE_DETECTOR_HIGH
,DATA:"deck_edge_detector_ideal" AS DECK_EDGE_DETECTOR_IDEAL
,DATA:"deck_edge_detector_low" AS DECK_EDGE_DETECTOR_LOW
,DATA:"deck_edge_detector_min" AS DECK_EDGE_DETECTOR_MIN
,DATA:"width_tolerance" AS WIDTH_TOLERANCE
,DATA:"sticker_color_no" AS STICKER_COLOR_NO
,DATA:"deck_vented" AS DECK_VENTED
,DATA:"deck_hanger_tab" AS DECK_HANGER_TAB
,DATA:"deck_regular" AS DECK_REGULAR
,DATA:"deck_acoustic" AS DECK_ACOUSTIC
,DATA:"deck_full_acoustic" AS DECK_FULL_ACOUSTIC
,DATA:"deck_depth" AS DECK_DEPTH
,DATA:"deck_accessory" AS DECK_ACCESSORY
,DATA:"deck_embossing" AS DECK_EMBOSSING
,DATA:"deck_type_code" AS DECK_TYPE_CODE
,DATA:"code_fin_c" AS CODE_FIN_C
,DATA:"paint_color" AS PAINT_COLOR
,DATA:"type_req" AS TYPE_REQ
,DATA:"mark_prefix" AS MARK_PREFIX
,DATA:"cat_struct" AS CAT_STRUCT
,DATA:"no_peinture" AS NO_PEINTURE
,DATA:"code_fin_t" AS CODE_FIN_T
,DATA:"deck_estimation_category" AS DECK_ESTIMATION_CATEGORY
,DATA:"additional_planning_delay" AS ADDITIONAL_PLANNING_DELAY
,DATA:"maximum_marks_number" AS MAXIMUM_MARKS_NUMBER
,DATA:"maximum_marks_qty" AS MAXIMUM_MARKS_QTY
,DATA:"automatic_sequencing" AS AUTOMATIC_SEQUENCING
,DATA:"invoicing_amt_calculation" AS INVOICING_AMT_CALCULATION
,DATA:"sold_detail_tolerance_amount" AS SOLD_DETAIL_TOLERANCE_AMOUNT
,DATA:"sold_detail_tolerance_weight_pct" AS SOLD_DETAIL_TOLERANCE_WEIGHT_PCT
,DATA:"sold_detail_tolerance_unit" AS SOLD_DETAIL_TOLERANCE_UNIT
,DATA:"uom_budget_entry_type" AS UOM_BUDGET_ENTRY_TYPE
,DATA:"sold_detail_tolerance_uom" AS SOLD_DETAIL_TOLERANCE_UOM
,DATA:"transfer_invoicing_amt" AS TRANSFER_INVOICING_AMT
,DATA:"hourly_production" AS HOURLY_PRODUCTION
,DATA:"capacity_uom_code" AS CAPACITY_UOM_CODE
,DATA:"preparation_planning" AS PREPARATION_PLANNING
,DATA:"revenue_quantity_type_uuid" AS REVENUE_QUANTITY_TYPE_UUID
,DATA:"erector_privilege" AS ERECTOR_PRIVILEGE
,DATA:"erector_priv_web_app_included" AS ERECTOR_PRIV_WEB_APP_INCLUDED
,DATA:"erector_priv_web_app_mark_weight" AS ERECTOR_PRIV_WEB_APP_MARK_WEIGHT
,DATA:"erector_priv_web_app_weight_pct" AS ERECTOR_PRIV_WEB_APP_WEIGHT_PCT
,DATA:"erector_priv_sale_product" AS ERECTOR_PRIV_SALE_PRODUCT
,DATA:"mark_piece_detail_allowed" AS MARK_PIECE_DETAIL_ALLOWED
,DATA:"transfer_waste_cost" AS TRANSFER_WASTE_COST
,DATA:"DisplayMarkDetailInErectorWebApp" AS DISPLAY_MARK_DETAIL_IN_ERECTOR_WEB_APP
,DATA:"TransferRecipeWeightOnly" AS TRANSFER_RECIPE_WEIGHT_ONLY
,DATA:"BundleAllowed" AS BUNDLE_ALLOWED
,DATA:"BundlingModule" AS BUNDLING_MODULE
,DATA:"PartialProductionAllowed" AS PARTIAL_PRODUCTION_ALLOWED
,DATA:"PartialBundleDeliveryAllowed" AS PARTIAL_BUNDLE_DELIVERY_ALLOWED
,DATA:"preparation_workflow_enabled" AS PREPARATION_WORKFLOW_ENABLED
,DATA:"PreparationFinishing" AS PREPARATION_FINISHING
,DATA:"SoldScheduledToleranceWeight" AS SOLD_SCHEDULED_TOLERANCE_WEIGHT
,DATA:"SoldScheduledToleranceQty" AS SOLD_SCHEDULED_TOLERANCE_QTY
,DATA:"SoldScheduledToleranceTime" AS SOLD_SCHEDULED_TOLERANCE_TIME
,DATA:"_rowid" AS ROW_ID
,DATA:"CreatedBy" AS CREATED_BY
,DATA:"CreatedDate" AS CREATED_DATE
,DATA:"ModifiedDate" AS MODIFIED_DATE
,DATA:"ModifiedBy" AS MODIFIED_BY
,DATA:"src_system_operation" AS SRC_SYSTEM_OPERATION
,DATA:"ipaas_updated_date" AS IPAAS_UPDATED_DATE
,DATA:"DataEventTimestamp" AS DATA_EVENT_TIMESTAMP
,FILENAME                            AS METADATA_FILENAME 
,FILE_ROW_NUMBER                     AS METADATA_FILE_ROW_NUMBER
,FILE_LAST_MODIFIED                  AS METADATA_FILE_LAST_MODIFIED
,START_SCAN_TIME                     AS METADATA_START_SCAN_TIME
,{{ dbt_utils.generate_surrogate_key(['DATA:"entity_code"','DATA:"no_produit"']) }} as TABLE_SK
,COALESCE(TO_TIMESTAMP_TZ(DATA:"DataEventTimestamp"),TO_TIMESTAMP_NTZ(DATEADD(microsecond, FILE_ROW_NUMBER,TO_TIMESTAMP_NTZ(DATA:"ipaas_updated_date"::string)))) as QUALIFY_TIMESTAMP

from {{ source("landing_spm_ca", "PRODUIT_S") }}
-- to only take the files after the last fullLoad
WHERE 
  split(FILENAME, '_')[array_size(split(FILENAME, '_')) - 2] >=
  (SELECT min_timestamp
  FROM
      (SELECT split(FILENAME, '_')[array_size(split(FILENAME, '_')) - 2] AS min_timestamp, split(FILENAME, '/')[3] AS type_file
      FROM {{ source("landing_spm_ca", "PRODUIT_S") }}
      WHERE type_file LIKE 'fullload%'
      QUALIFY ROW_NUMBER() OVER (ORDER BY min_timestamp DESC) = 1)
  )