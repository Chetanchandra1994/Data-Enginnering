{{
  config(
    materialized = "view",
    alias = "tasks",
    schema='CTM'
  )
}}

SELECT 
 DATA:UniqueId As UNIQUE_ID
,DATA:Title As TITLE
,DATA:Status As STATUS
,DATA:DivisionDueDateDelta As DIVISION_DUE_DATE_DELTA
,DATA:StatusUpdateDate As STATUS_UPDATE_DATE
,DATA:ProjectDivisionProductId As PROJECT_DIVISION_PRODUCT_ID
,DATA:RemainingHours As REMAINING_HOURS
,DATA:EstimatedHours As ESTIMATED_HOURS
,DATA:Priority As PRIORITY
,DATA:StatusComments As STATUS_COMMENTS
,DATA:Complexity As COMPLEXITY
,DATA:Order As "ORDER"
,DATA:AssignedUserId As ASSIGNED_USERID
,DATA:ResponsibleProjectProductTeamId As RESPONSIBLE_PROJECT_PRODUCT_TEAMID
,DATA:Notes As NOTES
,DATA:FixedDueDate As FIXED_DUE_DATE
,DATA:ProjectTypeTaskCodeId As PROJECT_TYPE_TASK_CODE_ID
,DATA:DueDateLinkedTypeId As DUE_DATE_LINKED_TYPE_ID
,DATA:RealDueDate As REAL_DUE_DATE
,DATA:RealHours As REAL_HOURS
,DATA:Id As ID
,DATA:TemplateEstimatedHours As TEMPLATE_ESTIMATED_HOURS
,DATA:ProcessTemplateId As PROCESS_TEMPLATE_ID
,FILENAME                           AS METADATA_FILENAME 
,FILE_ROW_NUMBER                    AS METADATA_FILE_ROW_NUMBER
,FILE_LAST_MODIFIED                 AS METADATA_FILE_LAST_MODIFIED
,START_SCAN_TIME                    AS METADATA_START_SCAN_TIME
from {{ source("landing_CTM", "Tasks") }}
-- to only take the files after the last fullLoad
  WHERE 
  split(FILENAME, '_')[array_size(split(FILENAME, '_')) - 2] >=
    (SELECT min_timestamp
  FROM
      (SELECT split(FILENAME, '_')[array_size(split(FILENAME, '_')) - 2] AS min_timestamp, split(FILENAME, '/')[3] AS type_file
      FROM {{ source("landing_CTM", "Tasks") }}
      WHERE type_file LIKE 'fullload%'
      QUALIFY ROW_NUMBER() OVER (ORDER BY min_timestamp DESC) = 1)
    )