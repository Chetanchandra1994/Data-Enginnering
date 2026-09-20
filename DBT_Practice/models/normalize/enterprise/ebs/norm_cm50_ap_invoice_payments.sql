{{
  config(
    materialized = "view",
    alias = "cm50_ap_invoice_payments",
    schema='EBS',
    meta = {
        'table_key': 'APP_ACCOUNTING_EVENT_ID',
        'tests': {
            'null_values':{
                'columns':[
                    'RDM_APP_ORG_ID_LOOKUP_CODE'
                ]
            }
        }
    }
  )
}}

with raw_data_deduplicated as (

  SELECT *
  FROM {{ref('prep_cm50_ap_invoice_payments')}}
  QUALIFY ROW_NUMBER() OVER (PARTITION BY APP_INVOICE_PAYMENT_ID ORDER BY TO_TIMESTAMP_NTZ(APP_LAST_UPDATE_DATE::STRING, 'YYYY-MM-DD HH24:MI:SS.FF') DESC) = 1 

),
rdm_oracle_logisticcompany as
  (SELECT distinct Business_Application_Value, Standard_Application_Value
  from {{ref('gov_referencedata_rdm')}}
  where Business_Application_Code='oracle-ebs'
  and Business_Application_Domain_Code='LogisticCompany')

SELECT raw_data_deduplicated.APP_ACCOUNTING_DATE::date as APP_ACCOUNTING_DATE
, raw_data_deduplicated.APP_ACCOUNTING_EVENT_ID::number(38,0) as APP_ACCOUNTING_EVENT_ID
, raw_data_deduplicated.APP_ACCRUAL_POSTED_FLAG::string as APP_ACCRUAL_POSTED_FLAG
, raw_data_deduplicated.APP_ACCTS_PAY_CC_ID::number(38,0) as APP_ACCTS_PAY_CC_ID
, raw_data_deduplicated.APP_AMOUNT::number(38,2) as APP_AMOUNT
, raw_data_deduplicated.APP_ASSETS_ADDITION_FLAG::string as APP_ASSETS_ADDITION_FLAG
, raw_data_deduplicated.APP_ASSET_CODE_COMBINATION_ID::number(38,0) as APP_ASSET_CODE_COMBINATION_ID
, raw_data_deduplicated.APP_CASH_POSTED_FLAG::string as APP_CASH_POSTED_FLAG
, raw_data_deduplicated.APP_CHECK_ID::number(38,0) as APP_CHECK_ID
, raw_data_deduplicated.APP_CREATED_BY::number(38,0) as APP_CREATED_BY
, raw_data_deduplicated.APP_CREATION_DATE::date as APP_CREATION_DATE
, raw_data_deduplicated.APP_DISCOUNT_LOST::number(38,2) as APP_DISCOUNT_LOST
, raw_data_deduplicated.APP_DISCOUNT_TAKEN::number(38,2) as APP_DISCOUNT_TAKEN
, raw_data_deduplicated.APP_EXCHANGE_DATE::date as APP_EXCHANGE_DATE
, raw_data_deduplicated.APP_EXCHANGE_RATE::number(38,4) as APP_EXCHANGE_RATE
, raw_data_deduplicated.APP_EXCHANGE_RATE_TYPE::string as APP_EXCHANGE_RATE_TYPE
, raw_data_deduplicated.APP_FUTURE_PAY_POSTED_FLAG::string as APP_FUTURE_PAY_POSTED_FLAG
, raw_data_deduplicated.APP_GAIN_CODE_COMBINATION_ID::number(38,0) as APP_GAIN_CODE_COMBINATION_ID
, raw_data_deduplicated.APP_INVOICE_BASE_AMOUNT::number(38,2) as APP_INVOICE_BASE_AMOUNT
, raw_data_deduplicated.APP_INVOICE_ID::number(38,0) as APP_INVOICE_ID
, raw_data_deduplicated.APP_INVOICE_PAYMENT_ID::number(38,0) as APP_INVOICE_PAYMENT_ID
, raw_data_deduplicated.APP_INVOICE_PAYMENT_TYPE::string as APP_INVOICE_PAYMENT_TYPE
, raw_data_deduplicated.APP_LAST_UPDATED_BY::number(38,0) as APP_LAST_UPDATED_BY
, TO_TIMESTAMP_NTZ(raw_data_deduplicated.APP_LAST_UPDATE_DATE::STRING, 'YYYY-MM-DD HH24:MI:SS.FF') as APP_LAST_UPDATE_DATE
, raw_data_deduplicated.APP_LAST_UPDATE_LOGIN::number(38,0) as APP_LAST_UPDATE_LOGIN
, raw_data_deduplicated.APP_LOSS_CODE_COMBINATION_ID::number(38,0) as APP_LOSS_CODE_COMBINATION_ID
, rdm_oracle_logisticcompany.Standard_Application_Value::number(38,0) as RDM_APP_ORG_ID_LOOKUP_CODE
, raw_data_deduplicated.APP_OTHER_INVOICE_ID::number(38,0) as APP_OTHER_INVOICE_ID
, raw_data_deduplicated.APP_PAYMENT_BASE_AMOUNT::number(38,2) as APP_PAYMENT_BASE_AMOUNT
, raw_data_deduplicated.APP_PAYMENT_NUM::number(38,0) as APP_PAYMENT_NUM
, raw_data_deduplicated.APP_PERIOD_NAME::string as APP_PERIOD_NAME
, raw_data_deduplicated.APP_POSTED_FLAG::string as APP_POSTED_FLAG
, raw_data_deduplicated.APP_REVERSAL_FLAG::string as APP_REVERSAL_FLAG
, raw_data_deduplicated.APP_REVERSAL_INV_PMT_ID::number(38,0) as APP_REVERSAL_INV_PMT_ID
, raw_data_deduplicated.APP_SET_OF_BOOKS_ID::number(38,0) as APP_SET_OF_BOOKS_ID
from raw_data_deduplicated
left join rdm_oracle_logisticcompany
on raw_data_deduplicated.APP_ORG_ID::string = rdm_oracle_logisticcompany.Business_Application_Value::string