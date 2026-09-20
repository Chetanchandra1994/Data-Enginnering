 {{
  config(
    materialized = "view",
    alias = "hz_party_sites",
    schema='EBS'
  )
}}

SELECT
 PARTY_SITE_ID::number(15,0) AS  PARTY_SITE_ID
, PARTY_ID::number(15,0) AS  PARTY_ID
, LOCATION_ID::number(15,0) AS  LOCATION_ID
, TO_TIMESTAMP_NTZ(LAST_UPDATE_DATE::string) AS  LAST_UPDATE_DATE
, PARTY_SITE_NUMBER::string AS  PARTY_SITE_NUMBER
, LAST_UPDATED_BY::number(15,0) AS  LAST_UPDATED_BY
, TO_TIMESTAMP_NTZ(CREATION_DATE::string) AS  CREATION_DATE
, CREATED_BY::number(15,0) AS  CREATED_BY
, LAST_UPDATE_LOGIN::number(15,0) AS  LAST_UPDATE_LOGIN
, REQUEST_ID::number(15,0) AS  REQUEST_ID
, PROGRAM_APPLICATION_ID::number(15,0) AS  PROGRAM_APPLICATION_ID
, PROGRAM_ID::number(15,0) AS  PROGRAM_ID
, TO_TIMESTAMP_NTZ(PROGRAM_UPDATE_DATE::string) AS  PROGRAM_UPDATE_DATE
--, TO_TIMESTAMP_NTZ(WH_UPDATE_DATE::string) AS  WH_UPDATE_DATE             -- column entirely NULL
--, ATTRIBUTE_CATEGORY::string AS  ATTRIBUTE_CATEGORY                       -- column entirely NULL
--, ATTRIBUTE1::string AS  ATTRIBUTE1                                       -- column entirely NULL
, ATTRIBUTE2::string AS  ATTRIBUTE2
, ATTRIBUTE3::string AS  ATTRIBUTE3
, UPPER(NULLIF(TRIM(ATTRIBUTE4::string),'')) AS  ATTRIBUTE4
, UPPER(NULLIF(TRIM(ATTRIBUTE5::string),'')) AS  ATTRIBUTE5
, ATTRIBUTE6::string AS  ATTRIBUTE6
, ATTRIBUTE7::string AS  ATTRIBUTE7
, ATTRIBUTE8::string AS  ATTRIBUTE8
, ATTRIBUTE9::string AS  ATTRIBUTE9
--, ATTRIBUTE10::string AS  ATTRIBUTE10             -- column entirely NULL
--, ATTRIBUTE11::string AS  ATTRIBUTE11             -- column entirely NULL
--, ATTRIBUTE12::string AS  ATTRIBUTE12             -- column entirely NULL
--, ATTRIBUTE13::string AS  ATTRIBUTE13             -- column entirely NULL
--, ATTRIBUTE14::string AS  ATTRIBUTE14             -- column entirely NULL
, ATTRIBUTE15::string AS  ATTRIBUTE15
--, ATTRIBUTE16::string AS  ATTRIBUTE16             -- column entirely NULL
--, ATTRIBUTE17::string AS  ATTRIBUTE17             -- column entirely NULL
--, ATTRIBUTE18::string AS  ATTRIBUTE18             -- column entirely NULL
--, ATTRIBUTE19::string AS  ATTRIBUTE19             -- column entirely NULL
--, ATTRIBUTE20::string AS  ATTRIBUTE20             -- column entirely NULL
--, GLOBAL_ATTRIBUTE_CATEGORY::string AS  GLOBAL_ATTRIBUTE_CATEGORY
--, GLOBAL_ATTRIBUTE1::string AS  GLOBAL_ATTRIBUTE1             -- column entirely NULL
--, GLOBAL_ATTRIBUTE2::string AS  GLOBAL_ATTRIBUTE2             -- column entirely NULL
--, GLOBAL_ATTRIBUTE3::string AS  GLOBAL_ATTRIBUTE3             -- column entirely NULL
--, GLOBAL_ATTRIBUTE4::string AS  GLOBAL_ATTRIBUTE4             -- column entirely NULL
--, GLOBAL_ATTRIBUTE5::string AS  GLOBAL_ATTRIBUTE5             -- column entirely NULL
--, GLOBAL_ATTRIBUTE6::string AS  GLOBAL_ATTRIBUTE6             -- column entirely NULL
--, GLOBAL_ATTRIBUTE7::string AS  GLOBAL_ATTRIBUTE7             -- column entirely NULL
--, GLOBAL_ATTRIBUTE8::string AS  GLOBAL_ATTRIBUTE8             -- column entirely NULL
--, GLOBAL_ATTRIBUTE9::string AS  GLOBAL_ATTRIBUTE9             -- column entirely NULL
--, GLOBAL_ATTRIBUTE10::string AS  GLOBAL_ATTRIBUTE10             -- column entirely NULL
--, GLOBAL_ATTRIBUTE11::string AS  GLOBAL_ATTRIBUTE11             -- column entirely NULL
--, GLOBAL_ATTRIBUTE12::string AS  GLOBAL_ATTRIBUTE12             -- column entirely NULL
--, GLOBAL_ATTRIBUTE13::string AS  GLOBAL_ATTRIBUTE13             -- column entirely NULL
--, GLOBAL_ATTRIBUTE14::string AS  GLOBAL_ATTRIBUTE14             -- column entirely NULL
--, GLOBAL_ATTRIBUTE15::string AS  GLOBAL_ATTRIBUTE15             -- column entirely NULL
--, GLOBAL_ATTRIBUTE16::string AS  GLOBAL_ATTRIBUTE16             -- column entirely NULL
--, GLOBAL_ATTRIBUTE17::string AS  GLOBAL_ATTRIBUTE17             -- column entirely NULL
--, GLOBAL_ATTRIBUTE18::string AS  GLOBAL_ATTRIBUTE18             -- column entirely NULL
--, GLOBAL_ATTRIBUTE19::string AS  GLOBAL_ATTRIBUTE19             -- column entirely NULL
--, GLOBAL_ATTRIBUTE20::string AS  GLOBAL_ATTRIBUTE20             -- column entirely NULL
, UPPER(NULLIF(TRIM(ORIG_SYSTEM_REFERENCE::string),'')) AS  ORIG_SYSTEM_REFERENCE
--, TO_TIMESTAMP_NTZ(START_DATE_ACTIVE::string) AS  START_DATE_ACTIVE             -- column entirely NULL
--, TO_TIMESTAMP_NTZ(END_DATE_ACTIVE::string) AS  END_DATE_ACTIVE                 -- column entirely NULL
--, INITCAP(NULLIF(TRIM(REGION::string),'')) AS  REGION                           -- column entirely NULL
, MAILSTOP::string AS  MAILSTOP
--, CUSTOMER_KEY_OSM::string AS  CUSTOMER_KEY_OSM               -- column entirely NULL
--, PHONE_KEY_OSM::string AS  PHONE_KEY_OSM                     -- column entirely NULL
--, CONTACT_KEY_OSM::string AS  CONTACT_KEY_OSM                 -- column entirely NULL
, IDENTIFYING_ADDRESS_FLAG::string AS  IDENTIFYING_ADDRESS_FLAG
, LANGUAGE::string AS  LANGUAGE
, STATUS::string AS  STATUS
--, PARTY_SITE_NAME::string AS  PARTY_SITE_NAME                 -- column entirely NULL
--, ADDRESSEE::string AS  ADDRESSEE                             -- column entirely NULL
, OBJECT_VERSION_NUMBER::number AS  OBJECT_VERSION_NUMBER
, CREATED_BY_MODULE::string AS  CREATED_BY_MODULE
, APPLICATION_ID::number AS  APPLICATION_ID
--, ACTUAL_CONTENT_SOURCE::string AS  ACTUAL_CONTENT_SOURCE               -- All rows contain same value USER_ENTERED  
--, GLOBAL_LOCATION_NUMBER::string AS  GLOBAL_LOCATION_NUMBER             -- column entirely NULL
FROM {{ref('prep_hz_party_sites')}}
QUALIFY ROW_NUMBER() OVER (PARTITION BY PARTY_SITE_ID ORDER BY TO_TIMESTAMP_NTZ(LAST_UPDATE_DATE) DESC) = 1