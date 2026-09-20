{{
  config(
    materialized = "view",
    alias = "product_attribute",
    schema='spm_ca'
  )
}}

SELECT
    UPPER(NULLIF(TRIM(ENTITY_CODE::string), '')) AS ENTITY_CODE,
    NO_PRODUIT::INTEGER AS NO_PRODUIT,
    UPPER(NULLIF(TRIM(ATTRIBUTE_CODE::string), '')) AS ATTRIBUTE_CODE,
    UPPER(NULLIF(TRIM(ATTRIBUTE_VALUE::string), '')) AS ATTRIBUTE_VALUE,
    --DUMMY::string AS DUMMY, /*Always Null*/
    IPAAS_UPDATED_DATE::DATE AS IPAAS_UPDATED_DATE
    
FROM {{ref('prep_product_attribute')}}
QUALIFY ROW_NUMBER() OVER (PARTITION BY TABLE_SK ORDER BY QUALIFY_TIMESTAMP DESC) = 1
