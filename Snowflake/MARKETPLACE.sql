/*
The purpose of MARKETPLACE is to expose business-friendly, consumption-ready data products.

For example, instead of Tableau having to understand:

FACT_SALES
    CUSTOMER_SK
    PRODUCT_SK
    ORDER_DATE_SK

we can provide:

MARKETPLACE.SALES_CUSTOMER_PRODUCT

containing:

Customer Name
Product Name
Order Date
Order Number
Quantity
Unit Price
Sales Amount
Tax
Freight
Product Cost

Conceptually:

              SCHEMATIZE
                  │
        ┌──────────┼──────────┐
        ▼         ▼         ▼
     CUSTOMER   PRODUCT    DATE
        │         │         │
        └──────────┼──────────┘
                  │
             FACT_SALES
                  │
                  ▼
             MARKETPLACE
                  │
                  ▼
      SALES_CUSTOMER_PRODUCT
                  │
                  ▼
          Tableau / Power BI
One important distinction

SCHEMATIZE = warehouse model

MARKETPLACE = consumer/business data product


*/

CREATE OR REPLACE VIEW ADVWORKS_DEV.MARKETPLACE.SALES_CUSTOMER_PRODUCT
AS
SELECT
    -- Order
    F.SALES_ORDER_NUMBER,
    F.SALES_ORDER_LINE_NUMBER,
    F.REVISION_NUMBER,

    -- Customer
    C.CUSTOMER_KEY,
    C.CUSTOMER_SK,

    -- Product
    P.PRODUCT_KEY,
    P.PRODUCT_SK,
    P.PRODUCT_NAME,
    P.COLOR,
    P.SIZE,

    -- Dates
    OD.FULL_DATE AS ORDER_DATE,
    DD.FULL_DATE AS DUE_DATE,
    SD.FULL_DATE AS SHIP_DATE,

    -- Measures
    F.ORDER_QUANTITY,
    F.UNIT_PRICE,
    F.EXTENDED_AMOUNT,
    F.UNIT_PRICE_DISCOUNT_PCT,
    F.DISCOUNT_AMOUNT,
    F.PRODUCT_STANDARD_COST,
    F.TOTAL_PRODUCT_COST,
    F.SALES_AMOUNT,
    F.TAX_AMT,
    F.FREIGHT,

    -- Transaction attributes
    F.CARRIER_TRACKING_NUMBER,
    F.CUSTOMER_PO_NUMBER,

    -- Audit
    F.SOURCE_FILE,
    F.LOAD_TIMESTAMP,
    F.CREATED_TIMESTAMP

FROM ADVWORKS_DEV.SCHEMATIZE.FACT_SALES F

INNER JOIN ADVWORKS_DEV.SCHEMATIZE.DIM_CUSTOMER C
    ON F.CUSTOMER_SK = C.CUSTOMER_SK

INNER JOIN ADVWORKS_DEV.SCHEMATIZE.DIM_PRODUCT P
    ON F.PRODUCT_SK = P.PRODUCT_SK

INNER JOIN ADVWORKS_DEV.SCHEMATIZE.DIM_DATE OD
    ON F.ORDER_DATE_SK = OD.DATE_SK

INNER JOIN ADVWORKS_DEV.SCHEMATIZE.DIM_DATE DD
    ON F.DUE_DATE_SK = DD.DATE_SK

INNER JOIN ADVWORKS_DEV.SCHEMATIZE.DIM_DATE SD
    ON F.SHIP_DATE_SK = SD.DATE_SK;

-- VALIDATE
SELECT COUNT(*) AS MARKETPLACE_COUNT
FROM ADVWORKS_DEV.MARKETPLACE.SALES_CUSTOMER_PRODUCT; -- 60398

SELECT
    COUNT(*) AS ROW_COUNT,
    COUNT(DISTINCT CONCAT(
        SALES_ORDER_NUMBER,
        '|',
        SALES_ORDER_LINE_NUMBER
    )) AS DISTINCT_ORDER_LINES
FROM ADVWORKS_DEV.MARKETPLACE.SALES_CUSTOMER_PRODUCT;
/*
ROW_COUNT	DISTINCT_ORDER_LINES
60398	60398
*/

-- verify the financial measures haven't changed:
SELECT
    COUNT(*) AS ROW_COUNT,
    SUM(SALES_AMOUNT) AS TOTAL_SALES,
    SUM(TOTAL_PRODUCT_COST) AS TOTAL_PRODUCT_COST,
    SUM(TAX_AMT) AS TOTAL_TAX,
    SUM(FREIGHT) AS TOTAL_FREIGHT
FROM ADVWORKS_DEV.MARKETPLACE.SALES_CUSTOMER_PRODUCT;
/*
ROW_COUNT	TOTAL_SALES	TOTAL_PRODUCT_COST	TOTAL_TAX	TOTAL_FREIGHT
60398	29358677.2207	17277793.5757	2348694.2301	733969.6091
*/

/*

                 CURRENT
                    │
                    ▼
        ┌─────────────────────────┐
        │ MANUAL SQL PIPELINE  │
        │                      │
        │ LANDING              │
        │ PREPARE              │
        │ NORMALIZE            │
        │ SCHEMATIZE           │
        │ MARKETPLACE          │
        └───────────┬─────────────┘
                   │
                   ▼
                 dbt
                   │
       ┌────────────┼─────────────┐
       ▼           ▼           ▼
     Models      Tests      Lineage
       │           │           │
       └────────────┼─────────────┘
                   ▼
               Terraform
                   │
                   ▼
            Azure Pipelines
                   │
                   ▼
            CI/CD Pipeline

That is where THIS project becomes much more aligned with the production-style stack
*/