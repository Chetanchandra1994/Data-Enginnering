{{
  config(
    materialized = "view",
    alias = "project_type_task_codes",
    schema='CTM'
  )
}}

SELECT
    ID::string AS ID
    ,NULLIF(TRIM(CODE::string),'') AS CODE
    ,NULLIF(TRIM(PROJECT_TYPE_ID::string),'') AS PROJECT_TYPE_ID
    ,DASHBOARD_ORDER::INTEGER AS DASHBOARD_ORDER
    ,EXCLUDE_ADVANCEMENT_FROM_TASK_COPY::string::BOOLEAN AS EXCLUDE_ADVANCEMENT_FROM_TASK_COPY
FROM {{ref('prep_project_type_task_codes')}}
QUALIFY ROW_NUMBER() OVER (
    PARTITION BY ID 
    ORDER BY METADATA_FILE_LAST_MODIFIED DESC, METADATA_FILE_ROW_NUMBER DESC
) = 1



