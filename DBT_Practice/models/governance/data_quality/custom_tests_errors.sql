{{
  config(
    full_refresh = true,
    materialized="dynamic_table",
    target_lag="1 hour",
    snowflake_warehouse= var('task_warehouse'),
    alias = "custom_tests_errors",
    schema= "data_quality",
    post_hook = "ALTER DYNAMIC TABLE {{ this }} SET LOG_LEVEL = ERROR"
  )
}}

WITH active_errors AS (
    SELECT DISTINCT
        etl_event_detail.ETL_EVENT_DETAIL_SK,
        etl_event_detail.EVENT_DATE_KEY,
        etl_event_detail.TABLE_KEY,
        etl_event_detail.FIELD_KEY,
        etl_event_detail.RECORD_CONTENT,
        etl_event_description.DESCRIPTION_EN
    FROM {{ ref('etl_event_detail') }} AS etl_event_detail
    JOIN {{ ref('etl_event_description') }} AS etl_event_description
        ON etl_event_detail.ETL_EVENT_DESCRIPTION_CODE = etl_event_description.ETL_EVENT_DESCRIPTION_CODE
    WHERE etl_event_detail.ETL_EVENT_STATUS = 'ACTIVE'

)

SELECT
    active_errors.ETL_EVENT_DETAIL_SK,
    active_errors.DESCRIPTION_EN,
    active_errors.EVENT_DATE_KEY,
    active_errors.FIELD_KEY,
    active_errors.TABLE_KEY,
    f.key AS attribute_name,
    f.value AS attribute_value
FROM active_errors,
    LATERAL FLATTEN(INPUT => active_errors.RECORD_CONTENT) AS f
ORDER BY active_errors.ETL_EVENT_DETAIL_SK