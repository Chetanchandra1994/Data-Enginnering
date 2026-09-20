{{
  config(
    materialized = "view",
    alias = "canam",
    schema='mqtt'
  )
}}

SELECT 
  routing_key,
  raw_body
FROM 
  {{ ref ('prep_canam') }}