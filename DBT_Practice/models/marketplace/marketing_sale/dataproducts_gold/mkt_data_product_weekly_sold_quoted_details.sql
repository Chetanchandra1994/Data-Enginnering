{{
  config(
    full_refresh = true,
    materialized="dynamic_table",
    target_lag="24 hour",
    snowflake_warehouse= var('task_warehouse'),
    alias = "weekly_sold_quoted_details",
    schema= "dataproducts_gold",
    post_hook = "ALTER DYNAMIC TABLE {{ this }} SET LOG_LEVEL = ERROR"

  )
}}

-- DATA PRODUCT : WEEKLY_SOLD_QUOTED_DETAILS

WITH SS_WEEKLY_DIM_DATE AS
(   
    SELECT 
        DATE_KEY,
        CANAM_WEEK_START_DATE,
        CANAM_WEEK_NUMBER,
        CALENDAR_YEAR,
        FISCAL_PERIOD_NUMBER,
        FISCAL_PERIOD_NAME,
        FISCAL_YEAR     
    FROM {{ref('sche_dim_Date')}}
    WHERE FULL_DATE BETWEEN NEXT_DAY(DATEADD(YEAR, -2, DATE_TRUNC('YEAR', CURRENT_DATE())) - 1, 'SUNDAY') AND PREVIOUS_DAY(CURRENT_DATE(), 'SATURDAY')
) ,SS_FACT_SALES_QUOTE_LINE_AGG AS 
(
    SELECT DISTINCT
        SALES_QUOTE_SK,
        SALES_QUOTE_CLOSING_CALENDAR_WEEK_START_DATE_KEY,
        SALES_QUOTE_CLOSING_DATE_KEY,
        ITEM_SK,
        SALES_OFFICE_SK,
        SALES_BRANCH_OFFICE_SK,
        FINANCIAL_COMPANY_SK,
        BUSINESS_UNIT_SK,
        WEIGHT_UOM_SK,
        LENGTH_UOM_SK,
        AREA_UOM_SK,
        QUANTITY_UOM_SK,
        PRICE_CURRENCY_SK,
        TO_CURRENCY_CAD_SK,
        FISCAL_PERIOD_END_AVG_EXCHANGE_RATE_TYPE_SK,
        WEIGHT,
        LENGTH,
        AREA,
        QUANTITY,
        GROSS_PRICE_LINE_AMOUNT
    FROM {{ref('sche_fact_Sales_Quote_Line')}}
), SS_FACT_SALES_QUOTE_AGG AS
(
    SELECT
        SFSQLA.SALES_QUOTE_SK,
        SFSQLA.SALES_OFFICE_SK,
        SFSQLA.SALES_BRANCH_OFFICE_SK,
        SFSQLA.FINANCIAL_COMPANY_SK,
        SFSQLA.BUSINESS_UNIT_SK,
        SFSQLA.PRICE_CURRENCY_SK,
        DSQ.SALES_QUOTE_CODE,
        DSQ.SALES_QUOTE_ALTERNATIVE_CODE,
        DD.FULL_DATE                                                AS SALES_QUOTE_CLOSING_DATE,
        DI.ITEM_SALES_GROUP_CODE                                    AS ITEM_SALES_GROUP_CODE,
        CASE WHEN DI.ITEM_CODE LIKE '160.%' 
            THEN DI.ITEM_NAME_EN
            ELSE DI.ITEM_SALES_GROUP_CODE
        END                                                         AS ITEM_NAME_GROUP,
        SUM(
            (CASE 
                WHEN DUOM.UOM_CODE = 'KG' 
                    THEN 2.2 
                ELSE 1 
            END)*SFSQLA.WEIGHT)                                     AS QUOTE_WEIGHT_LB,
        SUM(SFSQLA.AREA)                                            AS QUOTE_AREA_SF,
        SUM(SFSQLA.GROSS_PRICE_LINE_AMOUNT*FER.EXCHANGE_RATE)       AS QUOTE_AMOUNT_CAD
    FROM SS_FACT_SALES_QUOTE_LINE_AGG SFSQLA
        LEFT JOIN {{ref('sche_dim_Sales_Quote')}} DSQ ON SFSQLA.SALES_QUOTE_SK = DSQ.SALES_QUOTE_SK
        -- This join is needed because of the WHERE clause. Some attributes are not yet added in the dimensions.
        LEFT JOIN {{ref('norm_qc_quotation')}} QC ON DSQ.SALES_QUOTE_CODE = QC.MASTER_JOB_NO AND DSQ.SALES_QUOTE_ALTERNATIVE_CODE = QC.JOB_NO
            AND DSQ.SRC_OFFICE_CODE = QC.OFFICE_CODE AND UPPER(DSQ.ORIGIN_APPLICATION_CODE) = 'SPM'
        LEFT JOIN {{ref('sche_dim_Date')}} DD ON SFSQLA.SALES_QUOTE_CLOSING_DATE_KEY = DD.DATE_KEY
        LEFT JOIN {{ref('sche_dim_Date')}} DD_EXCH_RATE ON SFSQLA.SALES_QUOTE_CLOSING_CALENDAR_WEEK_START_DATE_KEY = DD_EXCH_RATE.DATE_KEY
        LEFT JOIN {{ref('sche_dim_Item')}} DI ON SFSQLA.ITEM_SK = DI.ITEM_SK
        LEFT JOIN {{ref('sche_dim_Unit_Of_Measure')}} DUOM ON SFSQLA.WEIGHT_UOM_SK = DUOM.UOM_SK
        LEFT JOIN {{ref('sche_dim_Currency')}} DCU_FROM ON SFSQLA.PRICE_CURRENCY_SK = DCU_FROM.CURRENCY_SK
        LEFT JOIN {{ref('sche_dim_Currency')}} DCU_TO ON SFSQLA.TO_CURRENCY_CAD_SK = DCU_TO.CURRENCY_SK
        LEFT JOIN {{ref('sche_dim_Exchange_Rate_Type')}} DERT ON SFSQLA.FISCAL_PERIOD_END_AVG_EXCHANGE_RATE_TYPE_SK = DERT.EXCHANGE_RATE_TYPE_SK
        LEFT JOIN {{ref('sche_fact_Exchange_Rate')}} FER ON DCU_FROM.CURRENCY_SK = FER.FROM_CURRENCY_SK AND DCU_TO.CURRENCY_SK = FER.TO_CURRENCY_SK
            AND DD_EXCH_RATE.DATE_KEY = FER.EXCHANGE_RATE_DATE_KEY AND DERT.EXCHANGE_RATE_TYPE_SK = FER.EXCHANGE_RATE_TYPE_SK
    WHERE DSQ.SALES_QUOTE_STATUS_CODE <> 'ESTS' -- Equivalent of D_QUOTATION.QUOT_PROJECT_STEP <> 'IN PROCESS'
        AND DSQ.SALES_QUOTE_ACTIVE_STATUS_CODE = 'Active' -- Equivalent of D_QUOTATION.QUOT_ACTIVE = 'Y'
        AND (QC.STATUS1 IS NULL OR QC.STATUS1 = 'R') AND QC.STATUS2 IS NULL AND QC.EXTRA_CREDIT = FALSE
        AND DI.ITEM_CODE <> 'N/A'
    GROUP BY 
        SFSQLA.SALES_QUOTE_SK,
        DSQ.SALES_QUOTE_CODE,
        DSQ.SALES_QUOTE_ALTERNATIVE_CODE,
        SFSQLA.SALES_OFFICE_SK,
        SFSQLA.SALES_BRANCH_OFFICE_SK,
        SFSQLA.FINANCIAL_COMPANY_SK,
        SFSQLA.BUSINESS_UNIT_SK,
        SFSQLA.PRICE_CURRENCY_SK,
        DD.FULL_DATE,
        ITEM_SALES_GROUP_CODE,
        ITEM_NAME_GROUP
), SS_WEEKLY_SOLD_QUOTED_CAN AS 
(
    SELECT 
        SWDD.CANAM_WEEK_START_DATE                                      AS CANAM_WEEK_START_DATE,
        SWDD.CANAM_WEEK_NUMBER                                          AS CANAM_WEEK_NUMBER,
        SWDD.CALENDAR_YEAR                                              AS CALENDAR_YEAR,
        SWDD.FISCAL_PERIOD_NUMBER                                       AS FISCAL_PERIOD_NUMBER,
        SWDD.FISCAL_PERIOD_NAME                                         AS FISCAL_PERIOD_NAME,
        SWDD.FISCAL_YEAR                                                AS FISCAL_YEAR,
        DBU.BUSINESS_UNIT_CODE                                          AS BUSINESS_UNIT_CODE,
        DBU.BUSINESS_UNIT_NAME_FR                                       AS BUSINESS_UNIT_NAME_FR,
        DBU.BUSINESS_UNIT_NAME_EN                                       AS BUSINESS_UNIT_NAME_EN,
        UPPER(TRIM(DSO.SALES_OFFICE_DEPARTMENT_CODE))                   AS SALES_OFFICE_DEPARTMENT_CODE,
        UPPER(TRIM(DSO.SALES_OFFICE_DEPARTMENT_NAME_EN))                AS SALES_OFFICE_DEPARTMENT_NAME,
        UPPER(TRIM(DSBO.SALES_BRANCH_OFFICE_DEPARTMENT_NAME_EN))        AS SALES_BRANCH_OFFICE_DEPARTMENT_GROUP_NAME,
        DSO.SALES_OFFICE_DEPARTMENT_COUNTRY_CODE                        AS SALES_OFFICE_DEPARTMENT_COUNTRY_CODE,
        DCU_FROM.CURRENCY_CODE                                          AS ORIGINAL_CURRENCY_CODE,
        'SOLD NEW PROJECT'                                              AS SOLD_QUOTED_FLAG,
        'NO BUDGET VARIATION'                                           AS BUDGET_VARIATION_TYPE_NAME,
        DP.PROJECT_CODE                                                 AS PROJECT_CODE,
        DP.PROJECT_NAME_EN                                              AS PROJECT_NAME,
        DP.PROJECT_SHIPPING_CITY_CODE                                   AS PROJECT_CITY_CODE,
        'N/A'                                                           AS SALES_QUOTE_CODE,
        DC.CUSTOMER_NAME                                                AS CUSTOMER_NAME,
        DC.BUSINESS_PARTNER_NAME                                        AS BUSINESS_PARTNER_CUSTOMER_NAME,
        DI.ITEM_SALES_GROUP_CODE                                        AS ITEM_SALES_GROUP_CODE,
        CASE WHEN DI.ITEM_CODE LIKE '160.%' 
            THEN DI.ITEM_NAME_EN
            ELSE DI.ITEM_SALES_GROUP_CODE
        END                                                             AS ITEM_NAME_GROUP,
        IFNULL(SUM(FPA.WEIGHT_ORIGINAL_BUDGET),0)                       AS SALES_WEIGHT_LB,
        IFNULL(SUM(FPA.WEIGHT_ORIGINAL_BUDGET/2000),0)                  AS SALES_WEIGHT_T,
        IFNULL(SUM(FPA.AREA_ORIGINAL_BUDGET),0)                         AS SALES_AREA_SF,
        IFNULL(SUM(FPA.SOLD_PRICE_ORIGINAL_BUDGET*FER.EXCHANGE_RATE),0) AS SALES_AMOUNT_CAD,
        0                                                               AS QUOTE_WEIGHT_LB,
        0                                                               AS QUOTE_WEIGHT_T,
        0                                                               AS QUOTE_AREA_SF,
        0                                                               AS QUOTE_AMOUNT_CAD,
        CASE UPPER(TRIM(DSBO.SALES_BRANCH_OFFICE_DEPARTMENT_NAME_EN))
            WHEN 'ATLANTIC PROVINCES'  THEN 1
            WHEN 'QUEBEC' THEN 2
            WHEN 'ONTARIO' THEN 3
            WHEN 'WESTERN CANADA' THEN 4
            ELSE 9999
        END                                                             AS SALES_BRANCH_OFFICE_DEPARTMENT_GROUP_NAME_ORDER_DISPLAY,
        CASE UPPER(TRIM(ITEM_NAME_GROUP))
            WHEN 'JOISTS' THEN 1
            WHEN 'JOIST GIRDERS' THEN 2
            WHEN 'DECK' THEN 3
            WHEN 'GIRTS' THEN 4
            WHEN 'STRUCTURAL STEEL & TRUSSES' THEN 5
            WHEN 'HAMBRO' THEN 6
            WHEN 'OTHERS' THEN 7
            WHEN 'FINISHING' THEN 8
            WHEN 'ERECTION' THEN 9
            WHEN 'FREIGHT JOISTS' THEN 9910
            WHEN 'FREIGHT GIRDERS' THEN 9911
            WHEN 'FREIGHT DECK' THEN 9912
            WHEN 'FREIGHT GIRTS' THEN 9913
            WHEN 'FREIGHT HAMBRO' THEN 9914
            ELSE 9999
        END                                                     AS ITEM_NAME_GROUP_ORDER_DISPLAY
    FROM SS_WEEKLY_DIM_DATE SWDD
        LEFT JOIN {{ref('sche_fact_Project_Activity')}} FPA ON SWDD.DATE_KEY = FPA.PROJECT_START_DATE_KEY
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
        -- Equivalent to TRUNC(fact_sales_orders.sales_orders_date,'MONTH')= dw_currency_rate.currency_date
        LEFT JOIN {{ref('sche_fact_Exchange_Rate')}} FER ON DCU_FROM.CURRENCY_SK = FER.FROM_CURRENCY_SK AND DCU_TO.CURRENCY_SK = FER.TO_CURRENCY_SK
            AND DD.DATE_KEY = FER.EXCHANGE_RATE_DATE_KEY AND DERT.EXCHANGE_RATE_TYPE_SK = FER.EXCHANGE_RATE_TYPE_SK
    WHERE DC.CUSTOMER_CODE <> 'AFFILIATED' --  Equivalent of dc.customer_affiliated <> 'AFFILIATED'
        AND DI.ITEM_CODE <> 'N/A' -- Equivalent to NVL(dsa_salestrx.REJECTED_CODE,100) <> '8'
    GROUP BY 
        SWDD.CANAM_WEEK_START_DATE,  
        SWDD.CANAM_WEEK_NUMBER,
        SWDD.CALENDAR_YEAR,
        SWDD.FISCAL_PERIOD_NUMBER,
        SWDD.FISCAL_PERIOD_NAME,
        SWDD.FISCAL_YEAR,
        DBU.BUSINESS_UNIT_CODE,
        DBU.BUSINESS_UNIT_NAME_FR,
        DBU.BUSINESS_UNIT_NAME_EN,
        DSO.SALES_OFFICE_DEPARTMENT_CODE,
        SALES_OFFICE_DEPARTMENT_NAME,
        SALES_BRANCH_OFFICE_DEPARTMENT_GROUP_NAME,
        SALES_OFFICE_DEPARTMENT_COUNTRY_CODE,
        ORIGINAL_CURRENCY_CODE,
        PROJECT_CODE,
        PROJECT_NAME,
        PROJECT_CITY_CODE,
        CUSTOMER_NAME,
        BUSINESS_PARTNER_NAME,                                      
        ITEM_SALES_GROUP_CODE,
        ITEM_NAME_GROUP
    UNION ALL
    SELECT 
        SWDD.CANAM_WEEK_START_DATE                                          AS CANAM_WEEK_START_DATE,
        SWDD.CANAM_WEEK_NUMBER                                              AS CANAM_WEEK_NUMBER,
        SWDD.CALENDAR_YEAR                                                  AS CALENDAR_YEAR,
        SWDD.FISCAL_PERIOD_NUMBER                                           AS FISCAL_PERIOD_NUMBER,
        SWDD.FISCAL_PERIOD_NAME                                             AS FISCAL_PERIOD_NAME,
        SWDD.FISCAL_YEAR                                                    AS FISCAL_YEAR,
        DBU.BUSINESS_UNIT_CODE                                              AS BUSINESS_UNIT_CODE,
        DBU.BUSINESS_UNIT_NAME_FR                                           AS BUSINESS_UNIT_NAME_FR,
        DBU.BUSINESS_UNIT_NAME_EN                                           AS BUSINESS_UNIT_NAME_EN,
        UPPER(TRIM(DSO.SALES_OFFICE_DEPARTMENT_CODE))                       AS SALES_OFFICE_DEPARTMENT_CODE,
        UPPER(TRIM(DSO.SALES_OFFICE_DEPARTMENT_NAME_EN))                    AS SALES_OFFICE_DEPARTMENT_NAME,
        UPPER(TRIM(DSBO.SALES_BRANCH_OFFICE_DEPARTMENT_NAME_EN))            AS SALES_BRANCH_OFFICE_DEPARTMENT_GROUP_NAME,
        DSO.SALES_OFFICE_DEPARTMENT_COUNTRY_CODE                            AS SALES_OFFICE_DEPARTMENT_COUNTRY_CODE,
        DCU_FROM.CURRENCY_CODE                                              AS ORIGINAL_CURRENCY_CODE,
        CASE WHEN FPABV.BUDGET_VARIATION_TYPE_CODE = 'C' 
                THEN 'CANCELLATION'
            ELSE 'SOLD EXTRA/CREDIT'
        END                                                                 AS SOLD_QUOTED_FLAG,
        CASE FPABV.BUDGET_VARIATION_TYPE_CODE
            WHEN 'E' THEN 'EXTRA/CREDIT'
            WHEN 'P' THEN 'PERMUTATION'
            WHEN 'A' THEN 'MANUAL ADJUSTMENT'
            WHEN 'C' THEN 'CANCELLATION'
            WHEN 'T' THEN 'PROJECT TRANSFER'
            ELSE 'NOT FOUND' 
        END                                                                 AS BUDGET_VARIATION_TYPE_NAME,
        DP.PROJECT_CODE                                                     AS PROJECT_CODE,
        DP.PROJECT_NAME_EN                                                  AS PROJECT_NAME,
        DP.PROJECT_SHIPPING_CITY_CODE                                       AS PROJECT_CITY_CODE,
        'N/A'                                                               AS SALES_QUOTE_CODE,
        DC.CUSTOMER_NAME                                                    AS CUSTOMER_NAME,
        DC.BUSINESS_PARTNER_NAME                                            AS BUSINESS_PARTNER_CUSTOMER_NAME,
        DI.ITEM_SALES_GROUP_CODE                                            AS ITEM_SALES_GROUP_CODE,
        CASE WHEN DI.ITEM_CODE LIKE '160.%' 
            THEN DI.ITEM_NAME_EN
            ELSE DI.ITEM_SALES_GROUP_CODE
        END                                                                 AS ITEM_NAME_GROUP,
        IFNULL(SUM(FPABV.WEIGHT_BUDGET_VARIATION),0)                        AS SALES_WEIGHT_LB,
        IFNULL(SUM(FPABV.WEIGHT_BUDGET_VARIATION/2000),0)                   AS SALES_WEIGHT_T,
        IFNULL(SUM(FPABV.AREA_BUDGET_VARIATION),0)                          AS SALES_AREA_SF,
        IFNULL(SUM(FPABV.SOLD_PRICE_BUDGET_VARIATION*FER.EXCHANGE_RATE),0)  AS SALES_AMOUNT_CAD,
        0                                                                   AS QUOTE_WEIGHT_LB,
        0                                                                   AS QUOTE_WEIGHT_T,
        0                                                                   AS QUOTE_AREA_SF,
        0                                                                   AS QUOTE_AMOUNT_CAD,
        CASE UPPER(TRIM(DSBO.SALES_BRANCH_OFFICE_DEPARTMENT_NAME_EN))
            WHEN 'ATLANTIC PROVINCES'  THEN 1
            WHEN 'QUEBEC' THEN 2
            WHEN 'ONTARIO' THEN 3
            WHEN 'WESTERN CANADA' THEN 4
            ELSE 9999
        END                                                                 AS SALES_BRANCH_OFFICE_DEPARTMENT_GROUP_NAME_ORDER_DISPLAY,
        CASE UPPER(TRIM(ITEM_NAME_GROUP))
            WHEN 'JOISTS' THEN 1
            WHEN 'JOIST GIRDERS' THEN 2
            WHEN 'DECK' THEN 3
            WHEN 'GIRTS' THEN 4
            WHEN 'STRUCTURAL STEEL & TRUSSES' THEN 5
            WHEN 'HAMBRO' THEN 6
            WHEN 'OTHERS' THEN 7
            WHEN 'FINISHING' THEN 8
            WHEN 'ERECTION' THEN 9
            WHEN 'FREIGHT JOISTS' THEN 9910
            WHEN 'FREIGHT GIRDERS' THEN 9911
            WHEN 'FREIGHT DECK' THEN 9912
            WHEN 'FREIGHT GIRTS' THEN 9913
            WHEN 'FREIGHT HAMBRO' THEN 9914
            ELSE 9999
        END                                                                 AS ITEM_NAME_GROUP_ORDER_DISPLAY
    FROM SS_WEEKLY_DIM_DATE SWDD
        LEFT JOIN {{ref('sche_fact_Project_Activity_Budget_Variation')}} FPABV ON SWDD.DATE_KEY = FPABV.BUDGET_VARIATION_DATE_KEY
        LEFT JOIN {{ref('sche_dim_Date')}} DD ON FPABV.BUDGET_VARIATION_DATE_KEY = DD.DATE_KEY
        LEFT JOIN {{ref('sche_dim_Project')}} DP ON FPABV.PROJECT_SK = DP.PROJECT_SK
        LEFT JOIN {{ref('sche_dim_Business_Unit')}} DBU ON FPABV.BUSINESS_UNIT_SK = DBU.BUSINESS_UNIT_SK
        LEFT JOIN {{ref('sche_dim_Sales_Office')}} DSO ON FPABV.SALES_OFFICE_SK = DSO.SALES_OFFICE_SK
        LEFT JOIN {{ref('sche_dim_Sales_Branch_Office')}} DSBO ON FPABV.SALES_BRANCH_OFFICE_SK = DSBO.SALES_BRANCH_OFFICE_SK
        LEFT JOIN {{ref('sche_dim_Item')}} DI ON FPABV.ITEM_SK = DI.ITEM_SK
        LEFT JOIN {{ref('sche_dim_Customer')}} DC ON FPABV.SOLD_TO_CUSTOMER_SK  = DC.CUSTOMER_SK
        LEFT JOIN {{ref('sche_dim_Currency')}} DCU_FROM ON FPABV.PRICE_AND_COST_BUDGET_VARIATION_CURRENCY_SK = DCU_FROM.CURRENCY_SK
        LEFT JOIN {{ref('sche_dim_Currency')}} DCU_TO ON FPABV.TO_CURRENCY_CAD_SK = DCU_TO.CURRENCY_SK
        LEFT JOIN {{ref('sche_dim_Exchange_Rate_Type')}} DERT ON FPABV.FISCAL_PERIOD_END_AVG_EXCHANGE_RATE_TYPE_SK = DERT.EXCHANGE_RATE_TYPE_SK  
        -- Equivalent to TRUNC(fact_sales_orders.sales_orders_date,'MONTH')= dw_currency_rate.currency_date
        LEFT JOIN {{ref('sche_fact_Exchange_Rate')}} FER ON DCU_FROM.CURRENCY_SK = FER.FROM_CURRENCY_SK AND DCU_TO.CURRENCY_SK = FER.TO_CURRENCY_SK
            AND DD.DATE_KEY = FER.EXCHANGE_RATE_DATE_KEY AND DERT.EXCHANGE_RATE_TYPE_SK = FER.EXCHANGE_RATE_TYPE_SK
    WHERE DC.CUSTOMER_CODE <> 'AFFILIATED' --  Equivalent of dc.customer_affiliated <> 'AFFILIATED'
        AND DI.ITEM_CODE <> 'N/A' -- Equivalent to NVL(dsa_salestrx.REJECTED_CODE,100) <> '8'
    GROUP BY 
        SWDD.CANAM_WEEK_START_DATE,
        SWDD.CANAM_WEEK_NUMBER,
        SWDD.CALENDAR_YEAR,
        SWDD.FISCAL_PERIOD_NUMBER,
        SWDD.FISCAL_PERIOD_NAME,
        SWDD.FISCAL_YEAR,
        DBU.BUSINESS_UNIT_CODE,
        DBU.BUSINESS_UNIT_NAME_FR,
        DBU.BUSINESS_UNIT_NAME_EN,
        DSO.SALES_OFFICE_DEPARTMENT_CODE,
        SALES_OFFICE_DEPARTMENT_NAME,
        SALES_BRANCH_OFFICE_DEPARTMENT_GROUP_NAME,
        SALES_OFFICE_DEPARTMENT_COUNTRY_CODE,
        ORIGINAL_CURRENCY_CODE,
        SOLD_QUOTED_FLAG,
        BUDGET_VARIATION_TYPE_NAME,
        PROJECT_CODE,
        PROJECT_NAME,
        PROJECT_CITY_CODE,
        CUSTOMER_NAME,
        BUSINESS_PARTNER_NAME,
        ITEM_SALES_GROUP_CODE,
        ITEM_NAME_GROUP
    UNION ALL
    SELECT 
        SWDD.CANAM_WEEK_START_DATE                                  AS CANAM_WEEK_START_DATE,
        SWDD.CANAM_WEEK_NUMBER                                      AS CANAM_WEEK_NUMBER,                               
        SWDD.CALENDAR_YEAR                                          AS CALENDAR_YEAR,
        SWDD.FISCAL_PERIOD_NUMBER                                   AS FISCAL_PERIOD_NUMBER,
        SWDD.FISCAL_PERIOD_NAME                                     AS FISCAL_PERIOD_NAME,
        SWDD.FISCAL_YEAR                                            AS FISCAL_YEAR,
        DBU.BUSINESS_UNIT_CODE                                      AS BUSINESS_UNIT_CODE,
        DBU.BUSINESS_UNIT_NAME_FR                                   AS BUSINESS_UNIT_NAME_FR,
        DBU.BUSINESS_UNIT_NAME_EN                                   AS BUSINESS_UNIT_NAME_EN,
        UPPER(TRIM(DSO.SALES_OFFICE_DEPARTMENT_CODE))               AS SALES_OFFICE_DEPARTMENT_CODE,
        UPPER(TRIM(DSO.SALES_OFFICE_DEPARTMENT_NAME_EN))            AS SALES_OFFICE_DEPARTMENT_NAME,
        UPPER(TRIM(DSBO.SALES_BRANCH_OFFICE_DEPARTMENT_NAME_EN))    AS SALES_BRANCH_OFFICE_DEPARTMENT_GROUP_NAME,
        DSO.SALES_OFFICE_DEPARTMENT_COUNTRY_CODE                    AS SALES_OFFICE_DEPARTMENT_COUNTRY_CODE,
        DCU.CURRENCY_CODE                                           AS ORIGINAL_CURRENCY_CODE,
        'QUOTED'                                                    AS SOLD_QUOTED_FLAG,
        'NO BUDGET VARIATION'                                       AS BUDGET_VARIATION_TYPE_NAME,
        'N/A'                                                       AS PROJECT_CODE,
        'N/A'                                                       AS PROJECT_NAME,
        'N/A'                                                       AS PROJECT_CITY_CODE,
        DSQ.SALES_QUOTE_CODE                                        AS SALES_QUOTE_CODE,
        'N/A'                                                       AS CUSTOMER_NAME,
        'N/A'                                                       AS BUSINESS_PARTNER_CUSTOMER_NAME,
        SFSQA_ALL.ITEM_SALES_GROUP_CODE                             AS ITEM_SALES_GROUP_CODE,
        SFSQA_ALL.ITEM_NAME_GROUP                                   AS ITEM_NAME_GROUP,
        0                                                           AS SALES_WEIGHT_LB,
        0                                                           AS SALES_WEIGHT_T,
        0                                                           AS SALES_AREA_SF,
        0                                                           AS SALES_AMOUNT_CAD,
        IFNULL(AVG(SFSQA_ALL.QUOTE_WEIGHT_LB),0)
            - IFNULL(AVG(SFSQA_OLD.QUOTE_WEIGHT_LB),0)              AS QUOTE_WEIGHT_LB,
        IFNULL(AVG(SFSQA_ALL.QUOTE_WEIGHT_LB/2000),0)
            - IFNULL(AVG(SFSQA_OLD.QUOTE_WEIGHT_LB/2000),0)         AS QUOTE_WEIGHT_T,
        IFNULL(AVG(SFSQA_ALL.QUOTE_AREA_SF),0)  
            - IFNULL(AVG(SFSQA_OLD.QUOTE_AREA_SF),0)                AS QUOTE_AREA_SF,
        IFNULL(AVG(SFSQA_ALL.QUOTE_AMOUNT_CAD),0)   
            - IFNULL(AVG(SFSQA_OLD.QUOTE_AMOUNT_CAD),0)             AS QUOTE_AMOUNT_CAD,
        CASE UPPER(TRIM(DSBO.SALES_BRANCH_OFFICE_DEPARTMENT_NAME_EN))
            WHEN 'ATLANTIC PROVINCES'  THEN 1
            WHEN 'QUEBEC' THEN 2
            WHEN 'ONTARIO' THEN 3
            WHEN 'WESTERN CANADA' THEN 4
            ELSE 9999
        END                                                         AS SALES_BRANCH_OFFICE_DEPARTMENT_GROUP_NAME_ORDER_DISPLAY,
        CASE UPPER(TRIM(SFSQA_ALL.ITEM_NAME_GROUP))
            WHEN 'JOISTS' THEN 1
            WHEN 'JOIST GIRDERS' THEN 2
            WHEN 'DECK' THEN 3
            WHEN 'GIRTS' THEN 4
            WHEN 'STRUCTURAL STEEL & TRUSSES' THEN 5
            WHEN 'HAMBRO' THEN 6
            WHEN 'OTHERS' THEN 7
            WHEN 'FINISHING' THEN 8
            WHEN 'ERECTION' THEN 9
            WHEN 'FREIGHT JOISTS' THEN 9910
            WHEN 'FREIGHT GIRDERS' THEN 9911
            WHEN 'FREIGHT DECK' THEN 9912
            WHEN 'FREIGHT GIRTS' THEN 9913
            WHEN 'FREIGHT HAMBRO' THEN 9914
            ELSE 9999
        END                                                         AS ITEM_NAME_GROUP_ORDER_DISPLAY
    FROM SS_WEEKLY_DIM_DATE SWDD
    -- Get a snapchot between a target week (excluded) and 3 month ago
        LEFT JOIN SS_FACT_SALES_QUOTE_AGG SFSQA_ALL ON SFSQA_ALL.SALES_QUOTE_CLOSING_DATE BETWEEN DATEADD(MONTH,-3,DATEADD(day, 10, SWDD.CANAM_WEEK_START_DATE)) AND DATEADD(DAY,6,SWDD.CANAM_WEEK_START_DATE)
        -- Get a snapchot between a target week (included) and 3 month ago
        LEFT JOIN SS_FACT_SALES_QUOTE_AGG SFSQA_OLD ON SFSQA_OLD.SALES_QUOTE_CLOSING_DATE BETWEEN DATEADD(MONTH,-3,DATEADD(day, 10, SWDD.CANAM_WEEK_START_DATE)) AND DATEADD(DAY,-1,SWDD.CANAM_WEEK_START_DATE)
            AND SFSQA_ALL.SALES_QUOTE_CODE = SFSQA_OLD.SALES_QUOTE_CODE AND SFSQA_ALL.ITEM_NAME_GROUP = SFSQA_OLD.ITEM_NAME_GROUP
        INNER JOIN {{ref('sche_dim_Sales_Quote')}} DSQ ON CONCAT(SFSQA_ALL.SALES_QUOTE_CODE,'01') = DSQ.SALES_QUOTE_ALTERNATIVE_CODE
        LEFT JOIN {{ref('sche_dim_Business_Unit')}} DBU ON SFSQA_ALL.BUSINESS_UNIT_SK = DBU.BUSINESS_UNIT_SK
        LEFT JOIN {{ref('sche_dim_Sales_Office')}} DSO ON SFSQA_ALL.SALES_OFFICE_SK = DSO.SALES_OFFICE_SK
        LEFT JOIN {{ref('sche_dim_Sales_Branch_Office')}} DSBO ON SFSQA_ALL.SALES_BRANCH_OFFICE_SK = DSBO.SALES_BRANCH_OFFICE_SK
        LEFT JOIN {{ref('sche_dim_Currency')}} DCU ON SFSQA_ALL.PRICE_CURRENCY_SK = DCU.CURRENCY_SK
    GROUP BY 
        SWDD.CANAM_WEEK_START_DATE,
        SWDD.CANAM_WEEK_NUMBER,
        SWDD.CALENDAR_YEAR,
        SWDD.FISCAL_PERIOD_NUMBER,
        SWDD.FISCAL_PERIOD_NAME,
        SWDD.FISCAL_YEAR,
        DBU.BUSINESS_UNIT_CODE,
        DBU.BUSINESS_UNIT_NAME_FR,
        DBU.BUSINESS_UNIT_NAME_EN,
        DSO.SALES_OFFICE_DEPARTMENT_CODE,
        SALES_OFFICE_DEPARTMENT_NAME,
        SALES_BRANCH_OFFICE_DEPARTMENT_GROUP_NAME,
        SALES_OFFICE_DEPARTMENT_COUNTRY_CODE,
        ORIGINAL_CURRENCY_CODE,
        DSQ.SALES_QUOTE_CODE,
        SFSQA_ALL.ITEM_SALES_GROUP_CODE,
        SFSQA_ALL.ITEM_NAME_GROUP
)

