{{
  config(
    materialized = "view",
    alias = "project_type_task_codes",
    schema='CTM'
  )
}}


SELECT
 DATA:Id AS ID
,DATA:Code AS CODE
,DATA:ProjectType_Id AS Project_Type_ID
,DATA:DashboardOrder AS Dashboard_Order
,DATA:ExcludeAdvancementFromTaskCopy AS Exclude_Advancement_From_Task_Copy
,FILENAME                           AS METADATA_FILENAME 
,FILE_ROW_NUMBER                    AS METADATA_FILE_ROW_NUMBER
,FILE_LAST_MODIFIED                 AS METADATA_FILE_LAST_MODIFIED
,START_SCAN_TIME                    AS METADATA_START_SCAN_TIME
from {{ source("landing_CTM", "ProjectTypeTaskCodes") }}
-- to only take the files after the last fullLoad
  WHERE 
  split(FILENAME, '_')[array_size(split(FILENAME, '_')) - 2] >=
    (SELECT min_timestamp
  FROM
      (SELECT split(FILENAME, '_')[array_size(split(FILENAME, '_')) - 2] AS min_timestamp, split(FILENAME, '/')[3] AS type_file
      FROM {{ source("landing_CTM", "ProjectTypeTaskCodes") }}
      WHERE type_file LIKE 'fullload%'
      QUALIFY ROW_NUMBER() OVER (ORDER BY min_timestamp DESC) = 1)
    )
 