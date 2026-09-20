{{
  config(
    full_refresh = true,
    materialized="dynamic_table",
    target_lag="downstream",
    snowflake_warehouse= var('task_warehouse'),
    alias = "IMPACT_BY_LOCATION_INFOR_DATA",
    schema= "DATAPRODUCTS_BRONZE",
    post_hook = "ALTER DYNAMIC TABLE {{ this }} SET LOG_LEVEL = ERROR",
    tags=["impact_by_location_infor_data"],
    meta = {
    'cron_prod': '*/15 7-19 * * 1-5',
    'cron_test': '*/15 7-19 * * 1-5',
    'timezone': 'America/Toronto'    
    }
  )
}}

-- It standardizes various project number formats into a consistent projectnumber by applying a series of regular expression-based rules
-- It combines the IMPACT_YEAR and IMPACT_PERIOD columns to create a standardized PERIOD string in 'MON-YY' format (e.g., 'JAN-26')
-- It filters out test projects (those starting with ZZ_) and projects with a 9-digit number format
WITH RAW AS (
    SELECT
        A.*,
        CASE
            -- 1. If project is exactly 6 digits, prepend 'C'
            WHEN REGEXP_LIKE(project, '^[0-9]{6}$') THEN
                'C' || project
    
            -- 2. If project contains both letters and numbers, apply transformation logic
            WHEN REGEXP_LIKE(project, '.*[a-zA-Z].*') AND REGEXP_LIKE(project, '.*[0-9].*') THEN
                CASE
                    -- Check if the transformed string starts with 1-2 letters followed by a digit
                    WHEN REGEXP_LIKE(
                        CASE 
                            WHEN REGEXP_LIKE(project, '^[EUC].*') THEN 'C' || SUBSTR(project, 2)
                            ELSE 'C' || project 
                        END, 
                        '^[a-zA-Z]{1,2}[0-9].*'
                    )
                    THEN LEFT(
                        CASE 
                            WHEN REGEXP_LIKE(project, '^[EUC].*') THEN 'C' || SUBSTR(project, 2)
                            ELSE 'C' || project 
                        END, 
                        7
                    )
                    -- Fallback if the regex doesn't match
                    ELSE
                        CASE 
                            WHEN REGEXP_LIKE(project, '^[EUC].*') THEN 'C' || SUBSTR(project, 2)
                            ELSE 'C' || project 
                        END
                END
    
            -- 3. Default: return original project
            ELSE project
        END AS projectnumber,
    
        UPPER(TO_CHAR(DATE_FROM_PARTS(IMPACT_YEAR::INT, IMPACT_PERIOD::INT, 1), 'MON-YY')) AS PERIOD
    FROM
        {{('TEST_CORPORATE_NORMALIZE' if target.name == 'test' else 'PROD_CORPORATE_NORMALIZE' if target.name == 'prod')}}.INFOR.PROJECT_IMPACT AS A
    WHERE
        project NOT LIKE 'ZZ_%'
        AND NOT REGEXP_LIKE(project, '^\\d{9}$')
),

-- After the project number standardization in the RAW CTE, some project/period combinations might become duplicates (e.g., '2437060U2' and '2437060U1')
-- This CTE uses the QUALIFY clause with ROW_NUMBER() to ensure that only a single, unique record exists for each combination of projectnumber, impact_year, and impact_period
PREPARED_RAW AS (
    SELECT *
    FROM RAW
    QUALIFY ROW_NUMBER() OVER(
      PARTITION BY projectnumber, impact_year, impact_period
      ORDER BY project DESC
    ) = 1
),

