{{
  config(
    materialized = "view",
    alias = "dsa_steel_items_categ_custom",
    schema='CANAM_MANUAL',
    tags=["dsa_steel_items_categ_custom"]
  )
}}

SELECT 
CATEGORY_CODE,
DESCRIPTION
FROM {{ref('prep_dsa_steel_items_categ_custom')}}