{{
  config(
    materialized = "view",
    alias = "qc_office",
    schema='spm_gdm'
  )
}}


SELECT
DATA:"office_code" AS OFFICE_CODE
,DATA:"next_job_no" AS NEXT_JOB_NO
,DATA:"prefix" AS PREFIX
,DATA:"bill_ship" AS BILL_SHIP
,DATA:"addrss1" AS ADDRSS1
,DATA:"addrss2" AS ADDRSS2
,DATA:"city" AS CITY
,DATA:"st" AS ST
,DATA:"country" AS COUNTRY
,DATA:"zip_code" AS ZIP_CODE
,DATA:"phone" AS PHONE
,DATA:"fax" AS FAX
,DATA:"opening_fee" AS OPENING_FEE
,DATA:"rounding_factor" AS ROUNDING_FACTOR
,DATA:"mesure" AS MESURE
,DATA:"logo_file_3" AS LOGO_FILE_3
,DATA:"logo_file_1" AS LOGO_FILE_1
,DATA:"logo_file_2" AS LOGO_FILE_2
,DATA:"name" AS NAME
,DATA:"currency_cod" AS CURRENCY_COD
,DATA:"calc_soft" AS CALC_SOFT
,DATA:"seq_year" AS SEQ_YEAR
,DATA:"active" AS ACTIVE
,DATA:"default_contrc_note_3" AS DEFAULT_CONTRC_NOTE_3
,DATA:"default_contrc_note_1" AS DEFAULT_CONTRC_NOTE_1
,DATA:"default_contrc_note_2" AS DEFAULT_CONTRC_NOTE_2
,DATA:"date_format" AS DATE_FORMAT
,DATA:"tolerance_factor" AS TOLERANCE_FACTOR
,DATA:"signature" AS SIGNATURE
,DATA:"phone_format" AS PHONE_FORMAT
,DATA:"price_expiration_delay" AS PRICE_EXPIRATION_DELAY
,DATA:"detail_edit_allowed" AS DETAIL_EDIT_ALLOWED
,DATA:"use_office_logo" AS USE_OFFICE_LOGO
,DATA:"eng_solution_completed_mandatory" AS ENG_SOLUTION_COMPLETED_MANDATORY
,DATA:"ar_entity" AS AR_ENTITY
,DATA:"show_addresses_on_fps" AS SHOW_ADDRESSES_ON_FPS
,DATA:"toll_free" AS TOLL_FREE
,DATA:"office_address_format_on_doc" AS OFFICE_ADDRESS_FORMAT_ON_DOC
,DATA:"show_currency_on_fps" AS SHOW_CURRENCY_ON_FPS
,DATA:"documents_due_in_delay" AS DOCUMENTS_DUE_IN_DELAY
,DATA:"SalesManagerPeopleID" AS SALESMANAGERPEOPLEID
,DATA:"EstimationTargetDateDelay" AS ESTIMATIONTARGETDATEDELAY
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
,{{ dbt_utils.generate_surrogate_key(['DATA:"office_code"']) }} as TABLE_SK
,COALESCE(TO_TIMESTAMP_TZ(DATA:"DataEventTimestamp"),TO_TIMESTAMP_NTZ(DATEADD(microsecond, FILE_ROW_NUMBER,TO_TIMESTAMP_NTZ(DATA:"ipaas_updated_date"::string)))) as QUALIFY_TIMESTAMP

from {{ source("landing_spm_gdm", "QC_OFFICE") }}
-- to only take the files after the last fullLoad
  WHERE 
  split(FILENAME, '_')[array_size(split(FILENAME, '_')) - 2] >=
    (SELECT min_timestamp
  FROM
      (SELECT split(FILENAME, '_')[array_size(split(FILENAME, '_')) - 2] AS min_timestamp, split(FILENAME, '/')[3] AS type_file
      FROM {{ source("landing_spm_gdm", "QC_OFFICE") }}
      WHERE type_file LIKE 'fullload%'
      QUALIFY ROW_NUMBER() OVER (ORDER BY min_timestamp DESC) = 1)
    )
 