-- It mimics logic from a similar view in BigQuery to ensure consistency. See edl-fast-track-canam.ProjectAccounting.vw_GL_TRANSLATION_RATES
GL_TRANSLATION_RATES_BY_PERIODS AS (
    SELECT 
        SET_OF_BOOKS_ID, 
        PERIOD_NAME, 
        TO_CURRENCY_CODE, 
        ACTUAL_FLAG, 
        AVG_RATE, 
        EOP_RATE, 
        UPDATE_FLAG, 
        LAST_UPDATE_DATE, 
        LAST_UPDATED_BY, 
        CREATION_DATE, 
        CREATED_BY, 
        LAST_UPDATE_LOGIN,
        EOP_RATE_NUMERATOR, 
        EOP_RATE_DENOMINATOR, 
        AVG_RATE_NUMERATOR, 
        AVG_RATE_DENOMINATOR
    FROM {{ref('norm_gl_translation_rates')}}
    WHERE SET_OF_BOOKS_ID = 1
      AND ACTUAL_FLAG = 'A'
    
    UNION ALL
    
    SELECT 
        SET_OF_BOOKS_ID, 
        UPPER(TO_CHAR(DATEADD(month, 1, TO_DATE(PERIOD_NAME, 'Mon-YY')), 'Mon-YY')) AS PERIOD_NAME, 
        TO_CURRENCY_CODE, 
        ACTUAL_FLAG, 
        AVG_RATE, 
        EOP_RATE, 
        UPDATE_FLAG, 
        LAST_UPDATE_DATE, 
        LAST_UPDATED_BY, 
        CREATION_DATE, 
        CREATED_BY, 
        LAST_UPDATE_LOGIN, 
        EOP_RATE_NUMERATOR, 
        EOP_RATE_DENOMINATOR, 
        AVG_RATE_NUMERATOR, 
        AVG_RATE_DENOMINATOR
    FROM {{ref('norm_gl_translation_rates')}}
    WHERE SET_OF_BOOKS_ID = 1
      AND ACTUAL_FLAG = 'A'
      AND PERIOD_NAME = (
          SELECT UPPER(TO_CHAR(MAX(TO_DATE(PERIOD_NAME, 'Mon-YY')), 'Mon-YY'))
          FROM {{ref('norm_gl_translation_rates')}}
          WHERE SET_OF_BOOKS_ID = 1
            AND ACTUAL_FLAG = 'A'
      )
    
    UNION ALL
    
    SELECT 
        SET_OF_BOOKS_ID, 
        PERIOD_NAME, 
        'CAD', 
        ACTUAL_FLAG, 
        1, 
        1, 
        UPDATE_FLAG, 
        LAST_UPDATE_DATE, 
        LAST_UPDATED_BY, 
        CREATION_DATE, 
        CREATED_BY, 
        LAST_UPDATE_LOGIN, 
        EOP_RATE_NUMERATOR, 
        EOP_RATE_DENOMINATOR, 
        AVG_RATE_NUMERATOR, 
        AVG_RATE_DENOMINATOR
    FROM {{ref('norm_gl_translation_rates')}}
    WHERE SET_OF_BOOKS_ID = 1
      AND ACTUAL_FLAG = 'A'
      AND TO_CURRENCY_CODE = 'USD'
    
    UNION ALL
    
    SELECT 
        SET_OF_BOOKS_ID, 
        UPPER(TO_CHAR(DATEADD(month, 1, TO_DATE(PERIOD_NAME, 'Mon-YY')), 'Mon-YY')) AS PERIOD_NAME, 
        'CAD', 
        ACTUAL_FLAG, 
        1, 
        1, 
        UPDATE_FLAG, 
        LAST_UPDATE_DATE, 
        LAST_UPDATED_BY, 
        CREATION_DATE, 
        CREATED_BY, 
        LAST_UPDATE_LOGIN, 
        EOP_RATE_NUMERATOR, 
        EOP_RATE_DENOMINATOR, 
        AVG_RATE_NUMERATOR, 
        AVG_RATE_DENOMINATOR
    FROM {{ref('norm_gl_translation_rates')}}
    WHERE SET_OF_BOOKS_ID = 1
      AND ACTUAL_FLAG = 'A'
      AND TO_CURRENCY_CODE = 'USD'
      AND PERIOD_NAME = (
          SELECT UPPER(TO_CHAR(MAX(TO_DATE(PERIOD_NAME, 'Mon-YY')), 'Mon-YY'))
          FROM {{ref('norm_gl_translation_rates')}}
          WHERE SET_OF_BOOKS_ID = 1
            AND ACTUAL_FLAG = 'A'
            AND TO_CURRENCY_CODE = 'USD'
      )
),

