{{
  config(
    materialized = "view",
    alias = "working_shift_detail",
    schema='spm_ca'
  )
}}

SELECT
    DATA:"CreatedBy" AS CreatedBy,
    DATA:"CreatedDate" AS CreatedDate,
    DATA:"ModifiedBy" AS ModifiedBy,
    DATA:"ModifiedDate" AS ModifiedDate,
    DATA:"active_from_date" AS active_from_date,
    DATA:"active_to_date" AS active_to_date,
    DATA:"assembly_workers_number" AS assembly_workers_number,
    DATA:"break1_end_time" AS break1_end_time,
    DATA:"break1_included_std_time" AS break1_included_std_time,
    DATA:"break1_start_time" AS break1_start_time,
    DATA:"break2_end_time" AS break2_end_time,
    DATA:"break2_included_std_time" AS break2_included_std_time,
    DATA:"break2_start_time" AS break2_start_time,
    DATA:"break3_end_time" AS break3_end_time,
    DATA:"break3_included_std_time" AS break3_included_std_time,
    DATA:"break3_start_time" AS break3_start_time,
    DATA:"entity_code" AS entity_code,
    DATA:"foreman_id" AS foreman_id,
    DATA:"ipaas_updated_date" AS ipaas_updated_date,
    DATA:"machn_no" AS machn_no,
    DATA:"nonworking_time" AS nonworking_time,
    DATA:"painting_workers_number" AS painting_workers_number,
    DATA:"preparation_workers_number" AS preparation_workers_number,
    DATA:"shift_date" AS shift_date,
    DATA:"shift_end_time" AS shift_end_time,
    DATA:"shift_start_time" AS shift_start_time,
    DATA:"shift_to_update" AS shift_to_update,
    DATA:"shop_no" AS shop_no,
    DATA:"src_system_operation" AS src_system_operation,
    DATA:"total_workers_number" AS total_workers_number,
    DATA:"week_day" AS week_day,
    DATA:"welding_workers_number" AS welding_workers_number,
    DATA:"working_shift_detail_uuid" AS working_shift_detail_uuid,
    DATA:"working_shift_type" AS working_shift_type,
    DATA:"working_shift_uuid" AS working_shift_uuid,
    DATA:"src_system_operation" AS SRC_SYSTEM_OPERATION,
    DATA:"DataEventTimestamp" AS DATA_EVENT_TIMESTAMP,
    FILENAME AS METADATA_FILENAME,
    FILE_ROW_NUMBER AS METADATA_FILE_ROW_NUMBER,
    FILE_LAST_MODIFIED AS METADATA_FILE_LAST_MODIFIED,
    START_SCAN_TIME AS METADATA_START_SCAN_TIME
    ,{{ dbt_utils.generate_surrogate_key(['DATA:"working_shift_detail_uuid"']) }} as TABLE_SK
    ,COALESCE(TO_TIMESTAMP_TZ(DATA:"DataEventTimestamp"),TO_TIMESTAMP_NTZ(DATEADD(microsecond, FILE_ROW_NUMBER,TO_TIMESTAMP_NTZ(DATA:"ipaas_updated_date"::string)))) as QUALIFY_TIMESTAMP

FROM
    {{ source("landing_spm_ca", "WORKING_SHIFT_DETAIL") }}
WHERE
    -- Only take the files after the last fullLoad
    SPLIT(FILENAME, '_')[ARRAY_SIZE(SPLIT(FILENAME, '_')) - 2] >= (
        SELECT
            min_timestamp
        FROM
            (
                SELECT
                    SPLIT(FILENAME, '_')[ARRAY_SIZE(SPLIT(FILENAME, '_')) - 2] AS min_timestamp,
                    SPLIT(FILENAME, '/')[3] AS type_file
                FROM
                    {{ source("landing_spm_ca", "WORKING_SHIFT_DETAIL") }}
                WHERE
                    type_file LIKE 'fullload%'
                QUALIFY ROW_NUMBER() OVER (ORDER BY min_timestamp DESC) = 1
            )
    )