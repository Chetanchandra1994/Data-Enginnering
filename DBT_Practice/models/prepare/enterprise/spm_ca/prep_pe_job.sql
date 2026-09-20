{{
  config(
    materialized = "view",
    alias = "pe_job",
    schema='spm_ca'
  )
}}

SELECT
     DATA:"in_entity" AS IN_ENTITY
    ,DATA:"whs_code" AS WHS_CODE
    ,DATA:"no_job" AS NO_JOB
    ,DATA:"desc_job" AS DESC_JOB
    ,DATA:"date_ouv" AS DATE_OUV
    ,DATA:"date_ferm" AS DATE_FERM
    ,DATA:"cout_job" AS COUT_JOB
    ,DATA:"cout_estim" AS COUT_ESTIM
    ,DATA:"cumul_reg" AS CUMUL_REG
    ,DATA:"cumul_sup" AS CUMUL_SUP
    ,DATA:"cumul_dbl" AS CUMUL_DBL
    ,DATA:"type" AS TYPE
    ,DATA:"no_gl" AS NO_GL
    ,DATA:"statut_proj" AS STATUT_PROJ
    ,DATA:"ipaas_updated_date" AS IPAAS_UPDATED_DATE
    ,DATA:"DataEventTimestamp" AS DATA_EVENT_TIMESTAMP
    ,FILENAME AS METADATA_FILENAME 
    ,FILE_ROW_NUMBER AS METADATA_FILE_ROW_NUMBER
    ,FILE_LAST_MODIFIED AS METADATA_FILE_LAST_MODIFIED
    ,START_SCAN_TIME AS METADATA_START_SCAN_TIME
    ,{{ dbt_utils.generate_surrogate_key(['DATA:"in_entity"','DATA:"whs_code"','DATA:"no_job"','DATA:"desc_job"']) }} as TABLE_SK
    ,COALESCE(TO_TIMESTAMP_TZ(DATA:"DataEventTimestamp"),TO_TIMESTAMP_NTZ(DATEADD(microsecond, FILE_ROW_NUMBER,TO_TIMESTAMP_NTZ(DATA:"ipaas_updated_date"::string)))) as QUALIFY_TIMESTAMP

FROM {{ source("landing_spm_ca", "PE_JOB") }}

-- to only take the files after the last fullLoad
WHERE 
  split(FILENAME, '_')[array_size(split(FILENAME, '_')) - 2] >=
  (SELECT min_timestamp
  FROM
      (SELECT split(FILENAME, '_')[array_size(split(FILENAME, '_')) - 2] AS min_timestamp, split(FILENAME, '/')[3] AS type_file
      FROM {{ source("landing_spm_ca", "PE_JOB") }}
      WHERE type_file LIKE 'fullload%'
      QUALIFY ROW_NUMBER() OVER (ORDER BY min_timestamp DESC) = 1)
  )