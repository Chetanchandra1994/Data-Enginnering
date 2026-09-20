{{
  config(
    full_refresh = true,
    materialized="dynamic_table",
    target_lag="1 hour",
    snowflake_warehouse= var('task_warehouse'),
    alias = "suppliers_agreements",
    schema= "dataproducts_gold",
    post_hook = "ALTER DYNAMIC TABLE {{ this }} SET LOG_LEVEL = ERROR"
  
  )
}}

SELECT
Supplier_Number ,
INITCAP(LOWER(Supplier_name)) AS Supplier_Name,
UPPER(SUBSTRING(
        INITCAP(LOWER(SPLIT_PART(agreement_type_name, '/', 2))),
        POSITION('(' IN INITCAP(LOWER(SPLIT_PART(agreement_type_name, '/', 2)))) + 1,
        POSITION(')' IN INITCAP(LOWER(SPLIT_PART(agreement_type_name, '/', 2)))) - POSITION('(' IN INITCAP(LOWER(SPLIT_PART(agreement_type_name, '/', 2)))) - 1
    )) as agreement_type_code,
RTRIM(INITCAP(LOWER(SPLIT_PART(agreement_type_name, '/', 1)))) AS agreement_type_french,
LTRIM(REGEXP_REPLACE(
        INITCAP(LOWER(SPLIT_PART(agreement_type_name, '/', 2))), -- Original expression
        '\\s*\\([^)]*\\)$', -- The regex pattern to find
        '' -- Replace with an empty string
    )) AS agreement_type_english,
effective_date,
expiry_date,
-- Not clean enough to include yet
--payment_terms,
--discount,
TRIM(SPLIT_PART(incoterms, ' - ', 1)) AS incoterms_code,
CASE
    WHEN -- First, define the suffix (the part after ' - ')
         (CASE WHEN POSITION(' - ', incoterms) > 0 THEN TRIM(SPLIT_PART(incoterms, ' - ', 2)) ELSE NULL END) IS NOT NULL
         AND -- Then, check if this suffix contains a '/'
         POSITION('/', (CASE WHEN POSITION(' - ', incoterms) > 0 THEN TRIM(SPLIT_PART(incoterms, ' - ', 2)) ELSE NULL END)) > 0
    THEN -- If both are true, then extract the part before the '/'
         TRIM(SPLIT_PART((CASE WHEN POSITION(' - ', incoterms) > 0 THEN TRIM(SPLIT_PART(incoterms, ' - ', 2)) ELSE NULL END), '/', 1))
    ELSE -- Otherwise (no suffix, or suffix exists but has no '/'), s1 should be NULL
         NULL
END AS incoterms_french,
CASE
    WHEN (CASE WHEN POSITION(' - ', incoterms) > 0 THEN TRIM(SPLIT_PART(incoterms, ' - ', 2)) ELSE NULL END) IS NULL THEN
        NULL
    WHEN POSITION('/', (CASE WHEN POSITION(' - ', incoterms) > 0 THEN TRIM(SPLIT_PART(incoterms, ' - ', 2)) ELSE NULL END)) > 0 THEN
        TRIM(SPLIT_PART((CASE WHEN POSITION(' - ', incoterms) > 0 THEN TRIM(SPLIT_PART(incoterms, ' - ', 2)) ELSE NULL END), '/', 2))
    ELSE
        (CASE WHEN POSITION(' - ', incoterms) > 0 THEN TRIM(SPLIT_PART(incoterms, ' - ', 2)) ELSE NULL END)
END AS incoterms_english,
IFNULL(REGEXP_LIKE(volume_discount, '\\b(OUI|YES)\\b', 'i'),FALSE) AS volume_discount,
INITCAP(LOWER(negociated_by)) as negociated_by,
INITCAP(LOWER(SPLIT_PART(contract_origin, '/', 1))) AS contract_origin_french,
INITCAP(LOWER(SPLIT_PART(contract_origin, '/', 2))) AS contract_origin_english,
-- Full URL cannot be retrieved from the source, only the name of the file is there.
link as contract_file_name,
archived as archived
FROM {{ ref ('sche_dim_Supplier_Agreement') }} 