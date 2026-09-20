{{
  config(
    materialized = "view",
    alias = "in_control",
    schema='spm_ca'
  )
}}

SELECT
DATA:"in_entity" AS IN_ENTITY
,DATA:"in_yr" AS IN_YR
,DATA:"in_prd" AS IN_PRD
,DATA:"number_prd" AS NUMBER_PRD
,DATA:"whs_code" AS WHS_CODE
,DATA:"uom_code" AS UOM_CODE
,DATA:"cost_method" AS COST_METHOD
,DATA:"break_code" AS BREAK_CODE
,DATA:"prod_group" AS PROD_GROUP
,DATA:"pr_gp_length" AS PR_GP_LENGTH
,DATA:"entity_inv" AS ENTITY_INV
,DATA:"entity_wip" AS ENTITY_WIP
,DATA:"mli" AS MLI
,DATA:"allow_bo" AS ALLOW_BO
,DATA:"misc_code" AS MISC_CODE
,DATA:"gl_physical" AS GL_PHYSICAL
,DATA:"view_login" AS VIEW_LOGIN
,DATA:"udm_alt" AS UDM_ALT
,DATA:"facteur" AS FACTEUR
,DATA:"coil_group" AS COIL_GROUP
,DATA:"mesure" AS MESURE
,DATA:"deck_group" AS DECK_GROUP
,DATA:"desgo_versant" AS DESGO_VERSANT
,DATA:"slit_group" AS SLIT_GROUP
,DATA:"duty_free_rate" AS DUTY_FREE_RATE
,DATA:"in_control_uuid" AS IN_CONTROL_UUID
,DATA:"_rowid" AS ROW_ID
,DATA:"src_system_operation" AS SRC_SYSTEM_OPERATION
,DATA:"ipaas_updated_date" AS IPAAS_UPDATED_DATE
,DATA:"CreatedDate" AS CREATED_DATE
,DATA:"ModifiedDate" AS MODIFIED_DATE
,DATA:"CreatedBy" AS CREATED_BY
,DATA:"ModifiedBy" AS MODIFIED_BY
,DATA:"DataEventTimestamp" AS DATA_EVENT_TIMESTAMP
,{{ dbt_utils.generate_surrogate_key(['DATA:"in_entity"']) }} as TABLE_SK
,COALESCE(TO_TIMESTAMP_TZ(DATA:"DataEventTimestamp"),TO_TIMESTAMP_NTZ(DATEADD(microsecond, FILE_ROW_NUMBER,TO_TIMESTAMP_NTZ(DATA:"ipaas_updated_date"::string)))) as QUALIFY_TIMESTAMP
from {{ source("landing_spm_ca", "IN_CONTROL") }}
-- to only take the files after the last fullLoad
WHERE 
  split(FILENAME, '_')[array_size(split(FILENAME, '_')) - 2] >=
  (SELECT min_timestamp
  FROM
      (SELECT split(FILENAME, '_')[array_size(split(FILENAME, '_')) - 2] AS min_timestamp, split(FILENAME, '/')[3] AS type_file
      FROM {{ source("landing_spm_ca", "IN_CONTROL") }}
      WHERE type_file LIKE 'fullload%'
      QUALIFY ROW_NUMBER() OVER (ORDER BY min_timestamp DESC) = 1)
  )