{{
  config(
    materialized = "view",
    alias = "cm50_ap_invoices_all",
    schema='EBS',
    meta = {
        'table_key': 'AIA_INVOICE_ID',
        'tests': {
            'null_values':{
                'columns':[
                    'RDM_AIA_TERMS_ID',
                    'RDM_AIA_PAYMENT_METHOD_LOOKUP_CODE',
                    'RDM_AIA_PAYMENT_CURRENCY_CODE',
                    'RDM_AIA_ORG_ID_LOOKUP_CODE',
                    'RDM_AIA_INVOICE_CURRENCY_CODE'
                ]
            }
        }
    }
  )
}}

with raw_data_deduplicated as (

  SELECT *
  FROM {{ref('prep_cm50_ap_invoices_all')}}
  QUALIFY ROW_NUMBER() OVER (PARTITION BY AIA_INVOICE_ID ORDER BY TO_TIMESTAMP_NTZ(AIA_LAST_UPDATE_DATE) DESC) = 1 

),

raw_data_typed as (
    SELECT 
    AIA_ACCTS_PAY_CC_ID::number(38,0) as AIA_ACCTS_PAY_CC_ID
    , AIA_AMOUNT_APP_TO_DISCOUNT::number(38,3) as AIA_AMOUNT_APP_TO_DISCOUNT
    , AIA_AMOUNT_PAID::number(38,2) as AIA_AMOUNT_PAID
    , AIA_APPROVAL_DESCRIPTION::string as AIA_APPROVAL_DESCRIPTION
    , AIA_APPROVAL_ITERATION::number(38,0) as AIA_APPROVAL_ITERATION
    , AIA_APPROVAL_READY_FLAG::string as AIA_APPROVAL_READY_FLAG
    , AIA_APPROVED_AMOUNT::number(38,3) as AIA_APPROVED_AMOUNT
    , AIA_ATTRIBUTE_CATEGORY::string as AIA_ATTRIBUTE_CATEGORY
    , AIA_AUTO_TAX_CALC_FLAG::string as AIA_AUTO_TAX_CALC_FLAG
    , AIA_AWT_FLAG::string as AIA_AWT_FLAG
    , AIA_BASE_AMOUNT::number(38,2) as AIA_BASE_AMOUNT
    , AIA_BATCH_ID::number(38,0) as AIA_BATCH_ID
    , AIA_CANCELLED_AMOUNT::number(38,3) as AIA_CANCELLED_AMOUNT
    , AIA_CANCELLED_BY::number(38,0) as AIA_CANCELLED_BY
    , AIA_CANCELLED_DATE::date as AIA_CANCELLED_DATE
    , AIA_CMG_AP_APPROVER::number(38,0) as AIA_CMG_AP_APPROVER
    , AIA_CMG_AP_FAPPROVER::number(38,0) as AIA_CMG_AP_FAPPROVER
    , AIA_CMG_AP_MODEL_NO::string as AIA_CMG_AP_MODEL_NO
    , AIA_CMG_AP_REMIT_TO::string as AIA_CMG_AP_REMIT_TO
    , AIA_CMG_AP_SERIAL_NO::string as AIA_CMG_AP_SERIAL_NO
    , AIA_CMG_FA_PRODN_LINE::string as AIA_CMG_FA_PRODN_LINE
    , AIA_CMG_GL_DETAIL_ACTIVITY::string as AIA_CMG_GL_DETAIL_ACTIVITY
    , AIA_CMG_GL_LOCATION::string as AIA_CMG_GL_LOCATION
    , AIA_CMG_PO_FLEET_WK_ORDER::string as AIA_CMG_PO_FLEET_WK_ORDER
    , AIA_CMG_PO_MANUF_NAME::string as AIA_CMG_PO_MANUF_NAME
    , AIA_CMG_PO_PHSE1A_PROJECT::string as AIA_CMG_PO_PHSE1A_PROJECT
    , AIA_CMG_PO_PHSE1A_TR_TYPE::string as AIA_CMG_PO_PHSE1A_TR_TYPE
    , AIA_CMG_PO_TAG_NUMBER::string as AIA_CMG_PO_TAG_NUMBER
    , AIA_CREATED_BY::number(38,0) as AIA_CREATED_BY
    , TO_TIMESTAMP_NTZ(AIA_CREATION_DATE) as AIA_CREATION_DATE
    , AIA_DESCRIPTION::string as AIA_DESCRIPTION
    , AIA_DISCOUNT_AMOUNT_TAKEN::number(38,2) as AIA_DISCOUNT_AMOUNT_TAKEN
    , AIA_EARLIEST_SETTLEMENT_DATE::date as AIA_EARLIEST_SETTLEMENT_DATE
    , TRY_TO_DATE(AIA_EXCHANGE_DATE::string) as AIA_EXCHANGE_DATE
    , AIA_EXCHANGE_RATE::number(38,16) as AIA_EXCHANGE_RATE
    , AIA_EXCHANGE_RATE_TYPE::string as AIA_EXCHANGE_RATE_TYPE
    , AIA_EXCLUSIVE_PAYMENT_FLAG::string as AIA_EXCLUSIVE_PAYMENT_FLAG
    , AIA_EXPENDITURE_ITEM_DATE::date as AIA_EXPENDITURE_ITEM_DATE
    , AIA_EXPENDITURE_ORG_ID::number(38,0) as AIA_EXPENDITURE_ORG_ID
    , AIA_EXPENDITURE_TYPE::string as AIA_EXPENDITURE_TYPE
    , AIA_FREIGHT_AMOUNT::number(38,2) as AIA_FREIGHT_AMOUNT
    , AIA_GL_DATE::date  as AIA_GL_DATE
    , AIA_INVOICE_AMOUNT::number(38,2) as AIA_INVOICE_AMOUNT
    , AIA_INVOICE_CURRENCY_CODE::string as AIA_INVOICE_CURRENCY_CODE
    , AIA_INVOICE_DATE::date as AIA_INVOICE_DATE
    , AIA_INVOICE_ID::number(38,0) as AIA_INVOICE_ID
    , AIA_INVOICE_NUM::string  as AIA_INVOICE_NUM
    , AIA_INVOICE_RECEIVED_DATE::date as AIA_INVOICE_RECEIVED_DATE
    , AIA_INVOICE_TYPE_LOOKUP_CODE::string as AIA_INVOICE_TYPE_LOOKUP_CODE
    , AIA_LAST_UPDATED_BY::number(38,0) as AIA_LAST_UPDATED_BY
    , TO_TIMESTAMP_NTZ(AIA_LAST_UPDATE_DATE) as AIA_LAST_UPDATE_DATE
    , AIA_LAST_UPDATE_LOGIN::number(38,0) as AIA_LAST_UPDATE_LOGIN
    , AIA_ORG_ID::number(38,0) as AIA_ORG_ID
    , AIA_ORIGINAL_PREPAYMENT_AMOUNT::number(38,2) as AIA_ORIGINAL_PREPAYMENT_AMOUNT
    , AIA_PAYMENT_CROSS_RATE::number(38,0) as AIA_PAYMENT_CROSS_RATE
    , AIA_PAYMENT_CROSS_RATE_DATE::date as AIA_PAYMENT_CROSS_RATE_DATE
    , AIA_PAYMENT_CURRENCY_CODE::string  as AIA_PAYMENT_CURRENCY_CODE
    , AIA_PAYMENT_METHOD_LOOKUP_CODE::string as AIA_PAYMENT_METHOD_LOOKUP_CODE
    , AIA_PAYMENT_STATUS_FLAG::string as AIA_PAYMENT_STATUS_FLAG
    , AIA_PAY_CURR_INVOICE_AMOUNT::number(38,2) as AIA_PAY_CURR_INVOICE_AMOUNT
    , AIA_PAY_GROUP_LOOKUP_CODE::string as AIA_PAY_GROUP_LOOKUP_CODE
    , AIA_PA_DEFAULT_DIST_CCID::number(38,0) as AIA_PA_DEFAULT_DIST_CCID
    , AIA_POSTING_STATUS::string as AIA_POSTING_STATUS
    , AIA_PO_HEADER_ID::number(38,0) as AIA_PO_HEADER_ID
    , AIA_PREPAY_FLAG::string as AIA_PREPAY_FLAG
    , AIA_PROJECT_ID::number(38,0) as AIA_PROJECT_ID
    , AIA_RECURRING_PAYMENT_ID::number(38,0) as AIA_RECURRING_PAYMENT_ID
    , AIA_SET_OF_BOOKS_ID::number(38,0) as AIA_SET_OF_BOOKS_ID
    , AIA_SOURCE::string as AIA_SOURCE
    , AIA_TASK_ID::number(38,0) as AIA_TASK_ID
    , AIA_TEMP_CANCELLED_AMOUNT::number(38,3) as AIA_TEMP_CANCELLED_AMOUNT
    , AIA_TERMS_DATE::date as AIA_TERMS_DATE
    , AIA_TERMS_ID::number(38,0) as AIA_TERMS_ID
    , AIA_VALIDATED_TAX_AMOUNT::number(38,2) as AIA_VALIDATED_TAX_AMOUNT
    , AIA_VAT_CODE::string  as AIA_VAT_CODE
    , AIA_VENDOR_ID::number(38,0) as AIA_VENDOR_ID
    , AIA_VENDOR_PREPAY_AMOUNT::number(38,2) as AIA_VENDOR_PREPAY_AMOUNT
    , AIA_VENDOR_SITE_ID::number(38,0)  as AIA_VENDOR_SITE_ID
    , AIA_WFAPPROVAL_STATUS::string  as AIA_WFAPPROVAL_STATUS
    from raw_data_deduplicated),
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
rdm_oracle_paymentterm as 
  (SELECT distinct Business_Application_Value, Standard_Application_Value
  from {{ref('gov_referencedata_rdm')}}
  where Business_Application_Code='oracle-ebs'
  and Business_Application_Domain_Code='PaymentTerm'),
