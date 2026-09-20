{{
  config(
    materialized = "view",
    alias = "proj_seq_lp",
    schema='spm_ca',
    tags=["proj_seq_lp"]
  )
}}

SELECT 
 UPPER(DATA:"entity_code"::string) AS ENTITY_CODE
,UPPER(DATA:"no_projet"::string) AS NO_PROJET
,DATA:"seq_no"::integer AS SEQ_NO
,DATA:"no_produit"::integer AS NO_PRODUIT
,DATA:"weight_1"::double AS WEIGHT_1
,DATA:"weight_2"::double AS WEIGHT_2
,DATA:"weight_3"::double AS WEIGHT_3
,DATA:"tmps_1"::double AS TMPS_1
,DATA:"tmps_2"::double AS TMPS_2
,DATA:"pces_1"::double AS PCES_1
,DATA:"pces_2"::double AS PCES_2
,DATA:"pces_3"::double AS PCES_3
,DATA:"requisitions_received_date"::date AS REQUISITIONS_RECEIVED_DATE
,DATA:"produced_amount"::double AS PRODUCED_AMOUNT
,DATA:"shipped_amount"::double AS SHIPPED_AMOUNT
,DATA:"estimated_amount"::double AS ESTIMATED_AMOUNT
,DATA:"produced_uom"::double AS PRODUCED_UOM
,DATA:"shipped_uom"::double AS SHIPPED_UOM
,DATA:"estimated_uom"::double AS ESTIMATED_UOM
,TO_BOOLEAN(DATA:"print_information_on_item"::string) AS PRINT_INFORMATION_ON_ITEM
,DATA:"estimated_plant_fabrication_time"::double AS ESTIMATED_PLANT_FABRICATION_TIME
,TO_TIMESTAMP_NTZ(DATA:"CreatedDate"::string) AS CREATED_DATE
,TO_TIMESTAMP_NTZ(DATA:"ModifiedDate"::string) AS MODIFIED_DATE
,NULLIF(DATA:"CreatedBy"::string,'') AS CREATED_BY
,NULLIF(DATA:"ModifiedBy"::string,'') AS MODIFIED_BY
,DATA:"proj_seq_lp_uuid"::string AS PROJ_SEQ_LP_UUID
,TO_TIMESTAMP_NTZ(DATA:"ipaas_updated_date"::string) AS IPAAS_UPDATED_DATE
,DATA:"DataEventTimestamp" AS DATA_EVENT_TIMESTAMP
,DATA:"src_system_operation"::string AS SRC_SYSTEM_OPERATION
,FILENAME                           AS METADATA_FILENAME 
,FILE_ROW_NUMBER                    AS METADATA_FILE_ROW_NUMBER
,FILE_LAST_MODIFIED                 AS METADATA_FILE_LAST_MODIFIED
,START_SCAN_TIME                    AS METADATA_START_SCAN_TIME
,{{ dbt_utils.generate_surrogate_key(['DATA:"no_projet"','DATA:"seq_no"','DATA:"entity_code"','DATA:"no_produit"']) }} as TABLE_SK
,COALESCE(TO_TIMESTAMP_TZ(DATA:"DataEventTimestamp"),TO_TIMESTAMP_NTZ(DATEADD(microsecond, FILE_ROW_NUMBER,TO_TIMESTAMP_NTZ(DATA:"ipaas_updated_date"::string)))) as QUALIFY_TIMESTAMP

from {{ source("landing_spm_ca", "PROJ_SEQ_LP") }}
-- to only take the files after the last fullLoad
WHERE 
  split(FILENAME, '_')[array_size(split(FILENAME, '_')) - 2] >=
  (SELECT min_timestamp
  FROM
      (SELECT split(FILENAME, '_')[array_size(split(FILENAME, '_')) - 2] AS min_timestamp, split(FILENAME, '/')[3] AS type_file
      FROM {{ source("landing_spm_ca", "PROJ_SEQ_LP") }}
      WHERE type_file LIKE 'fullload%'
      QUALIFY ROW_NUMBER() OVER (ORDER BY min_timestamp DESC) = 1)
  )