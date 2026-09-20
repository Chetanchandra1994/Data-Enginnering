{{
  config(
    materialized = "view",
    alias = "cm50_po_supplier_site",
    schema='EBS',
    meta = {
        'table_key': 'PVS_VENDOR_SITE_ID',
        'tests': {
            'null_values':{
                'columns':[
                    'RDM_PVS_PAYMENT_METHOD_LOOKUP_CODE',
                    'RDM_PVS_PAYMENT_CURRENCY_CODE',
                    'RDM_PVS_LANGUAGE',
                    'RDM_PVS_INVOICE_CURRENCY_CODE',
                    'RDM_PVS_COUNTRY',
                    'RDM_ATE_TERM_ID'
                ]
            }
        }
    }
  )
}}

with raw_data_deduplicated as (

  SELECT *
  FROM {{ref('prep_cm50_po_supplier_site')}}
  QUALIFY ROW_NUMBER() OVER (PARTITION BY PVS_VENDOR_SITE_ID ORDER BY TO_TIMESTAMP_NTZ(PVS_LAST_UPDATE_DATE) DESC) = 1 

),

raw_data_typed as (
    SELECT 
    ATE_DESCRIPTION::string as ATE_DESCRIPTION
    , ATE_ENABLED_FLAG::string as ATE_ENABLED_FLAG
    , ATE_NAME::string as ATE_NAME
    , ATE_START_DATE_ACTIVE::date as ATE_START_DATE_ACTIVE
    , ATE_TERM_ID::number(38,0) as ATE_TERM_ID
    , ATE_TYPE::string as ATE_TYPE
    , FNT_CREATED_BY::number(38,0) as FNT_CREATED_BY
    , TO_TIMESTAMP_NTZ(FNT_CREATION_DATE) as FNT_CREATION_DATE
    , FNT_EU_CODE::string as FNT_EU_CODE
    , FNT_ISO_NUMERIC_CODE::string as FNT_ISO_NUMERIC_CODE
    , FNT_ISO_TERRITORY_CODE::string as FNT_ISO_TERRITORY_CODE
    , FNT_LAST_UPDATED_BY::number(38,0) as FNT_LAST_UPDATED_BY
    , FNT_LAST_UPDATE_DATE::date as FNT_LAST_UPDATE_DATE
    , FNT_LAST_UPDATE_LOGIN::number(38,0) as FNT_LAST_UPDATE_LOGIN
    , FNT_NLS_TERRITORY::string as FNT_NLS_TERRITORY
    , FNT_OBSOLETE_FLAG::string as FNT_OBSOLETE_FLAG
    , FNT_TERRITORY_CODE::string as FNT_TERRITORY_CODE
    , PVS_ACCTS_PAY_CODE_COMB_ID::number(38,0) as PVS_ACCTS_PAY_CODE_COMB_ID
    , PVS_ADDRESS_LINE1::string as PVS_ADDRESS_LINE1
    , PVS_ADDRESS_LINE2::string as PVS_ADDRESS_LINE2
    , PVS_ADDRESS_LINE3::string as PVS_ADDRESS_LINE3
    , PVS_ADDRESS_LINE4::string as PVS_ADDRESS_LINE4
    , PVS_ADDRESS_LINES_ALT::string as PVS_ADDRESS_LINES_ALT
    , PVS_ALLOW_AWT_FLAG::string as PVS_ALLOW_AWT_FLAG
    , PVS_ALWAYS_TAKE_DISC_FLAG::string as PVS_ALWAYS_TAKE_DISC_FLAG
    , PVS_AMOUNT_INCLUDES_TAX_FLAG::string as PVS_AMOUNT_INCLUDES_TAX_FLAG
    , PVS_AP_TAX_ROUNDING_RULE::string as PVS_AP_TAX_ROUNDING_RULE
    , PVS_AREA_CODE::string as PVS_AREA_CODE
    , PVS_ATTENTION_AR_FLAG::string as PVS_ATTENTION_AR_FLAG
    , PVS_AUTO_TAX_CALC_FLAG::string as PVS_AUTO_TAX_CALC_FLAG
    , PVS_AUTO_TAX_CALC_OVERRIDE::string as PVS_AUTO_TAX_CALC_OVERRIDE
    , PVS_BANK_ACCOUNT_NAME::string as PVS_BANK_ACCOUNT_NAME
    , PVS_BANK_ACCOUNT_NUM::string as PVS_BANK_ACCOUNT_NUM
    , PVS_BANK_CHARGE_BEARER::string as PVS_BANK_CHARGE_BEARER
    , PVS_BANK_NUM::string as PVS_BANK_NUM
    , PVS_BANK_NUMBER::string as PVS_BANK_NUMBER
    , PVS_BILL_TO_LOCATION_ID::number(38,0) as PVS_BILL_TO_LOCATION_ID
    , PVS_CAN_SPM_VENDOR_NUMBER::string as PVS_CAN_SPM_VENDOR_NUMBER
    , PVS_CITY::string as PVS_CITY
    , PVS_COUNTRY::string as PVS_COUNTRY
    , PVS_COUNTY::string as PVS_COUNTY
    , PVS_CREATED_BY::number(38,0) as PVS_CREATED_BY
    , PVS_CREATE_DEBIT_MEMO_FLAG::string as PVS_CREATE_DEBIT_MEMO_FLAG
    , TO_TIMESTAMP_NTZ(PVS_CREATION_DATE) as PVS_CREATION_DATE
    , PVS_CUSTOMER_NUM::string as PVS_CUSTOMER_NUM
    , PVS_DISTRIBUTION_SET_ID::number(38,0) as PVS_DISTRIBUTION_SET_ID
    , PVS_EDI_TRANSACTION_HANDLING::string as PVS_EDI_TRANSACTION_HANDLING
    , PVS_EMAIL::string  as PVS_EMAIL
    , PVS_EMAIL_ADDRESS::string as PVS_EMAIL_ADDRESS
    , PVS_EXCLUSIVE_PAYMENT_FLAG::string as PVS_EXCLUSIVE_PAYMENT_FLAG
    , PVS_EXCLU_FREIGHT_FR_DISCOUNT::string as PVS_EXCLU_FREIGHT_FR_DISCOUNT
    , PVS_EXCLU_TAXES_FR_DISCOUNT::number(38,0) as PVS_EXCLU_TAXES_FR_DISCOUNT
    , PVS_FAX::string as PVS_FAX
    , PVS_FAX_AREA_CODE::string as PVS_FAX_AREA_CODE
    , PVS_FREIGHT_TERMS_LOOKUP_CODE::string as PVS_FREIGHT_TERMS_LOOKUP_CODE
    , PVS_GST_HST_NUMBER::string as PVS_GST_HST_NUMBER
    , PVS_HOLD_ALL_PAYMENTS_FLAG::string as PVS_HOLD_ALL_PAYMENTS_FLAG
    , PVS_HOLD_FUTURE_PAYMENTS_FLAG::string as PVS_HOLD_FUTURE_PAYMENTS_FLAG
    , PVS_HOLD_REASON::string as PVS_HOLD_REASON
    , PVS_HOLD_UNMATCHED_INV_FLAG::string as PVS_HOLD_UNMATCHED_INV_FLAG
    , PVS_INACTIVE_DATE::date as PVS_INACTIVE_DATE
    , PVS_INVOICE_CURRENCY_CODE::string as PVS_INVOICE_CURRENCY_CODE
    , PVS_LANGUAGE::string as PVS_LANGUAGE
    , PVS_LAST_UPDATED_BY::number(38,0) as PVS_LAST_UPDATED_BY
    , TO_TIMESTAMP_NTZ(PVS_LAST_UPDATE_DATE) as PVS_LAST_UPDATE_DATE
    , PVS_LAST_UPDATE_LOGIN::number(38,0) as PVS_LAST_UPDATE_LOGIN
    , PVS_MATCH_OPTION::string as PVS_MATCH_OPTION
    , PVS_OFFSET_TAX_FLAG::string as PVS_OFFSET_TAX_FLAG
    , PVS_ORG_ID::number(38,0) as PVS_ORG_ID
    , PVS_PAYMENT_CURRENCY_CODE::string as PVS_PAYMENT_CURRENCY_CODE
    , PVS_PAYMENT_METHOD::string as PVS_PAYMENT_METHOD
    , PVS_PAYMENT_METHOD_LOOKUP_CODE::string as PVS_PAYMENT_METHOD_LOOKUP_CODE
    , PVS_PAYMENT_PRIORITY::number(38,0) as PVS_PAYMENT_PRIORITY
    , PVS_PAY_DATE_BASIS_LOOKUP_CODE::string as PVS_PAY_DATE_BASIS_LOOKUP_CODE
    , PVS_PAY_GROUP_LOOKUP_CODE::string as PVS_PAY_GROUP_LOOKUP_CODE
    , PVS_PAY_SITE_FLAG::string as PVS_PAY_SITE_FLAG
    , PVS_PCARD_SITE_FLAG::string as PVS_PCARD_SITE_FLAG
    , PVS_PHONE::string  as PVS_PHONE
    , PVS_PREPAY_CODE_COMBINATION_ID::number(38,0) as PVS_PREPAY_CODE_COMBINATION_ID
    , PVS_PRIMARY_PAY_SITE_FLAG::string as PVS_PRIMARY_PAY_SITE_FLAG
    , PVS_PROVINCE::string as PVS_PROVINCE
    , PVS_PURCHASING_SITE_FLAG::string as PVS_PURCHASING_SITE_FLAG
    , PVS_PURCHASING_SPN::string as PVS_PURCHASING_SPN
    , PVS_QST_NUMBER::string as PVS_QST_NUMBER
    , PVS_RFQ_ONLY_SITE_FLAG::string as PVS_RFQ_ONLY_SITE_FLAG
    , PVS_SHIP_VIA_LOOKUP_CODE::string as PVS_SHIP_VIA_LOOKUP_CODE
    , PVS_STATE::string as PVS_STATE
    , PVS_TAX_REPORTING_SITE_FLAG::string as PVS_TAX_REPORTING_SITE_FLAG
    , PVS_TELEX::string as PVS_TELEX
    , PVS_TERMS_DATE_BASIS::string as PVS_TERMS_DATE_BASIS
    , PVS_TERMS_ID::number(38,0) as PVS_TERMS_ID
    , PVS_TOLERANCE_ID::number(38,0) as PVS_TOLERANCE_ID
    , PVS_USA_SPM_VENDOR_NUMBER::string as PVS_USA_SPM_VENDOR_NUMBER
    , PVS_VALIDATION_NUMBER::number(38,0) as PVS_VALIDATION_NUMBER
    , PVS_VAT_CODE::string as PVS_VAT_CODE
    , PVS_VAT_REGISTRATION_NUM::string as PVS_VAT_REGISTRATION_NUM
    , PVS_VENDOR_ID::number(38,0) as PVS_VENDOR_ID
    , PVS_VENDOR_SITE_CODE::string as PVS_VENDOR_SITE_CODE
    , PVS_VENDOR_SITE_CODE_ALT::string as PVS_VENDOR_SITE_CODE_ALT
    , PVS_VENDOR_SITE_ID::number(38,0) as PVS_VENDOR_SITE_ID
    , PVS_ZIP::string as PVS_ZIP
    , SRC_SYSTEM_OPERATION::string as SRC_SYSTEM_OPERATION
    FROM raw_data_deduplicated),
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
rdm_oracle_language as 
  (SELECT distinct Business_Application_Value, Standard_Application_Value
  from {{ref('gov_referencedata_rdm')}}
  where Business_Application_Code='oracle-ebs'
  and Business_Application_Domain_Code='Language'),
