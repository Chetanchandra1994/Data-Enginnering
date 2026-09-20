{{
  config(
    materialized = "view",
    alias = "cmaitre_s",
    schema='spm_ca'
  )
}}

SELECT 
     DATA:"entity_code" AS ENTITY_CODE
    ,DATA:"no_contr" AS NO_CONTR
    ,DATA:"nom_contr" AS NOM_CONTR
    ,DATA:"no_usine" AS NO_USINE
    ,DATA:"regr_usine" AS REGR_USINE
    ,DATA:"ipaas_updated_date" AS IPAAS_UPDATED_DATE
    ,DATA:"DataEventTimestamp" AS DATA_EVENT_TIMESTAMP
    ,{{ dbt_utils.generate_surrogate_key(['DATA:"entity_code"','DATA:"no_contr"']) }} as TABLE_SK
    ,COALESCE(TO_TIMESTAMP_TZ(DATA:"DataEventTimestamp"),TO_TIMESTAMP_NTZ(DATEADD(microsecond, FILE_ROW_NUMBER,TO_TIMESTAMP_NTZ(DATA:"ipaas_updated_date"::string)))) as QUALIFY_TIMESTAMP

FROM {{ source("landing_spm_ca", "CMAITRE_S") }}

-- to only take the files after the last fullLoad
WHERE 
  split(FILENAME, '_')[array_size(split(FILENAME, '_')) - 2] >=
  (SELECT min_timestamp
  FROM
      (SELECT split(FILENAME, '_')[array_size(split(FILENAME, '_')) - 2] AS min_timestamp, split(FILENAME, '/')[3] AS type_file
      FROM {{ source("landing_spm_ca", "CMAITRE_S") }}
      WHERE type_file LIKE 'fullload%'
      QUALIFY ROW_NUMBER() OVER (ORDER BY min_timestamp DESC) = 1)
  )