SELECT 
    CANAM_WEEK_START_DATE::DATE AS CANAM_WEEK_START_DATE,
    CANAM_WEEK_NUMBER::INTEGER AS CANAM_WEEK_NUMBER,
    CALENDAR_YEAR::INTEGER AS CALENDAR_YEAR,
    FISCAL_PERIOD_NUMBER::INTEGER AS FISCAL_PERIOD_NUMBER,
    FISCAL_PERIOD_NAME::STRING AS FISCAL_PERIOD_NAME,
    FISCAL_YEAR::INTEGER AS FISCAL_YEAR,
    BUSINESS_UNIT_CODE::STRING AS BUSINESS_UNIT_CODE,
    BUSINESS_UNIT_NAME_FR::STRING AS BUSINESS_UNIT_NAME_FR,
    BUSINESS_UNIT_NAME_EN::STRING AS BUSINESS_UNIT_NAME_EN,
    UPPER(TRIM(SALES_OFFICE_DEPARTMENT_CODE::STRING)) AS SALES_OFFICE_DEPARTMENT_CODE,
    UPPER(TRIM(SALES_OFFICE_DEPARTMENT_NAME::STRING)) AS SALES_OFFICE_DEPARTMENT_NAME,
    UPPER(TRIM(SALES_BRANCH_OFFICE_DEPARTMENT_GROUP_NAME::STRING)) AS SALES_BRANCH_OFFICE_DEPARTMENT_GROUP_NAME,
    SALES_OFFICE_DEPARTMENT_COUNTRY_CODE::STRING AS SALES_OFFICE_DEPARTMENT_COUNTRY_CODE,
    ORIGINAL_CURRENCY_CODE::STRING AS ORIGINAL_CURRENCY_CODE,
    SOLD_QUOTED_FLAG::STRING AS SOLD_QUOTED_FLAG,
    BUDGET_VARIATION_TYPE_NAME::STRING AS BUDGET_VARIATION_TYPE_NAME,
    PROJECT_CODE::STRING AS PROJECT_CODE,
    PROJECT_NAME::STRING AS PROJECT_NAME,
    PROJECT_CITY_CODE::STRING AS PROJECT_CITY_CODE,
    SALES_QUOTE_CODE::STRING AS SALES_QUOTE_CODE,
    CUSTOMER_NAME::STRING AS CUSTOMER_NAME,
    BUSINESS_PARTNER_CUSTOMER_NAME::STRING AS BUSINESS_PARTNER_CUSTOMER_NAME,
    ITEM_SALES_GROUP_CODE::STRING AS ITEM_SALES_GROUP_CODE,
    ITEM_NAME_GROUP::STRING AS ITEM_NAME_GROUP,
    SALES_WEIGHT_LB::NUMBER(38,2) AS SALES_WEIGHT_LB,
    SALES_WEIGHT_T::NUMBER(38,2) AS SALES_WEIGHT_T,
    SALES_AREA_SF::NUMBER(38,2) AS SALES_AREA_SF,
    SALES_AMOUNT_CAD::NUMBER(38,2) AS SALES_AMOUNT_CAD,
    QUOTE_WEIGHT_LB::NUMBER(38,2) AS QUOTE_WEIGHT_LB,
    QUOTE_WEIGHT_T::NUMBER(38,2) AS QUOTE_WEIGHT_T,
    QUOTE_AREA_SF::NUMBER(38,2) AS QUOTE_AREA_SF,
    QUOTE_AMOUNT_CAD::NUMBER(38,2) AS QUOTE_AMOUNT_CAD,
    SALES_BRANCH_OFFICE_DEPARTMENT_GROUP_NAME_ORDER_DISPLAY::INTEGER AS SALES_BRANCH_OFFICE_DEPARTMENT_GROUP_NAME_ORDER_DISPLAY,
    ITEM_NAME_GROUP_ORDER_DISPLAY::INTEGER AS ITEM_NAME_GROUP_ORDER_DISPLAY
FROM SS_WEEKLY_SOLD_QUOTED_CAN
WHERE (ROUND(SALES_WEIGHT_LB,2) <> 0 OR ROUND(SALES_AREA_SF,2) <> 0 OR ROUND(SALES_AMOUNT_CAD,2) <> 0
    OR ROUND(QUOTE_WEIGHT_LB,2) <> 0 OR ROUND(QUOTE_AREA_SF,2) <> 0 OR ROUND(QUOTE_AMOUNT_CAD,2) <> 0)