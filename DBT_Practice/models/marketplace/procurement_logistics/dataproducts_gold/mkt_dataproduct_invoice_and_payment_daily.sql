{{
  config(
    full_refresh = true,
    materialized="dynamic_table",
    target_lag="24 hour",
    snowflake_warehouse= var('task_warehouse'),
    alias = "invoice_and_payment_daily",
    schema= "dataproducts_gold",
    post_hook = "ALTER DYNAMIC TABLE {{ this }} SET LOG_LEVEL = ERROR"
  
  )
}}

-- It returns the EXPIRY_DATE of the previous agreement for the same supplier based on the order of the EFFECTIVE_DATE
WITH Supplier_Agreement_Source AS (
    SELECT
        Supplier_Number AS SUPPLIER_NUMBER
        ,AGREEMENT_TYPE_NAME
        ,EFFECTIVE_DATE
        ,EXPIRY_DATE
        ,LAG(EXPIRY_DATE) OVER (
            PARTITION BY SUPPLIER_NUMBER
            ORDER BY EFFECTIVE_DATE
        ) AS PREVIOUS_END_DATE
    FROM
        {{ ref ('sche_dim_Supplier_Agreement') }}
),
-- It's identifying whether a new group starts based on a missing previous end date or a gap of more than one day:
-- 1 indicates that a new group or agreement sequence is starting because there’s no prior agreement or there’s a gap
-- 0 indicates the current record continues directly from the previous one without a break
Supplier_Agreement_Grouping_Flags AS (
    SELECT
        *
        ,CASE
            WHEN PREVIOUS_END_DATE IS NULL THEN 1
            WHEN EFFECTIVE_DATE > DATEADD(day, 1, PREVIOUS_END_DATE) THEN 1
            ELSE 0
        END AS NEW_GROUP
    FROM
        Supplier_Agreement_Source
),
-- Calculates a cumulative sum of NEW_GROUP for each supplier over time ordered by the effective date
Supplier_Agreement_Grouping AS (
    SELECT
        *
        ,SUM(NEW_GROUP) OVER (
            PARTITION BY SUPPLIER_NUMBER
            ORDER BY EFFECTIVE_DATE
            ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
        ) AS GROUP_ID
    FROM
        Supplier_Agreement_Grouping_Flags
),
-- Return the earliest EFFECTIVE_DATE and latest EXPIRY_DATE
Supplier_Agreement AS (
    SELECT
        SUPPLIER_NUMBER
        ,AGREEMENT_TYPE_NAME
        ,MIN(EFFECTIVE_DATE) AS EFFECTIVE_DATE
        ,MAX(EXPIRY_DATE) AS EXPIRY_DATE
    FROM
        Supplier_Agreement_Grouping
    GROUP BY
        SUPPLIER_NUMBER,
        AGREEMENT_TYPE_NAME,
        GROUP_ID
)

SELECT 
     e.Supplier_Number AS Supplier_Number
    ,d.PT_NAME AS Supplier_Usual_Name
    ,e.Nature_of_Supply_Name AS Nature_Of_Supply
    ,c.INVOICE_DATE AS Invoice_Date
    ,b.payment_date AS Payment_Date
    ,a.Invoice_Payment_Amount_CAD AS Payment_Amount_CAD
    ,a.Invoice_Payment_Discount_Lost_Amt_CAD AS Discount_Lost_CAD
    ,c.Invoice_Currency AS Invoice_Currency
    ,c.Invoice_Amount AS Invoice_Amount
    ,a.Invoice_Payment_Discount_Lost AS Discount_Lost
    ,f.AGREEMENT_TYPE_NAME AS Agreement_Type
    ,IFF(c.INVOICE_DATE >= f.Effective_Date 
        AND c.INVOICE_DATE <= f.Expiry_Date 
        , 'yes','no') AS Agreement_Is_Template_Canam
    ,c.Invoice_Code
    ,a.Supplier_Payment_Detail_sk
    ,b.Supplier_Payment_sk
    ,c.Supplier_Purchase_Invoice_sk
FROM 
    {{ ref ('sche_fact_Supplier_Payment_Detail') }} a
LEFT JOIN 
    {{ ref ('sche_fact_Supplier_Payment') }} b
    ON a.Supplier_Payment_sk = b.Supplier_Payment_sk
LEFT JOIN 
    {{ ref ('sche_fact_Purchase_Invoice') }} c
    ON a.Supplier_Purchase_Invoice_sk = c.Supplier_Purchase_Invoice_sk
LEFT JOIN 
    {{ ref ('sche_dim_Pay_To_Profile') }} d
    ON a.PT_PROFILE_SK = d.PT_PROFILE_SK
LEFT JOIN 
    {{ ref ('sche_dim_Supplier') }} e
    ON b.supplier_sk = e.supplier_sk
LEFT JOIN 
    Supplier_Agreement f
    ON e.Supplier_Number = TRY_TO_NUMBER(f.Supplier_Number)
    AND UPPER(f.AGREEMENT_TYPE_NAME) = 'ENTENTE CADRE / FRAMEWORK AGREEMENT (FWK)'
    AND c.INVOICE_DATE BETWEEN f.Effective_Date AND f.Expiry_Date
WHERE 
    b.Payment_Status <> 'VOIDED'
    AND c.Invoice_Type <> 'CREDIT'