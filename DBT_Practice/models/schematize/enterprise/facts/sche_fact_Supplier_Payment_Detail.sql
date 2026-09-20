{{
  config(
    full_refresh = true,
    materialized="dynamic_table",
    target_lag="downstream",
    snowflake_warehouse= var('task_warehouse'),
    alias = "fact_Supplier_Payment_Detail",
    schema= "facts",
    post_hook = "ALTER DYNAMIC TABLE {{ this }} SET LOG_LEVEL = ERROR"
  )
}}


SELECT
          {{ dbt_utils.generate_surrogate_key(['b.AIA_INVOICE_NUM', 'e.ACA_BANK_ACCOUNT_NAME','e.ACA_BANK_ACCOUNT_NUM', 'e.ACA_CHECK_NUMBER', 'a.RDM_APP_ORG_ID_LOOKUP_CODE','c.POV_VENDOR_NUMBER', 'd.PVS_VENDOR_SITE_CODE']) }}  AS Supplier_Payment_Detail_sk
        , f.IF_PROFILE_SK                                                                                 AS IF_PROFILE_SK
        , g.PT_PROFILE_SK                                                                                 AS PT_PROFILE_SK      
        , sum(a.APP_AMOUNT)                                                                               AS Invoice_Payment_Amount
        , sum(a.app_discount_lost)                                                                        AS Invoice_Payment_Discount_Lost
        , b.AIA_PAYMENT_CURRENCY_CODE                                                                     AS Invoice_Payment_Currency
        , sum(coalesce(a.APP_PAYMENT_BASE_AMOUNT, a.APP_AMOUNT))                                          AS Invoice_Payment_Amount_CAD
        , ROUND(sum(a.app_discount_lost*IFNULL(a.APP_PAYMENT_BASE_AMOUNT/NULLIFZERO(a.APP_AMOUNT),1)),2)  AS Invoice_Payment_Discount_Lost_Amt_CAD
        , 'oracle-ebs'                                                                                    AS Application_Code
        , a.RDM_APP_ORG_ID_LOOKUP_CODE                                                                    AS Financial_Company
        , b.AIA_INVOICE_NUM                                                                               AS Invoice_Code
        , {{ dbt_utils.generate_surrogate_key(['b.RDM_AIA_ORG_ID_LOOKUP_CODE','b.AIA_INVOICE_NUM', 'c.POV_VENDOR_NUMBER','d.PVS_VENDOR_SITE_CODE']) }} as Supplier_Purchase_Invoice_sk
        , e.ACA_CHECK_NUMBER                                                                              AS Payment_Code
        , {{ dbt_utils.generate_surrogate_key(['e.ACA_BANK_ACCOUNT_NAME', 'e.ACA_BANK_ACCOUNT_NUM', 'e.ACA_CHECK_NUMBER', 'e.RDM_ACA_ORG_ID_LOOKUP_CODE','c.POV_VENDOR_NUMBER', 'd.PVS_VENDOR_SITE_CODE']) }} as Supplier_Payment_sk                                                                            
        , e.ACA_BANK_ACCOUNT_NAME                                                                         AS Payment_Bank_Account_Name   
  
    from {{ref('norm_cm50_ap_invoice_payments')}} a
    left join {{ref('norm_cm50_ap_invoices_all')}} b
    on a.app_invoice_id=b.aia_invoice_id
    left join {{ref('norm_cm50_po_supplier')}} c
    on b.AIA_VENDOR_ID = c.POV_VENDOR_ID
    left join {{ref('norm_cm50_po_supplier_site')}} d 
    on b.AIA_VENDOR_ID = c.POV_VENDOR_ID and b.AIA_VENDOR_SITE_ID = d.PVS_VENDOR_SITE_ID
    left join {{ref('norm_cm50_ap_checks_all')}} e
    on a.app_check_id = e.aca_check_id
    left join {{ref('sche_dim_Supplier')}} h
    on c.pov_vendor_number = h.supplier_number
    left join {{ref('sche_dim_Invoice_From_Profile')}} f
    on h.supplier_sk = f.supplier_sk and d.PVS_VENDOR_SITE_CODE = f.if_profile_code
    left join {{ref('sche_dim_Pay_To_Profile')}}  g
    on h.supplier_sk = g.supplier_sk and d.PVS_VENDOR_SITE_CODE = g.pt_profile_code
    GROUP BY 
          RDM_APP_ORG_ID_LOOKUP_CODE
        , AIA_INVOICE_NUM
        , ACA_CHECK_NUMBER
        , PVS_VENDOR_SITE_CODE                                                                    
        , AIA_PAYMENT_CURRENCY_CODE
        , POV_VENDOR_NUMBER
        , e.ACA_BANK_ACCOUNT_NUM
        , e.ACA_BANK_ACCOUNT_NAME
        , f.if_profile_sk
        , g.pt_profile_sk
        , e.RDM_ACA_ORG_ID_LOOKUP_CODE
        , b.RDM_AIA_ORG_ID_LOOKUP_CODE



