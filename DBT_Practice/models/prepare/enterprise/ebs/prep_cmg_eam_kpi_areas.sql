{{
  config(
    materialized = "view",
    alias = "cmg_eam_kpi_areas",
    schema='EBS'
  )
}}

SELECT 
     DATA:"AREA_ID" AS AREA_ID
    ,DATA:"AREA_NAME" AS AREA_NAME
    ,DATA:"PRODUCT_LINE_ID" AS PRODUCT_LINE_ID
    ,DATA:"SHOP_ID" AS SHOP_ID
    ,DATA:"CREATION_DATE" AS CREATION_DATE
    ,DATA:"LAST_UPDATE_DATE" AS LAST_UPDATE_DATE
    ,DATA:"ORGANIZATION_ID" AS ORGANIZATION_ID
    ,DATA:"ENABLED_FLAG" AS ENABLED_FLAG
    ,FILENAME AS METADATA_FILENAME 
    ,FILE_ROW_NUMBER AS METADATA_FILE_ROW_NUMBER
    ,FILE_LAST_MODIFIED AS METADATA_FILE_LAST_MODIFIED
    ,START_SCAN_TIME AS METADATA_START_SCAN_TIME
FROM
    {{ source("landing_ebs", "CMG_EAM_KPI_AREAS")}}
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
                    {{ source("landing_ebs", "CMG_EAM_KPI_AREAS")}}
                WHERE
                    type_file LIKE 'fullload%' QUALIFY ROW_NUMBER() OVER (
                        ORDER BY
                            min_timestamp DESC
                    ) = 1
            )
    )