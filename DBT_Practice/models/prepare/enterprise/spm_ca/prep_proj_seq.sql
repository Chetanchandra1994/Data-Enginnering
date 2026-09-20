{{
  config(
    materialized = "view",
    alias = "proj_seq",
    schema='spm_ca'
  )
}}

SELECT 
 DATA:"d_design" AS D_DESIGN
,DATA:"no_projet" AS NO_PROJET
,DATA:"seq_no" AS SEQ_NO
,DATA:"seq_name" AS SEQ_NAME
,DATA:"d_update" AS D_UPDATE
,DATA:"d_prod" AS D_PROD
,DATA:"w_prod" AS W_PROD
,DATA:"d_ship" AS D_SHIP
,DATA:"w_ship" AS W_SHIP
,DATA:"r_update" AS R_UPDATE
,DATA:"complete" AS COMPLETE
,DATA:"comments_3" AS COMMENTS_3
,DATA:"comments_4" AS COMMENTS_4
,DATA:"comments_5" AS COMMENTS_5
,DATA:"comments_1" AS COMMENTS_1
,DATA:"comments_2" AS COMMENTS_2
,DATA:"job_type" AS JOB_TYPE
,DATA:"eng_dates_1" AS ENG_DATES_1
,DATA:"eng_dates_2" AS ENG_DATES_2
,DATA:"eng_app_init_2" AS ENG_APP_INIT_2
,DATA:"eng_app_init_1" AS ENG_APP_INIT_1
,DATA:"eng_app_init_3" AS ENG_APP_INIT_3
,DATA:"eng_app_init_4" AS ENG_APP_INIT_4
,DATA:"eng_remarks_2" AS ENG_REMARKS_2
,DATA:"eng_remarks_1" AS ENG_REMARKS_1
,DATA:"indc_reserv" AS INDC_RESERV
,DATA:"buy_list" AS BUY_LIST
,DATA:"buyer" AS BUYER
,DATA:"struct_commnt_1" AS STRUCT_COMMNT_1
,DATA:"struct_commnt_5" AS STRUCT_COMMNT_5
,DATA:"struct_commnt_2" AS STRUCT_COMMNT_2
,DATA:"struct_commnt_4" AS STRUCT_COMMNT_4
,DATA:"struct_commnt_3" AS STRUCT_COMMNT_3
,DATA:"struct_plant" AS STRUCT_PLANT
,DATA:"seq_div" AS SEQ_DIV
,DATA:"site_printed" AS SITE_PRINTED
,DATA:"w_design" AS W_DESIGN
,DATA:"proj_hold_code" AS PROJ_HOLD_CODE
,DATA:"eng_start_date_4" AS ENG_START_DATE_4
,DATA:"eng_start_date_1" AS ENG_START_DATE_1
,DATA:"eng_start_date_2" AS ENG_START_DATE_2
,DATA:"eng_start_date_3" AS ENG_START_DATE_3
,DATA:"eng_end_date_4" AS ENG_END_DATE_4
,DATA:"eng_end_date_1" AS ENG_END_DATE_1
,DATA:"eng_end_date_2" AS ENG_END_DATE_2
,DATA:"eng_end_date_3" AS ENG_END_DATE_3
,DATA:"drwg_office_code" AS DRWG_OFFICE_CODE
,DATA:"drw_dates_2" AS DRW_DATES_2
,DATA:"drw_dates_1" AS DRW_DATES_1
,DATA:"drw_dates_7" AS DRW_DATES_7
,DATA:"drw_dates_3" AS DRW_DATES_3
,DATA:"drw_dates_6" AS DRW_DATES_6
,DATA:"drw_dates_4" AS DRW_DATES_4
,DATA:"drw_dates_5" AS DRW_DATES_5
,DATA:"checking_office_code" AS CHECKING_OFFICE_CODE
,DATA:"rfi_initials" AS RFI_INITIALS
,DATA:"rfi_start_date" AS RFI_START_DATE
,DATA:"rfi_end_date" AS RFI_END_DATE
,DATA:"layout_initials" AS LAYOUT_INITIALS
,DATA:"layout_start_date" AS LAYOUT_START_DATE
,DATA:"layout_end_date" AS LAYOUT_END_DATE
,DATA:"layout_checker_initials" AS LAYOUT_CHECKER_INITIALS
,DATA:"layout_checker_start_date" AS LAYOUT_CHECKER_START_DATE
,DATA:"layout_checker_end_date" AS LAYOUT_CHECKER_END_DATE
,DATA:"complexity_code" AS COMPLEXITY_CODE
,DATA:"complexity_comments" AS COMPLEXITY_COMMENTS
,DATA:"drwg_rcvd_dropdead_date" AS DRWG_RCVD_DROPDEAD_DATE
,DATA:"drwg_appr_dropdead_date" AS DRWG_APPR_DROPDEAD_DATE
,DATA:"release_eng_dropdead_date" AS RELEASE_ENG_DROPDEAD_DATE
,DATA:"req_compl_dropdead_date" AS REQ_COMPL_DROPDEAD_DATE
,DATA:"fabr_compl_dropdead_date" AS FABR_COMPL_DROPDEAD_DATE
,DATA:"deli_approved_by_proj_coord" AS DELI_APPROVED_BY_PROJ_COORD
,DATA:"deli_approved_by_deli_coord" AS DELI_APPROVED_BY_DELI_COORD
,DATA:"deli_approved_date_proj_coord" AS DELI_APPROVED_DATE_PROJ_COORD
,DATA:"deli_approved_date_deli_coord" AS DELI_APPROVED_DATE_DELI_COORD
,DATA:"deli_approved_time_proj_coord" AS DELI_APPROVED_TIME_PROJ_COORD
,DATA:"deli_approved_time_deli_coord" AS DELI_APPROVED_TIME_DELI_COORD
,DATA:"expedition_comments" AS EXPEDITION_COMMENTS
,DATA:"initial_contract" AS INITIAL_CONTRACT
,DATA:"drafting_advancement" AS DRAFTING_ADVANCEMENT
,DATA:"drwg_sentout_dropdead_date" AS DRWG_SENTOUT_DROPDEAD_DATE
,DATA:"division_comments" AS DIVISION_COMMENTS
,DATA:"engineering_comments" AS ENGINEERING_COMMENTS
,DATA:"structural_comments" AS STRUCTURAL_COMMENTS
,DATA:"fabrication_start_date" AS FABRICATION_START_DATE
,DATA:"tie_joist_out_target" AS TIE_JOIST_OUT_TARGET
,DATA:"tie_joist_out" AS TIE_JOIST_OUT
,DATA:"layout_approval_target" AS LAYOUT_APPROVAL_TARGET
,DATA:"layout_approval_received" AS LAYOUT_APPROVAL_RECEIVED
,DATA:"layout_back_for_check_target" AS LAYOUT_BACK_FOR_CHECK_TARGET
,DATA:"rfi_end_target" AS RFI_END_TARGET
,DATA:"engineering_target" AS ENGINEERING_TARGET
,DATA:"purchase_end" AS PURCHASE_END
,DATA:"material_received" AS MATERIAL_RECEIVED
,DATA:"recent_delivery" AS RECENT_DELIVERY
,DATA:"complete_delivery" AS COMPLETE_DELIVERY
,DATA:"drwg_received_draft_office_date" AS DRWG_RECEIVED_DRAFT_OFFICE_DATE
,DATA:"drwg_approved_draft_office_date" AS DRWG_APPROVED_DRAFT_OFFICE_DATE
,DATA:"erector_privilege_included" AS ERECTOR_PRIVILEGE_INCLUDED
,DATA:"marking_color_uuid" AS MARKING_COLOR_UUID
,DATA:"fast_track" AS FAST_TRACK
,DATA:"quality_verification_engineer" AS QUALITY_VERIFICATION_ENGINEER
,DATA:"drawing_approval_revision_code" AS DRAWING_APPROVAL_REVISION_CODE
,DATA:"file_and_field_revision_code" AS FILE_AND_FIELD_REVISION_CODE
,DATA:"drawing_approval_type_uuid" AS DRAWING_APPROVAL_TYPE_UUID
,DATA:"binder_received_date" AS BINDER_RECEIVED_DATE
,DATA:"engineering_verification_date" AS ENGINEERING_VERIFICATION_DATE
,DATA:"erection_plans_responsible" AS ERECTION_PLANS_RESPONSIBLE
,DATA:"erection_plans_resp_people_id" AS ERECTION_PLANS_RESP_PEOPLE_ID
,DATA:"SpecialAttentionUUID" AS SPECIALATTENTIONUUID
,DATA:"StampingDoneSetBy" AS STAMPINGDONESETBY
,DATA:"ReadyToStampDateTime" AS READYTOSTAMPDATETIME
,DATA:"ReadyToStampSetBy" AS READYTOSTAMPSETBY
,DATA:"StampingDoneDateTime" AS STAMPINGDONEDATETIME
,DATA:"DrawingEstimatedWeeksDelay" AS DRAWINGESTIMATEDWEEKSDELAY
,DATA:"ApprovalEstimatedWeeksDelay" AS APPROVALESTIMATEDWEEKSDELAY
,DATA:"FabricationEstimatedWeeksDelay" AS FABRICATIONESTIMATEDWEEKSDELAY
,DATA:"FabricationManualDelay" AS FABRICATIONMANUALDELAY
,DATA:"QVIEmailAlertSentDateTime" AS QVIEMAILALERTSENTDATETIME
,DATA:"RFI2EndTarget" AS RFI2ENDTARGET
,DATA:"RFI2Initials" AS RFI2INITIALS
,DATA:"RFI2StartDate" AS RFI2STARTDATE
,DATA:"RFI2EndDate" AS RFI2ENDDATE
,DATA:"KickOffCompleteDate" AS KICKOFFCOMPLETEDATE
,DATA:"Abm" AS ABM
,DATA:"WallPanelsMaterials" AS WALLPANELSMATERIALS
,DATA:"FabricationTarget_1" AS FABRICATIONTARGET_1
,DATA:"FabricationTarget_2" AS FABRICATIONTARGET_2
,DATA:"ErectionPlanTarget" AS ERECTIONPLANTARGET
,DATA:"ClashDetectionTarget" AS CLASHDETECTIONTARGET
,DATA:"ClashDetectionEnd" AS CLASHDETECTIONEND
,DATA:"CopyCTMTasksFrom" AS COPYCTMTASKSFROM
,DATA:"CopyCTMAdvancement" AS COPYCTMADVANCEMENT
,DATA:"PurchaseStartDate" AS PURCHASESTARTDATE
,DATA:"MaximumPurchaseStartDate" AS MAXIMUMPURCHASESTARTDATE
,DATA:"CreatedDate" AS CREATEDDATE
,DATA:"ModifiedDate" AS MODIFIEDDATE
,DATA:"CreatedBy" AS CREATEDBY
,DATA:"ModifiedBy" AS MODIFIEDBY
,DATA:"src_system_operation" AS SRC_SYSTEM_OPERATION
,DATA:"DataEventTimestamp" AS DATA_EVENT_TIMESTAMP
,FILENAME                           AS METADATA_FILENAME 
,FILE_ROW_NUMBER                    AS METADATA_FILE_ROW_NUMBER
,FILE_LAST_MODIFIED                 AS METADATA_FILE_LAST_MODIFIED
,START_SCAN_TIME                    AS METADATA_START_SCAN_TIME
,{{ dbt_utils.generate_surrogate_key(['DATA:"no_projet"','DATA:"seq_no"']) }} as TABLE_SK
,COALESCE(TO_TIMESTAMP_TZ(DATA:"DataEventTimestamp"),TO_TIMESTAMP_NTZ(DATEADD(microsecond, FILE_ROW_NUMBER,TO_TIMESTAMP_NTZ(DATA:"ipaas_updated_date"::string)))) as QUALIFY_TIMESTAMP

from {{ source("landing_spm_ca", "PROJ_SEQ") }}
-- to only take the files after the last fullLoad
WHERE 
  split(FILENAME, '_')[array_size(split(FILENAME, '_')) - 2] >=
  (SELECT min_timestamp
  FROM
      (SELECT split(FILENAME, '_')[array_size(split(FILENAME, '_')) - 2] AS min_timestamp, split(FILENAME, '/')[3] AS type_file
      FROM {{ source("landing_spm_ca", "PROJ_SEQ") }}
      WHERE type_file LIKE 'fullload%'
      QUALIFY ROW_NUMBER() OVER (ORDER BY min_timestamp DESC) = 1)
  )