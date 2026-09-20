{{
  config(
    full_refresh = true,
    materialized="dynamic_table",
    target_lag="24hour",
    snowflake_warehouse= var('task_warehouse'),
    alias = "project_event",
    schema= "dataproducts_gold",
    post_hook = "ALTER DYNAMIC TABLE {{ this }} SET LOG_LEVEL = ERROR"
  )
}}

WITH Region_Mapping (Site_Code, Region_Fr, Region_En) AS (
    SELECT '1C1', 'EST', 'EASTERN' UNION ALL
    SELECT '1C2', 'EST', 'EASTERN' UNION ALL
    SELECT '1C3', 'EST', 'EASTERN' UNION ALL
    SELECT '1C4', 'CENTRE', 'CENTRAL' UNION ALL
    SELECT '1C5', 'OUEST', 'WESTERN'
),
Project_Amounts_CAD AS (
    SELECT
        t0.Project_Event_Detail_Sk,
        T0.ADDITIONAL_COST_AMOUNT * T11.EXCHANGE_RATE AS ADDITIONAL_COST_AMOUNT_CAD,
        T0.PROVISION_AMOUNT * T11.EXCHANGE_RATE AS PROVISION_AMOUNT_CAD,
        T0.TRANSACTION_AMOUNT * T11.EXCHANGE_RATE AS PAYMENT_CREDIT_AMOUNT_CAD
    FROM
        {{ref("sche_fact_Project_Event_Detail")}} t0
    LEFT JOIN {{ref("sche_dim_Project")}} t1
        ON t0.Project_Sk = t1.Project_Sk
    LEFT JOIN {{ref("sche_fact_Exchange_Rate")}} t11
        ON T0.PROJECT_SK = T11.PROJECT_SK
        AND T0.AMOUNT_CURRENCY_SK = T11.FROM_CURRENCY_SK 
        AND T0.TO_CURRENCY_CAD_SK = T11.TO_CURRENCY_SK
)
SELECT
    t1.Project_Code,
    t2.Customer_Code || ' | ' || t2.Customer_Name AS Customer,
    IFNULL(t3.Given_Name || ' ' || t3.Family_Name, 'Unknown') AS Project_Manager,
    Event_Type_FR.NAME AS Event_Type_FR,
    Event_Type_EN.NAME AS Event_Type_EN,
    Project_Step_FR.NAME AS Project_Step_Fr,
    Project_Step_EN.NAME AS Project_Step_En,
    IFNULL(RM.Region_Fr, 'AUTRE') AS Region_Fr,
    IFNULL(RM.Region_En, 'OTHER') AS Region_En,
    NULLIF(
        CONCAT(
            IFNULL(t0.Location_Site_Code, ''),
            IFF(t0.Location_Site_Code IS NULL OR t12.Name IS NULL, '', ' | '),
            IFNULL(t12.Name, '')
        ),
        ''
    ) AS Location_Site ,
    p.Additional_Cost_Amount_CAD,
    p.Provision_Amount_CAD,
    IFNULL(
        t15.Supplier_Number || ' | ' || t15.Supplier_Name,
        t14.Customer_Code || ' | ' || t14.Customer_Name
    ) AS Payment_To,
    CASE
        WHEN t13.supplier_sk IS NOT NULL THEN 'Supplier'
        WHEN t13.customer_sk IS NOT NULL THEN 'Customer'
        ELSE INITCAP(t7.TRANSACTION_TYPE_CODE)
    END AS Credit_Payment_Type,
    p.Payment_Credit_Amount_CAD,
    ZEROIFNULL(p.Provision_Amount_CAD) + ZEROIFNULL(p.Additional_Cost_Amount_CAD) - (ZEROIFNULL(p.Provision_Amount_CAD) - ZEROIFNULL(p.Payment_Credit_Amount_CAD)) AS Backcharge_Amount_CAD, 
    ZEROIFNULL(p.Provision_Amount_CAD) - ZEROIFNULL(p.Payment_Credit_Amount_CAD) AS Amount_To_Be_Released_CAD,

    t10.Full_Date AS Approval_Date,
    t7_fr.NAME AS Transaction_Transfer_Status_Fr,
    t7_en.NAME AS Transaction_Transfer_Status_En

