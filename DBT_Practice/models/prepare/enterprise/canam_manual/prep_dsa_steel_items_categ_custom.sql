{{
  config(
    materialized = "view",
    alias = "dsa_steel_items_categ_custom",
    schema='enterprise_MANUAL',
    tags=["dsa_steel_items_categ_custom"]
  )
}}

SELECT 
UPPER(CATEGORY_CODE::string) AS CATEGORY_CODE,
UPPER(DESCRIPTION::string) AS DESCRIPTION
FROM {{ source("landing_enterprise", "DSA_STEEL_ITEMS_CATEG_CUSTOM") }}