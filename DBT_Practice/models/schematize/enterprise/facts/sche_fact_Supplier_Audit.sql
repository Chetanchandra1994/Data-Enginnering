{{
  config(
    full_refresh = true,
    materialized="dynamic_table",
    target_lag="downstream",
    snowflake_warehouse= var('task_warehouse'),
    alias = "fact_Supplier_Audit",
    schema= "facts",
    post_hook = "ALTER DYNAMIC TABLE {{ this }} SET LOG_LEVEL = ERROR"
  )
}}

SELECT
    DS.SUPPLIER_SK,
    DD_START.DATE_KEY AS VALID_FROM_DATE_KEY,
    DD_END.DATE_KEY AS VALID_TO_DATE_KEY,
    SAS.AUDIT_SCORE
FROM {{ ref('norm_supplier_audit_scores') }} AS SAS
LEFT JOIN {{ ref('sche_dim_Supplier') }} AS DS
    ON SAS.AUDIT_SUPPLIER_CODE = DS.SUPPLIER_NUMBER
LEFT JOIN {{ ref('sche_dim_Date') }} AS DD_START
    ON SAS.AUDIT_EFFECTIVE_START_DATE = DD_START.FULL_DATE
LEFT JOIN {{ ref('sche_dim_Date') }} AS DD_END
    ON SAS.AUDIT_EFFECTIVE_END_DATE = DD_END.FULL_DATE