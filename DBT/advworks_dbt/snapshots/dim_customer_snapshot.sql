{% snapshot dim_customer_snapshot %}

{{
    config(
        target_database='ADVWORKS_DEV',
        target_schema='SNAPSHOTS',
        unique_key='CUSTOMER_KEY',
        strategy='timestamp',
        updated_at='LOAD_TIMESTAMP'
    )
}}

SELECT
    CUSTOMER_KEY,
    GEOGRAPHY_KEY,
    CUSTOMER_ALTERNATE_KEY,
    TITLE,
    FIRST_NAME,
    MIDDLE_NAME,
    LAST_NAME,
    NAME_STYLE,
    BIRTH_DATE,
    MARITAL_STATUS,
    SUFFIX,
    GENDER,
    EMAIL_ADDRESS,
    YEARLY_INCOME,
    TOTAL_CHILDREN,
    NUMBER_CHILDREN_AT_HOME,
    ENGLISH_EDUCATION,
    SPANISH_EDUCATION,
    FRENCH_EDUCATION,
    ENGLISH_OCCUPATION,
    SPANISH_OCCUPATION,
    FRENCH_OCCUPATION,
    HOUSE_OWNER_FLAG,
    NUMBER_CARS_OWNED,
    ADDRESS_LINE_1,
    ADDRESS_LINE_2,
    PHONE,
    DATE_FIRST_PURCHASE,
    COMMUTE_DISTANCE,
    LOAD_TIMESTAMP
FROM {{ ref('dim_customer_normalize') }}

{% endsnapshot %}