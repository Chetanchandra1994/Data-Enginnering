{{
  config(
    materialized = "view",
    alias = "projetx_g",
    schema='spm_ca'
  )
}}

SELECT
DATA:"no_projet" AS NO_PROJET
,DATA:"no_estime" AS NO_ESTIME
,DATA:"entity_code" AS ENTITY_CODE
,DATA:"no_bon_achat" AS NO_BON_ACHAT
,DATA:"d_saisie" AS D_SAISIE
,DATA:"t_saisie" AS T_SAISIE
,DATA:"usager" AS USAGER
,DATA:"d_livraison" AS D_LIVRAISON
,DATA:"form_impr" AS FORM_IMPR
,DATA:"type_appr" AS TYPE_APPR
,DATA:"no_appr_cre" AS NO_APPR_CRE
,DATA:"d_app_credit" AS D_APP_CREDIT
,DATA:"ord_prod" AS ORD_PROD
,DATA:"generation" AS GENERATION
,DATA:"seq_no" AS SEQ_NO
,DATA:"genere" AS GENERE
,DATA:"no_catg" AS NO_CATG
,DATA:"proj_transf" AS PROJ_TRANSF
,DATA:"sold_date" AS SOLD_DATE
,DATA:"revision_type" AS REVISION_TYPE
,DATA:"approved_by" AS APPROVED_BY
,DATA:"approved_date" AS APPROVED_DATE
,DATA:"approved_time" AS APPROVED_TIME
,DATA:"approval_status" AS APPROVAL_STATUS
,DATA:"gdm_extra_code" AS GDM_EXTRA_CODE
,DATA:"price_expiration_date" AS PRICE_EXPIRATION_DATE
,DATA:"quotation_sent_date" AS QUOTATION_SENT_DATE
,DATA:"no_agent_ct" AS NO_AGENT_CT
,DATA:"erector_privilege_parent_proj_id" AS ERECTOR_PRIVILEGE_PARENT_PROJ_ID
,DATA:"financial_comments" AS FINANCIAL_COMMENTS
,DATA:"official_budget" AS OFFICIAL_BUDGET
,DATA:"estimated_last_shipping_date" AS ESTIMATED_LAST_SHIPPING_DATE
,DATA:"CMICPotentialChangeItemNumber" AS CMIC_POTENTIAL_CHANGE_ITEM_NUMBER
,DATA:"projetx_g_uuid" AS PROJETX_G_UUID
,DATA:"_rowid" AS ROW_ID
,DATA:"src_system_operation" AS SRC_SYSTEM_OPERATION
,DATA:"ipaas_updated_date" AS IPAAS_UPDATED_DATE
,DATA:"CreatedDate" AS CREATED_DATE
,DATA:"ModifiedDate" AS MODIFIED_DATE
,DATA:"CreatedBy" AS CREATED_BY
,DATA:"ModifiedBy" AS MODIFIED_BY
,DATA:"DataEventTimestamp" AS DATA_EVENT_TIMESTAMP
,{{ dbt_utils.generate_surrogate_key(['DATA:"projetx_g_uuid"']) }} as TABLE_SK
,COALESCE(TO_TIMESTAMP_TZ(DATA:"DataEventTimestamp"),TO_TIMESTAMP_NTZ(DATEADD(microsecond, FILE_ROW_NUMBER,TO_TIMESTAMP_NTZ(DATA:"ipaas_updated_date"::string)))) as QUALIFY_TIMESTAMP

from {{ source("landing_spm_ca", "PROJETX_G") }}
-- to only take the files after the last fullLoad
WHERE 
  split(FILENAME, '_')[array_size(split(FILENAME, '_')) - 2] >=
  (SELECT min_timestamp
  FROM
      (SELECT split(FILENAME, '_')[array_size(split(FILENAME, '_')) - 2] AS min_timestamp, split(FILENAME, '/')[3] AS type_file
      FROM {{ source("landing_spm_ca", "PROJETX_G") }}
      WHERE type_file LIKE 'fullload%'
      QUALIFY ROW_NUMBER() OVER (ORDER BY min_timestamp DESC) = 1)
  )