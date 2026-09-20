{{
  config(
    materialized = "view",
    alias = "pa_periods_all",
    schema='EBS'
  )
}}

SELECT DATA:"PERIOD_NAME" AS PERIOD_NAME
,DATA:"LAST_UPDATE_DATE" AS LAST_UPDATE_DATE
,DATA:"LAST_UPDATED_BY" AS LAST_UPDATED_BY
,DATA:"CREATION_DATE" AS CREATION_DATE
,DATA:"CREATED_BY" AS CREATED_BY
,DATA:"LAST_UPDATE_LOGIN" AS LAST_UPDATE_LOGIN
,DATA:"START_DATE" AS START_DATE
,DATA:"END_DATE" AS END_DATE
,DATA:"STATUS" AS STATUS
,DATA:"GL_PERIOD_NAME" AS GL_PERIOD_NAME
,DATA:"CURRENT_PA_PERIOD_FLAG" AS CURRENT_PA_PERIOD_FLAG
,DATA:"ORG_ID" AS ORG_ID
,FILENAME                             AS METADATA_FILENAME 
,FILE_ROW_NUMBER                      AS METADATA_FILE_ROW_NUMBER
,FILE_LAST_MODIFIED                   AS METADATA_FILE_LAST_MODIFIED
,START_SCAN_TIME                      AS METADATA_START_SCAN_TIME
FROM {{ source("landing_ebs", "PA_PERIODS_ALL") }}
-- to only take the files after the last fullLoad
  WHERE 
  split(FILENAME, '_')[array_size(split(FILENAME, '_')) - 2] >=
    (SELECT min_timestamp
  FROM
      (SELECT split(FILENAME, '_')[array_size(split(FILENAME, '_')) - 2] AS min_timestamp, split(FILENAME, '/')[3] AS type_file
      FROM {{ source("landing_ebs", "PA_PERIODS_ALL") }}
      WHERE type_file LIKE 'fullload%'
      QUALIFY ROW_NUMBER() OVER (ORDER BY min_timestamp DESC) = 1)
    )