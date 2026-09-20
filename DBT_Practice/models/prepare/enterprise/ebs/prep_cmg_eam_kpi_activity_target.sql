
{{
  config(
    materialized = "view",
    alias = "cmg_eam_kpi_activity_target",
    schema='EBS'
  )
}}

SELECT 
     DATA:TARGET_PERCENT_TO AS TARGET_PERCENT_TO
    ,DATA:TARGET_TIME AS TARGET_TIME
    ,DATA:TARGET_PERCENT_FROM AS TARGET_PERCENT_FROM
    ,DATA:END_DATE_ACTIVE AS END_DATE_ACTIVE
    ,DATA:START_DATE_ACTIVE AS START_DATE_ACTIVE
    ,DATA:LAST_UPDATE_DATE AS LAST_UPDATE_DATE
    ,DATA:CREATION_DATE AS CREATION_DATE
    ,DATA:ORGANIZATION_ID AS ORGANIZATION_ID
    ,DATA:ACTIVITY_TYPE_CODE AS ACTIVITY_TYPE_CODE
    ,DATA:TARGET_ID AS TARGET_ID
    ,FILENAME AS METADATA_FILENAME 
    ,FILE_ROW_NUMBER AS METADATA_FILE_ROW_NUMBER
    ,FILE_LAST_MODIFIED AS METADATA_FILE_LAST_MODIFIED
    ,START_SCAN_TIME AS METADATA_START_SCAN_TIME
FROM
    {{ source("landing_ebs", "CMG_EAM_KPI_ACTIVITY_TARGET")}}
    -- to only take the files after the last fullLoad
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
                    {{ source("landing_ebs", "CMG_EAM_KPI_ACTIVITY_TARGET")}}
                WHERE
                    type_file LIKE 'fullload%' QUALIFY ROW_NUMBER() OVER (
                        ORDER BY
                            min_timestamp DESC
                    ) = 1
            )
    )