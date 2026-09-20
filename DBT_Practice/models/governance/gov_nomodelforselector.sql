{{
  config(
    materialized="view",
    alias = "dummy",
    schema= "public"
  )
}}

SELECT * FROM (
  VALUES
    ('')
) AS NOMODEL_FORSELECTOR (NOTHING)