{{
  config(
    materialized = "view",
    alias = "working_shift",
    schema='spm_ca'
  )
}}

SELECT 
    NULLIF(CREATEDBY::string, '') AS CREATEDBY,
    TO_TIMESTAMP_NTZ(CreatedDate::string) as CreatedDate,
    NULLIF(ModifiedBy::string, '') as ModifiedBy,
    TO_TIMESTAMP_NTZ(ModifiedDate::string) AS ModifiedDate,
    TO_BOOLEAN(active::string) AS ACTIVE,
    UPPER(entity_code::string) AS entity_code,
    TO_TIMESTAMP_NTZ(ipaas_updated_date::string) AS ipaas_updated_date,
    payroll_working_shift_uuid::string AS payroll_working_shift_uuid,
    UPPER(working_shift_code::string) AS working_shift_code,
    working_shift_name_id::integer AS working_shift_name_id,
    working_shift_uuid::string AS working_shift_uuid,
    from {{ref('prep_working_shift')}}
QUALIFY ROW_NUMBER() OVER (PARTITION BY TABLE_SK ORDER BY QUALIFY_TIMESTAMP DESC) = 1 AND UPPER(TRIM(SRC_SYSTEM_OPERATION::STRING)) <> 'DELETE'