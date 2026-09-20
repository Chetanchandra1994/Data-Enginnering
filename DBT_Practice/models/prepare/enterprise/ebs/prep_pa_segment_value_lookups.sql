{{
  config(
    materialized = "view",
    alias = "pa_segment_value_lookups",
    schema='EBS'
  )
}}

SELECT 
	DATA:"LAST_UPDATE_LOGIN" AS LAST_UPDATE_LOGIN,
	DATA:"CREATED_BY" AS CREATED_BY,
	DATA:"CREATION_DATE" AS CREATION_DATE,
	DATA:"LAST_UPDATE_DATE" AS LAST_UPDATE_DATE,
	DATA:"SEGMENT_VALUE_LOOKUP" AS SEGMENT_VALUE_LOOKUP,
	DATA:"SEGMENT_VALUE_LOOKUP_SET_ID" AS SEGMENT_VALUE_LOOKUP_SET_ID,
	DATA:"SEGMENT_VALUE" AS SEGMENT_VALUE,
	DATA:"LAST_UPDATED_BY" AS LAST_UPDATED_BY,
	FILENAME AS METADATA_FILENAME,
    FILE_ROW_NUMBER AS METADATA_FILE_ROW_NUMBER,
    FILE_LAST_MODIFIED AS METADATA_FILE_LAST_MODIFIED,
    START_SCAN_TIME AS METADATA_START_SCAN_TIME
FROM 
	{{ source("landing_ebs", "PA_SEGMENT_VALUE_LOOKUPS") }}
-- to only take the files after the last fullLoad
WHERE 
    split(FILENAME, '_')[array_size(split(FILENAME, '_')) - 2] >= (
        SELECT 
            min_timestamp
        FROM (
            SELECT 
                split(FILENAME, '_')[array_size(split(FILENAME, '_')) - 2] AS min_timestamp, 
                split(FILENAME, '/')[3] AS type_file
            FROM 
               {{ source("landing_ebs", "PA_SEGMENT_VALUE_LOOKUPS") }}
            WHERE 
                type_file LIKE 'fullload%'
            QUALIFY 
                ROW_NUMBER() OVER (ORDER BY min_timestamp DESC) = 1
        )
    )