{{ config(
    materialized='table',
    schema='MARKETPLACE'
) }}

SELECT

    /* =========================
       ORDER
       ========================= */

    f.SALES_ORDER_NUMBER,
    f.SALES_ORDER_LINE_NUMBER,

    f.ORDER_DATE,
    f.DUE_DATE,
    f.SHIP_DATE,

    d.YEAR,
    d.QUARTER,
    d.MONTH,
    d.MONTH_NAME,
    d.DAY_NAME,
    d.IS_WEEKDAY,

    /* =========================
       CUSTOMER
       ========================= */

    f.CUSTOMER_KEY,
    c.CUSTOMER_ALTERNATE_KEY,
    c.FULL_NAME AS CUSTOMER_NAME,
    c.EMAIL_ADDRESS,
    c.GENDER,
    c.MARITAL_STATUS,
    c.YEARLY_INCOME,

    /* =========================
       PRODUCT
       ========================= */

    f.PRODUCT_KEY,
    p.PRODUCT_ALTERNATE_KEY,
    p.PRODUCT_NAME,
    p.COLOR,
    p.SIZE,
    p.STANDARD_COST,
    p.LIST_PRICE,
    p.STATUS AS PRODUCT_STATUS,

    /* =========================
       SALES
       ========================= */

    f.ORDER_QUANTITY,
    f.UNIT_PRICE,
    f.EXTENDED_AMOUNT,
    f.UNIT_PRICE_DISCOUNT_PCT,
    f.DISCOUNT_AMOUNT,
    f.PRODUCT_STANDARD_COST,
    f.TOTAL_PRODUCT_COST,
    f.SALES_AMOUNT,
    f.TAX_AMT,
    f.FREIGHT,

    /* =========================
       OTHER DIMENSIONS
       ========================= */

    f.PROMOTION_KEY,
    f.CURRENCY_KEY,
    f.SALES_TERRITORY_KEY,

    f.SOURCE_FILE,
    f.LOAD_TIMESTAMP,

    CURRENT_TIMESTAMP() AS CREATED_TIMESTAMP

FROM {{ ref('fact_internet_sales') }} f

LEFT JOIN {{ ref('dim_customer') }} c
    ON f.CUSTOMER_KEY = c.CUSTOMER_KEY

LEFT JOIN {{ ref('dim_product') }} p
    ON f.PRODUCT_KEY = p.PRODUCT_KEY

LEFT JOIN {{ ref('dim_date') }} d
    ON f.ORDER_DATE::DATE = d.FULL_DATE