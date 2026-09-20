{{
  config(
    materialized = "view",
    alias = "entity_descriptions",
    schema='enterprise_MANUAL'
  )
}}

SELECT 

    ENTITY_CODE::string AS ENTITY_CODE
    ,CITY::string AS CITY
    ,TIMEZONE::string AS TIMEZONE
    ,TIME_FORMAT::string AS TIME_FORMAT
    ,NAME::string AS NAME
    ,DEFAULT_LANGUAGE_CODE::string AS DEFAULT_LANGUAGE_CODE
    ,LOCATION_STATE_CODE::string AS LOCATION_STATE_CODE
    ,LOCATION_STATE_NAME_EN::string AS LOCATION_STATE_NAME_EN
    ,LOCATION_STATE_NAME_FR::string AS LOCATION_STATE_NAME_FR
    ,LOCATION_COUNTRY_CODE::string AS LOCATION_COUNTRY_CODE
    ,LOCATION_COUNTRY_NAME_EN::string AS LOCATION_COUNTRY_NAME_EN
    ,LOCATION_COUNTRY_NAME_FR ::string AS LOCATION_COUNTRY_NAME_FR 

from {{ ref ('prep_manual_entity_descriptions') }} 