rdm_oracle_logisticcompany as
  (SELECT distinct Business_Application_Value, Standard_Application_Value
  from {{ref('gov_referencedata_rdm')}}
  where Business_Application_Code='oracle-ebs'
  and Business_Application_Domain_Code='LogisticCompany')

select 
raw_data_typed.AIA_ACCTS_PAY_CC_ID as AIA_ACCTS_PAY_CC_ID,
raw_data_typed.AIA_AMOUNT_APP_TO_DISCOUNT as AIA_AMOUNT_APP_TO_DISCOUNT,
raw_data_typed.AIA_AMOUNT_PAID as AIA_AMOUNT_PAID,
raw_data_typed.AIA_APPROVAL_DESCRIPTION as AIA_APPROVAL_DESCRIPTION,
raw_data_typed.AIA_APPROVAL_ITERATION as AIA_APPROVAL_ITERATION,
raw_data_typed.AIA_APPROVAL_READY_FLAG as AIA_APPROVAL_READY_FLAG,
raw_data_typed.AIA_APPROVED_AMOUNT as AIA_APPROVED_AMOUNT,
raw_data_typed.AIA_ATTRIBUTE_CATEGORY as AIA_ATTRIBUTE_CATEGORY,
raw_data_typed.AIA_AUTO_TAX_CALC_FLAG as AIA_AUTO_TAX_CALC_FLAG,
raw_data_typed.AIA_AWT_FLAG as AIA_AWT_FLAG,
raw_data_typed.AIA_BASE_AMOUNT as AIA_BASE_AMOUNT,
raw_data_typed.AIA_BATCH_ID as AIA_BATCH_ID,
raw_data_typed.AIA_CANCELLED_AMOUNT as AIA_CANCELLED_AMOUNT,
raw_data_typed.AIA_CANCELLED_BY as AIA_CANCELLED_BY,
raw_data_typed.AIA_CANCELLED_DATE as AIA_CANCELLED_DATE,
raw_data_typed.AIA_CMG_AP_APPROVER as AIA_CMG_AP_APPROVER,
raw_data_typed.AIA_CMG_AP_FAPPROVER as AIA_CMG_AP_FAPPROVER,
raw_data_typed.AIA_CMG_AP_MODEL_NO as AIA_CMG_AP_MODEL_NO,
raw_data_typed.AIA_CMG_AP_REMIT_TO as AIA_CMG_AP_REMIT_TO,
raw_data_typed.AIA_CMG_AP_SERIAL_NO as AIA_CMG_AP_SERIAL_NO,
raw_data_typed.AIA_CMG_FA_PRODN_LINE as AIA_CMG_FA_PRODN_LINE,
raw_data_typed.AIA_CMG_GL_DETAIL_ACTIVITY as AIA_CMG_GL_DETAIL_ACTIVITY,
raw_data_typed.AIA_CMG_GL_LOCATION as AIA_CMG_GL_LOCATION,
raw_data_typed.AIA_CMG_PO_FLEET_WK_ORDER as AIA_CMG_PO_FLEET_WK_ORDER,
raw_data_typed.AIA_CMG_PO_MANUF_NAME as AIA_CMG_PO_MANUF_NAME,
raw_data_typed.AIA_CMG_PO_PHSE1A_PROJECT as AIA_CMG_PO_PHSE1A_PROJECT,
raw_data_typed.AIA_CMG_PO_PHSE1A_TR_TYPE as AIA_CMG_PO_PHSE1A_TR_TYPE,
raw_data_typed.AIA_CMG_PO_TAG_NUMBER as AIA_CMG_PO_TAG_NUMBER,
raw_data_typed.AIA_CREATED_BY as AIA_CREATED_BY,
raw_data_typed.AIA_CREATION_DATE as AIA_CREATION_DATE,
raw_data_typed.AIA_DESCRIPTION as AIA_DESCRIPTION,
raw_data_typed.AIA_DISCOUNT_AMOUNT_TAKEN as AIA_DISCOUNT_AMOUNT_TAKEN,
raw_data_typed.AIA_EARLIEST_SETTLEMENT_DATE as AIA_EARLIEST_SETTLEMENT_DATE,
raw_data_typed.AIA_EXCHANGE_DATE as AIA_EXCHANGE_DATE,
raw_data_typed.AIA_EXCHANGE_RATE as AIA_EXCHANGE_RATE,
raw_data_typed.AIA_EXCHANGE_RATE_TYPE as AIA_EXCHANGE_RATE_TYPE,
raw_data_typed.AIA_EXCLUSIVE_PAYMENT_FLAG as AIA_EXCLUSIVE_PAYMENT_FLAG,
raw_data_typed.AIA_EXPENDITURE_ITEM_DATE as AIA_EXPENDITURE_ITEM_DATE,
raw_data_typed.AIA_EXPENDITURE_ORG_ID as AIA_EXPENDITURE_ORG_ID,
raw_data_typed.AIA_EXPENDITURE_TYPE as AIA_EXPENDITURE_TYPE,
raw_data_typed.AIA_FREIGHT_AMOUNT as AIA_FREIGHT_AMOUNT,
raw_data_typed.AIA_GL_DATE as AIA_GL_DATE,
raw_data_typed.AIA_INVOICE_AMOUNT as AIA_INVOICE_AMOUNT,
raw_data_typed.AIA_INVOICE_CURRENCY_CODE as AIA_INVOICE_CURRENCY_CODE,
invoice_currency_code.Standard_Application_Value as RDM_AIA_INVOICE_CURRENCY_CODE,
raw_data_typed.AIA_INVOICE_DATE as AIA_INVOICE_DATE,
raw_data_typed.AIA_INVOICE_ID as AIA_INVOICE_ID,
raw_data_typed.AIA_INVOICE_NUM as AIA_INVOICE_NUM,
raw_data_typed.AIA_INVOICE_RECEIVED_DATE as AIA_INVOICE_RECEIVED_DATE,
raw_data_typed.AIA_INVOICE_TYPE_LOOKUP_CODE as AIA_INVOICE_TYPE_LOOKUP_CODE,
raw_data_typed.AIA_LAST_UPDATED_BY as AIA_LAST_UPDATED_BY,
raw_data_typed.AIA_LAST_UPDATE_DATE as AIA_LAST_UPDATE_DATE,
raw_data_typed.AIA_LAST_UPDATE_LOGIN as AIA_LAST_UPDATE_LOGIN,
rdm_oracle_logisticcompany.Business_Application_Value as RDM_AIA_ORG_ID_LOOKUP_CODE,
raw_data_typed.AIA_ORIGINAL_PREPAYMENT_AMOUNT as AIA_ORIGINAL_PREPAYMENT_AMOUNT,
raw_data_typed.AIA_PAYMENT_CROSS_RATE as AIA_PAYMENT_CROSS_RATE,
raw_data_typed.AIA_PAYMENT_CROSS_RATE_DATE as AIA_PAYMENT_CROSS_RATE_DATE,
raw_data_typed.AIA_PAYMENT_CURRENCY_CODE as AIA_PAYMENT_CURRENCY_CODE,
payment_currency_code.Standard_Application_Value as RDM_AIA_PAYMENT_CURRENCY_CODE,
raw_data_typed.AIA_PAYMENT_METHOD_LOOKUP_CODE as AIA_PAYMENT_METHOD_LOOKUP_CODE,
rdm_oracle_paymentmethod.Standard_Application_Value as RDM_AIA_PAYMENT_METHOD_LOOKUP_CODE,
raw_data_typed.AIA_PAYMENT_STATUS_FLAG as AIA_PAYMENT_STATUS_FLAG,
raw_data_typed.AIA_PAY_CURR_INVOICE_AMOUNT as AIA_PAY_CURR_INVOICE_AMOUNT,
raw_data_typed.AIA_PAY_GROUP_LOOKUP_CODE as AIA_PAY_GROUP_LOOKUP_CODE,
raw_data_typed.AIA_PA_DEFAULT_DIST_CCID as AIA_PA_DEFAULT_DIST_CCID,
raw_data_typed.AIA_POSTING_STATUS as AIA_POSTING_STATUS,
raw_data_typed.AIA_PO_HEADER_ID as AIA_PO_HEADER_ID,
raw_data_typed.AIA_PREPAY_FLAG as AIA_PREPAY_FLAG,
raw_data_typed.AIA_PROJECT_ID as AIA_PROJECT_ID,
raw_data_typed.AIA_RECURRING_PAYMENT_ID as AIA_RECURRING_PAYMENT_ID,
raw_data_typed.AIA_SET_OF_BOOKS_ID as AIA_SET_OF_BOOKS_ID,
raw_data_typed.AIA_SOURCE as AIA_SOURCE,
raw_data_typed.AIA_TASK_ID as AIA_TASK_ID,
raw_data_typed.AIA_TEMP_CANCELLED_AMOUNT as AIA_TEMP_CANCELLED_AMOUNT,
raw_data_typed.AIA_TERMS_DATE as AIA_TERMS_DATE,
raw_data_typed.AIA_TERMS_ID as AIA_TERMS_ID,
rdm_oracle_paymentterm.Standard_Application_Value as RDM_AIA_TERMS_ID,
raw_data_typed.AIA_VALIDATED_TAX_AMOUNT as AIA_VALIDATED_TAX_AMOUNT,
raw_data_typed.AIA_VAT_CODE as AIA_VAT_CODE,
raw_data_typed.AIA_VENDOR_ID as AIA_VENDOR_ID,
raw_data_typed.AIA_VENDOR_PREPAY_AMOUNT as AIA_VENDOR_PREPAY_AMOUNT,
raw_data_typed.AIA_VENDOR_SITE_ID as AIA_VENDOR_SITE_ID,
raw_data_typed.AIA_WFAPPROVAL_STATUS as AIA_WFAPPROVAL_STATUS
from raw_data_typed
left join rdm_oracle_currency as invoice_currency_code
on raw_data_typed.AIA_INVOICE_CURRENCY_CODE=invoice_currency_code.Business_Application_Value
left join rdm_oracle_currency as payment_currency_code
on raw_data_typed.AIA_PAYMENT_CURRENCY_CODE=payment_currency_code.Business_Application_Value
left join rdm_oracle_paymentmethod
on raw_data_typed.AIA_PAYMENT_METHOD_LOOKUP_CODE=rdm_oracle_paymentmethod.Business_Application_Value
left join rdm_oracle_paymentterm
on raw_data_typed.AIA_TERMS_ID::string=rdm_oracle_paymentterm.Business_Application_Value::string
left join rdm_oracle_logisticcompany
on raw_data_typed.AIA_ORG_ID::string = rdm_oracle_logisticcompany.Business_Application_Value::string
