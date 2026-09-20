{{
  config(
    materialized = "view",
    alias = "standard_code_mapping",
    schema="RDM"
  )
}}


with 

raw_data_deduplicated as (

    SELECT *
    from {{ref('prep_standard_code_mapping')}}
    QUALIFY TO_TIMESTAMP_NTZ(exported_datetime_utc) = MAX(TO_TIMESTAMP_NTZ(exported_datetime_utc)) OVER()
)

SELECT
  Business_Application_Code::STRING         as Business_Application_Code
, Business_Application_Domain_Code::STRING  as Business_Application_Domain_Code
, CASE
    --Logique fournie par Carl
    WHEN Business_Application_Value::STRING IS NULL THEN '' -- Les cellules vides dans la feuille de chargement RDM (et les feuilles sources) doivent être des blank strings
    WHEN Business_Application_Value::STRING = '*NULL' THEN NULL -- Les cellules dont le texte est "*NULL" doivent être NULL
    ELSE Business_Application_Value
  END as Business_Application_Value
, Standard_Application_Code::STRING         as Standard_Application_Code
, Standard_Domain_Application_Code::STRING  as Standard_Domain_Application_Code
, Standard_Application_Value::STRING        as Standard_Application_Value
, EXPORTED_DATETIME_UTC::DATETIME as EXPORTED_DATETIME_UTC
from raw_data_deduplicated
