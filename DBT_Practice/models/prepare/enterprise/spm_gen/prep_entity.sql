{{
  config(
    materialized = "view",
    alias = "entity",
    schema='spm_gen'
  )
}}


SELECT
 DATA:"Entity_code" AS ENTITY_CODE
,DATA:"Name" AS NAME
,SPLIT_PART(TRIM(DATA:"Name_Address_1"),';',1) AS NAME_ADDRESS_1
,SPLIT_PART(TRIM(DATA:"Name_Address_1"),';',2) AS NAME_ADDRESS_2
,SPLIT_PART(TRIM(DATA:"Name_Address_1"),';',3) AS NAME_ADDRESS_3
,SPLIT_PART(TRIM(DATA:"Name_Address_1"),';',4) AS NAME_ADDRESS_4
,SPLIT_PART(TRIM(DATA:"Name_Address_1"),';',5) AS NAME_ADDRESS_5
,DATA:"Ar_entity" AS AR_ENTITY
,DATA:"Ap_entity" AS AP_ENTITY
,DATA:"Gl_entity" AS GL_ENTITY
,DATA:"Py_entity" AS PY_ENTITY
,DATA:"In_entity" AS IN_ENTITY
,DATA:"Fa_entity" AS FA_ENTITY
,SPLIT_PART(TRIM(DATA:"Application"),';',1) AS APPLICATION_1
,SPLIT_PART(TRIM(DATA:"Application"),';',2) AS APPLICATION_2
,SPLIT_PART(TRIM(DATA:"Application"),';',3) AS APPLICATION_3
,SPLIT_PART(TRIM(DATA:"Application"),';',4) AS APPLICATION_4
,SPLIT_PART(TRIM(DATA:"Application"),';',5) AS APPLICATION_5
,SPLIT_PART(TRIM(DATA:"Control_ent"),';',1) AS CONTROL_ENT_1
,SPLIT_PART(TRIM(DATA:"Control_ent"),';',2) AS CONTROL_ENT_2
,SPLIT_PART(TRIM(DATA:"Control_ent"),';',3) AS CONTROL_ENT_3
,SPLIT_PART(TRIM(DATA:"Control_ent"),';',4) AS CONTROL_ENT_4
,SPLIT_PART(TRIM(DATA:"Control_ent"),';',5) AS CONTROL_ENT_5
,DATA:"Cp_entity" AS CP_ENTITY
,DATA:"ipaas_updated_date" AS IPAAS_UPDATED_DATE
,DATA:"src_system_operation" AS SRC_SYSTEM_OPERATION
,DATA:"DataEventTimestamp" AS DATA_EVENT_TIMESTAMP
,{{ dbt_utils.generate_surrogate_key(['DATA:"Entity_code"']) }} as TABLE_SK
,COALESCE(TO_TIMESTAMP_TZ(DATA:"DataEventTimestamp"),TO_TIMESTAMP_NTZ(DATEADD(microsecond, FILE_ROW_NUMBER,TO_TIMESTAMP_NTZ(DATA:"ipaas_updated_date"::string)))) as QUALIFY_TIMESTAMP
from {{ source("landing_spm_gen", "ENTITY") }}
-- to only take the files after the last fullLoad
  WHERE 
  split(FILENAME, '_')[array_size(split(FILENAME, '_')) - 2] >=
    (SELECT min_timestamp
  FROM
      (SELECT split(FILENAME, '_')[array_size(split(FILENAME, '_')) - 2] AS min_timestamp, split(FILENAME, '/')[3] AS type_file
      FROM {{ source("landing_spm_gen", "ENTITY") }}
      WHERE type_file LIKE 'fullload%'
      QUALIFY ROW_NUMBER() OVER (ORDER BY min_timestamp DESC) = 1)
    )
 