rdm_oracle_paymentmethod as 
  (SELECT distinct Business_Application_Value, Standard_Application_Value
  from {{ref('gov_referencedata_rdm')}}
  where Business_Application_Code='oracle-ebs'
  and Business_Application_Domain_Code='PaymentMethod'),
rdm_oracle_paymentterm as 
  (SELECT distinct Business_Application_Value, Standard_Application_Value
  from {{ref('gov_referencedata_rdm')}}
  where Business_Application_Code='oracle-ebs'
  and Business_Application_Domain_Code='PaymentTerm'),
with_rdm as (
select  
raw_data_typed.ATE_DESCRIPTION AS ATE_DESCRIPTION
, raw_data_typed.ATE_ENABLED_FLAG AS ATE_ENABLED_FLAG
, raw_data_typed.ATE_NAME AS ATE_NAME
, raw_data_typed.ATE_START_DATE_ACTIVE AS ATE_START_DATE_ACTIVE
, raw_data_typed.ATE_TERM_ID AS ATE_TERM_ID
, ate_payment_term.Standard_Application_Value AS RDM_ATE_TERM_ID
, raw_data_typed.ATE_TYPE AS ATE_TYPE
, raw_data_typed.FNT_CREATED_BY AS FNT_CREATED_BY
, raw_data_typed.FNT_CREATION_DATE AS FNT_CREATION_DATE
, raw_data_typed.FNT_EU_CODE AS FNT_EU_CODE
, raw_data_typed.FNT_ISO_NUMERIC_CODE AS FNT_ISO_NUMERIC_CODE
, raw_data_typed.FNT_ISO_TERRITORY_CODE AS FNT_ISO_TERRITORY_CODE
, raw_data_typed.FNT_LAST_UPDATED_BY AS FNT_LAST_UPDATED_BY
, raw_data_typed.FNT_LAST_UPDATE_DATE AS FNT_LAST_UPDATE_DATE
, raw_data_typed.FNT_LAST_UPDATE_LOGIN AS FNT_LAST_UPDATE_LOGIN
, raw_data_typed.FNT_NLS_TERRITORY AS FNT_NLS_TERRITORY
, raw_data_typed.FNT_OBSOLETE_FLAG AS FNT_OBSOLETE_FLAG
, raw_data_typed.FNT_TERRITORY_CODE AS FNT_TERRITORY_CODE
, raw_data_typed.PVS_ACCTS_PAY_CODE_COMB_ID AS PVS_ACCTS_PAY_CODE_COMB_ID
, raw_data_typed.PVS_ADDRESS_LINE1 AS PVS_ADDRESS_LINE1
, raw_data_typed.PVS_ADDRESS_LINE2 AS PVS_ADDRESS_LINE2
, raw_data_typed.PVS_ADDRESS_LINE3 AS PVS_ADDRESS_LINE3
, raw_data_typed.PVS_ADDRESS_LINE4 AS PVS_ADDRESS_LINE4
, raw_data_typed.PVS_ADDRESS_LINES_ALT AS PVS_ADDRESS_LINES_ALT
, raw_data_typed.PVS_ALLOW_AWT_FLAG AS PVS_ALLOW_AWT_FLAG
, raw_data_typed.PVS_ALWAYS_TAKE_DISC_FLAG AS PVS_ALWAYS_TAKE_DISC_FLAG
, raw_data_typed.PVS_AMOUNT_INCLUDES_TAX_FLAG AS PVS_AMOUNT_INCLUDES_TAX_FLAG
, raw_data_typed.PVS_AP_TAX_ROUNDING_RULE AS PVS_AP_TAX_ROUNDING_RULE
, raw_data_typed.PVS_AREA_CODE AS PVS_AREA_CODE
, raw_data_typed.PVS_ATTENTION_AR_FLAG AS PVS_ATTENTION_AR_FLAG
, raw_data_typed.PVS_AUTO_TAX_CALC_FLAG AS PVS_AUTO_TAX_CALC_FLAG
, raw_data_typed.PVS_AUTO_TAX_CALC_OVERRIDE AS PVS_AUTO_TAX_CALC_OVERRIDE
, raw_data_typed.PVS_BANK_ACCOUNT_NAME AS PVS_BANK_ACCOUNT_NAME
, raw_data_typed.PVS_BANK_ACCOUNT_NUM AS PVS_BANK_ACCOUNT_NUM
, raw_data_typed.PVS_BANK_CHARGE_BEARER AS PVS_BANK_CHARGE_BEARER
, raw_data_typed.PVS_BANK_NUM AS PVS_BANK_NUM
, raw_data_typed.PVS_BANK_NUMBER AS PVS_BANK_NUMBER
, raw_data_typed.PVS_BILL_TO_LOCATION_ID AS PVS_BILL_TO_LOCATION_ID
, raw_data_typed.PVS_CAN_SPM_VENDOR_NUMBER AS PVS_CAN_SPM_VENDOR_NUMBER
, raw_data_typed.PVS_CITY AS PVS_CITY
, raw_data_typed.PVS_COUNTRY AS PVS_COUNTRY
, rdm_oracle_country.Standard_Application_Value AS RDM_PVS_COUNTRY
, raw_data_typed.PVS_COUNTY AS PVS_COUNTY
, raw_data_typed.PVS_CREATED_BY AS PVS_CREATED_BY
, raw_data_typed.PVS_CREATE_DEBIT_MEMO_FLAG AS PVS_CREATE_DEBIT_MEMO_FLAG
, raw_data_typed.PVS_CREATION_DATE AS PVS_CREATION_DATE
, raw_data_typed.PVS_CUSTOMER_NUM AS PVS_CUSTOMER_NUM
, raw_data_typed.PVS_DISTRIBUTION_SET_ID AS PVS_DISTRIBUTION_SET_ID
, raw_data_typed.PVS_EDI_TRANSACTION_HANDLING AS PVS_EDI_TRANSACTION_HANDLING
, raw_data_typed.PVS_EMAIL AS PVS_EMAIL
, raw_data_typed.PVS_EMAIL_ADDRESS AS PVS_EMAIL_ADDRESS
, raw_data_typed.PVS_EXCLUSIVE_PAYMENT_FLAG AS PVS_EXCLUSIVE_PAYMENT_FLAG
, raw_data_typed.PVS_EXCLU_FREIGHT_FR_DISCOUNT AS PVS_EXCLU_FREIGHT_FR_DISCOUNT
, raw_data_typed.PVS_EXCLU_TAXES_FR_DISCOUNT AS PVS_EXCLU_TAXES_FR_DISCOUNT
, raw_data_typed.PVS_FAX AS PVS_FAX
, raw_data_typed.PVS_FAX_AREA_CODE AS PVS_FAX_AREA_CODE
, raw_data_typed.PVS_FREIGHT_TERMS_LOOKUP_CODE AS PVS_FREIGHT_TERMS_LOOKUP_CODE
, raw_data_typed.PVS_GST_HST_NUMBER AS PVS_GST_HST_NUMBER
, raw_data_typed.PVS_HOLD_ALL_PAYMENTS_FLAG AS PVS_HOLD_ALL_PAYMENTS_FLAG
, raw_data_typed.PVS_HOLD_FUTURE_PAYMENTS_FLAG AS PVS_HOLD_FUTURE_PAYMENTS_FLAG
, raw_data_typed.PVS_HOLD_REASON AS PVS_HOLD_REASON
, raw_data_typed.PVS_HOLD_UNMATCHED_INV_FLAG AS PVS_HOLD_UNMATCHED_INV_FLAG
, raw_data_typed.PVS_INACTIVE_DATE AS PVS_INACTIVE_DATE
, raw_data_typed.PVS_INVOICE_CURRENCY_CODE AS PVS_INVOICE_CURRENCY_CODE
, invoice_currency_code.Standard_Application_Value AS RDM_PVS_INVOICE_CURRENCY_CODE
, raw_data_typed.PVS_LANGUAGE AS PVS_LANGUAGE
, rdm_oracle_language.Standard_Application_Value AS RDM_PVS_LANGUAGE
, raw_data_typed.PVS_LAST_UPDATED_BY AS PVS_LAST_UPDATED_BY
, raw_data_typed.PVS_LAST_UPDATE_DATE AS PVS_LAST_UPDATE_DATE
, raw_data_typed.PVS_LAST_UPDATE_LOGIN AS PVS_LAST_UPDATE_LOGIN
, raw_data_typed.PVS_MATCH_OPTION AS PVS_MATCH_OPTION
, raw_data_typed.PVS_OFFSET_TAX_FLAG AS PVS_OFFSET_TAX_FLAG
, raw_data_typed.PVS_ORG_ID AS PVS_ORG_ID
, raw_data_typed.PVS_PAYMENT_CURRENCY_CODE AS PVS_PAYMENT_CURRENCY_CODE
, payment_currency_code.Standard_Application_Value AS RDM_PVS_PAYMENT_CURRENCY_CODE
, raw_data_typed.PVS_PAYMENT_METHOD AS PVS_PAYMENT_METHOD
, raw_data_typed.PVS_PAYMENT_METHOD_LOOKUP_CODE AS PVS_PAYMENT_METHOD_LOOKUP_CODE
, rdm_oracle_paymentmethod.Standard_Application_Value AS RDM_PVS_PAYMENT_METHOD_LOOKUP_CODE
, raw_data_typed.PVS_PAYMENT_PRIORITY AS PVS_PAYMENT_PRIORITY
, raw_data_typed.PVS_PAY_DATE_BASIS_LOOKUP_CODE AS PVS_PAY_DATE_BASIS_LOOKUP_CODE
, raw_data_typed.PVS_PAY_GROUP_LOOKUP_CODE AS PVS_PAY_GROUP_LOOKUP_CODE
, raw_data_typed.PVS_PAY_SITE_FLAG AS PVS_PAY_SITE_FLAG
, raw_data_typed.PVS_PCARD_SITE_FLAG AS PVS_PCARD_SITE_FLAG
, raw_data_typed.PVS_PHONE AS PVS_PHONE
, raw_data_typed.PVS_PREPAY_CODE_COMBINATION_ID AS PVS_PREPAY_CODE_COMBINATION_ID
, raw_data_typed.PVS_PRIMARY_PAY_SITE_FLAG AS PVS_PRIMARY_PAY_SITE_FLAG
, raw_data_typed.PVS_PROVINCE AS PVS_PROVINCE
, raw_data_typed.PVS_PURCHASING_SITE_FLAG AS PVS_PURCHASING_SITE_FLAG
, raw_data_typed.PVS_PURCHASING_SPN AS PVS_PURCHASING_SPN
, raw_data_typed.PVS_QST_NUMBER AS PVS_QST_NUMBER
, raw_data_typed.PVS_RFQ_ONLY_SITE_FLAG AS PVS_RFQ_ONLY_SITE_FLAG
, raw_data_typed.PVS_SHIP_VIA_LOOKUP_CODE AS PVS_SHIP_VIA_LOOKUP_CODE
, raw_data_typed.PVS_STATE AS PVS_STATE
, raw_data_typed.PVS_TAX_REPORTING_SITE_FLAG AS PVS_TAX_REPORTING_SITE_FLAG
, raw_data_typed.PVS_TELEX AS PVS_TELEX
, raw_data_typed.PVS_TERMS_DATE_BASIS AS PVS_TERMS_DATE_BASIS
, raw_data_typed.PVS_TERMS_ID AS PVS_TERMS_ID
, raw_data_typed.PVS_TOLERANCE_ID AS PVS_TOLERANCE_ID
, raw_data_typed.PVS_USA_SPM_VENDOR_NUMBER AS PVS_USA_SPM_VENDOR_NUMBER
, raw_data_typed.PVS_VALIDATION_NUMBER AS PVS_VALIDATION_NUMBER
, raw_data_typed.PVS_VAT_CODE AS PVS_VAT_CODE
, raw_data_typed.PVS_VAT_REGISTRATION_NUM AS PVS_VAT_REGISTRATION_NUM
, raw_data_typed.PVS_VENDOR_ID AS PVS_VENDOR_ID
, raw_data_typed.PVS_VENDOR_SITE_CODE AS PVS_VENDOR_SITE_CODE
, raw_data_typed.PVS_VENDOR_SITE_CODE_ALT AS PVS_VENDOR_SITE_CODE_ALT
, raw_data_typed.PVS_VENDOR_SITE_ID AS PVS_VENDOR_SITE_ID
, raw_data_typed.PVS_ZIP AS PVS_ZIP
, raw_data_typed.SRC_SYSTEM_OPERATION AS SRC_SYSTEM_OPERATION
from raw_data_typed
left join rdm_oracle_country
on raw_data_typed.PVS_COUNTRY=rdm_oracle_country.Business_Application_Value
left join rdm_oracle_currency as invoice_currency_code
on raw_data_typed.PVS_INVOICE_CURRENCY_CODE=invoice_currency_code.Business_Application_Value
left join rdm_oracle_currency as payment_currency_code
on raw_data_typed.PVS_PAYMENT_CURRENCY_CODE=payment_currency_code.Business_Application_Value
left join rdm_oracle_language
on raw_data_typed.PVS_LANGUAGE=rdm_oracle_language.Business_Application_Value
left join rdm_oracle_paymentmethod
on raw_data_typed.PVS_PAYMENT_METHOD_LOOKUP_CODE=rdm_oracle_paymentmethod.Business_Application_Value
left join rdm_oracle_paymentterm as ate_payment_term
on raw_data_typed.ATE_TERM_ID::string=ate_payment_term.Business_Application_Value::string
left join rdm_oracle_paymentterm as pvs_payment_term
on raw_data_typed.PVS_TERMS_ID::string=pvs_payment_term.Business_Application_Value::string)

select 
* 
from with_rdm



