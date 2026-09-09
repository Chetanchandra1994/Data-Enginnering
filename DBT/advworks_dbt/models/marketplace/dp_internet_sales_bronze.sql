{{ config(
    materialized='table',
    schema='MARKETPLACE'
) }}

SELECT
    SALES_ORDER_NUMBER,
    SALES_ORDER_LINE_NUMBER,
    PRODUCT_KEY,
    CUSTOMER_KEY,
    ORDER_DATE_KEY,
    ORDER_QUANTITY,
    UNIT_PRICE,
    EXTENDED_AMOUNT,
    DISCOUNT_AMOUNT,
    TOTAL_PRODUCT_COST,
    SALES_AMOUNT,
    TAX_AMT,
    FREIGHT,
    ORDER_DATE

FROM {{ ref('fact_internet_sales') }}