{{
  config(
    materialized = "view",
    alias = "project_divisions",
    schema='CTM'
  )
}}

SELECT
  DATA:Id AS ID
, DATA:ProjectId AS PROJECT_ID
, DATA:Code AS CODE
, DATA:Description AS DESCRIPTION
, DATA:DueDate AS DUE_DATE
, DATA:SpecialAttention AS SPECIAL_ATTENTION
, DATA:BuildMaster AS BUILD_MASTER
, DATA:Comment AS COMMENT
, DATA:SPMDivisionId AS SPM_DIVISION_ID
, DATA:Discriminator AS DISCRIMINATOR
, DATA:DeliveryDate AS DELIVERY_DATE
, DATA:TargetRFIEndDate AS TARGET_RFI_END_DATE
, DATA:TargetTieJoistOut AS TARGET_TIE_JOIST_OUT
, DATA:TargetDrawingsOutDate AS TARGET_DRAWINGS_OUT_DATE
, DATA:FabricationDueDate AS FABRICATION_DUE_DATE
, DATA:EngineeringDueDate AS ENGINEERING_DUE_DATE
, DATA:FabricationDueDateConfirmed AS FABRICATION_DUE_DATE_CONFIRMED
, DATA:EngineeringDueDateConfirmed AS ENGINEERING_DUE_DATE_CONFIRMED
, DATA:DrawingsReceivedDate AS DRAWINGS_RECEIVED_DATE
, DATA:QuotationUUID AS QUOTATION_UUID
, DATA:EstimationTargetDate AS ESTIMATION_TARGET_DATE
, DATA:DropDeadTimeInMinutes AS DROP_DEADTIME_IN_MINUTES
, DATA:TargetRFI2EndDate AS TARGET_RFI2_END_DATE
, DATA:ClientApprovalDate AS CLIENT_APPROVAL_DATE
, DATA:CopyCTMTasksFrom AS COPY_CTM_TASKSFROM
, DATA:CopyCTMAdvancement AS COPY_CTM_ADVANCEMENT
,FILENAME                           AS METADATA_FILENAME 
,FILE_ROW_NUMBER                    AS METADATA_FILE_ROW_NUMBER
,FILE_LAST_MODIFIED                 AS METADATA_FILE_LAST_MODIFIED
,START_SCAN_TIME                    AS METADATA_START_SCAN_TIME
from {{ source("landing_CTM", "ProjectDivisions") }}
-- to only take the files after the last fullLoad
  WHERE 
  split(FILENAME, '_')[array_size(split(FILENAME, '_')) - 2] >=
    (SELECT min_timestamp
  FROM
      (SELECT split(FILENAME, '_')[array_size(split(FILENAME, '_')) - 2] AS min_timestamp, split(FILENAME, '/')[3] AS type_file
      FROM {{ source("landing_CTM", "ProjectDivisions") }}
      WHERE type_file LIKE 'fullload%'
      QUALIFY ROW_NUMBER() OVER (ORDER BY min_timestamp DESC) = 1)
      
    )