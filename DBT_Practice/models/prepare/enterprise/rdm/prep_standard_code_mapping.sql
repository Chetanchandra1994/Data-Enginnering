{{
  config(
    materialized = "view",
    alias = "standard_code_mapping",
    schema='RDM'
  )
}}

SELECT 
    DATA:Business_Application_Code        as Business_Application_Code
  , DATA:Business_Application_Domain_Code as Business_Application_Domain_Code
  , DATA:Business_Application_Value       as Business_Application_Value
  , DATA:Standard_Application_Code        as Standard_Application_Code
  , DATA:Standard_Domain_Application_Code as Standard_Domain_Application_Code
  , DATA:Standard_Application_Value       as Standard_Application_Value
  , DATA:exported_datetime_utc            as exported_datetime_utc

from {{ source("landing_rdm", "standard_code_mapping") }}
WHERE 
  split(FILENAME, '_') -- fullload _ valuemapping _ (timestamp) _ 0.json
  [array_size(split(FILENAME, '_')) - 2] >=
  (SELECT min_timestamp
  FROM
      (SELECT split(FILENAME, '_')[array_size(split(FILENAME, '_')) - 2] AS min_timestamp, split(FILENAME, '/')[3] AS type_file
      FROM {{ source("landing_rdm", "standard_code_mapping") }}
      WHERE type_file LIKE 'fullload%'
      QUALIFY ROW_NUMBER() OVER (ORDER BY min_timestamp DESC) = 1)
  )