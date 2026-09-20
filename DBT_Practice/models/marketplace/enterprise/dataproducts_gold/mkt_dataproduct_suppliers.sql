{{
  config(
    full_refresh = true,
    materialized="dynamic_table",
    target_lag="24 hour",
    snowflake_warehouse= var('task_warehouse'),
    alias = "Suppliers",
    schema= "dataproducts_gold",
    post_hook = "ALTER DYNAMIC TABLE {{ this }} SET LOG_LEVEL = ERROR"
  
  )
}}

WITH Suppliers AS (
    SELECT 
        Company_Code,
        Nature_of_Supply_Name AS Nature_of_Supply,
        Supplier_Number,
        Supplier_SK,
        Supplier_Status_Code AS Supplier_Status,
        Country,
        Administrative_Area,
        Locality,
        Route,
        PO_Box_Number,
        Postal_Code
    FROM {{ ref('sche_dim_Supplier') }}
),
payment_methods AS (
    SELECT Business_Application_Value, STANDARD_APPLICATION_VALUE_NAME_EN, STANDARD_APPLICATION_VALUE_NAME_FR
    FROM {{ref('gov_referencedata_rdm')}}
    WHERE Business_Application_Code = 'oracle-ebs' AND Standard_Domain_Application_Code = 'PaymentMethod'
),
payment_terms AS (
    SELECT Standard_Application_Value, STANDARD_APPLICATION_VALUE_NAME_EN, STANDARD_APPLICATION_VALUE_NAME_FR
    FROM {{ref('gov_referencedata_rdm')}}
    WHERE Business_Application_Code = 'oracle-ebs' AND Standard_Domain_Application_Code = 'PaymentTerm'
),
profiles AS (
    SELECT
        Supplier_SK,
        'PayTo' AS Profile_Type,
        PT_Profile_Code AS Profile_Code,
        PT_Currency_Code AS Profile_Currency,
        PT_NAME AS Profile_Name,
        PT_PAYMENT_METHOD_CODE AS Payment_Method_Code,
        PT_PAYMENT_TERM_CODE AS Payment_Term_Code,
        PT_Status_Code AS Status_Code,
        PT_Country AS Profile_Location_Country,
        PT_Administrative_Area AS Profile_Location_Administrative_Area,
        PT_Locality AS Profile_Location_Locality,
        PT_Route AS Profile_Location_Route,
        PT_Status_Code AS Profile_Location_Status,
        PT_PO_Box_Number AS Profile_Location_PO_Box_Number,
        PT_Postal_Code AS Profile_Location_Postal_Code
    FROM {{ ref('sche_dim_Pay_To_Profile') }}

    UNION ALL

    SELECT
        Supplier_SK,
        'InvoiceFrom' AS Profile_Type,
        IF_Profile_Code,
        IF_Currency_Code,
        IF_Name,
        IF_PAYMENT_METHOD_CODE,
        IF_PAYMENT_TERM_CODE,
        IF_Status_Code,
        IF_Country,
        IF_Administrative_Area,
        IF_Locality,
        IF_Route,
        IF_Status_Code,
        IF_PO_Box_Number,
        IF_Postal_Code
    FROM {{ ref('sche_dim_Invoice_From_Profile') }}
)
SELECT
    S.*,
    P.Profile_Type,
    P.Profile_Code,
    P.Profile_Currency,
    P.Profile_Name,
    PM.STANDARD_APPLICATION_VALUE_NAME_EN AS Profile_Payment_Method_English,
    PM.STANDARD_APPLICATION_VALUE_NAME_FR AS Profile_Payment_Method_French,
    PT.STANDARD_APPLICATION_VALUE_NAME_EN AS Profile_Payment_Term_English,
    PT.STANDARD_APPLICATION_VALUE_NAME_FR AS Profile_Payment_Term_French,
    CASE S.Supplier_Status WHEN 'Inactive' THEN 'Inactive' ELSE P.Status_Code END AS Profile_Status,
    P.Profile_Location_Country,
    P.Profile_Location_Administrative_Area,
    P.Profile_Location_Locality,
    P.Profile_Location_Route,
    P.Profile_Location_Status,
    P.Profile_Location_PO_Box_Number,
    P.Profile_Location_Postal_Code
FROM Suppliers S
LEFT JOIN profiles P ON S.Supplier_SK = P.Supplier_SK
LEFT JOIN payment_methods PM ON P.Payment_Method_Code = PM.Business_Application_Value
LEFT JOIN payment_terms PT ON P.Payment_Term_Code = PT.Standard_Application_Value