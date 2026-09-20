{{
  config(
    materialized = "view",
    alias = "descriptions",
    schema='RDM'
  )
}}

select 
  DATA:"ApplicationCode" AS APPLICATIONCODE
, DATA:"DomainCode" AS DOMAINCODE
, DATA:"Value" AS VALUE
, DATA:"Language" AS LANGUAGE
, DATA:"Name" AS NAME
, DATA:"exported_datetime_utc" AS exported_datetime_utc
from {{ source("landing_rdm", "descriptions") }}
WHERE 
  split(FILENAME, '_') -- fullload _ valuemapping _ (timestamp) _ 0.json
  [array_size(split(FILENAME, '_')) - 2] >=
  (SELECT min_timestamp
  FROM
      (SELECT split(FILENAME, '_')[array_size(split(FILENAME, '_')) - 2] AS min_timestamp, split(FILENAME, '/')[3] AS type_file
      FROM {{ source("landing_rdm", "descriptions") }}
      WHERE type_file LIKE 'fullload%'
      QUALIFY ROW_NUMBER() OVER (ORDER BY min_timestamp DESC) = 1)
  )