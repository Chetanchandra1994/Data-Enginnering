{{
  config(
    full_refresh = true,
    materialized="dynamic_table",
    target_lag="downstream",
    snowflake_warehouse= var('task_warehouse'),
    alias = "fact_Project_Exchange_Rate",
    schema= "facts",
    post_hook = "ALTER DYNAMIC TABLE {{ this }} SET LOG_LEVEL = ERROR",
    meta = {
    'table_key': 'PROJECT_SK',
    'tests': {
      'unexpected_values':{
        'columns':{
            'RATE': "0"
          }
        }
      }    
    }
  )
}}

WITH SPM_RATES_AND_QUOTATIONS AS (
    SELECT
        A.NO_PROJET,
        B.EXCHGN_RATE,
        B.QUOTATION_DATE
    FROM
        {{ref('norm_projet_g')}} AS A
    LEFT JOIN
        {{ref('norm_project')}} AS B
        ON A.GDM_PROJECT_ID = B.PROJECT_ID
),
PROJECT_EXCHANGE_RATES AS (
    SELECT
        C.Standard_Application_Value AS FROM_CURRENCY_CODE,
        A.PROJECT_CURRENCY_CODE AS TO_CURRENCY_CODE,
        D.Standard_Application_Value AS EXCHANGE_RATE_TYPE,
        {{ target.name }}_ENTERPRISE_SCHEMATIZE.PUBLIC.format_date_key(B.quotation_date, 'YYYY-MM-DD HH24:MI:SS.FF') AS EXCHANGE_RATE_DATE_KEY,
        A.PROJECT_SK AS PROJECT_SK,
        B.EXCHGN_RATE AS RATE,
        CASE WHEN B.EXCHGN_RATE = 0 THEN TRUE ELSE FALSE END AS POTENTIAL_INVALID_EXCHANGE_RATE
    FROM
        {{ref('sche_dim_Project')}} AS A
    LEFT JOIN
        SPM_RATES_AND_QUOTATIONS AS B
        ON A.PROJECT_CODE = B.NO_PROJET
    LEFT JOIN
        {{ref('gov_referencedata_rdm')}} AS C
        ON C.Business_Application_Value = 'CAD'
        AND C.Business_Application_Code = 'spm'
        AND C.Business_Application_Domain_Code = 'Currency'
    LEFT JOIN
        {{ref('gov_referencedata_rdm')}} AS D
        ON D.Business_Application_Value = 'DailyProjectRate'
        AND D.Business_Application_Code = 'spm'
        AND D.Business_Application_Domain_Code = 'ExchangeRateType'
),
INVERTED_PROJECT_EXCHANGE_RATES AS (
    SELECT
        TO_CURRENCY_CODE AS FROM_CURRENCY_CODE,
        FROM_CURRENCY_CODE AS TO_CURRENCY_CODE,
        EXCHANGE_RATE_TYPE,
        EXCHANGE_RATE_DATE_KEY,
        PROJECT_SK,
        CASE WHEN RATE = 0 THEN 0 ELSE 1 / RATE END AS RATE,
        POTENTIAL_INVALID_EXCHANGE_RATE
    FROM
        PROJECT_EXCHANGE_RATES
)

-- SELECT DISTINCT ensures that you won't get duplicate inverted exchange rates for the same project. 
-- For instance, if you have an exchange rate where FROM_CURRENCY_CODE is 'CAD', TO_CURRENCY_CODE is 'CAD', and the RATE is '1', SELECT DISTINCT will make sure this exact entry only appears once.
SELECT DISTINCT
    FROM_CURRENCY_CODE,
    TO_CURRENCY_CODE,
    EXCHANGE_RATE_TYPE,
    EXCHANGE_RATE_DATE_KEY,
    PROJECT_SK,
    RATE,
    POTENTIAL_INVALID_EXCHANGE_RATE
FROM
    (
        SELECT
            *
        FROM
            PROJECT_EXCHANGE_RATES
        UNION ALL
        SELECT
            *
        FROM
            INVERTED_PROJECT_EXCHANGE_RATES
    )
