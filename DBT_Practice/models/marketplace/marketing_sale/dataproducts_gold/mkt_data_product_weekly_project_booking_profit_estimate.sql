{{
  config(
    full_refresh = true,
    materialized="dynamic_table",
    target_lag="24 hour",
    snowflake_warehouse= var('task_warehouse'),
    alias = "weekly_project_booking_profit_estimate",
    schema= "dataproducts_gold",
    post_hook = "ALTER DYNAMIC TABLE {{ this }} SET LOG_LEVEL = ERROR"
  )
}}

WITH SS_WEEKLY_DIM_DATE AS
(   
    SELECT 
        DATE_KEY,
        CANAM_WEEK_START_DATE,
        CANAM_WEEK_NUMBER,
        CALENDAR_MONTH_NUMBER,
        CALENDAR_MONTH_NAME_EN,
        CALENDAR_YEAR,
        FISCAL_PERIOD_NUMBER,
        FISCAL_PERIOD_NAME,
        FISCAL_YEAR     
    FROM {{ref('sche_dim_Date')}}
    WHERE FULL_DATE BETWEEN NEXT_DAY(DATEADD(YEAR, -2, DATE_TRUNC('YEAR', CURRENT_DATE())) - 1, 'SUNDAY') AND PREVIOUS_DAY(CURRENT_DATE(), 'SATURDAY')
), SS_WEEKLY_PROJECT_BOOKING_AND_PROFIT_ESTIMATE AS
(
SELECT 
    SWDD.CANAM_WEEK_START_DATE                                                      AS CANAM_WEEK_START_DATE,
    SWDD.CANAM_WEEK_NUMBER                                                          AS CANAM_WEEK_NUMBER,
    SWDD.CALENDAR_MONTH_NUMBER                                                      AS CALENDAR_MONTH_NUMBER,
    SWDD.CALENDAR_MONTH_NAME_EN                                                     AS CALENDAR_MONTH_NAME_EN,
    SWDD.CALENDAR_YEAR                                                              AS CALENDAR_YEAR,
    SWDD.FISCAL_PERIOD_NUMBER                                                       AS FISCAL_PERIOD_NUMBER,
    SWDD.FISCAL_PERIOD_NAME                                                         AS FISCAL_PERIOD_NAME,
    SWDD.FISCAL_YEAR                                                                AS FISCAL_YEAR,
    DBU.BUSINESS_UNIT_CODE                                                          AS BUSINESS_UNIT_CODE,
    DBU.BUSINESS_UNIT_NAME_FR                                                       AS BUSINESS_UNIT_NAME_FR,
    DBU.BUSINESS_UNIT_NAME_EN                                                       AS BUSINESS_UNIT_NAME_EN,
    UPPER(TRIM(DSO.SALES_OFFICE_DEPARTMENT_CODE))                                   AS SALES_OFFICE_DEPARTMENT_CODE,
    UPPER(TRIM(DSO.SALES_OFFICE_DEPARTMENT_NAME_EN))                                   AS SALES_OFFICE_DEPARTMENT_NAME,
    UPPER(TRIM(DSBO.SALES_BRANCH_OFFICE_DEPARTMENT_NAME_EN))                     AS SALES_BRANCH_OFFICE_DEPARTMENT_GROUP_NAME,
    DSO.SALES_OFFICE_DEPARTMENT_COUNTRY_CODE                                        AS SALES_OFFICE_DEPARTMENT_COUNTRY_CODE,
    UPPER(TRIM(DSBO.SALES_BRANCH_OFFICE_DEPARTMENT_CODE))                           AS SALES_BRANCH_OFFICE_DEPARTMENT_CODE,
    UPPER(TRIM(DSBO.SALES_BRANCH_OFFICE_DEPARTMENT_NAME_EN))                           AS SALES_BRANCH_OFFICE_DEPARTMENT_NAME,
    DCU_FROM.CURRENCY_CODE                                                          AS ORIGINAL_CURRENCY_CODE,
    'NO BUDGET VARIATION'                                                           AS BUDGET_VARIATION_TYPE_NAME,
    DP.PROJECT_CODE                                                                 AS PROJECT_CODE,
    DP.PROJECT_NAME_EN                                                              AS PROJECT_NAME,
    DP.PROJECT_START_DATE                                                           AS PROJECT_START_DATE,
    DP.PROJECT_STATUS_CODE                                                          AS PROJECT_STATUS_CODE,
    DP.PROJECT_TYPE_CODE                                                            AS PROJECT_TYPE_CODE,
    DP.PROJECT_PACKAGE_STATUS_CODE                                                  AS PROJECT_PACKAGE_STATUS_CODE,
    DP.PROJECT_SHIPPING_CITY_CODE                                                   AS PROJECT_CITY_CODE,
    DP.PROJECT_SHIPPING_STATE_CODE                                                  AS PROJECT_STATE_CODE,
    DP.PROJECT_SHIPPING_COUNTRY_CODE                                                AS PROJECT_COUNTRY_CODE,
    DC.CUSTOMER_NAME                                                                AS CUSTOMER_NAME,
    DC.CUSTOMER_CODE                                                          AS CUSTOMER_CLASS_CODE,
    DC.BUSINESS_PARTNER_NAME                                                        AS BUSINESS_PARTNER_CUSTOMER_NAME,
    DI.ITEM_SALES_GROUP_CODE                                                        AS ITEM_SALES_GROUP_CODE,
    CASE WHEN DI.ITEM_CODE LIKE '160.%' 
        THEN DI.ITEM_NAME_EN
        ELSE DI.ITEM_SALES_GROUP_CODE
    END                                                                             AS ITEM_NAME_GROUP,
    IFNULL(SUM(FPA.DIRECT_TIME_ORIGINAL_BUDGET/60),0)                               AS DIRECT_TIME_HR,
    IFNULL(SUM(FPA.INDIRECT_TIME_ORIGINAL_BUDGET/60),0)                             AS INDIRECT_TIME_HR,
    IFNULL(SUM(FPA.WEIGHT_ORIGINAL_BUDGET),0)                                       AS SALES_WEIGHT_LB,
    IFNULL(SUM(FPA.WEIGHT_ORIGINAL_BUDGET/2000),0)                                  AS SALES_WEIGHT_T,
    IFNULL(SUM(FPA.AREA_ORIGINAL_BUDGET),0)                                         AS SALES_AREA_SF,
    IFNULL(SUM(FPA.SOLD_PRICE_ORIGINAL_BUDGET*FER.EXCHANGE_RATE),0)                 AS SALES_AMOUNT_CAD,
    IFNULL(SUM(FPA.MATERIAL_COST_ORIGINAL_BUDGET_AMOUNT),0)                         AS MATERIAL_COST_AMOUNT_CAD,
    IFNULL(SUM(FPA.FABRICATION_COST_ORIGINAL_BUDGET_AMOUNT),0)                      AS FABRICATION_COST_AMOUNT_CAD,
    IFNULL(SUM(FPA.LABOR_COST_ORIGINAL_BUDGET_AMOUNT),0)                            AS LABOR_COST_AMOUNT_CAD,
    IFNULL(SUM(FPA.SOLD_PRICE_ORIGINAL_BUDGET*FER.EXCHANGE_RATE),0) - 
        SUM(IFNULL(FPA.MATERIAL_COST_ORIGINAL_BUDGET_AMOUNT,0) + 
            IFNULL(FPA.FABRICATION_COST_ORIGINAL_BUDGET_AMOUNT,0) + 
            IFNULL(FPA.LABOR_COST_ORIGINAL_BUDGET_AMOUNT,0))                        AS SALES_PROFIT_ESTIMATE_AMOUNT_CAD
FROM SS_WEEKLY_DIM_DATE SWDD
    LEFT JOIN {{ref('sche_fact_Project_Activity')}}  FPA ON SWDD.DATE_KEY = FPA.PROJECT_START_DATE_KEY
    LEFT JOIN {{ref('sche_dim_Date')}}  DD ON FPA.PROJECT_START_DATE_KEY = DD.DATE_KEY
    LEFT JOIN {{ref('sche_dim_Project')}} DP ON FPA.PROJECT_SK = DP.PROJECT_SK
    LEFT JOIN {{ref('sche_dim_Business_Unit')}} DBU ON FPA.BUSINESS_UNIT_SK = DBU.BUSINESS_UNIT_SK
    LEFT JOIN {{ref('sche_dim_Sales_Office')}} DSO ON FPA.SALES_OFFICE_SK = DSO.SALES_OFFICE_SK
    LEFT JOIN {{ref('sche_dim_Sales_Branch_Office')}} DSBO ON FPA.SALES_BRANCH_OFFICE_SK = DSBO.SALES_BRANCH_OFFICE_SK
    LEFT JOIN {{ref('sche_dim_Item')}} DI ON FPA.ITEM_SK = DI.ITEM_SK
    LEFT JOIN {{ref('sche_dim_Customer')}} DC ON FPA.SOLD_TO_CUSTOMER_SK = DC.CUSTOMER_SK
    LEFT JOIN {{ref('sche_dim_Currency')}} DCU_FROM ON FPA.PRICE_AND_COST_ORIGINAL_BUDGET_CURRENCY_SK = DCU_FROM.CURRENCY_SK
    LEFT JOIN {{ref('sche_dim_Currency')}} DCU_TO ON FPA.TO_CURRENCY_CAD_SK = DCU_TO.CURRENCY_SK
    LEFT JOIN {{ref('sche_dim_Exchange_Rate_Type')}} DERT ON FPA.FISCAL_PERIOD_END_AVG_EXCHANGE_RATE_TYPE_SK = DERT.EXCHANGE_RATE_TYPE_SK
    LEFT JOIN {{ref('sche_fact_Exchange_Rate')}} FER ON DCU_FROM.CURRENCY_SK = FER.FROM_CURRENCY_SK AND DCU_TO.CURRENCY_SK = FER.TO_CURRENCY_SK
            AND DD.DATE_KEY = FER.EXCHANGE_RATE_DATE_KEY AND DERT.EXCHANGE_RATE_TYPE_SK = FER.EXCHANGE_RATE_TYPE_SK
WHERE DI.ITEM_CODE <> 'N/A' 
GROUP BY 
    SWDD.CANAM_WEEK_START_DATE,  
    SWDD.CANAM_WEEK_NUMBER,
    SWDD.CALENDAR_MONTH_NUMBER,
    SWDD.CALENDAR_MONTH_NAME_EN,
    SWDD.CALENDAR_YEAR,
    SWDD.FISCAL_PERIOD_NUMBER,
    SWDD.FISCAL_PERIOD_NAME,
    SWDD.FISCAL_YEAR,
    DBU.BUSINESS_UNIT_CODE,
    BUSINESS_UNIT_NAME_FR,
    BUSINESS_UNIT_NAME_EN,
    DSO.SALES_OFFICE_DEPARTMENT_CODE,
    SALES_OFFICE_DEPARTMENT_NAME,
    SALES_BRANCH_OFFICE_DEPARTMENT_GROUP_NAME,
    SALES_OFFICE_DEPARTMENT_COUNTRY_CODE,
    SALES_BRANCH_OFFICE_DEPARTMENT_CODE,
    SALES_BRANCH_OFFICE_DEPARTMENT_NAME,
    ORIGINAL_CURRENCY_CODE,
    BUDGET_VARIATION_TYPE_NAME,
    PROJECT_CODE,
    PROJECT_NAME,
    PROJECT_START_DATE,
    PROJECT_STATUS_CODE,
    PROJECT_TYPE_CODE,
    PROJECT_PACKAGE_STATUS_CODE,
    PROJECT_CITY_CODE,
    PROJECT_STATE_CODE,
    PROJECT_COUNTRY_CODE,
    CUSTOMER_NAME,
    CUSTOMER_CLASS_CODE,
    BUSINESS_PARTNER_NAME,
    ITEM_SALES_GROUP_CODE,
    ITEM_NAME_GROUP

UNION ALL

SELECT 
    SWDD.CANAM_WEEK_START_DATE                                                      AS CANAM_WEEK_START_DATE,
    SWDD.CANAM_WEEK_NUMBER                                                          AS CANAM_WEEK_NUMBER,
    SWDD.CALENDAR_MONTH_NUMBER                                                      AS CALENDAR_MONTH_NUMBER,
    SWDD.CALENDAR_MONTH_NAME_EN                                                     AS CALENDAR_MONTH_NAME_EN,
    SWDD.CALENDAR_YEAR                                                              AS CALENDAR_YEAR,
    SWDD.FISCAL_PERIOD_NUMBER                                                       AS FISCAL_PERIOD_NUMBER,
    SWDD.FISCAL_PERIOD_NAME                                                         AS FISCAL_PERIOD_NAME,
    SWDD.FISCAL_YEAR                                                                AS FISCAL_YEAR,
    DBU.BUSINESS_UNIT_CODE                                                          AS BUSINESS_UNIT_CODE,
    DBU.BUSINESS_UNIT_NAME_FR                                                       AS BUSINESS_UNIT_NAME_FR,
    DBU.BUSINESS_UNIT_NAME_EN                                                       AS BUSINESS_UNIT_NAME_EN,
    UPPER(TRIM(DSO.SALES_OFFICE_DEPARTMENT_CODE))                                   AS SALES_OFFICE_DEPARTMENT_CODE,
    UPPER(TRIM(DSO.SALES_OFFICE_DEPARTMENT_NAME_EN))                                   AS SALES_OFFICE_DEPARTMENT_NAME,
    UPPER(TRIM(DSBO.SALES_BRANCH_OFFICE_DEPARTMENT_NAME_EN))                     AS SALES_BRANCH_OFFICE_DEPARTMENT_GROUP_NAME,
    DSO.SALES_OFFICE_DEPARTMENT_COUNTRY_CODE                                        AS SALES_OFFICE_DEPARTMENT_COUNTRY_CODE,
    UPPER(TRIM(DSBO.SALES_BRANCH_OFFICE_DEPARTMENT_CODE))                           AS SALES_BRANCH_OFFICE_DEPARTMENT_CODE,
    UPPER(TRIM(DSBO.SALES_BRANCH_OFFICE_DEPARTMENT_NAME_EN))                           AS SALES_BRANCH_OFFICE_DEPARTMENT_NAME,
    DCU_FROM.CURRENCY_CODE                                                          AS ORIGINAL_CURRENCY_CODE,
    CASE FPABV.BUDGET_VARIATION_TYPE_CODE
        WHEN 'E' THEN 'EXTRA/CREDIT'
        WHEN 'P' THEN 'PERMUTATION'
        WHEN 'A' THEN 'MANUAL ADJUSTMENT'
        WHEN 'C' THEN 'CANCELLATION'
        WHEN 'T' THEN 'PROJECT TRANSFER'
        ELSE 'NOT FOUND' 
    END                                                                             AS BUDGET_VARIATION_TYPE_NAME,
    DP.PROJECT_CODE                                                                 AS PROJECT_CODE,
    DP.PROJECT_NAME_EN                                                              AS PROJECT_NAME,
    DP.PROJECT_START_DATE                                                           AS PROJECT_START_DATE,
    DP.PROJECT_STATUS_CODE                                                          AS PROJECT_STATUS_CODE,
    DP.PROJECT_TYPE_CODE                                                            AS PROJECT_TYPE_CODE, 
    DP.PROJECT_PACKAGE_STATUS_CODE                                                  AS PROJECT_PACKAGE_STATUS_CODE,
    DP.PROJECT_SHIPPING_CITY_CODE                                                   AS PROJECT_CITY_CODE,
    DP.PROJECT_SHIPPING_STATE_CODE                                                  AS PROJECT_STATE_CODE,
    DP.PROJECT_SHIPPING_COUNTRY_CODE                                                AS PROJECT_COUNTRY_CODE,
    DC.CUSTOMER_NAME                                                                AS CUSTOMER_NAME,
    DC.CUSTOMER_CODE                                                          AS CUSTOMER_CLASS_CODE,
    DC.BUSINESS_PARTNER_NAME                                                        AS BUSINESS_PARTNER_CUSTOMER_NAME,
    DI.ITEM_SALES_GROUP_CODE                                                        AS ITEM_SALES_GROUP_CODE,
    CASE WHEN DI.ITEM_CODE LIKE '160.%' 
        THEN DI.ITEM_NAME_EN
        ELSE DI.ITEM_SALES_GROUP_CODE
    END                                                                             AS ITEM_NAME_GROUP,
    IFNULL(SUM(FPABV.DIRECT_TIME_BUDGET_VARIATION/60),0)                            AS DIRECT_TIME_HR,
    IFNULL(SUM(FPABV.INDIRECT_TIME_BUDGET_VARIATION/60),0)                          AS INDIRECT_TIME_HR,
    IFNULL(SUM(FPABV.WEIGHT_BUDGET_VARIATION),0)                                    AS SALES_WEIGHT_LB,
    IFNULL(SUM(FPABV.WEIGHT_BUDGET_VARIATION/2000),0)                               AS SALES_WEIGHT_T,
    IFNULL(SUM(FPABV.AREA_BUDGET_VARIATION),0)                                      AS SALES_AREA_SF,
    IFNULL(SUM(FPABV.SOLD_PRICE_BUDGET_VARIATION*FER.EXCHANGE_RATE),0)              AS SALES_AMOUNT_CAD,
    IFNULL(SUM(FPABV.MATERIAL_COST_BUDGET_VARIATION_AMOUNT),0)                      AS MATERIAL_COST_AMOUNT_CAD,
    IFNULL(SUM(FPABV.FABRICATION_COST_BUDGET_VARIATION_AMOUNT),0)                   AS FABRICATION_COST_AMOUNT_CAD,
    IFNULL(SUM(FPABV.LABOR_COST_BUDGET_VARIATION_AMOUNT),0)                         AS LABOR_COST_AMOUNT_CAD,
    IFNULL(SUM(FPABV.SOLD_PRICE_BUDGET_VARIATION*FER.EXCHANGE_RATE),0) - 
        SUM(IFNULL(FPABV.MATERIAL_COST_BUDGET_VARIATION_AMOUNT,0) + 
            IFNULL(FPABV.FABRICATION_COST_BUDGET_VARIATION_AMOUNT,0) + 
            IFNULL(FPABV.LABOR_COST_BUDGET_VARIATION_AMOUNT,0))                     AS SALES_PROFIT_ESTIMATE_AMOUNT_CAD
FROM SS_WEEKLY_DIM_DATE SWDD
    LEFT JOIN {{ref('sche_fact_Project_Activity_Budget_Variation')}} FPABV ON SWDD.DATE_KEY = FPABV.BUDGET_VARIATION_DATE_KEY
    LEFT JOIN {{ref('sche_dim_Date')}} DD ON FPABV.BUDGET_VARIATION_DATE_KEY = DD.DATE_KEY
    LEFT JOIN {{ref('sche_dim_Project')}}  DP ON FPABV.PROJECT_SK = DP.PROJECT_SK
    LEFT JOIN {{ref('sche_dim_Business_Unit')}} DBU ON FPABV.BUSINESS_UNIT_SK = DBU.BUSINESS_UNIT_SK
    LEFT JOIN {{ref('sche_dim_Sales_Office')}} DSO ON FPABV.SALES_OFFICE_SK = DSO.SALES_OFFICE_SK
    LEFT JOIN {{ref('sche_dim_Sales_Branch_Office')}} DSBO ON FPABV.SALES_BRANCH_OFFICE_SK = DSBO.SALES_BRANCH_OFFICE_SK
    LEFT JOIN {{ref('sche_dim_Item')}} DI ON FPABV.ITEM_SK = DI.ITEM_SK
    LEFT JOIN {{ref('sche_dim_Customer')}} DC ON FPABV.SOLD_TO_CUSTOMER_SK = DC.CUSTOMER_SK
    LEFT JOIN {{ref('sche_dim_Currency')}} DCU_FROM ON FPABV.PRICE_AND_COST_BUDGET_VARIATION_CURRENCY_SK = DCU_FROM.CURRENCY_SK
    LEFT JOIN {{ref('sche_dim_Currency')}} DCU_TO ON FPABV.TO_CURRENCY_CAD_SK = DCU_TO.CURRENCY_SK
    LEFT JOIN {{ref('sche_dim_Exchange_Rate_Type')}} DERT ON FPABV.FISCAL_PERIOD_END_AVG_EXCHANGE_RATE_TYPE_SK = DERT.EXCHANGE_RATE_TYPE_SK
    LEFT JOIN {{ref('sche_fact_Exchange_Rate')}} FER ON DCU_FROM.CURRENCY_SK = FER.FROM_CURRENCY_SK AND DCU_TO.CURRENCY_SK = FER.TO_CURRENCY_SK
            AND DD.DATE_KEY = FER.EXCHANGE_RATE_DATE_KEY AND DERT.EXCHANGE_RATE_TYPE_SK = FER.EXCHANGE_RATE_TYPE_SK
WHERE DI.ITEM_CODE <> 'N/A' 
GROUP BY 
    SWDD.CANAM_WEEK_START_DATE,  
    SWDD.CANAM_WEEK_NUMBER,
    SWDD.CALENDAR_MONTH_NUMBER,
    SWDD.CALENDAR_MONTH_NAME_EN,
    SWDD.CALENDAR_YEAR,
    SWDD.FISCAL_PERIOD_NUMBER,
    SWDD.FISCAL_PERIOD_NAME,
    SWDD.FISCAL_YEAR,
    DBU.BUSINESS_UNIT_CODE,
    BUSINESS_UNIT_NAME_FR,
    BUSINESS_UNIT_NAME_EN,
    DSO.SALES_OFFICE_DEPARTMENT_CODE,
    SALES_OFFICE_DEPARTMENT_NAME,
    SALES_BRANCH_OFFICE_DEPARTMENT_GROUP_NAME,
    SALES_OFFICE_DEPARTMENT_COUNTRY_CODE,
    SALES_BRANCH_OFFICE_DEPARTMENT_CODE,
    SALES_BRANCH_OFFICE_DEPARTMENT_NAME,
    ORIGINAL_CURRENCY_CODE,
    BUDGET_VARIATION_TYPE_NAME,
    PROJECT_CODE,
    PROJECT_NAME,
    PROJECT_START_DATE,
    PROJECT_STATUS_CODE,
    PROJECT_TYPE_CODE,
    PROJECT_PACKAGE_STATUS_CODE,
    PROJECT_CITY_CODE,
    PROJECT_STATE_CODE,
    PROJECT_COUNTRY_CODE,
    CUSTOMER_NAME,
    CUSTOMER_CLASS_CODE,
    BUSINESS_PARTNER_NAME,
    ITEM_SALES_GROUP_CODE,
    ITEM_NAME_GROUP
)

