{{
  config(
    materialized = "view",
    alias = "fnd_flex_values_tl",
    schema='EBS'
  )
}}

SELECT DATA:"DESCRIPTION" AS DESCRIPTION
,DATA:"LAST_UPDATE_LOGIN" AS LAST_UPDATE_LOGIN
,DATA:"CREATED_BY" AS CREATED_BY
,DATA:"CREATION_DATE" AS CREATION_DATE
,DATA:"LAST_UPDATED_BY" AS LAST_UPDATED_BY
,DATA:"LAST_UPDATE_DATE" AS LAST_UPDATE_DATE
,DATA:"LANGUAGE" AS LANGUAGE
,DATA:"FLEX_VALUE_ID" AS FLEX_VALUE_ID
,DATA:"FLEX_VALUE_MEANING" AS FLEX_VALUE_MEANING
,DATA:"SOURCE_LANG" AS SOURCE_LANG
FROM
    {{ source("landing_ebs", "FND_FLEX_VALUES_TL")}}
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
                    {{ source("landing_ebs", "FND_FLEX_VALUES_TL")}}
                WHERE
                    type_file LIKE 'fullload%' QUALIFY ROW_NUMBER() OVER (
                        ORDER BY
                            min_timestamp DESC
                    ) = 1
            )
         )