{{
  config(
    materialized = "view",
    alias = "qc_quotation_product",
    tags=["qc_quotation_product"],
    schema='spm_ca'
  )
}}

SELECT 
  DATA:"office_code" AS OFFICE_CODE
,DATA:"job_no" AS JOB_NO
,DATA:"prodct_no" AS PRODCT_NO
,DATA:"acc_no" AS ACC_NO
,DATA:"bud_deli_cost" AS BUD_DELI_COST
,DATA:"bud_prod_cost" AS BUD_PROD_COST
,DATA:"bud_weight" AS BUD_WEIGHT
,DATA:"est_deli_cost" AS EST_DELI_COST
,DATA:"est_prod_cost" AS EST_PROD_COST
,DATA:"est_weight" AS EST_WEIGHT
,DATA:"fab_ind_h" AS FAB_IND_H
,DATA:"fab_set_h_1" AS FAB_SET_H_1
,DATA:"fab_set_h_2" AS FAB_SET_H_2
,DATA:"group_no" AS GROUP_NO
,DATA:"mark_qty" AS MARK_QTY
,DATA:"group_descrp_1" AS GROUP_DESCRP_1
,DATA:"group_descrp_2" AS GROUP_DESCRP_2
,DATA:"group_descrp_3" AS GROUP_DESCRP_3
,DATA:"qty_1" AS QTY_1
,DATA:"qty_2" AS QTY_2
,DATA:"surface" AS SURFACE
,DATA:"spm_entity_code" AS SPM_ENTITY_CODE
,DATA:"spm_prodct_no" AS SPM_PRODCT_NO
,DATA:"qty_type" AS QTY_TYPE
,DATA:"dummy" AS DUMMY
,DATA:"apply_mark_up" AS APPLY_MARK_UP
,DATA:"seq_no" AS SEQ_NO
,DATA:"markup_weight_%" AS MARKUP_WEIGHT_PCT
,DATA:"markup_weight" AS MARKUP_WEIGHT
,DATA:"markup_price_%" AS MARKUP_PRICE_PCT
,DATA:"markup_price_$" AS MARKUP_PRICE_DOLLAR
,DATA:"group_rpt_model" AS GROUP_RPT_MODEL
,DATA:"freight" AS FREIGHT
,DATA:"deck" AS DECK
,DATA:"type_fact" AS TYPE_FACT
,DATA:"estim_det" AS ESTIM_DET
,DATA:"estim_des" AS ESTIM_DES
,DATA:"dsg_cost_1" AS DSG_COST_1
,DATA:"dsg_cost_2" AS DSG_COST_2
,DATA:"dsg_cost_3" AS DSG_COST_3
,DATA:"dsg_cost_4" AS DSG_COST_4
,DATA:"dsg_cost_5" AS DSG_COST_5
,DATA:"dsg_cost_6" AS DSG_COST_6
,DATA:"complex_code" AS COMPLEX_CODE
,DATA:"sort_name" AS SORT_NAME
,DATA:"measure_qty" AS MEASURE_QTY
,DATA:"item_no" AS ITEM_NO
,DATA:"uom_code" AS UOM_CODE
,DATA:"udm_alt" AS UDM_ALT
,DATA:"name_1" AS NAME_1
,DATA:"name_2" AS NAME_2
,DATA:"name_3" AS NAME_3
,DATA:"name_4" AS NAME_4
,DATA:"estimt_modul" AS ESTIMT_MODUL
,DATA:"std" AS STD
,DATA:"break_amt" AS BREAK_AMT
,DATA:"unit_qty_1" AS UNIT_QTY_1
,DATA:"unit_qty_2" AS UNIT_QTY_2
,DATA:"currency_cod" AS CURRENCY_COD
,DATA:"constr_load" AS CONSTR_LOAD
,DATA:"line_no" AS LINE_NO
,DATA:"QcQuotProductHierarchyUUID" AS QC_QUOT_PRODUCT_HIERARCHY_UUID
,DATA:"NumberOfEscorts" AS NUMBER_OF_ESCORTS
,DATA:"DeliveryCountryTaxesAmount" AS DELIVERY_COUNTRY_TAXES_AMOUNT
,DATA:"ProductionCountryTaxesAmount" AS PRODUCTION_COUNTRY_TAXES_AMOUNT
,DATA:"AdjustmentGrossMargin" AS ADJUSTMENT_GROSS_MARGIN
,DATA:"ImportedFromLinkedEstimModule" AS IMPORTED_FROM_LINKED_ESTIM_MODULE
,DATA:"JobCostLineEntityCode" AS JOB_COST_LINE_ENTITY_CODE
,DATA:"CreatedDate" AS CREATEDDATE
,DATA:"ModifiedDate" AS MODIFIEDDATE
,DATA:"CreatedBy" AS CREATEDBY
,DATA:"ModifiedBy" AS MODIFIEDBY
,DATA:"src_system_operation" AS SRC_SYSTEM_OPERATION
,DATA:"ipaas_updated_date" AS IPAAS_UPDATED_DATE
,DATA:"DataEventTimestamp" AS DATA_EVENT_TIMESTAMP
,FILENAME                            AS METADATA_FILENAME 
,FILE_ROW_NUMBER                     AS METADATA_FILE_ROW_NUMBER
,FILE_LAST_MODIFIED                  AS METADATA_FILE_LAST_MODIFIED
,START_SCAN_TIME                     AS METADATA_START_SCAN_TIME
,{{ dbt_utils.generate_surrogate_key(['DATA:"office_code"','DATA:"job_no"','DATA:"seq_no"','DATA:"estimt_modul"']) }} as TABLE_SK
,COALESCE(TO_TIMESTAMP_TZ(DATA:"DataEventTimestamp"),TO_TIMESTAMP_NTZ(DATEADD(microsecond, FILE_ROW_NUMBER,TO_TIMESTAMP_NTZ(DATA:"ipaas_updated_date"::string)))) as QUALIFY_TIMESTAMP

from {{ source("landing_spm_ca", "QC_QUOTATION_PRODUCT") }}
-- to only take the files after the last fullLoad
WHERE 
  split(FILENAME, '_')[array_size(split(FILENAME, '_')) - 2] >=
  (SELECT min_timestamp
  FROM
      (SELECT split(FILENAME, '_')[array_size(split(FILENAME, '_')) - 2] AS min_timestamp, split(FILENAME, '/')[3] AS type_file
      FROM {{ source("landing_spm_ca", "QC_QUOTATION_PRODUCT") }}
      WHERE type_file LIKE 'fullload%'
      QUALIFY ROW_NUMBER() OVER (ORDER BY min_timestamp DESC) = 1)
  )