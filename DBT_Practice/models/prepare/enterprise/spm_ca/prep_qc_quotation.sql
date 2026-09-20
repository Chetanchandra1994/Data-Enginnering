{{
  config(
    materialized = "view",
    alias = "qc_quotation",
    schema='spm_ca'
  )
}}


SELECT
DATA:"office_code" AS OFFICE_CODE
,DATA:"job_no" AS JOB_NO
,DATA:"master_job_no" AS MASTER_JOB_NO
,DATA:"status1" AS STATUS1
,DATA:"status2" AS STATUS2
,DATA:"status1_no" AS STATUS1_NO
,DATA:"status2_no" AS STATUS2_NO
,DATA:"no_projet" AS NO_PROJET
,DATA:"proj_name" AS PROJ_NAME
,DATA:"active" AS ACTIVE
,DATA:"century" AS CENTURY
,DATA:"city" AS CITY
,DATA:"propst_no" AS PROPST_NO
,DATA:"design_code" AS DESIGN_CODE
,DATA:"inscrp_date" AS INSCRP_DATE
,DATA:"recall_date" AS RECALL_DATE
,DATA:"bid_date" AS BID_DATE
,DATA:"salesm_init_code" AS SALESM_INIT_CODE
,DATA:"estimt_init_code" AS ESTIMT_INIT_CODE
,DATA:"price" AS PRICE
,DATA:"projct_step" AS PROJCT_STEP
,DATA:"nb_alt" AS NB_ALT
,DATA:"status_contrc" AS STATUS_CONTRC
,DATA:"estimt_ship_date" AS ESTIMT_SHIP_DATE
,DATA:"issued_for" AS ISSUED_FOR
,DATA:"gc_close_date" AS GC_CLOSE_DATE
,DATA:"general_note" AS GENERAL_NOTE
,DATA:"ship_terr_code" AS SHIP_TERR_CODE
,DATA:"sale_terr_code" AS SALE_TERR_CODE
,DATA:"follow_date" AS FOLLOW_DATE
,DATA:"spm_entity_code" AS SPM_ENTITY_CODE
,DATA:"xtra_no" AS XTRA_NO
,DATA:"spm_date" AS SPM_DATE
,DATA:"longest" AS LONGEST
,DATA:"contrc_compt_no" AS CONTRC_COMPT_NO
,DATA:"contrc_date" AS CONTRC_DATE
,DATA:"contrc_note" AS CONTRC_NOTE
,DATA:"nom_contact" AS NOM_CONTACT
,DATA:"d_livraison" AS D_LIVRAISON
,DATA:"d_estime" AS D_ESTIME
,DATA:"no_contrat_v" AS NO_CONTRAT_V
,DATA:"no_bon_achat" AS NO_BON_ACHAT
,DATA:"adresse_liv_2" AS ADRESSE_LIV_2
,DATA:"adresse_liv_1" AS ADRESSE_LIV_1
,DATA:"adresse_liv_3" AS ADRESSE_LIV_3
,DATA:"fob_code" AS FOB_CODE
,DATA:"memo" AS MEMO
,DATA:"dummy" AS DUMMY
,DATA:"user_code" AS USER_CODE
,DATA:"dsg_entity_code" AS DSG_ENTITY_CODE
,DATA:"markup_weight_percent" AS MARKUP_WEIGHT_PERCENT
,DATA:"markup_weight" AS MARKUP_WEIGHT
,DATA:"markup_price_percent" AS MARKUP_PRICE_PERCENT
,DATA:"markup_price_dollar" AS MARKUP_PRICE_DOLLAR
,DATA:"markup_price" AS MARKUP_PRICE
,DATA:"markup_opening_fee" AS MARKUP_OPENING_FEE
,DATA:"markup_rounding" AS MARKUP_ROUNDING
,DATA:"mesure" AS MESURE
,DATA:"design_date" AS DESIGN_DATE
,DATA:"design_desc" AS DESIGN_DESC
,DATA:"addend" AS ADDEND
,DATA:"addend_date" AS ADDEND_DATE
,DATA:"addend_desc" AS ADDEND_DESC
,DATA:"specfc" AS SPECFC
,DATA:"specfc_date" AS SPECFC_DATE
,DATA:"specfc_desc" AS SPECFC_DESC
,DATA:"input_by_init_code" AS INPUT_BY_INIT_CODE
,DATA:"po_date" AS PO_DATE
,DATA:"country" AS COUNTRY
,DATA:"county_code" AS COUNTY_CODE
,DATA:"deck" AS DECK
,DATA:"zip_code" AS ZIP_CODE
,DATA:"input_by_name" AS INPUT_BY_NAME
,DATA:"branch_office_code" AS BRANCH_OFFICE_CODE
,DATA:"projct_surface" AS PROJCT_SURFACE
,DATA:"st" AS ST
,DATA:"apply_fee" AS APPLY_FEE
,DATA:"public" AS PUBLIC
,DATA:"opening_fee" AS OPENING_FEE
,DATA:"class_categ" AS CLASS_CATEG
,DATA:"class_code" AS CLASS_CODE
,DATA:"follow_up" AS FOLLOW_UP
,DATA:"last_update_date" AS LAST_UPDATE_DATE
,DATA:"hot" AS HOT
,DATA:"lost_date" AS LOST_DATE
,DATA:"mark_qty" AS MARK_QTY
,DATA:"standing_id" AS STANDING_ID
,DATA:"last_update_time" AS LAST_UPDATE_TIME
,DATA:"contrc_compt_office_code" AS CONTRC_COMPT_OFFICE_CODE
,DATA:"round_to_factor" AS ROUND_TO_FACTOR
,DATA:"currency_cod" AS CURRENCY_COD
,DATA:"transfer_date" AS TRANSFER_DATE
,DATA:"drawing_due_in" AS DRAWING_DUE_IN
,DATA:"special_elements_note" AS SPECIAL_ELEMENTS_NOTE
,DATA:"proj_coord" AS PROJ_COORD
,DATA:"exchgn_rate" AS EXCHGN_RATE
,DATA:"drawing_due_back" AS DRAWING_DUE_BACK
,DATA:"approval_type" AS APPROVAL_TYPE
,DATA:"drawing_due_out" AS DRAWING_DUE_OUT
,DATA:"weight_increase_comment" AS WEIGHT_INCREASE_COMMENT
,DATA:"lost_status_comment" AS LOST_STATUS_COMMENT
,DATA:"LastLoadedEstimationFileName" AS LAST_LOADED_ESTIMATION_FILE_NAME
,DATA:"LastLoadedEstimationFileDateTime" AS LAST_LOADED_ESTIMATION_FILE_DATETIME
,DATA:"contrc_buyer_contact_uuid" AS CONTRC_BUYER_CONTACT_UUID
,DATA:"contrc_proj_manager_contact_uuid" AS CONTRC_PROJ_MANAGER_CONTACT_UUID
,DATA:"ves_entry_completed_user_code" AS VES_ENTRY_COMPLETED_USER_CODE
,DATA:"estimation_include_design" AS ESTIMATION_INCLUDE_DESIGN
,DATA:"lead" AS LEAD
,DATA:"lead_prospector_init_code" AS LEAD_PROSPECTOR_INIT_CODE
,DATA:"leed_certified" AS LEED_CERTIFIED
,DATA:"ExtraCredit" AS EXTRA_CREDIT
,DATA:"SignatoryApprovalStatus" AS SIGNATORY_APPROVAL_STATUS
,DATA:"SignatoryApprovedAmount" AS SIGNATORY_APPROVED_AMOUNT
,DATA:"bid_customer_uuid" AS BID_CUSTOMER_UUID
,DATA:"contract_customer_uuid" AS CONTRACT_CUSTOMER_UUID
,DATA:"show_addresses_on_fps" AS SHOW_ADDRESSES_ON_FPS
,DATA:"quotation_uuid" AS QUOTATION_UUID
,DATA:"deck_calc_soft" AS DECK_CALC_SOFT
,DATA:"domestic_steel_only" AS DOMESTIC_STEEL_ONLY
,DATA:"mill_test_required" AS MILL_TEST_REQUIRED
,DATA:"LastLoadedEstimationFileLoadBy" AS LAST_LOADED_ESTIMATION_FILE_LOAD_BY
,DATA:"ProjectType" AS PROJECT_TYPE
,DATA:"QuotationTypeUUID" AS QUOTATION_TYPE_UUID
,DATA:"LastLoadedEstimationBudgetFormat" AS LAST_LOADED_ESTIMATION_BUDGET_FORMAT
,DATA:"DraftingContract" AS DRAFTING_CONTRACT
,DATA:"QuotationMainProduct" AS QUOTATION_MAIN_PRODUCT
,DATA:"QuotationSentDate" AS QUOTATION_SENT_DATE
,DATA:"erector_privilege_included" AS ERECTOR_PRIVILEGE_INCLUDED
,DATA:"DeliveryOfficeCode" AS DELIVERY_OFFICE_CODE
,DATA:"DeliveryBranchOfficeCode" AS DELIVERY_BRANCH_OFFICE_CODE
,DATA:"EstimationTargetDateTime" AS ESTIMATION_TARGET_DATETIME
,DATA:"IsNationalAccount" AS IS_NATIONAL_ACCOUNT
,DATA:"OpportunityRating" AS OPPORTUNITY_RATING
,DATA:"OpportunityStatus" AS OPPORTUNITY_STATUS
,DATA:"OpportunityStage" AS OPPORTUNITY_STAGE
,DATA:"complx_code" AS COMPLX_CODE
,DATA:"LostPriceDelta" AS LOST_PRICE_DELTA
,DATA:"ConfidenceRating" AS CONFIDENCE_RATING
,DATA:"LostToComptNo" AS LOST_TO_COMPT_NO
,DATA:"OpportunityDelieveryDateSpan" AS OPPORTUNITY_DELIEVERY_DATE_SPAN
,DATA:"OpportunityDelieveryDateSpanMin" AS OPPORTUNITY_DELIEVERY_DATE_SPAN_MIN
,DATA:"OpportunityDelieveryDateSpanMax" AS OPPORTUNITY_DELIEVERY_DATE_SPAN_MAX
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
,{{ dbt_utils.generate_surrogate_key(['DATA:"office_code"','DATA:"job_no"']) }} as TABLE_SK
,COALESCE(TO_TIMESTAMP_TZ(DATA:"DataEventTimestamp"),TO_TIMESTAMP_NTZ(DATEADD(microsecond, FILE_ROW_NUMBER,TO_TIMESTAMP_NTZ(DATA:"ipaas_updated_date"::string)))) as QUALIFY_TIMESTAMP

from {{ source("landing_spm_ca", "QC_QUOTATION") }}
-- to only take the files after the last fullLoad
WHERE 
  split(FILENAME, '_')[array_size(split(FILENAME, '_')) - 2] >=
  (SELECT min_timestamp
  FROM
      (SELECT split(FILENAME, '_')[array_size(split(FILENAME, '_')) - 2] AS min_timestamp, split(FILENAME, '/')[3] AS type_file
      FROM {{ source("landing_spm_ca", "QC_QUOTATION") }}
      WHERE type_file LIKE 'fullload%'
      QUALIFY ROW_NUMBER() OVER (ORDER BY min_timestamp DESC) = 1)
  )