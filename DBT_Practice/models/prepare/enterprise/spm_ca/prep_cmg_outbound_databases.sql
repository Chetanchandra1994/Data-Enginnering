{{
  config(
    materialized = "view",
    alias = "cmg_outbound_databases",
    schema='spm_ca'
  )
}}


SELECT
DATA:"database_name" AS DATABASE_NAME
,DATA:"database_description" AS DATABASE_DESCRIPTION
,DATA:"local_output_path" AS LOCAL_OUTPUT_PATH
,DATA:"host_name" AS HOST_NAME
,DATA:"host_destination_path" AS HOST_DESTINATION_PATH
,DATA:"host_user_name" AS HOST_USER_NAME
,DATA:"host_password" AS HOST_PASSWORD
,DATA:"set_of_books" AS SET_OF_BOOKS
,DATA:"project_prefix" AS PROJECT_PREFIX
,DATA:"administrator_email" AS ADMINISTRATOR_EMAIL
,DATA:"local_currency" AS LOCAL_CURRENCY
,DATA:"desgo_email" AS DESGO_EMAIL
,DATA:"ar_entity" AS AR_ENTITY
,DATA:"manufacturing_helpdesk_email" AS MANUFACTURING_HELPDESK_EMAIL
,DATA:"finapps_helpdesk_email" AS FINAPPS_HELPDESK_EMAIL
,DATA:"customer_credit_management_email" AS CUSTOMER_CREDIT_MANAGEMENT_EMAIL
,DATA:"CreatedBy" AS CREATEDBY
,DATA:"CreatedDate" AS CREATEDDATE
,DATA:"ModifiedDate" AS MODIFIEDDATE
,DATA:"ModifiedBy" AS MODIFIEDBY
,FILENAME                           AS METADATA_FILENAME 
,FILE_ROW_NUMBER                    AS METADATA_FILE_ROW_NUMBER
,FILE_LAST_MODIFIED                 AS METADATA_FILE_LAST_MODIFIED
,START_SCAN_TIME                    AS METADATA_START_SCAN_TIME
,DATA:"DataEventTimestamp" AS DATA_EVENT_TIMESTAMP
,{{ dbt_utils.generate_surrogate_key(['DATA:"database_name"']) }} as TABLE_SK
,COALESCE(TO_TIMESTAMP_TZ(DATA:"DataEventTimestamp"),TO_TIMESTAMP_NTZ(DATEADD(microsecond, FILE_ROW_NUMBER,TO_TIMESTAMP_NTZ(DATA:"ipaas_updated_date"::string)))) as QUALIFY_TIMESTAMP
FROM {{ source("landing_spm_ca", "CMG_OUTBOUND_DATABASES") }}
-- to only take the files after the last fullLoad
WHERE 
  split(FILENAME, '_')[array_size(split(FILENAME, '_')) - 2] >=
  (SELECT min_timestamp
  FROM
      (SELECT split(FILENAME, '_')[array_size(split(FILENAME, '_')) - 2] AS min_timestamp, split(FILENAME, '/')[3] AS type_file
      FROM {{ source("landing_spm_ca", "CMG_OUTBOUND_DATABASES") }}
      WHERE type_file LIKE 'fullload%'
      QUALIFY ROW_NUMBER() OVER (ORDER BY min_timestamp DESC) = 1)
  )