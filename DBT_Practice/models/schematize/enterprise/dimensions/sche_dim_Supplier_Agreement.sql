{{
  config(
    full_refresh = true,
    materialized="dynamic_table",
    target_lag="downstream",
    snowflake_warehouse= var('task_warehouse'),
    alias = "dim_Supplier_Agreement",
    schema= "dimensions",
    post_hook = "ALTER DYNAMIC TABLE {{ this }} SET LOG_LEVEL = ERROR"
  )
}}

SELECT
{{ dbt_utils.generate_surrogate_key(['START_DATE', 'END_DATE', 'VENDOR_ID', 'CONTRACT_TYPE']) }} as Supplier_Agreement_sk
, CONTRACT_TYPE as Agreement_Type_Name
, START_DATE as Effective_Date
, END_DATE as Expiry_Date
, VENDOR_ID as Supplier_Number
, VENDOR_NAME as Supplier_Name
, PAYMENT_TERMS as Payment_Terms
, DISCOUNT as Discount
, INCOTERMS as Incoterms
, VOLUME_DISCOUNT as Volume_Discount
, NEGOCIATED_BY as Negociated_By
, CONTRACT_ORIGIN as Contract_Origin
, LINK::string as LINK
, ARCHIVED as archived
from {{ ref ('norm_purchasing_agreement_register') }} 