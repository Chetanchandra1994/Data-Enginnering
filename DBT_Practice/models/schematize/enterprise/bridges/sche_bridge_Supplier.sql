{{
  config(
    full_refresh = true,
    materialized="dynamic_table",
    target_lag="downstream",
    snowflake_warehouse= var('task_warehouse'),
    alias = "bridge_supplier",
    schema= "bridges",
    post_hook = "ALTER DYNAMIC TABLE {{ this }} SET LOG_LEVEL = ERROR"
  )
}}

SELECT
  {{ dbt_utils.generate_surrogate_key(['a.SUPPLIERCODE', 'b.VENDOR_CODE']) }} as BRIDGE_SUPPLIER_SK
  ,{{ dbt_utils.generate_surrogate_key(['a.SUPPLIERCODE']) }} as SUPPLIER_SK
  ,a.suppliercode as EBS_CODE
  ,b.vendor_code as SPM_CODE
FROM {{ref('norm_enterprisemodel_suppliers')}} a
LEFT JOIN {{ref('norm_vendor')}} b
ON a.suppliercode::string = b.CANSIS_VENDOR_NUMBER::string