{{
  config(
    materialized = "view",
    alias = "supplier_audit_scores",
    schema='streamlit'
  )
}}

SELECT
    AUDIT_SUPPLIER_CODE,
    AUDIT_SCORE,
    AUDIT_EFFECTIVE_START_DATE,
    AUDIT_EFFECTIVE_END_DATE,
    AUDIT_COMMENT
FROM
    {{ ref ('prep_supplier_audit_scores') }}
QUALIFY ROW_NUMBER() OVER (PARTITION BY AUDIT_SUPPLIER_CODE, AUDIT_EFFECTIVE_START_DATE, AUDIT_EFFECTIVE_END_DATE ORDER BY SEQ8() DESC) = 1