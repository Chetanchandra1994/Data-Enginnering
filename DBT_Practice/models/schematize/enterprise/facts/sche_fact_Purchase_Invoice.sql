{{
  config(
    full_refresh = true,
    materialized="dynamic_table",
    target_lag="downstream",
    snowflake_warehouse= var('task_warehouse'),
    alias = "fact_Purchase_Invoice",
    schema= "facts",
    post_hook = "ALTER DYNAMIC TABLE {{ this }} SET LOG_LEVEL = ERROR"
  )
}}


with 

ebs_data_joined as (

    select 
          {{ dbt_utils.generate_surrogate_key(['RDM_AIA_ORG_ID_LOOKUP_CODE','AIA_INVOICE_NUM', 'POV_VENDOR_NUMBER','PVS_VENDOR_SITE_CODE']) }} as Supplier_PurchaseInvoice_sk
        , a.AIA_INVOICE_NUM as InvoiceCode
        , a.RDM_AIA_ORG_ID_LOOKUP_CODE as FinancialCompany
        , b.POV_VENDOR_NUMBER as SupplierCode
        , c.PVS_VENDOR_SITE_CODE as IF_PROFILECODE
        , 'oracle-ebs' as ApplicationCode
        , a.RDM_AIA_INVOICE_CURRENCY_CODE as InvoiceCurrency
        , a.AIA_INVOICE_AMOUNT as InvoiceAmount
        , a.AIA_INVOICE_TYPE_LOOKUP_CODE as InvoiceType
        , a.rdm_aia_terms_id as InvoiceTerm
        , a.aia_invoice_date as InvoiceDate
        , a.aia_discount_amount_taken as InvoiceDiscountTakenAmt
    from {{ref('norm_cm50_ap_invoices_all')}} a
    left join {{ref('norm_cm50_po_supplier')}} b
    on a.AIA_VENDOR_ID = b.POV_VENDOR_ID
    left join {{ref('norm_cm50_po_supplier_site')}} c
    on a.AIA_VENDOR_ID = c.PVS_VENDOR_ID
    and a.AIA_VENDOR_SITE_ID = c.PVS_VENDOR_SITE_ID
    --Needed to avoid the scenario where an invoice is deleted and re-added in Oracle since we don't capture delete events
    QUALIFY ROW_NUMBER() OVER (PARTITION BY AIA_INVOICE_NUM, POV_VENDOR_NUMBER, PVS_VENDOR_SITE_CODE, RDM_AIA_ORG_ID_LOOKUP_CODE ORDER BY IFNULL(AIA_LAST_UPDATE_DATE,'0000-01-01'::DATE) DESC) = 1
),

ebs_data_with_if_profile_sk as (

    select 
          a.Supplier_PurchaseInvoice_sk
        , a.InvoiceCode
        , a.FinancialCompany
        , c.supplier_sk
        , a.IF_PROFILECODE
        , b.IF_PROFILE_SK
        , a.ApplicationCode
        , a.InvoiceCurrency
        , a.InvoiceAmount
        , a.InvoiceType
        , a.InvoiceTerm
        , a.InvoiceDate
        , a.InvoiceDiscountTakenAmt
    from ebs_data_joined a
    left join {{ref('sche_dim_Supplier')}} c
    on a.SupplierCode = c.supplier_number
    left join {{ref('sche_dim_Invoice_From_Profile')}} b
    on b.supplier_sk=c.supplier_sk
    and a.IF_PROFILECODE=b.IF_PROFILE_CODE
)




SELECT 
  Supplier_PurchaseInvoice_sk as Supplier_Purchase_Invoice_sk
, supplier_sk as supplier_sk
, IF_PROFILE_SK
, InvoiceCode as Invoice_Code
, InvoiceDate as Invoice_Date
, InvoiceAmount as Invoice_Amount
, InvoiceCurrency as Invoice_Currency
, InvoiceType as Invoice_Type
, InvoiceTerm as Invoice_Term
, InvoiceDiscountTakenAmt as Invoice_Discount_Taken_Amt
, ApplicationCode as Application_Code
, FinancialCompany as Financial_Company
from ebs_data_with_if_profile_sk