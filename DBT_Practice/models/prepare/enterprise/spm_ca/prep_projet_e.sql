{{
  config(
    materialized = "view",
    alias = "projet_e",
    schema='spm_ca'
  )
}}

SELECT 
DATA:"no_projet" AS NO_PROJET
,DATA:"d_estime" AS D_ESTIME
,DATA:"d_ouverture" AS D_OUVERTURE
,DATA:"d_livraison" AS D_LIVRAISON
,DATA:"d_app_credit" AS D_APP_CREDIT
,DATA:"d_d_design" AS D_D_DESIGN
,DATA:"d_f_design" AS D_F_DESIGN
,DATA:"d_d_detail" AS D_D_DETAIL
,DATA:"d_f_detail" AS D_F_DETAIL
,DATA:"d_d_prod" AS D_D_PROD
,DATA:"d_f_prod" AS D_F_PROD
,DATA:"d_d_livre" AS D_D_LIVRE
,DATA:"d_f_livre" AS D_F_LIVRE
,DATA:"denonciation" AS DENONCIATION
,DATA:"impr_histo" AS IMPR_HISTO
,DATA:"d_plans" AS D_PLANS
,DATA:"d_plans_sd" AS D_PLANS_SD
,DATA:"appr_canam" AS APPR_CANAM
,DATA:"d_app_canam" AS D_APP_CANAM
,DATA:"d_saisie" AS D_SAISIE
,DATA:"d_contrat" AS D_CONTRAT
,DATA:"type_appr" AS TYPE_APPR
,DATA:"no_appr_cre" AS NO_APPR_CRE
,DATA:"no_detailer" AS NO_DETAILER
,DATA:"mesure" AS MESURE
,DATA:"no_peinture" AS NO_PEINTURE
,DATA:"arc_air" AS ARC_AIR
,DATA:"design_bridg" AS DESIGN_BRIDG
,DATA:"splice_top" AS SPLICE_TOP
,DATA:"splice_bot" AS SPLICE_BOT
,DATA:"impr_ingen" AS IMPR_INGEN
,DATA:"man_auto_cred" AS MAN_AUTO_CRED
,DATA:"d_inactif" AS D_INACTIF
,DATA:"t_saisie" AS T_SAISIE
,DATA:"usager" AS USAGER
,DATA:"finishing_code" AS FINISHING_CODE
,DATA:"sloped_shoes" AS SLOPED_SHOES
,DATA:"deep_shoes" AS DEEP_SHOES
,DATA:"splices" AS SPLICES
,DATA:"spec_loads" AS SPEC_LOADS
,DATA:"spec_deflect" AS SPEC_DEFLECT
,DATA:"uplift" AS UPLIFT
,DATA:"stand_seam" AS STAND_SEAM
,DATA:"eng_seal_req" AS ENG_SEAL_REQ
,DATA:"spec_inspect" AS SPEC_INSPECT
,DATA:"dwg_avail" AS DWG_AVAIL
,DATA:"moments" AS MOMENTS
,DATA:"spec_camber" AS SPEC_CAMBER
,DATA:"csqe_bb" AS CSQE_BB
,DATA:"spec_holes" AS SPEC_HOLES
,DATA:"spec_conn" AS SPEC_CONN
,DATA:"spec_brdg" AS SPEC_BRDG
,DATA:"cklist" AS CKLIST
,DATA:"d_histo" AS D_HISTO
,DATA:"production_doc_archived" AS PRODUCTION_DOC_ARCHIVED
,DATA:"production_doc_archived_by" AS PRODUCTION_DOC_ARCHIVED_BY
,DATA:"production_doc_archived_date" AS PRODUCTION_DOC_ARCHIVED_DATE
,DATA:"no_agent_ct" AS NO_AGENT_CT
,DATA:"_rowid" AS ROW_ID
,DATA:"src_system_operation" AS SRC_SYSTEM_OPERATION
,DATA:"ipaas_updated_date" AS IPAAS_UPDATED_DATE
,DATA:"CreatedDate" AS CREATED_DATE
,DATA:"ModifiedDate" AS MODIFIED_DATE
,DATA:"CreatedBy" AS CREATED_BY
,DATA:"ModifiedBy" AS MODIFIED_BY
,DATA:"projet_e_uuid" AS PROJET_E_UUID
,DATA:"DataEventTimestamp" AS DATA_EVENT_TIMESTAMP
,FILENAME                           AS METADATA_FILENAME 
,FILE_ROW_NUMBER                    AS METADATA_FILE_ROW_NUMBER
,FILE_LAST_MODIFIED                 AS METADATA_FILE_LAST_MODIFIED
,START_SCAN_TIME                    AS METADATA_START_SCAN_TIME
,{{ dbt_utils.generate_surrogate_key(['DATA:"no_projet"']) }} as TABLE_SK
,COALESCE(TO_TIMESTAMP_TZ(DATA:"DataEventTimestamp"),TO_TIMESTAMP_NTZ(DATEADD(microsecond, FILE_ROW_NUMBER,TO_TIMESTAMP_NTZ(DATA:"ipaas_updated_date"::string)))) as QUALIFY_TIMESTAMP

from {{ source("landing_spm_ca", "PROJET_E") }}
-- to only take the files after the last fullLoad
WHERE 
  split(FILENAME, '_')[array_size(split(FILENAME, '_')) - 2] >=
  (SELECT min_timestamp
  FROM
      (SELECT split(FILENAME, '_')[array_size(split(FILENAME, '_')) - 2] AS min_timestamp, split(FILENAME, '/')[3] AS type_file
      FROM {{ source("landing_spm_ca", "PROJET_E") }}
      WHERE type_file LIKE 'fullload%'
      QUALIFY ROW_NUMBER() OVER (ORDER BY min_timestamp DESC) = 1)
  )