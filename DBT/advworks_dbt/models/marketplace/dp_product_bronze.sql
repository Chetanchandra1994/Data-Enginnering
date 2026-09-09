{{ config(
    materialized='table',
    schema='MARKETPLACE'
) }}

SELECT
    PRODUCT_KEY,
    PRODUCT_ALTERNATE_KEY,
    ENGLISH_PRODUCT_NAME,
    COLOR,
    SIZE,
    STANDARD_COST,
    LIST_PRICE,
    PRODUCT_SUBCATEGORY_KEY,
    START_DATE,
    END_DATE,
    STATUS

FROM {{ ref('dim_product') }}