{{ config(
    materialized='table',
    schema='NORMALIZE'
) }}

SELECT

    CUSTOMER_KEY,

    GEOGRAPHY_KEY,

    NULLIF(
        TRIM(CUSTOMER_ALTERNATE_KEY),
        ''
    ) AS CUSTOMER_ALTERNATE_KEY,

    NULLIF(
        TRIM(TITLE),
        ''
    ) AS TITLE,

    NULLIF(
        TRIM(FIRST_NAME),
        ''
    ) AS FIRST_NAME,

    NULLIF(
        TRIM(MIDDLE_NAME),
        ''
    ) AS MIDDLE_NAME,

    NULLIF(
        TRIM(LAST_NAME),
        ''
    ) AS LAST_NAME,

    TRIM(
        CONCAT_WS(
            ' ',
            NULLIF(TRIM(FIRST_NAME), ''),
            NULLIF(TRIM(MIDDLE_NAME), ''),
            NULLIF(TRIM(LAST_NAME), '')
        )
    ) AS FULL_NAME,

    NAME_STYLE,

    BIRTH_DATE,

    UPPER(
        NULLIF(TRIM(MARITAL_STATUS), '')
    ) AS MARITAL_STATUS,

    NULLIF(
        TRIM(SUFFIX),
        ''
    ) AS SUFFIX,

    UPPER(
        NULLIF(TRIM(GENDER), '')
    ) AS GENDER,

    LOWER(
        NULLIF(TRIM(EMAIL_ADDRESS), '')
    ) AS EMAIL_ADDRESS,

    YEARLY_INCOME,

    TOTAL_CHILDREN,

    NUMBER_CHILDREN_AT_HOME,

    NULLIF(
        TRIM(ENGLISH_EDUCATION),
        ''
    ) AS ENGLISH_EDUCATION,

    NULLIF(
        TRIM(SPANISH_EDUCATION),
        ''
    ) AS SPANISH_EDUCATION,

    NULLIF(
        TRIM(FRENCH_EDUCATION),
        ''
    ) AS FRENCH_EDUCATION,

    NULLIF(
        TRIM(ENGLISH_OCCUPATION),
        ''
    ) AS ENGLISH_OCCUPATION,

    NULLIF(
        TRIM(SPANISH_OCCUPATION),
        ''
    ) AS SPANISH_OCCUPATION,

    NULLIF(
        TRIM(FRENCH_OCCUPATION),
        ''
    ) AS FRENCH_OCCUPATION,

    HOUSE_OWNER_FLAG,

    NUMBER_CARS_OWNED,

    NULLIF(
        TRIM(ADDRESS_LINE1),
        ''
    ) AS ADDRESS_LINE1,

    NULLIF(
        TRIM(ADDRESS_LINE2),
        ''
    ) AS ADDRESS_LINE2,

    NULLIF(
        TRIM(PHONE),
        ''
    ) AS PHONE,

    DATE_FIRST_PURCHASE,

    NULLIF(
        TRIM(COMMUTE_DISTANCE),
        ''
    ) AS COMMUTE_DISTANCE,

    SOURCE_FILE,

    LOAD_TIMESTAMP,

    CURRENT_TIMESTAMP() AS CREATED_TIMESTAMP,

    CURRENT_TIMESTAMP() AS UPDATED_TIMESTAMP

FROM {{ ref('dim_customer_prepare') }}