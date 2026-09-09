{{ config(
    materialized='table',
    schema='MARKETPLACE'
) }}

SELECT
    CUSTOMER_KEY,
    CUSTOMER_ALTERNATE_KEY,
    FIRST_NAME,
    LAST_NAME,
    GENDER,
    EMAIL_ADDRESS,
    YEARLY_INCOME,
    TOTAL_CHILDREN,
    NUMBER_CARS_OWNED,
    DATE_FIRST_PURCHASE

FROM {{ ref('dim_customer') }}