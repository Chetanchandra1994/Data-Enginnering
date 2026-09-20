{{
  config(
    full_refresh = true,
    materialized="dynamic_table",
    target_lag="downstream",
    snowflake_warehouse= var('task_warehouse'),
    alias = "dim_Payment_To",
    schema= "dimensions",
    post_hook = "ALTER DYNAMIC TABLE {{ this }} SET LOG_LEVEL = ERROR"
  )
}}

WITH cte as(
SELECT DISTINCT
IFF(cust_no IS NOT NULL,{{ dbt_utils.generate_surrogate_key(['cust_no']) }},null) as CUSTOMER_SK,
BS.SUPPLIER_SK as SUPPLIER_SK
FROM 
{{ref('norm_project_event')}} PE
LEFT JOIN
{{ref('norm_customer')}} C
ON PE.PAYMENT_TO_CUSTOMER_UUID = C.customer_uuid
LEFT JOIN
{{ref('norm_vendor')}} V
ON UPPER(PE.payment_to_vendor_code) = UPPER(V.vendor_code)
LEFT JOIN 
{{ref('sche_bridge_Supplier')}} BS
ON UPPER(V.vendor_code) = UPPER(BS.SPM_CODE)
WHERE C.cust_no IS NOT NULL OR BS.SUPPLIER_SK IS NOT NULL
)
SELECT
{{ dbt_utils.generate_surrogate_key(['CUSTOMER_SK','SUPPLIER_SK']) }} as PAYMENT_TO_SK,
CUSTOMER_SK,
SUPPLIER_SK
FROM cte


