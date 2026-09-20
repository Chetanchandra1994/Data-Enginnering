{{
 config(
 materialized = "view",
 alias = "product_attribute",
 schema='spm_ca'
 )
}}

SELECT
    DATA:"entity_code" AS ENTITY_CODE
    ,DATA:"no_produit" AS NO_PRODUIT
    ,DATA:"attribute_code" AS ATTRIBUTE_CODE
    ,DATA:"attribute_value" AS ATTRIBUTE_VALUE
    ,DATA:"dummy" AS DUMMY
    ,DATA:"ipaas_updated_date" AS IPAAS_UPDATED_DATE
    ,DATA:"DataEventTimestamp" AS DATA_EVENT_TIMESTAMP
    ,FILENAME AS METADATA_FILENAME 
    ,FILE_ROW_NUMBER AS METADATA_FILE_ROW_NUMBER
    ,FILE_LAST_MODIFIED AS METADATA_FILE_LAST_MODIFIED
    ,START_SCAN_TIME AS METADATA_START_SCAN_TIME
    ,{{ dbt_utils.generate_surrogate_key(['DATA:"entity_code"','DATA:"no_produit"','DATA:"attribute_code"','DATA:"attribute_value"']) }} as TABLE_SK
    ,COALESCE(TO_TIMESTAMP_TZ(DATA:"DataEventTimestamp"),TO_TIMESTAMP_NTZ(DATEADD(microsecond, FILE_ROW_NUMBER,TO_TIMESTAMP_NTZ(DATA:"ipaas_updated_date"::string)))) as QUALIFY_TIMESTAMP

FROM {{ source("landing_spm_ca", "PRODUCT_ATTRIBUTE") }}
-- to only take the files after the last fullLoad
WHERE 
    split(FILENAME, '_')[array_size(split(FILENAME, '_')) - 2] >=
    (SELECT min_timestamp
    FROM
    (SELECT split(FILENAME, '_')[array_size(split(FILENAME, '_')) - 2] AS min_timestamp, split(FILENAME, '/')[3] AS type_file
    FROM {{ source("landing_spm_ca", "PRODUCT_ATTRIBUTE") }}
    WHERE type_file LIKE 'fullload%'
    QUALIFY ROW_NUMBER() OVER (ORDER BY min_timestamp DESC) = 1)
    )