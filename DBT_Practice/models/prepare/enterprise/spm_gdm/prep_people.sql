{{
  config(
    materialized = "view",
    alias = "people",
    schema='spm_gdm'
  )
}}

SELECT
DATA:"people_uuid" AS PEOPLE_UUID
,DATA:"people_id" AS PEOPLE_ID
,DATA:"code" AS CODE
,DATA:"name" AS NAME
,DATA:"active" AS ACTIVE
,DATA:"email" AS EMAIL
,DATA:"email2" AS EMAIL2
,DATA:"drawing_follow_up_email" AS DRAWING_FOLLOW_UP_EMAIL
,DATA:"delivery_date_modification_email" AS DELIVERY_DATE_MODIFICATION_EMAIL
,DATA:"delivery_date_req_rec_date_email" AS DELIVERY_DATE_REQ_REC_DATE_EMAIL
,DATA:"office_code" AS OFFICE_CODE
,DATA:"branch_office_code" AS BRANCH_OFFICE_CODE
,DATA:"default_role_uuid" AS DEFAULT_ROLE_UUID
,DATA:"truck_loading_password" AS TRUCK_LOADING_PASSWORD
,DATA:"default_loading_team" AS DEFAULT_LOADING_TEAM
,DATA:"events_follow_up_email" AS EVENTS_FOLLOW_UP_EMAIL
,DATA:"vehicle_modification_email" AS VEHICLE_MODIFICATION_EMAIL
,DATA:"delivery_date_modif_daily_email" AS DELIVERY_DATE_MODIF_DAILY_EMAIL
,DATA:"new_projects_daily_email" AS NEW_PROJECTS_DAILY_EMAIL
,DATA:"FaxServiceUUID" AS FAX_SERVICE_UUID
,DATA:"SupervisorPeopleID" AS SUPERVISOR_PEOPLE_ID
,DATA:"CreditStatusModificationEmail" AS CREDIT_STATUS_MODIFICATION_EMAIL
,DATA:"_rowid" AS ROW_ID
,DATA:"src_system_operation" AS SRC_SYSTEM_OPERATION
,DATA:"ipaas_updated_date" AS IPAAS_UPDATED_DATE
,DATA:"CreatedDate" AS CREATED_DATE
,DATA:"ModifiedDate" AS MODIFIED_DATE
,DATA:"CreatedBy" AS CREATED_BY
,DATA:"ModifiedBy" AS MODIFIED_BY
,DATA:"DataEventTimestamp" AS DATA_EVENT_TIMESTAMP
,FILENAME                            AS METADATA_FILENAME 
,FILE_ROW_NUMBER                     AS METADATA_FILE_ROW_NUMBER
,FILE_LAST_MODIFIED                  AS METADATA_FILE_LAST_MODIFIED
,START_SCAN_TIME                     AS METADATA_START_SCAN_TIME
,{{ dbt_utils.generate_surrogate_key(['DATA:"code"']) }} as TABLE_SK
,COALESCE(TO_TIMESTAMP_TZ(DATA:"DataEventTimestamp"),TO_TIMESTAMP_NTZ(DATEADD(microsecond, FILE_ROW_NUMBER,TO_TIMESTAMP_NTZ(DATA:"ipaas_updated_date"::string)))) as QUALIFY_TIMESTAMP

from
(
   SELECT OBJECT_INSERT(OBJECT_INSERT(PARSE_JSON(PARSE_JSON(DATA):Body), 'ipaas_updated_date', PARSE_JSON(DATA):ipaas_updated_date::string),'src_system_operation',PARSE_JSON(DATA):Action::string) AS DATA
    ,FILENAME, FILE_ROW_NUMBER, FILE_LAST_MODIFIED, START_SCAN_TIME
    FROM  {{ source("landing_spm_gdm", "DATAEVENTS") }}
    WHERE PARSE_JSON(DATA):TableName = 'gdm.people'
    UNION (SELECT * FROM  {{ source("landing_spm_gdm", "PEOPLE") }}
))
-- to only take the files after the last fullLoad
WHERE  
split(FILENAME, '_')[array_size(split(FILENAME, '_')) - 2] >=
(SELECT min_timestamp
FROM
  (SELECT split(FILENAME, '_')[array_size(split(FILENAME, '_')) - 2] AS min_timestamp, split(FILENAME, '/')[3] AS type_file
  FROM  {{ source("landing_spm_gdm", "PEOPLE") }}
  WHERE type_file LIKE 'fullload%'
  QUALIFY ROW_NUMBER() OVER (ORDER BY min_timestamp DESC) = 1)
)