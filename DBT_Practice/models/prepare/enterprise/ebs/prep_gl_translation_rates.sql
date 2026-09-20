{{
  config(
    materialized = "view",
    alias = "gl_translation_rates",
    schema='EBS'
  )
}}

SELECT
    DATA:"CONTEXT" AS CONTEXT
    ,DATA:"ATTRIBUTE5" AS ATTRIBUTE5
    ,DATA:"ATTRIBUTE4" AS ATTRIBUTE4
    ,DATA:"ATTRIBUTE3" AS ATTRIBUTE3
    ,DATA:"ATTRIBUTE2" AS ATTRIBUTE2
    ,DATA:"ATTRIBUTE1" AS ATTRIBUTE1
    ,DATA:"EOP_RATE" AS EOP_RATE
    ,DATA:"AVG_RATE" AS AVG_RATE
    ,DATA:"ACTUAL_FLAG" AS ACTUAL_FLAG
    ,DATA:"TO_CURRENCY_CODE" AS TO_CURRENCY_CODE
    ,DATA:"PERIOD_NAME" AS PERIOD_NAME
    ,DATA:"SET_OF_BOOKS_ID" AS SET_OF_BOOKS_ID
    ,DATA:"AVG_RATE_DENOMINATOR" AS AVG_RATE_DENOMINATOR
    ,DATA:"AVG_RATE_NUMERATOR" AS AVG_RATE_NUMERATOR
    ,DATA:"EOP_RATE_DENOMINATOR" AS EOP_RATE_DENOMINATOR
    ,DATA:"EOP_RATE_NUMERATOR" AS EOP_RATE_NUMERATOR
    ,DATA:"UPDATE_FLAG" AS UPDATE_FLAG
    ,DATA:"LAST_UPDATE_DATE" AS LAST_UPDATE_DATE
    ,DATA:"LAST_UPDATE_LOGIN" AS LAST_UPDATE_LOGIN
    ,DATA:"LAST_UPDATED_BY" AS LAST_UPDATED_BY
    ,DATA:"CREATED_BY" AS CREATED_BY
    ,DATA:"CREATION_DATE" AS CREATION_DATE
    ,FILENAME AS METADATA_FILENAME
    ,FILE_ROW_NUMBER AS METADATA_FILE_ROW_NUMBER
    ,FILE_LAST_MODIFIED AS METADATA_FILE_LAST_MODIFIED
    ,START_SCAN_TIME AS METADATA_START_SCAN_TIME
FROM
    {{ source("landing_ebs", "GL_TRANSLATION_RATES") }}
    -- to only take the files after the last fullLoad
WHERE
    split(FILENAME, '_') [array_size(split(FILENAME, '_')) - 2] >= (
        SELECT
            min_timestamp
        FROM
            (
                SELECT
                    split(FILENAME, '_') [array_size(split(FILENAME, '_')) - 2] AS min_timestamp,
                    split(FILENAME, '/') [3] AS type_file
                FROM
                    {{ source("landing_ebs", "GL_TRANSLATION_RATES") }}
                WHERE
                    type_file LIKE 'fullload%' QUALIFY ROW_NUMBER() OVER (
                        ORDER BY
                            min_timestamp DESC
                    ) = 1
            )
         )
