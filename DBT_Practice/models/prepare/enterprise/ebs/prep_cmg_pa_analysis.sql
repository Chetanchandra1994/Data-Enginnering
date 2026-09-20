{{
  config(
    materialized = "view",
    alias = "cmg_pa_analysis",
    schema='EBS'
  )
}}

SELECT 
DATA:SHIPPED_UOM AS SHIPPED_UOM
,DATA:SHIPPED_LBS AS SHIPPED_LBS
,DATA:COGS_AMOUNT AS COGS_AMOUNT
,DATA:REVENUE_AMOUNT AS REVENUE_AMOUNT
,DATA:PERIOD_NAME AS PERIOD_NAME
,DATA:ORGANIZATION_ID AS ORGANIZATION_ID
,DATA:BILL_TO_ADDRESS_ID AS BILL_TO_ADDRESS_ID
,DATA:TASK_ID AS TASK_ID
,DATA:PROJECT_ID AS PROJECT_ID
,DATA:ORG_ID AS ORG_ID
,DATA:MONTH_ENDING_DATE AS MONTH_ENDING_DATE
,DATA:MEMBER_FLAG AS MEMBER_FLAG
,DATA:SHIPPED_UNITS AS SHIPPED_UNITS
,DATA:ADJUST_AMOUNT AS ADJUST_AMOUNT
,DATA:PRINT_FLAG AS PRINT_FLAG
,DATA:BACKCHARGE_AMOUNT AS BACKCHARGE_AMOUNT
,DATA:LAST_UPDATE_DATE AS LAST_UPDATE_DATE
,FILENAME                             AS METADATA_FILENAME 
,FILE_ROW_NUMBER                      AS METADATA_FILE_ROW_NUMBER
,FILE_LAST_MODIFIED                   AS METADATA_FILE_LAST_MODIFIED
,START_SCAN_TIME                      AS METADATA_START_SCAN_TIME
FROM {{ source("landing_ebs", "CMG_PA_ANALYSIS") }}
WHERE
    split(FILENAME, '_') [array_size(split(FILENAME, '_')) - 2] >= (
        SELECT
            min_timestamp
        FROM 
            (
                SELECT
                    split(FILENAME, '_') [array_size(split(FILENAME, '_')) - 2] AS min_timestamp,
                    split(FILENAME, '/') [3] AS type_file
                FROM 
                  {{ source("landing_ebs", "CMG_PA_ANALYSIS")}}
                    
                WHERE
                    type_file LIKE 'fullload%' QUALIFY ROW_NUMBER() OVER (
                        ORDER BY
                            min_timestamp DESC
                    ) = 1
            )
         )