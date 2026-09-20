{{
  config(
    materialized = "view",
    alias = "cmg_eam_kpi_shops",
    schema='EBS'
  )
}}

SELECT 
 DATA:ENABLED_FLAG AS ENABLED_FLAG
,DATA:ORGANIZATION_ID AS ORGANIZATION_ID
,DATA:LAST_UPDATE_DATE AS LAST_UPDATE_DATE
,DATA:CREATION_DATE AS CREATION_DATE
,DATA:SHOP_NAME AS SHOP_NAME
,DATA:SHOP_ID AS SHOP_ID
,FILENAME                             AS METADATA_FILENAME 
,FILE_ROW_NUMBER                      AS METADATA_FILE_ROW_NUMBER
,FILE_LAST_MODIFIED                   AS METADATA_FILE_LAST_MODIFIED
,START_SCAN_TIME                      AS METADATA_START_SCAN_TIME
FROM {{ source("landing_ebs", "CMG_EAM_KPI_SHOPS") }}
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
                  {{ source("landing_ebs", "CMG_EAM_KPI_SHOPS")}}
                    
                WHERE
                    type_file LIKE 'fullload%' QUALIFY ROW_NUMBER() OVER (
                        ORDER BY
                            min_timestamp DESC
                    ) = 1
            )
         )