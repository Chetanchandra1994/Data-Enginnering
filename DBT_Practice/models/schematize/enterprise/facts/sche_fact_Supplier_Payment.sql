{{
  config(
    full_refresh = true,
    materialized="dynamic_table",
    target_lag="downstream",
    snowflake_warehouse= var('task_warehouse'),
    alias = "fact_Supplier_Payment",
    schema= "facts",
    post_hook = "ALTER DYNAMIC TABLE {{ this }} SET LOG_LEVEL = ERROR"
  )
}}



with 

ebs_data_joined as (

    select 
          {{ dbt_utils.generate_surrogate_key(['ACA_BANK_ACCOUNT_NAME', 'ACA_BANK_ACCOUNT_NUM', 'ACA_CHECK_NUMBER', 'RDM_ACA_ORG_ID_LOOKUP_CODE','POV_VENDOR_NUMBER', 'PVS_VENDOR_SITE_CODE']) }} as Supplier_Payment_sk
        , a.ACA_CHECK_NUMBER as PaymentCode
        , a.RDM_ACA_ORG_ID_LOOKUP_CODE as FinancialCompany
        , a.ACA_AMOUNT as PaymentAmount
        , b.POV_VENDOR_NUMBER as SupplierCode
        , c.PVS_VENDOR_SITE_CODE as PT_PROFILECODE
        , a.ACA_EXCHANGE_RATE as PaymentExchangeRate
        , a.RDM_ACA_CURRENCY_CODE as PaymentCurrency
        , a.ACA_CHECK_DATE as PaymentDate
        , 'oracle-ebs' as ApplicationCode
        , a.ACA_STATUS_LOOKUP_CODE as PaymentStatus
        , a.ACA_BANK_ACCOUNT_NUM as PaymentBankAccount
        , a.ACA_BANK_ACCOUNT_NAME as PaymentBankAccountName
    from {{ref('norm_cm50_ap_checks_all')}} a
    left join {{ref('norm_cm50_po_supplier')}} b
    on a.ACA_VENDOR_ID = b.POV_VENDOR_ID
    left join {{ref('norm_cm50_po_supplier_site')}} c
    on a.ACA_VENDOR_ID = c.PVS_VENDOR_ID
    and a.ACA_VENDOR_SITE_ID = c.PVS_VENDOR_SITE_ID
),
ebs_data_with_PT_PROFILE_SK as (

    select 
          a.Supplier_Payment_sk
        , a.PaymentCode
        , a.FinancialCompany
        , a.PaymentAmount
        , c.supplier_sk
        , a.PT_PROFILECODE
        , b.PT_PROFILE_SK
        , a.PaymentExchangeRate
        , a.PaymentCurrency
        , a.PaymentDate
        , a.ApplicationCode
        , a.PaymentStatus
        , a.PaymentBankAccount
        , a.PaymentBankAccountName
    from ebs_data_joined a
    left join {{ref('sche_dim_Supplier')}} c
    on a.SupplierCode = c.supplier_number
    left join {{ref('sche_dim_Pay_To_Profile')}} b
    on c.supplier_sk=b.supplier_sk
    and a.PT_PROFILECODE=b.PT_PROFILE_CODE
)


SELECT 
  Supplier_Payment_sk
, supplier_sk as supplier_sk
, PT_PROFILE_SK
, PaymentCode as Payment_Code
, PaymentDate as Payment_Date
, PaymentAmount as Payment_Amount
, PaymentCurrency as Payment_Currency
, PaymentExchangeRate as Payment_Exchange_Rate
, PaymentStatus as Payment_Status
, PaymentBankAccount as Payment_Bank_Account
, PaymentBankAccountName as Payment_Bank_Account_Name
, ApplicationCode as Application_Code
, FinancialCompany as Financial_Company
from ebs_data_with_PT_PROFILE_SK