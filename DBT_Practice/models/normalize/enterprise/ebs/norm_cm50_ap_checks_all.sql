{{
  config(
    materialized = "view",
    alias = "cm50_ap_checks_all",
    schema='EBS',
    meta = {
        'table_key': 'ACA_CHECK_ID',
        'tests': {
            'null_values':{
                'columns':[
                    'RDM_ACA_COUNTRY',
                    'RDM_ACA_CURRENCY_CODE',
                    'RDM_ACA_ORG_ID_LOOKUP_CODE',
                    'RDM_ACA_PAYMENT_METHOD_LOOKUP_CODE'
                ]
            }
        }    
    }
  )
}}

with raw_data_deduplicated as (

  SELECT *
  FROM {{ref('prep_cm50_ap_checks_all')}}
  QUALIFY ROW_NUMBER() OVER (PARTITION BY ACA_CHECK_ID ORDER BY 
  TO_TIMESTAMP_NTZ(
-- Some rows are formatted YYYYMMDD HH24MISS.FF and some are formatted YYYY-MM-DD HH24:MI:SS.FF
-- Simplest fix was to remove the extra characters and look for one format
  REPLACE(REPLACE(ACA_LAST_UPDATE_DATE::STRING, '-', ''), ':', ''), 
  'YYYYMMDD HH24MISS.FF') DESC) = 1
),

