{{
  config(
    materialized = "view",
    alias = "enterprise",
    schema='mqtt'
  )
}}

SELECT 
  routing_key,
  raw_body
FROM 
  {{ ref ('prep_enterprise') }}