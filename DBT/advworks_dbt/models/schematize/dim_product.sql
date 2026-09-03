{{ config(
    materialized='table',
    schema='SCHEMATIZE'
) }}

SELECT

    PRODUCT_KEY,

    PRODUCT_ALTERNATE_KEY,

    PRODUCT_NAME,

    COLOR,

    SIZE,

    STANDARD_COST,

    LIST_PRICE,

    PRODUCT_SUBCATEGORY_KEY,

    START_DATE,

    END_DATE,

    STATUS,

    CREATED_TIMESTAMP,

    UPDATED_TIMESTAMP

FROM {{ ref('dim_product_normalize') }}