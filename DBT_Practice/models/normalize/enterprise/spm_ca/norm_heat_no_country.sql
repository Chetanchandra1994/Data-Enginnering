{{
  config(
    materialized = "view",
    alias = "heat_no_country",
    schema='spm_ca'
  )
}}

SELECT
 NULLIF(UPPER(HEAT_NO::string), '') AS HEAT_NO
,TO_BOOLEAN(CERTIF::string) AS CERTIF
--ALWAYS NULL
--,PATH_MILL_TEST::string AS PATH_MILL_TEST
,UPPER(DUMMY::string) AS DUMMY
,UPPER(COUNTRY_CODE::string) AS COUNTRY_CODE
,NULLIF(UPPER(RECEIPT_NO::string), '') AS RECEIPT_NO
FROM {{ref('prep_heat_no_country')}}