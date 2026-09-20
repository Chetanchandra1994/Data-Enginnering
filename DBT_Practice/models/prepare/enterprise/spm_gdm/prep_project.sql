{{
  config(
    materialized = "view",
    alias = "project",
    schema='spm_gdm'
  )
}}

SELECT
DATA:"project_id" AS PROJECT_ID
,DATA:"project_name" AS PROJECT_NAME
,DATA:"project_short_name" AS PROJECT_SHORT_NAME
,DATA:"project_code" AS PROJECT_CODE
,DATA:"quotation_code" AS QUOTATION_CODE
,DATA:"quotation_date" AS QUOTATION_DATE
,DATA:"contract_code" AS CONTRACT_CODE
,DATA:"contract_date" AS CONTRACT_DATE
,DATA:"customer_project_code" AS CUSTOMER_PROJECT_CODE
,DATA:"project_status_code" AS PROJECT_STATUS_CODE
,DATA:"last_updated_by" AS LAST_UPDATED_BY
,DATA:"customer_po" AS CUSTOMER_PO
,DATA:"currency_code" AS CURRENCY_CODE
,DATA:"report_template_id" AS REPORT_TEMPLATE_ID
,DATA:"business_unit_id" AS BUSINESS_UNIT_ID
,DATA:"estimated_shipping_date" AS ESTIMATED_SHIPPING_DATE
,DATA:"extra_prefix" AS EXTRA_PREFIX
,DATA:"master_project_id" AS MASTER_PROJECT_ID
,DATA:"link_db_alias" AS LINK_DB_ALIAS
,DATA:"project_source_code" AS PROJECT_SOURCE_CODE
,DATA:"erection_advancement_percentage" AS ERECTION_ADVANCEMENT_PERCENTAGE
,DATA:"bill_to_customer_uuid" AS BILL_TO_CUSTOMER_UUID
,DATA:"erector_privilege_parent_proj_id" AS ERECTOR_PRIVILEGE_PARENT_PROJ_ID
,DATA:"job_site_image_path" AS JOB_SITE_IMAGE_PATH
,DATA:"erection_target_end_date" AS ERECTION_TARGET_END_DATE
,DATA:"erection_revised_end_date" AS ERECTION_REVISED_END_DATE
,DATA:"erector_privilege_included" AS ERECTOR_PRIVILEGE_INCLUDED
,DATA:"market_uuid" AS MARKET_UUID
,DATA:"no_projet" AS NO_PROJET
,DATA:"job_no" AS JOB_NO
,DATA:"quotation_entity_code" AS QUOTATION_ENTITY_CODE
,DATA:"price_expiration_date" AS PRICE_EXPIRATION_DATE
,DATA:"quotation_sent_date" AS QUOTATION_SENT_DATE
,DATA:"d_contrat" AS D_CONTRAT
,DATA:"nom_contact" AS NOM_CONTACT
,DATA:"site_phone" AS SITE_PHONE
,DATA:"site_fax" AS SITE_FAX
,DATA:"contact_email" AS CONTACT_EMAIL
,DATA:"financial_comments" AS FINANCIAL_COMMENTS
,DATA:"exchgn_rate" AS EXCHGN_RATE
,DATA:"cmg_invoice_style" AS CMG_INVOICE_STYLE
,DATA:"term_code" AS TERM_CODE
,DATA:"no_agent_ct" AS NO_AGENT_CT
,DATA:"type_appr" AS TYPE_APPR
,DATA:"d_app_credit" AS D_APP_CREDIT
,DATA:"credit_approved_by" AS CREDIT_APPROVED_BY
,DATA:"no_appr_cre" AS NO_APPR_CRE
,DATA:"cmg_check_amt" AS CMG_CHECK_AMT
,DATA:"cmg_credit_comm" AS CMG_CREDIT_COMM
,DATA:"man_auto_cred" AS MAN_AUTO_CRED
,DATA:"denonciation" AS DENONCIATION
,DATA:"set_off_information" AS SET_OFF_INFORMATION
,DATA:"entity_code" AS ENTITY_CODE
,DATA:"form_entity" AS FORM_ENTITY
,DATA:"is_layout_job" AS IS_LAYOUT_JOB
,DATA:"douane_proj" AS DOUANE_PROJ
,DATA:"type_projet" AS TYPE_PROJET
,DATA:"taxation_address" AS TAXATION_ADDRESS
,DATA:"terr_code" AS TERR_CODE
,DATA:"pst_license" AS PST_LICENSE
,DATA:"fst_license" AS FST_LICENSE
,DATA:"slsmn_code" AS SLSMN_CODE
,DATA:"office_code" AS OFFICE_CODE
,DATA:"branch_office_code" AS BRANCH_OFFICE_CODE
,DATA:"max_deck_bundl_weight" AS MAX_DECK_BUNDL_WEIGHT
,DATA:"max_deck_bundl_pieces" AS MAX_DECK_BUNDL_PIECES
,DATA:"deck_bundl_pieces_tolerance" AS DECK_BUNDL_PIECES_TOLERANCE
,DATA:"statut_proj" AS STATUT_PROJ
,DATA:"project_status_comment" AS PROJECT_STATUS_COMMENT
,DATA:"project_status_updated_by" AS PROJECT_STATUS_UPDATED_BY
,DATA:"project_status_updated_datetime" AS PROJECT_STATUS_UPDATED_DATETIME
,DATA:"estimated_shipment_number" AS ESTIMATED_SHIPMENT_NUMBER
,DATA:"estimated_escort_number" AS ESTIMATED_ESCORT_NUMBER
,DATA:"sequencing" AS SEQUENCING
,DATA:"follow_div" AS FOLLOW_DIV
,DATA:"follow_mark" AS FOLLOW_MARK
,DATA:"mark_type" AS MARK_TYPE
,DATA:"estimated_shipping_week" AS ESTIMATED_SHIPPING_WEEK
,DATA:"estimated_fabrication_date" AS ESTIMATED_FABRICATION_DATE
,DATA:"estimated_engineering_date" AS ESTIMATED_ENGINEERING_DATE
,DATA:"estimated_fabrication_week" AS ESTIMATED_FABRICATION_WEEK
,DATA:"estimated_engineering_week" AS ESTIMATED_ENGINEERING_WEEK
,DATA:"po_no_trans_oracle" AS PO_NO_TRANS_ORACLE
,DATA:"lst_bcklog" AS LST_BCKLOG
,DATA:"weight_increase_comment" AS WEIGHT_INCREASE_COMMENT
,DATA:"cmg_transfer" AS CMG_TRANSFER
,DATA:"dsg_transfer" AS DSG_TRANSFER
,DATA:"dsms_transfer" AS DSMS_TRANSFER
,DATA:"priority_code" AS PRIORITY_CODE
,DATA:"special_elements" AS SPECIAL_ELEMENTS
,DATA:"special_elements_comments" AS SPECIAL_ELEMENTS_COMMENTS
,DATA:"drawing_due_in" AS DRAWING_DUE_IN
,DATA:"layout_process_code" AS LAYOUT_PROCESS_CODE
,DATA:"cmg_source_template" AS CMG_SOURCE_TEMPLATE
,DATA:"mesure" AS MESURE
,DATA:"no_peinture" AS NO_PEINTURE
,DATA:"finishing_code" AS FINISHING_CODE
,DATA:"creation_datetime" AS CREATION_DATETIME
,DATA:"last_updated_datetime" AS LAST_UPDATED_DATETIME
,DATA:"global_project_uuid" AS GLOBAL_PROJECT_UUID
,DATA:"preparation_follow_up" AS PREPARATION_FOLLOW_UP
,DATA:"prep_follow_up_marks_filter" AS PREP_FOLLOW_UP_MARKS_FILTER
,DATA:"estimated_last_shipping_date" AS ESTIMATED_LAST_SHIPPING_DATE
,DATA:"estimated_last_shipping_week" AS ESTIMATED_LAST_SHIPPING_WEEK
,DATA:"official_budget" AS OFFICIAL_BUDGET
,DATA:"enterpriseTaskManagementExport" AS enterpriseTASKMANAGEMENTEXPORT
,DATA:"Package" AS PACKAGE
,DATA:"JobSiteResponsibleId" AS JOBSITERESPONSIBLEID
,DATA:"JobSiteResponsibleText" AS JOBSITERESPONSIBLETEXT
,DATA:"SAPTransfer" AS SAPTRANSFER
,DATA:"_rowid" AS ROW_ID
,DATA:"src_system_operation" AS SRC_SYSTEM_OPERATION
,DATA:"ipaas_updated_date" AS IPAAS_UPDATED_DATE
,DATA:"CreatedDate" AS CREATED_DATE
,DATA:"ModifiedDate" AS MODIFIED_DATE
,DATA:"CreatedBy" AS CREATED_BY
,DATA:"ModifiedBy" AS MODIFIED_BY
,DATA:"DataEventTimestamp" AS DATA_EVENT_TIMESTAMP
,FILENAME                            AS METADATA_FILENAME 
,FILE_ROW_NUMBER                     AS METADATA_FILE_ROW_NUMBER
,FILE_LAST_MODIFIED                  AS METADATA_FILE_LAST_MODIFIED
,START_SCAN_TIME                     AS METADATA_START_SCAN_TIME
,{{ dbt_utils.generate_surrogate_key(['DATA:"project_code"']) }} as TABLE_SK
,COALESCE(TO_TIMESTAMP_TZ(DATA:"DataEventTimestamp"),TO_TIMESTAMP_NTZ(DATEADD(microsecond, FILE_ROW_NUMBER,TO_TIMESTAMP_NTZ(DATA:"ipaas_updated_date"::string)))) as QUALIFY_TIMESTAMP

from {{ source("landing_spm_gdm", "PROJECT") }}
-- to only take the files after the last fullLoad
  WHERE 
  split(FILENAME, '_')[array_size(split(FILENAME, '_')) - 2] >=
    (SELECT min_timestamp
  FROM
      (SELECT split(FILENAME, '_')[array_size(split(FILENAME, '_')) - 2] AS min_timestamp, split(FILENAME, '/')[3] AS type_file
      FROM {{ source("landing_spm_gdm", "PROJECT") }}
      WHERE type_file LIKE 'fullload%'
      QUALIFY ROW_NUMBER() OVER (ORDER BY min_timestamp DESC) = 1)
    )