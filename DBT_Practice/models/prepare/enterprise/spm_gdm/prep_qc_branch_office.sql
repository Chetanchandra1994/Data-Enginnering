{{
  config(
    materialized = "view",
    alias = "qc_branch_office",
    schema='spm_gdm'
  )
}}

SELECT
DATA:"office_code" AS OFFICE_CODE
,DATA:"branch_office_code" AS BRANCH_OFFICE_CODE
,DATA:"addrss1" AS ADDRSS1
,DATA:"addrss2" AS ADDRSS2
,DATA:"city" AS CITY
,DATA:"st" AS ST
,DATA:"country" AS COUNTRY
,DATA:"zip_code" AS ZIP_CODE
,DATA:"name" AS NAME
,DATA:"phone" AS PHONE
,DATA:"fax" AS FAX
,DATA:"active" AS ACTIVE
,DATA:"tax" AS TAX
,DATA:"toll_free" AS TOLL_FREE
,DATA:"deck_calc_soft" AS DECK_CALC_SOFT
,DATA:"qc_branch_officeUUID" AS QC_BRANCH_OFFICEUUID
,DATA:"CreatedDate" AS CREATED_DATE
,DATA:"ModifiedDate" AS MODIFIED_DATE
,DATA:"CreatedBy" AS CREATED_BY
,DATA:"ModifiedBy" AS MODIFIED_BY
,DATA:"_rowid" AS ROW_ID
,DATA:"src_system_operation" AS SRC_SYSTEM_OPERATION
,DATA:"ipaas_updated_date" AS IPAAS_UPDATED_DATE
,DATA:"DataEventTimestamp" AS DATA_EVENT_TIMESTAMP
,FILENAME                            AS METADATA_FILENAME 
,FILE_ROW_NUMBER                     AS METADATA_FILE_ROW_NUMBER
,FILE_LAST_MODIFIED                  AS METADATA_FILE_LAST_MODIFIED
,START_SCAN_TIME                     AS METADATA_START_SCAN_TIME
,{{ dbt_utils.generate_surrogate_key(['DATA:"office_code"','DATA:"branch_office_code"']) }} as TABLE_SK
,COALESCE(TO_TIMESTAMP_TZ(DATA:"DataEventTimestamp"),TO_TIMESTAMP_NTZ(DATEADD(microsecond, FILE_ROW_NUMBER,TO_TIMESTAMP_NTZ(DATA:"ipaas_updated_date"::string)))) as QUALIFY_TIMESTAMP

from {{ source("landing_spm_gdm", "QC_BRANCH_OFFICE") }}
-- to only take the files after the last fullLoad
  WHERE 
  split(FILENAME, '_')[array_size(split(FILENAME, '_')) - 2] >=
    (SELECT min_timestamp
  FROM
      (SELECT split(FILENAME, '_')[array_size(split(FILENAME, '_')) - 2] AS min_timestamp, split(FILENAME, '/')[3] AS type_file
      FROM {{ source("landing_spm_gdm", "QC_BRANCH_OFFICE") }}
      WHERE type_file LIKE 'fullload%'
      QUALIFY ROW_NUMBER() OVER (ORDER BY min_timestamp DESC) = 1)
    )
 