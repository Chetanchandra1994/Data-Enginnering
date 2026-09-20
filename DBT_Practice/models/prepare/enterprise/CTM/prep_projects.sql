{{
  config(
    materialized = "view",
    alias = "projects",
    schema='CTM'
  )
}}


SELECT
 DATA:Id AS ID
,DATA:Code AS CODE
,DATA:Name AS NAME
,DATA:Leed AS LEED
,DATA:BuildMaster AS BUILD_MASTER
,DATA:SpecialElements AS SPECIAL_ELEMENTS
,DATA:Comments AS COMMENTS
,DATA:Customer AS CUSTOMER
,DATA:ProjectCoordinatorLDAPId AS PROJECT_COORDINATOR_LDAP_ID
,DATA:ProjectManagerLDAPId AS PROJECT_MANAGER_LDAP_ID
,DATA:Priority AS PRIORITY
,DATA:Status AS STATUS
,DATA:StatusComments AS STATUS_COMMENTS
,DATA:SPMProjectId AS SPM_PROJECT_ID
,DATA:Discriminator AS DISCRIMINATOR
,DATA:WeightIncreaseComment AS WEIGHT_INCREASE_COMMENT
,DATA:DesignCompleted AS DESIGN_COMPLETED
,DATA:ProjectTypeId AS PROJECT_TYPE_ID
,DATA:CreationDateTime AS CREATION_DATE_TIME
,DATA:QuotationUUID AS QUOTATION_UUID
,DATA:SalesRepresentativeLDAPId AS SALES_REPRESENTATIVE_LDAP_ID
,DATA:DirectDesign AS DIRECT_DESIGN
,DATA:MasterJobNo AS MASTER_JOB_NO
,DATA:ProjectFilesSubFolder AS PROJECT_FILES_SUB_FOLDER
,DATA:ProjectFilesConfiguration_Id AS PROJECT_FILES_CONFIGURATION_ID
,DATA:StatusUpdateDateTime AS STATUS_UPDATE_DATE_TIME
,DATA:QuotationNumber AS QUOTATION_NUMBER
,DATA:Package AS PACKAGE
,DATA:IssuedForBudget AS ISSUED_FOR_BUDGET
,FILENAME                           AS METADATA_FILENAME 
,FILE_ROW_NUMBER                    AS METADATA_FILE_ROW_NUMBER
,FILE_LAST_MODIFIED                 AS METADATA_FILE_LAST_MODIFIED
,START_SCAN_TIME                    AS METADATA_START_SCAN_TIME
from {{ source("landing_CTM", "Projects") }}
-- to only take the files after the last fullLoad
  WHERE 
  split(FILENAME, '_')[array_size(split(FILENAME, '_')) - 2] >=
    (SELECT min_timestamp
  FROM
      (SELECT split(FILENAME, '_')[array_size(split(FILENAME, '_')) - 2] AS min_timestamp, split(FILENAME, '/')[3] AS type_file
      FROM {{ source("landing_CTM", "Projects") }}
      WHERE type_file LIKE 'fullload%'
      QUALIFY ROW_NUMBER() OVER (ORDER BY min_timestamp DESC) = 1)
    )
 