raw_data_typed as (
  SELECT 
    ACA_ADDRESS_LINE1::string AS ACA_ADDRESS_LINE1
  , ACA_ADDRESS_LINE2::string AS ACA_ADDRESS_LINE2
  , ACA_ADDRESS_LINE3::string AS ACA_ADDRESS_LINE3
  , ACA_ADDRESS_LINE4::string AS ACA_ADDRESS_LINE4
  , ACA_AMOUNT::number(38,2) AS ACA_AMOUNT
  , ACA_BASE_AMOUNT::number(38,2) AS ACA_BASE_AMOUNT
  , ACA_CHECKRUN_ID::number(38,0) AS ACA_CHECKRUN_ID
  , ACA_CHECKRUN_NAME::string AS ACA_CHECKRUN_NAME
  , TO_TIMESTAMP_NTZ(TRANSLATE(ACA_CHECK_DATE::string,'-:',' '),'YYYYMMDD HH24MISS.FF') AS ACA_CHECK_DATE
  , ACA_CHECK_FORMAT_ID::number(38,0) AS ACA_CHECK_FORMAT_ID
  , ACA_CHECK_ID::number(38,0) AS ACA_CHECK_ID
  , ACA_CHECK_NUMBER::number(38,0) AS ACA_CHECK_NUMBER
  , ACA_CHECK_STOCK_ID::number(38,0) AS ACA_CHECK_STOCK_ID
  , ACA_CHECK_VOUCHER_NUM::number(38,0) AS ACA_CHECK_VOUCHER_NUM
  , ACA_CITY::string AS ACA_CITY
  , ACA_CLEARED_AMOUNT::number(38,2) AS ACA_CLEARED_AMOUNT
  , TO_TIMESTAMP_NTZ(TRANSLATE(ACA_CLEARED_DATE::string,'-:',' '),'YYYYMMDD HH24MISS.FF') AS ACA_CLEARED_DATE
  , ACA_CMG_150_CHARACTERS::string AS ACA_CMG_150_CHARACTERS
  , ACA_COUNTRY::string AS ACA_COUNTRY
  , ACA_COUNTY::string AS ACA_COUNTY
  , ACA_CREATED_BY::number(38,0) AS ACA_CREATED_BY
  , TO_TIMESTAMP_NTZ(TRANSLATE(ACA_CREATION_DATE::string,'-:',' '),'YYYYMMDD HH24MISS.FF') AS ACA_CREATION_DATE
  , ACA_CURRENCY_CODE::string AS ACA_CURRENCY_CODE
  , TO_TIMESTAMP_NTZ(TRANSLATE(ACA_EXCHANGE_DATE::string,'-:',' '),'YYYYMMDD HH24MISS.FF') AS ACA_EXCHANGE_DATE
  , ACA_EXCHANGE_RATE::number(38,4) AS ACA_EXCHANGE_RATE
  , ACA_EXCHANGE_RATE_TYPE::string AS ACA_EXCHANGE_RATE_TYPE
  , ACA_LAST_UPDATED_BY::number(38,0) AS ACA_LAST_UPDATED_BY
  , TO_TIMESTAMP_NTZ(TRANSLATE(ACA_LAST_UPDATE_DATE::string,'-:',' '),'YYYYMMDD HH24MISS.FF') AS ACA_LAST_UPDATE_DATE
  , ACA_LAST_UPDATE_LOGIN::number(38,0) AS ACA_LAST_UPDATE_LOGIN
  , TO_TIMESTAMP_NTZ(TRANSLATE(ACA_MATURITY_EXCHANGE_DATE::string,'-:',' '),'YYYYMMDD HH24MISS.FF') AS ACA_MATURITY_EXCHANGE_DATE
  , ACA_MATURITY_EXCHANGE_RATE::number(38,4) AS ACA_MATURITY_EXCHANGE_RATE
  , ACA_MATURITY_EX_RATE_TYPE::string AS ACA_MATURITY_EX_RATE_TYPE
  , ACA_ORG_ID::number(38,0) AS ACA_ORG_ID
  , ACA_PAYMENT_METHOD_LOOKUP_CODE::string AS ACA_PAYMENT_METHOD_LOOKUP_CODE
  , ACA_PAYMENT_TYPE_FLAG::string AS ACA_PAYMENT_TYPE_FLAG
  , ACA_POSITIVE_PAY_STATUS_CODE::string AS ACA_POSITIVE_PAY_STATUS_CODE
  , ACA_PROVINCE::string AS ACA_PROVINCE
  , TO_TIMESTAMP_NTZ(TRANSLATE(ACA_RELEASED_AT::STRING, 'É' ,'E'), 'DD-MON-YY HH24:MI:SS') as ACA_RELEASED_AT
  , ACA_RELEASED_BY::number(38,0) AS ACA_RELEASED_BY
  , TO_TIMESTAMP_NTZ(TRANSLATE(ACA_RELEASED_DATE::string,'-:',' '), 'YYYYMMDD HH24MISS.FF') AS ACA_RELEASED_DATE
  , ACA_REQUEST_ID::number(38,0) AS ACA_REQUEST_ID
  , ACA_STATE::string AS ACA_STATE
  , ACA_STATUS_LOOKUP_CODE::string AS ACA_STATUS_LOOKUP_CODE
  , TO_TIMESTAMP_NTZ(REPLACE(ACA_STOPPED_AT::STRING, 'É' ,'E'), 'DD-MON-YY HH24:MI:SS') as ACA_STOPPED_AT
  , ACA_STOPPED_BY::number(38,0) AS ACA_STOPPED_BY
  , TO_TIMESTAMP_NTZ(TRANSLATE(ACA_STOPPED_DATE::string,'-:',' '),'YYYYMMDD HH24MISS.FF') AS ACA_STOPPED_DATE
  , ACA_VENDOR_ID::number(38,0) AS ACA_VENDOR_ID
  , ACA_VENDOR_NAME::string AS ACA_VENDOR_NAME
  , ACA_VENDOR_SITE_CODE::string AS ACA_VENDOR_SITE_CODE
  , ACA_VENDOR_SITE_ID AS ACA_VENDOR_SITE_ID
  , TO_TIMESTAMP_NTZ(TRANSLATE(ACA_VOID_DATE::string,'-:',' '),'YYYYMMDD HH24MISS.FF') AS ACA_VOID_DATE
  , ACA_ZIP::string AS ACA_ZIP
  , ACA_BANK_ACCOUNT_NAME::string AS ACA_BANK_ACCOUNT_NAME
  , ACA_BANK_ACCOUNT_NUM::number AS ACA_BANK_ACCOUNT_NUM
  from raw_data_deduplicated),
