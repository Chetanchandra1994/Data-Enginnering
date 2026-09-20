{{
  config(
    materialized = "view",
    alias = "working_shift_detail",
    schema='spm_ca'
  )
}}

SELECT 
    NULLIF(CreatedBy::string, '') AS CreatedBy,
    TO_TIMESTAMP_NTZ(CreatedDate::string) AS CreatedDate,
    NULLIF(ModifiedBy::string, '') AS ModifiedBy,
    TO_TIMESTAMP_NTZ(ModifiedDate::String) AS ModifiedDate,
    active_from_date::date AS active_from_date,
    active_to_date::date AS active_to_date,
    assembly_workers_number::double AS assembly_workers_number,
    break1_end_time::integer AS break1_end_time,
    TO_BOOLEAN(break1_included_std_time::string) AS break1_included_std_time,
    break1_start_time::INTEGER AS break1_start_time,
    break2_end_time::INTEGER AS break2_end_time,
    TO_BOOLEAN(break2_included_std_time::string) AS break2_included_std_time,
    break2_start_time::INTEGER AS break2_start_time,
    break3_end_time::integer AS break3_end_time,
    to_boolean(break3_included_std_time::string) AS break3_included_std_time,
    break3_start_time::integer AS break3_start_time,
    UPPER(entity_code::string) AS entity_code,
    foreman_id::integer AS foreman_id,
    TO_TIMESTAMP_NTZ(ipaas_updated_date::string) AS ipaas_updated_date,
    machn_no::integer AS machn_no,
    to_boolean(nonworking_time::string) AS nonworking_time,
    painting_workers_number::double AS painting_workers_number,
    preparation_workers_number::double AS preparation_workers_number,
    shift_date::date AS shift_date,
    shift_end_time::integer AS shift_end_time,
    shift_start_time::integer AS shift_start_time,
    to_boolean(shift_to_update::string) AS shift_to_update,
    shop_no::integer AS shop_no,
    total_workers_number::double AS total_workers_number,
    week_day::integer AS week_day,
    welding_workers_number::double AS welding_workers_number,
    working_shift_detail_uuid::string AS working_shift_detail_uuid,
    working_shift_type::integer AS working_shift_type,
    working_shift_uuid::string AS working_shift_uuid,
    from {{ref('prep_working_shift_detail')}}
QUALIFY ROW_NUMBER() OVER (PARTITION BY TABLE_SK ORDER BY QUALIFY_TIMESTAMP DESC) = 1 AND UPPER(TRIM(SRC_SYSTEM_OPERATION::STRING)) <> 'DELETE'