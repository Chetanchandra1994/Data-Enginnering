{{
  config(
    materialized = "view",
    alias = "working_shift",
    schema='spm_ca'
  )
}}

SELECT
    DATA:"CreatedBy" AS CREATEDBY,
    DATA:"CreatedDate" AS CreatedDate,
    DATA:"ModifiedBy" AS ModifiedBy,
    DATA:"ModifiedDate" AS ModifiedDate,
    DATA:"active" AS ACTIVE,
    DATA:"entity_code" AS entity_code,
    DATA:"ipaas_updated_date" AS ipaas_updated_date,
    DATA:"payroll_working_shift_uuid" AS payroll_working_shift_uuid,
    DATA:"working_shift_code" AS working_shift_code,
    DATA:"working_shift_name_id" AS working_shift_name_id,
    DATA:"working_shift_uuid" AS working_shift_uuid,
    DATA:"src_system_operation" AS SRC_SYSTEM_OPERATION,
    DATA:"DataEventTimestamp" AS DATA_EVENT_TIMESTAMP,
    FILENAME AS METADATA_FILENAME,
    FILE_ROW_NUMBER AS METADATA_FILE_ROW_NUMBER,
    FILE_LAST_MODIFIED AS METADATA_FILE_LAST_MODIFIED,
    START_SCAN_TIME AS METADATA_START_SCAN_TIME
    ,{{ dbt_utils.generate_surrogate_key(['DATA:"working_shift_uuid"']) }} as TABLE_SK
    ,COALESCE(TO_TIMESTAMP_TZ(DATA:"DataEventTimestamp"),TO_TIMESTAMP_NTZ(DATEADD(microsecond, FILE_ROW_NUMBER,TO_TIMESTAMP_NTZ(DATA:"ipaas_updated_date"::string)))) as QUALIFY_TIMESTAMP

FROM
    {{ source("landing_spm_ca", "WORKING_SHIFT") }}
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
                    {{ source("landing_spm_ca", "WORKING_SHIFT") }}
                WHERE
                    type_file LIKE 'fullload%'
                QUALIFY ROW_NUMBER() OVER (ORDER BY min_timestamp DESC) = 1
            )
    )