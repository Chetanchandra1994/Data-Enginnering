{{
  config(
    materialized = "view",
    alias = "employee",
    schema='mdh'
  )
}}

SELECT
  data:"main_employee_number" as MAIN_EMPLOYEE_NUMBER
, data:"main_legal_entity" as MAIN_LEGAL_ENTITY
, data:"professional_email" as PROFESSIONAL_EMAIL
, data:"first_name" as FIRST_NAME
, data:"last_name" as LAST_NAME
, data:"status" as STATUS
, data:"ipaas_updated_date" as IPAAS_UPDATED_DATE
, data:"src_system_operation" as SRC_SYSTEM_OPERATION
from {{ source("landing_mdh", "EMPLOYEE") }}
WHERE 
  split(FILENAME, '_')[array_size(split(FILENAME, '_')) - 2] >=
  (SELECT min_timestamp
  FROM
      (SELECT split(FILENAME, '_')[array_size(split(FILENAME, '_')) - 2] AS min_timestamp, split(FILENAME, '/')[3] AS type_file
      FROM {{ source("landing_mdh", "EMPLOYEE") }}
      WHERE type_file LIKE 'fullload%'
      QUALIFY ROW_NUMBER() OVER (ORDER BY min_timestamp DESC) = 1)
  )