rdm_oracle_country as 
  (SELECT distinct Business_Application_Value, Standard_Application_Value
  from {{ref('gov_referencedata_rdm')}}
  where Business_Application_Code='oracle-ebs'
  and Business_Application_Domain_Code='Country'),
rdm_oracle_currency as 
  (SELECT distinct Business_Application_Value, Standard_Application_Value
  from {{ref('gov_referencedata_rdm')}}
  where Business_Application_Code='oracle-ebs'
  and Business_Application_Domain_Code='Currency'),
rdm_oracle_paymentmethod as 
  (SELECT distinct Business_Application_Value, Standard_Application_Value
  from {{ref('gov_referencedata_rdm')}}
  where Business_Application_Code='oracle-ebs'
  and Business_Application_Domain_Code='PaymentMethod'),
rdm_oracle_logisticcompany as
  (SELECT distinct Business_Application_Value, Standard_Application_Value
  from {{ref('gov_referencedata_rdm')}}
  where Business_Application_Code='oracle-ebs'
  and Business_Application_Domain_Code='LogisticCompany')

select 
raw_data_typed.ACA_ADDRESS_LINE1 as ACA_ADDRESS_LINE1
, raw_data_typed.ACA_ADDRESS_LINE2 as ACA_ADDRESS_LINE2
, raw_data_typed.ACA_ADDRESS_LINE3 as ACA_ADDRESS_LINE3
, raw_data_typed.ACA_ADDRESS_LINE4 as ACA_ADDRESS_LINE4
, raw_data_typed.ACA_AMOUNT as ACA_AMOUNT
, raw_data_typed.ACA_BASE_AMOUNT as ACA_BASE_AMOUNT
, raw_data_typed.ACA_CHECKRUN_ID as ACA_CHECKRUN_ID
, raw_data_typed.ACA_CHECKRUN_NAME as ACA_CHECKRUN_NAME
, raw_data_typed.ACA_CHECK_DATE as ACA_CHECK_DATE
, raw_data_typed.ACA_CHECK_FORMAT_ID as ACA_CHECK_FORMAT_ID
, raw_data_typed.ACA_CHECK_ID as ACA_CHECK_ID
, raw_data_typed.ACA_CHECK_NUMBER as ACA_CHECK_NUMBER
, raw_data_typed.ACA_CHECK_STOCK_ID as ACA_CHECK_STOCK_ID
, raw_data_typed.ACA_CHECK_VOUCHER_NUM as ACA_CHECK_VOUCHER_NUM
, raw_data_typed.ACA_CITY as ACA_CITY
, raw_data_typed.ACA_CLEARED_AMOUNT as ACA_CLEARED_AMOUNT
, raw_data_typed.ACA_CLEARED_DATE as ACA_CLEARED_DATE
, raw_data_typed.ACA_CMG_150_CHARACTERS as ACA_CMG_150_CHARACTERS
, raw_data_typed.ACA_COUNTRY as ACA_COUNTRY
, rdm_oracle_country.Standard_Application_Value as RDM_ACA_COUNTRY
, raw_data_typed.ACA_COUNTY as ACA_COUNTY
, raw_data_typed.ACA_CREATED_BY as ACA_CREATED_BY
, raw_data_typed.ACA_CREATION_DATE as ACA_CREATION_DATE
, raw_data_typed.ACA_CURRENCY_CODE as ACA_CURRENCY_CODE
, rdm_oracle_currency.Standard_Application_Value as RDM_ACA_CURRENCY_CODE
, raw_data_typed.ACA_EXCHANGE_DATE as ACA_EXCHANGE_DATE
, raw_data_typed.ACA_EXCHANGE_RATE as ACA_EXCHANGE_RATE
, raw_data_typed.ACA_EXCHANGE_RATE_TYPE as ACA_EXCHANGE_RATE_TYPE
, raw_data_typed.ACA_LAST_UPDATED_BY as ACA_LAST_UPDATED_BY
, raw_data_typed.ACA_LAST_UPDATE_DATE as ACA_LAST_UPDATE_DATE
, raw_data_typed.ACA_LAST_UPDATE_LOGIN as ACA_LAST_UPDATE_LOGIN
, raw_data_typed.ACA_MATURITY_EXCHANGE_DATE as ACA_MATURITY_EXCHANGE_DATE
, raw_data_typed.ACA_MATURITY_EXCHANGE_RATE as ACA_MATURITY_EXCHANGE_RATE
, raw_data_typed.ACA_MATURITY_EX_RATE_TYPE as ACA_MATURITY_EX_RATE_TYPE
, rdm_oracle_logisticcompany.Standard_Application_Value as RDM_ACA_ORG_ID_LOOKUP_CODE
, raw_data_typed.ACA_PAYMENT_METHOD_LOOKUP_CODE as ACA_PAYMENT_METHOD_LOOKUP_CODE
, rdm_oracle_paymentmethod.Standard_Application_Value as RDM_ACA_PAYMENT_METHOD_LOOKUP_CODE
, raw_data_typed.ACA_PAYMENT_TYPE_FLAG as ACA_PAYMENT_TYPE_FLAG
, raw_data_typed.ACA_POSITIVE_PAY_STATUS_CODE as ACA_POSITIVE_PAY_STATUS_CODE
, raw_data_typed.ACA_PROVINCE as ACA_PROVINCE
, raw_data_typed.ACA_RELEASED_AT as ACA_RELEASED_AT
, raw_data_typed.ACA_RELEASED_BY as ACA_RELEASED_BY
, raw_data_typed.ACA_RELEASED_DATE as ACA_RELEASED_DATE
, raw_data_typed.ACA_REQUEST_ID as ACA_REQUEST_ID
, raw_data_typed.ACA_STATE as ACA_STATE
, raw_data_typed.ACA_STATUS_LOOKUP_CODE as ACA_STATUS_LOOKUP_CODE
, raw_data_typed.ACA_STOPPED_AT as ACA_STOPPED_AT
, raw_data_typed.ACA_STOPPED_BY as ACA_STOPPED_BY
, raw_data_typed.ACA_STOPPED_DATE as ACA_STOPPED_DATE
, raw_data_typed.ACA_VENDOR_ID as ACA_VENDOR_ID
, raw_data_typed.ACA_VENDOR_NAME as ACA_VENDOR_NAME
, raw_data_typed.ACA_VENDOR_SITE_CODE as ACA_VENDOR_SITE_CODE
, raw_data_typed.ACA_VENDOR_SITE_ID as ACA_VENDOR_SITE_ID
, raw_data_typed.ACA_VOID_DATE as ACA_VOID_DATE
, raw_data_typed.ACA_ZIP as ACA_ZIP
, raw_data_typed.ACA_BANK_ACCOUNT_NAME AS ACA_BANK_ACCOUNT_NAME
, raw_data_typed.ACA_BANK_ACCOUNT_NUM AS ACA_BANK_ACCOUNT_NUM
from raw_data_typed
left join rdm_oracle_country
on raw_data_typed.ACA_COUNTRY=rdm_oracle_country.Business_Application_Value
left join rdm_oracle_currency
on raw_data_typed.ACA_CURRENCY_CODE=rdm_oracle_currency.Business_Application_Value
left join rdm_oracle_paymentmethod
on raw_data_typed.ACA_PAYMENT_METHOD_LOOKUP_CODE=rdm_oracle_paymentmethod.Business_Application_Value
left join rdm_oracle_logisticcompany
on raw_data_typed.ACA_ORG_ID::string = rdm_oracle_logisticcompany.Business_Application_Value::string
where
raw_data_typed.ACA_VENDOR_SITE_ID IS NOT null
AND raw_data_typed.ACA_CHECK_NUMBER NOT IN ('20000915','100001500')