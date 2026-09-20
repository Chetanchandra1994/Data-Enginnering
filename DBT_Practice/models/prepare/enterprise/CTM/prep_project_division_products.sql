{{
  config(
    materialized = "view",
    alias = "project_division_products",
    schema='CTM'
  )
}}

SELECT
  DATA:Id AS ID
, DATA:ProjectDivisionId AS PROJECT_DIVISION_ID
, DATA:ProjectProductId AS PROJECT_PRODUCT_ID
, DATA:ProcessTemplateId AS PROCESS_TEMPLATE_ID
, DATA:SegmentId AS SEGMENT_ID
, DATA:Status AS STATUS
, DATA:StatusComment AS STATUS_COMMENT
, DATA:Discriminator AS DISCRIMINATOR
, DATA:ManuallyIgnored AS MANUALLY_IGNORED
, DATA:StartingDateOffset AS STARTING_DATE_OFFSET
, DATA:StartingDate AS STARTING_DATE
,FILENAME                           AS METADATA_FILENAME 
,FILE_ROW_NUMBER                    AS METADATA_FILE_ROW_NUMBER
,FILE_LAST_MODIFIED                 AS METADATA_FILE_LAST_MODIFIED
,START_SCAN_TIME                    AS METADATA_START_SCAN_TIME
from {{ source("landing_CTM", "ProjectDivisionProducts") }}
-- to only take the files after the last fullLoad
  WHERE 
  split(FILENAME, '_')[array_size(split(FILENAME, '_')) - 2] >=
    (SELECT min_timestamp
  FROM
      (SELECT split(FILENAME, '_')[array_size(split(FILENAME, '_')) - 2] AS min_timestamp, split(FILENAME, '/')[3] AS type_file
      FROM {{ source("landing_CTM", "ProjectDivisionProducts") }}
      WHERE type_file LIKE 'fullload%'
      QUALIFY ROW_NUMBER() OVER (ORDER BY min_timestamp DESC) = 1)
    )