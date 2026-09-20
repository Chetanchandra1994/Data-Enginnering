{{
  config(
    materialized = "view",
    alias = "ess_line",
    schema='spm_ca'
  )
}}

SELECT
DATA:"entity_code" AS ENTITY_CODE
,DATA:"line_no" AS LINE_NO
,DATA:"section_no" AS SECTION_NO
,DATA:"drawing_type" AS DRAWING_TYPE
,DATA:"action_col_1" AS ACTION_COL_1
,DATA:"action_col_2" AS ACTION_COL_2
,DATA:"action_col_3" AS ACTION_COL_3
,DATA:"action_col_4" AS ACTION_COL_4
,DATA:"unit_col_2_1" AS UNIT_COL_2_1
,DATA:"unit_col_2_2" AS UNIT_COL_2_2
,DATA:"unit_col_2_3" AS UNIT_COL_2_3
,DATA:"unit_col_2_4" AS UNIT_COL_2_4
,DATA:"col_value_2_1" AS COL_VALUE_2_1
,DATA:"col_value_2_2" AS COL_VALUE_2_2
,DATA:"col_value_2_3" AS COL_VALUE_2_3
,DATA:"col_value_2_4" AS COL_VALUE_2_4
,DATA:"no_produit" AS NO_PRODUIT
,DATA:"taxe_prov" AS TAXE_PROV
,DATA:"taxe_fed" AS TAXE_FED
,DATA:"catg_mat" AS CATG_MAT
,DATA:"line_type" AS LINE_TYPE
,DATA:"col_value_1" AS COL_VALUE_1
,DATA:"col_value_2" AS COL_VALUE_2
,DATA:"col_value_3" AS COL_VALUE_3
,DATA:"col_value_4" AS COL_VALUE_4
,DATA:"col_value_5" AS COL_VALUE_5
,DATA:"unit_col_1" AS UNIT_COL_1
,DATA:"unit_col_2" AS UNIT_COL_2
,DATA:"unit_col_3" AS UNIT_COL_3
,DATA:"unit_col_4" AS UNIT_COL_4
,DATA:"unit_col_5" AS UNIT_COL_5
,DATA:"prn_total_1" AS PRN_TOTAL_1
,DATA:"prn_total_2" AS PRN_TOTAL_2
,DATA:"prn_total_3" AS PRN_TOTAL_3
,DATA:"prn_total_4" AS PRN_TOTAL_4
,DATA:"ind_s_cont" AS IND_S_CONT
,DATA:"dash_1" AS DASH_1
,DATA:"dash_2" AS DASH_2
,DATA:"statut" AS STATUT
,DATA:"gl_depense" AS GL_DEPENSE
,DATA:"desc_line_1" AS DESC_LINE_1
,DATA:"desc_line_2" AS DESC_LINE_2
,DATA:"gl_provision" AS GL_PROVISION
,DATA:"expense_rate" AS EXPENSE_RATE
,DATA:"gl_income" AS GL_INCOME
,DATA:"gl_imputation" AS GL_IMPUTATION
,DATA:"group_no" AS GROUP_NO
,DATA:"task_number" AS TASK_NUMBER
,DATA:"inv_type" AS INV_TYPE
,DATA:"pounds_input" AS POUNDS_INPUT
,DATA:"area_input" AS AREA_INPUT
,DATA:"is_active" AS IS_ACTIVE
,DATA:"dw_task" AS DW_TASK
,DATA:"external" AS EXTERNAL
,DATA:"erector_privilege" AS ERECTOR_PRIVILEGE
,DATA:"ess_line_uuid" AS ESS_LINE_UUID
,DATA:"_rowid" AS ROW_ID
,DATA:"src_system_operation" AS SRC_SYSTEM_OPERATION
,DATA:"ipaas_updated_date" AS IPAAS_UPDATED_DATE
,DATA:"CreatedDate" AS CREATED_DATE
,DATA:"ModifiedDate" AS MODIFIED_DATE
,DATA:"CreatedBy" AS CREATED_BY
,DATA:"ModifiedBy" AS MODIFIED_BY
,DATA:"DataEventTimestamp" AS DATA_EVENT_TIMESTAMP
,{{ dbt_utils.generate_surrogate_key(['DATA:"ess_line_uuid"']) }} as TABLE_SK
,COALESCE(TO_TIMESTAMP_TZ(DATA:"DataEventTimestamp"),TO_TIMESTAMP_NTZ(DATEADD(microsecond, FILE_ROW_NUMBER,TO_TIMESTAMP_NTZ(DATA:"ipaas_updated_date"::string)))) as QUALIFY_TIMESTAMP
from {{ source("landing_spm_ca", "ESS_LINE") }}
-- to only take the files after the last fullLoad
WHERE 
  split(FILENAME, '_')[array_size(split(FILENAME, '_')) - 2] >=
  (SELECT min_timestamp
  FROM
      (SELECT split(FILENAME, '_')[array_size(split(FILENAME, '_')) - 2] AS min_timestamp, split(FILENAME, '/')[3] AS type_file
      FROM {{ source("landing_spm_ca", "ESS_LINE") }}
      WHERE type_file LIKE 'fullload%'
      QUALIFY ROW_NUMBER() OVER (ORDER BY min_timestamp DESC) = 1)
  )