{{
  config(
    full_refresh = true,
    materialized="dynamic_table",
    target_lag="24 hour",
    snowflake_warehouse= var('task_warehouse'),
    alias = "Exchange_Rate",
    schema= "dataproducts_gold",
    post_hook = "ALTER DYNAMIC TABLE {{ this }} SET LOG_LEVEL = ERROR"
  
  )
}}

SELECT
    DD.FULL_DATE AS EXCHANGE_RATE_DATE,
    DP.PROJECT_CODE AS PROJECT_CODE,
    DC_FROM.CURRENCY_CODE AS FROM_CURRENCY_CODE,
    DC_TO.CURRENCY_CODE AS TO_CURRENCY_CODE,
    DERT.EXCHANGE_RATE_TYPE_CODE AS EXCHANGE_RATE_TYPE_CODE,
    DERT.EXCHANGE_RATE_TYPE_NAME_FR AS EXCHANGE_RATE_TYPE_NAME_FR,
    DERT.EXCHANGE_RATE_TYPE_NAME_EN AS EXCHANGE_RATE_TYPE_NAME_EN,
    FER.EXCHANGE_RATE::NUMBER(38,9) AS EXCHANGE_RATE
FROM {{ref('sche_fact_Exchange_Rate')}} FER
    LEFT JOIN {{ref('sche_dim_Date')}} DD ON FER.EXCHANGE_RATE_DATE_KEY = DD.DATE_KEY
    LEFT JOIN {{ref('sche_dim_Project')}} DP ON FER.PROJECT_SK = DP.PROJECT_SK
    LEFT JOIN {{ref('sche_dim_Currency')}} DC_FROM ON FER.FROM_CURRENCY_SK = DC_FROM.CURRENCY_SK
    LEFT JOIN {{ref('sche_dim_Currency')}} DC_TO ON FER.TO_CURRENCY_SK = DC_TO.CURRENCY_SK
    LEFT JOIN {{ref('sche_dim_Exchange_Rate_Type')}} DERT ON FER.EXCHANGE_RATE_TYPE_SK = DERT.EXCHANGE_RATE_TYPE_SK