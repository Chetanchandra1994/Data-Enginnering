{{
 config(
 materialized = "view",
 alias = "duty",
 schema='spm_ca'
 )
}}

SELECT
    DATA:"duty_code" AS DUTY_CODE,
    DATA:"_rowid" AS ROW_ID,
    DATA:"description" AS DESCRIPTION,
    DATA:"duty_pct" AS DUTY_PCT,
    DATA:"gl_expense" AS GL_EXPENSE,
    DATA:"CreatedBy" AS CREATEDBY,
    DATA:"ModifiedBy" AS MODIFIEDBY,
    DATA:"ipaas_updated_date" AS IPAAS_UPDATED_DATE,
    DATA:"src_system_operation" AS SRC_SYSTEM_OPERATION
    ,DATA:"DataEventTimestamp" AS DATA_EVENT_TIMESTAMP
    ,{{ dbt_utils.generate_surrogate_key(['DATA:"duty_code"']) }} as TABLE_SK
    ,COALESCE(TO_TIMESTAMP_TZ(DATA:"DataEventTimestamp"),TO_TIMESTAMP_NTZ(DATEADD(microsecond, FILE_ROW_NUMBER,TO_TIMESTAMP_NTZ(DATA:"ipaas_updated_date"::string)))) as QUALIFY_TIMESTAMP
FROM {{ source("landing_spm_ca", "DUTY") }}
-- to only take the files after the last fullLoad
WHERE 
    split(FILENAME, '_')[array_size(split(FILENAME, '_')) - 2] >=
    (SELECT min_timestamp
    FROM
    (SELECT split(FILENAME, '_')[array_size(split(FILENAME, '_')) - 2] AS min_timestamp, split(FILENAME, '/')[3] AS type_file
    FROM {{ source("landing_spm_ca", "DUTY") }}
    WHERE type_file LIKE 'fullload%'
    QUALIFY ROW_NUMBER() OVER (ORDER BY min_timestamp DESC) = 1)
    )