FROM
    {{ref("sche_fact_Project_Event_Detail")}} t0
LEFT JOIN Project_Amounts_CAD p
    ON t0.Project_Event_Detail_Sk = p.Project_Event_Detail_Sk
LEFT JOIN {{ref("sche_dim_Project")}} t1
    ON t0.Project_Sk = t1.Project_Sk
LEFT JOIN {{ref("sche_dim_Customer")}} t2
    ON t0.project_customer_sk = t2.Customer_Sk
LEFT JOIN {{ref("sche_dim_Employee")}} t3
    ON t0.Project_Manager_Sk = t3.Employee_Sk
LEFT JOIN {{ref("sche_dim_Event_Type")}} t6
    ON t0.Event_Type_Sk = t6.Event_Type_Sk
LEFT JOIN {{ref("sche_dim_Project_Event")}} t7
    ON t0.Project_Event_Sk = t7.Project_Event_Sk
LEFT JOIN {{ref("sche_dim_Date")}} t10
    ON t7.Provision_Transfer_Date_Key = t10.Date_Key

-- RDM Descriptions Joins
LEFT JOIN {{ref("norm_descriptions")}} Event_Type_FR
    ON Event_Type_FR.VALUE = t6.EVENT_NAME_CODE
    AND Event_Type_FR.LANGUAGE = 'FR'
    AND Event_Type_FR.DOMAINCODE = 'EventName'
LEFT JOIN {{ref("norm_descriptions")}} Event_Type_EN
    ON Event_Type_EN.VALUE = t6.EVENT_NAME_CODE
    AND Event_Type_EN.LANGUAGE = 'EN'
    AND Event_Type_EN.DOMAINCODE = 'EventName'
LEFT JOIN {{ref("norm_descriptions")}} Project_Step_FR
    ON Project_Step_FR.VALUE = t6.PROJECT_STEP_CODE
    AND Project_Step_FR.LANGUAGE = 'FR'
    AND Project_Step_FR.DOMAINCODE = 'ProjectStep'
LEFT JOIN {{ref("norm_descriptions")}} Project_Step_EN
    ON Project_Step_EN.VALUE = t6.PROJECT_STEP_CODE
    AND Project_Step_EN.LANGUAGE = 'EN'
    AND Project_Step_EN.DOMAINCODE = 'ProjectStep'
LEFT JOIN {{ref("norm_descriptions")}} t7_fr
    ON t7_fr.VALUE = t7.Transaction_Transfer_Status_Code
    AND t7_fr.LANGUAGE = 'FR'
    AND t7_fr.DOMAINCODE = 'TransactionTransfertStatus'
LEFT JOIN {{ref("norm_descriptions")}} t7_en
    ON t7_en.VALUE = t7.Transaction_Transfer_Status_Code
    AND t7_en.LANGUAGE = 'EN'
    AND t7_en.DOMAINCODE = 'TransactionTransfertStatus'

LEFT JOIN Region_Mapping RM
    ON t0.Location_Site_Code = RM.Site_Code

LEFT JOIN {{ref("norm_manual_entity_descriptions")}} t12
    ON t0.Location_Site_Code = t12.Entity_Code

LEFT JOIN {{ref('sche_dim_Payment_To')}} t13
    ON t0.payment_to_sk = t13.payment_to_sk
LEFT JOIN {{ref('sche_dim_Customer')}} t14
    ON t13.CUSTOMER_SK = t14.CUSTOMER_SK
LEFT JOIN {{ref('sche_dim_Supplier')}} t15
    ON t13.supplier_sk = t15.supplier_sk
-- transfer_oracle or APPRORA (rdm value) status only
WHERE UPPER(t7.Provision_Transfer_Status_Code) = 'APPRORA'