-- It links the PREPARED_RAW data with the rates from GL_TRANSLATION_RATES_BY_PERIODS
-- It determines the correct PROJECT_EXCHANGE_RATE by prioritizing the rate from the SPM_GDM.project table and falling back to a rate from the EBS.CM50_PA_PROJECTS table if the first is not available
RATES AS (
    SELECT
        PREPARED_RAW.PROJECTNUMBER,
        -- Using CHR(39) to represent a single quote (')
        CHR(39) || PREPARED_RAW.PERIOD AS periods,

        -- Use exchange_rate from SPM. If not found, use CGI rate
        CASE
          WHEN projects.EXCHGN_RATE IS NOT NULL THEN projects.EXCHGN_RATE
          ELSE CGI_RATES.ppa_project_bil_exchange_rate
        END AS PROJECT_EXCHANGE_RATE,
        
        RATES.AVG_RATE AS AVG_RATE
    FROM PREPARED_RAW
    LEFT JOIN GL_TRANSLATION_RATES_BY_PERIODS AS RATES
        ON PREPARED_RAW.PERIOD = UPPER(RATES.PERIOD_NAME)
        AND UPPER(PREPARED_RAW.PROJECT_CURRENCY) = UPPER(RATES.TO_CURRENCY_CODE)
    LEFT JOIN {{ref('norm_project')}} AS projects
        ON PREPARED_RAW.PROJECTNUMBER = UPPER(projects.PROJECT_CODE)
    LEFT JOIN {{ref('norm_cm50_pa_projects')}} AS CGI_RATES
        ON PREPARED_RAW.PROJECTNUMBER = UPPER(CGI_RATES.PPA_PROJECT_NUMBER)
)

SELECT
    -- Financial Calculations
    PREPARED_RAW.BUDGET_PROFIT_LOSS::DOUBLE          AS BUDGET_PROFIT,
    PREPARED_RAW.BUDGET_TOT_COST::DOUBLE             AS BUDGET_EXPENSE_TOTAL,
    PREPARED_RAW.BUDGET_REVENUE::DOUBLE              AS BUDGET_REVENUE,
    DIV0(
        BUDGET_REVENUE, 
        RATES.PROJECT_EXCHANGE_RATE
    )                                                AS BUDGET_REVENUE_PROJECT_CURRENCY,
    PREPARED_RAW.PTD_BILLING::DOUBLE                 AS CUM_BILL_AMOUNT,
    DIV0(
        CUM_BILL_AMOUNT, 
        RATES.PROJECT_EXCHANGE_RATE
    )                                                AS CUM_BILL_AMOUNT_PRJ_CURRENCY,
    DIV0(
        PREPARED_RAW.PTD_PROFIT_LOSS_HC::DOUBLE, 
        RATES.PROJECT_EXCHANGE_RATE
    )                                                AS CUM_PROFIT,
    DIV0(
        PREPARED_RAW.PERIOD_PROFIT_LOSS_HC::DOUBLE, 
        RATES.PROJECT_EXCHANGE_RATE
    )                                                AS CUR_MONTH_PROFIT,
    CASE 
        WHEN RATES.AVG_RATE > 1 THEN PREPARED_RAW.PERIOD_PROFIT_LOSS_HC::DOUBLE * RATES.AVG_RATE
        ELSE DIV0(PREPARED_RAW.PERIOD_PROFIT_LOSS_HC::DOUBLE, RATES.AVG_RATE)
    END                                              AS CUR_MONTH_PROFIT_AVERAGE,

    -- Cumulative Profit Window Function
    SUM(CUR_MONTH_PROFIT_AVERAGE) OVER (
        PARTITION BY PROJECT 
        ORDER BY 
            CAST(CAST(PREPARED_RAW.IMPACT_YEAR AS FLOAT) AS INT), 
            CAST(CAST(PREPARED_RAW.IMPACT_PERIOD AS FLOAT) AS INT)
        ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
    )                                                AS CUM_PROFIT_AVERAGE,

    PREPARED_RAW.PERIOD_COST_HC::DOUBLE              AS CUR_MONTH_COGS_HC,
    PREPARED_RAW.PTD_COST_HC::DOUBLE                 AS CUM_COGS_HC,
    CASE 
        WHEN RATES.AVG_RATE > 1 THEN PREPARED_RAW.PERIOD_COST_HC::DOUBLE * RATES.PROJECT_EXCHANGE_RATE
        ELSE DIV0(PREPARED_RAW.PERIOD_COST_HC::DOUBLE, RATES.PROJECT_EXCHANGE_RATE)
    END                                              AS CUR_MONTH_COGS,

    -- Cumulative COGS Window Function
    SUM(CUR_MONTH_COGS) OVER (
        PARTITION BY PROJECT 
        ORDER BY 
            CAST(CAST(PREPARED_RAW.IMPACT_YEAR AS FLOAT) AS INT), 
            CAST(CAST(PREPARED_RAW.IMPACT_PERIOD AS FLOAT) AS INT)
        ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
    )                                                AS CUM_COGS,

    DIV0(
        PREPARED_RAW.PTD_REVENUE_HC::DOUBLE, 
        RATES.PROJECT_EXCHANGE_RATE
    )                                                AS CUM_REVENUE,
    DIV0(
        PREPARED_RAW.PERIOD_REVENUE_HC::DOUBLE, 
        RATES.PROJECT_EXCHANGE_RATE
    )                                                AS CUR_MONTH_REVENUE,
    CASE 
        WHEN RATES.AVG_RATE > 1 THEN PREPARED_RAW.PERIOD_REVENUE_HC::DOUBLE * RATES.AVG_RATE
        ELSE DIV0(PREPARED_RAW.PERIOD_REVENUE_HC::DOUBLE, RATES.AVG_RATE)
    END                                              AS CUR_MONTH_REVENUE_AVERAGE,

    -- Cumulative Revenue Window Function
    SUM(CUR_MONTH_REVENUE_AVERAGE) OVER (
        PARTITION BY PROJECT 
        ORDER BY 
            CAST(CAST(PREPARED_RAW.IMPACT_YEAR AS FLOAT) AS INT), 
            CAST(CAST(PREPARED_RAW.IMPACT_PERIOD AS FLOAT) AS INT)
        ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
    )                                                AS CUM_REVENUE_AVERAGE,

    -- Period and Project Logic
    '''' || PREPARED_RAW.PERIOD                      AS PERIODS,
    PREPARED_RAW.PROJECTNUMBER                       AS PROJECTNUMBER,

    -- Business Unit Logic
    CASE 
        WHEN PREPARED_RAW.LINE_OF_BUSINESS = 'M01' THEN 30
        WHEN PREPARED_RAW.LINE_OF_BUSINESS = 'H01' THEN 20
        WHEN PREPARED_RAW.LINE_OF_BUSINESS = 'S01' THEN 10
        WHEN PREPARED_RAW.LINE_OF_BUSINESS IN ('J01', 'J02', 'J03') THEN 5
        WHEN PREPARED_RAW.LINE_OF_BUSINESS = 'D01' THEN 45
    END                                              AS BUSINESSUNITS_CODE,
    CASE 
        WHEN PREPARED_RAW.LINE_OF_BUSINESS = 'M01' THEN 'Buildings Murox'
        WHEN PREPARED_RAW.LINE_OF_BUSINESS = 'H01' THEN 'Buildings Hambro'
        WHEN PREPARED_RAW.LINE_OF_BUSINESS = 'S01' THEN 'Canam Structures'
        WHEN PREPARED_RAW.LINE_OF_BUSINESS IN ('J01', 'J02', 'J03') THEN 'Joists & Deck Northeast'
        WHEN PREPARED_RAW.LINE_OF_BUSINESS = 'D01' THEN 'Canam Detailin'
    END                                              AS BUSINESSUNITS_DESCRIPTION,

    -- Customer and Project Metadata
    PREPARED_RAW.INVOICE_TO_BP                       AS CUSTOMER_NUMBER,
    PREPARED_RAW.INVOICE_TO_BP_NAME                  AS CUSTOMER_NAME,

    -- Handle Boolean logic for Snowflake
    IFF(
        PREPARED_RAW.BP_FIN_GROUP_DESC NOT IN ('Multiple Business Partners', 'Third Party Partners'), 
        TRUE, 
        FALSE
    )                                                AS INTERCO,

    PREPARED_RAW.BP_FIN_GROUP_DESC                   AS INTERCO_DESC,
    PREPARED_RAW.PROJECT_DESC                        AS PROJECT_NAME,
    PREPARED_RAW.PROJECT_CURRENCY                    AS PROJECT_CURRENCY,
    PREPARED_RAW.FINANCIAL_CPY                       AS FINANCIAL_COMPANY,
    PREPARED_RAW.FINANCIAL_CPY_DESC                  AS FINANCIAL_COMPANY_DESC,
    PREPARED_RAW.PROJECT_MANAGER                     AS PROJECT_MANAGER,
    PREPARED_RAW.PROJECT_MANAGER_NAME                AS PROJECT_MANAGER_NAME,
    PREPARED_RAW.CLIN_RATE                           AS PROJECT_CURRENCY_RATE,
    PREPARED_RAW.PROJECT_STATUS                      AS PROJECT_STATUS_CODE,
    RATES.PROJECT_EXCHANGE_RATE                      AS PROJECT_EXCHANGE_RATE,
    RATES.AVG_RATE                                   AS AVG_RATE,
    PREPARED_RAW.FORECAST_TOT_COST::DOUBLE           AS PROJECT_FORECAST,
    PREPARED_RAW.ACTIVITY_DESC                       AS PROJECT_ACTIVITY_DESCRIPTION,
    "GROUP"                                          AS "GROUP",
    PREPARED_RAW.GROUP_DESC                          AS GROUP_DESC,
    PREPARED_RAW.GEO_AREA                            AS SHIPPING_TERRITORY,
    PREPARED_RAW.GEO_AREA_DESC                       AS SHIPPING_TERRITORY_DESC,
    PREPARED_RAW.PERIOD_BILLING::DOUBLE              AS PERIOD_BILLING,
    PREPARED_RAW.REMAIN_BILLING::DOUBLE              AS REMAIN_BILLING,
    PREPARED_RAW.REMAIN_BILLING_PCT::DOUBLE          AS REMAIN_BILLING_PCT,
    PREPARED_RAW.AMT_DUE::DOUBLE                     AS AMT_DUE,
    DIV0(
        BUDGET_PROFIT, 
        RATES.PROJECT_EXCHANGE_RATE
    )                                                AS BUDGET_PROFIT_PROJECT_CURRENCY
FROM PREPARED_RAW
LEFT JOIN RATES
    ON PREPARED_RAW.PROJECTNUMBER = RATES.PROJECTNUMBER
    AND ('''' || PREPARED_RAW.PERIOD) = RATES.PERIODS
ORDER BY 
    PREPARED_RAW.PROJECTNUMBER, 
    PREPARED_RAW.IMPACT_YEAR,
    PREPARED_RAW.IMPACT_PERIOD