SELECT 
    CANAM_WEEK_START_DATE::DATE                                         AS CANAM_WEEK_START_DATE,
    CANAM_WEEK_NUMBER::INTEGER                                          AS CANAM_WEEK_NUMBER,
    CALENDAR_MONTH_NUMBER::INTEGER                                      AS CALENDAR_MONTH_NUMBER,
    CALENDAR_MONTH_NAME_EN::STRING                                      AS CALENDAR_MONTH_NAME_EN,
    CALENDAR_YEAR::STRING                                               AS CALENDAR_YEAR,
    FISCAL_PERIOD_NUMBER::INTEGER                                       AS FISCAL_PERIOD_NUMBER,
    FISCAL_PERIOD_NAME::STRING                                          AS FISCAL_PERIOD_NAME,
    FISCAL_YEAR::INTEGER                                                AS FISCAL_YEAR,
    BUSINESS_UNIT_CODE::STRING                                          AS BUSINESS_UNIT_CODE,
    BUSINESS_UNIT_NAME_FR::STRING                                       AS BUSINESS_UNIT_NAME_FR,
    BUSINESS_UNIT_NAME_EN::STRING                                       AS BUSINESS_UNIT_NAME_EN,
    UPPER(TRIM(SALES_OFFICE_DEPARTMENT_CODE))::STRING                   AS SALES_OFFICE_DEPARTMENT_CODE,
    UPPER(TRIM(SALES_OFFICE_DEPARTMENT_NAME))::STRING                   AS SALES_OFFICE_DEPARTMENT_NAME,
    UPPER(TRIM(SALES_BRANCH_OFFICE_DEPARTMENT_GROUP_NAME))::STRING      AS SALES_BRANCH_OFFICE_DEPARTMENT_GROUP_NAME,
    SALES_OFFICE_DEPARTMENT_COUNTRY_CODE::STRING                        AS SALES_OFFICE_DEPARTMENT_COUNTRY_CODE,
    SALES_BRANCH_OFFICE_DEPARTMENT_CODE::STRING                         AS SALES_BRANCH_OFFICE_DEPARTMENT_CODE,
    SALES_BRANCH_OFFICE_DEPARTMENT_NAME::STRING                         AS SALES_BRANCH_OFFICE_DEPARTMENT_NAME,
    ORIGINAL_CURRENCY_CODE::STRING                                      AS ORIGINAL_CURRENCY_CODE,
    BUDGET_VARIATION_TYPE_NAME::STRING                                  AS BUDGET_VARIATION_TYPE_NAME,
    PROJECT_CODE::STRING                                                AS PROJECT_CODE,
    PROJECT_NAME::STRING                                                AS PROJECT_NAME,
    PROJECT_START_DATE::DATE                                            AS PROJECT_START_DATE,
    PROJECT_STATUS_CODE::STRING                                         AS PROJECT_STATUS_CODE,
    PROJECT_TYPE_CODE::STRING                                           AS PROJECT_TYPE_CODE,
    PROJECT_PACKAGE_STATUS_CODE::STRING                                 AS PROJECT_PACKAGE_STATUS_CODE,
    PROJECT_CITY_CODE::STRING                                           AS PROJECT_CITY_CODE,
    PROJECT_STATE_CODE::STRING                                          AS PROJECT_STATE_CODE,
    PROJECT_COUNTRY_CODE::STRING                                        AS PROJECT_COUNTRY_CODE,
    CUSTOMER_NAME::STRING                                               AS CUSTOMER_NAME,
    CUSTOMER_CLASS_CODE::STRING                                         AS CUSTOMER_CLASS_CODE,
    BUSINESS_PARTNER_CUSTOMER_NAME::STRING                              AS BUSINESS_PARTNER_CUSTOMER_NAME,
    ITEM_SALES_GROUP_CODE::STRING                                       AS ITEM_SALES_GROUP_CODE,
    ITEM_NAME_GROUP::STRING                                             AS ITEM_NAME_GROUP,
    DIRECT_TIME_HR::NUMBER(38, 2)                                       AS DIRECT_TIME_HR,
    INDIRECT_TIME_HR::NUMBER(38, 2)                                     AS INDIRECT_TIME_HR,
    SALES_WEIGHT_LB::NUMBER(38, 2)                                      AS SALES_WEIGHT_LB,
    SALES_WEIGHT_T::NUMBER(38, 2)                                       AS SALES_WEIGHT_T,
    SALES_AREA_SF::NUMBER(38, 2)                                        AS SALES_AREA_SF,
    SALES_AMOUNT_CAD::NUMBER(38, 2)                                     AS SALES_AMOUNT_CAD,
    MATERIAL_COST_AMOUNT_CAD::NUMBER(38, 2)                             AS MATERIAL_COST_AMOUNT_CAD,
    FABRICATION_COST_AMOUNT_CAD::NUMBER(38, 2)                          AS FABRICATION_COST_AMOUNT_CAD,
    LABOR_COST_AMOUNT_CAD::NUMBER(38, 2)                                AS LABOR_COST_AMOUNT_CAD,
    SALES_PROFIT_ESTIMATE_AMOUNT_CAD::NUMBER(38, 2)                     AS SALES_PROFIT_ESTIMATE_AMOUNT_CAD
FROM SS_WEEKLY_PROJECT_BOOKING_AND_PROFIT_ESTIMATE
WHERE DIRECT_TIME_HR <> 0 OR INDIRECT_TIME_HR <> 0 OR 
    SALES_WEIGHT_LB <> 0 OR SALES_AREA_SF <> 0 OR SALES_AMOUNT_CAD <> 0 OR 
    MATERIAL_COST_AMOUNT_CAD <> 0 OR FABRICATION_COST_AMOUNT_CAD <> 0 OR LABOR_COST_AMOUNT_CAD <> 0