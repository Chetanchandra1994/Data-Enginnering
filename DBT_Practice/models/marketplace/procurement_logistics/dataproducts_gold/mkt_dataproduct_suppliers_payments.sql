{{
  config(
    full_refresh = true,
    materialized="dynamic_table",
    target_lag="1 hour",
    snowflake_warehouse= var('task_warehouse'),
    alias = "suppliers_payments",
    schema= "dataproducts_gold",
    post_hook = "ALTER DYNAMIC TABLE {{ this }} SET LOG_LEVEL = ERROR"
  
  )
}}

SELECT
    C.SUPPLIER_NUMBER AS SUPPLIER_NUMBER,
    b.PAYMENT_DATE AS DATE,
    b.PAYMENT_STATUS AS STATUS,
    a.INVOICE_PAYMENT_AMOUNT_CAD AS PAYMENT_AMOUNT_CAD,
    a.INVOICE_PAYMENT_DISCOUNT_LOST_AMT_CAD AS DISCOUNT_LOST_CAD,
    a.INVOICE_PAYMENT_DISCOUNT_LOST AS DISCOUNT_LOST
FROM
    {{ ref ('sche_fact_Supplier_Payment_Detail') }} AS A
LEFT JOIN
    {{ ref ('sche_fact_Supplier_Payment') }} AS B
    ON A.SUPPLIER_PAYMENT_SK = B.SUPPLIER_PAYMENT_SK
LEFT JOIN
    {{ ref ('sche_dim_Supplier') }} AS C
    ON B.SUPPLIER_SK = C.SUPPLIER_SK