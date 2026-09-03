{{ config(
    materialized='table',
    schema='NORMALIZE'
) }}

SELECT

    PRODUCT_KEY,

    NULLIF(
        TRIM(PRODUCT_ALTERNATE_KEY),
        ''
    ) AS PRODUCT_ALTERNATE_KEY,

    NULLIF(
        TRIM(ENGLISH_PRODUCT_NAME),
        ''
    ) AS PRODUCT_NAME,

    NULLIF(
        TRIM(COLOR),
        ''
    ) AS COLOR,

    NULLIF(
        TRIM(SIZE),
        ''
    ) AS SIZE,

    STANDARD_COST,

    LIST_PRICE,

    PRODUCT_SUBCATEGORY_KEY,

    START_DATE,

    END_DATE,

    CASE
        WHEN END_DATE IS NULL THEN 'ACTIVE'
        ELSE 'INACTIVE'
    END AS STATUS,

    SOURCE_FILE,

    LOAD_TIMESTAMP,

    CURRENT_TIMESTAMP() AS CREATED_TIMESTAMP,

    CURRENT_TIMESTAMP() AS UPDATED_TIMESTAMP

FROM {{ ref('dim_product_prepare') }}