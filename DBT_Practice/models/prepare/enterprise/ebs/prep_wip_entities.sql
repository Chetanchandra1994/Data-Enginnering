{{
  config(
    materialized = "view",
    alias = "wip_entities",
    schema='EBS'
  )
}}

SELECT 
 DATA:PRIMARY_ITEM_ID AS PRIMARY_ITEM_ID
,DATA:DESCRIPTION AS DESCRIPTION
,DATA:ENTITY_TYPE AS ENTITY_TYPE
,DATA:WIP_ENTITY_NAME AS WIP_ENTITY_NAME
,DATA:PROGRAM_UPDATE_DATE AS PROGRAM_UPDATE_DATE
,DATA:PROGRAM_ID AS PROGRAM_ID
,DATA:PROGRAM_APPLICATION_ID AS PROGRAM_APPLICATION_ID
,DATA:REQUEST_ID AS REQUEST_ID
,DATA:LAST_UPDATE_LOGIN AS LAST_UPDATE_LOGIN
,DATA:CREATED_BY AS CREATED_BY
,DATA:CREATION_DATE AS CREATION_DATE
,DATA:LAST_UPDATED_BY AS LAST_UPDATED_BY
,DATA:LAST_UPDATE_DATE AS LAST_UPDATE_DATE
,DATA:ORGANIZATION_ID AS ORGANIZATION_ID
,DATA:WIP_ENTITY_ID AS WIP_ENTITY_ID
,DATA:GEN_OBJECT_ID AS GEN_OBJECT_ID
,FILENAME                             AS METADATA_FILENAME 
,FILE_ROW_NUMBER                      AS METADATA_FILE_ROW_NUMBER
,FILE_LAST_MODIFIED                   AS METADATA_FILE_LAST_MODIFIED
,START_SCAN_TIME                      AS METADATA_START_SCAN_TIME
FROM {{ source("landing_ebs", "WIP_ENTITIES") }}
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
                  {{ source("landing_ebs", "WIP_ENTITIES")}}
                    
                WHERE
                    type_file LIKE 'fullload%' QUALIFY ROW_NUMBER() OVER (
                        ORDER BY
                            min_timestamp DESC
                    ) = 1
            )
         )
         