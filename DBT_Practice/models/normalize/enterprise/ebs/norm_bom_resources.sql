{{
  config(
    materialized = "view",
    alias = "bom_resources",
    schema='EBS'
  )
}}

SELECT 
--NULLIF(TRIM(ATTRIBUTE9::string), '') AS ATTRIBUTE9 --excluded as always NULL
--,TO_TIMESTAMP_NTZ(PROGRAM_UPDATE_DATE::string) AS PROGRAM_UPDATE_DATE--excluded as always null
--,PROGRAM_ID::number AS PROGRAM_ID
--,PROGRAM_APPLICATION_ID::number AS PROGRAM_APPLICATION_ID
--,REQUEST_ID::number AS REQUEST_ID
--,NULLIF(TRIM(ATTRIBUTE15::string), '') AS ATTRIBUTE15 -- Excluded as always NULL
--,NULLIF(TRIM(ATTRIBUTE14::string), '') AS ATTRIBUTE14 -- Excluded as always NULL
--,NULLIF(TRIM(ATTRIBUTE13::string), '') AS ATTRIBUTE13 -- Excluded as always NULL
--,NULLIF(TRIM(ATTRIBUTE12::string), '') AS ATTRIBUTE12 -- Excluded as always NULL
--,NULLIF(TRIM(ATTRIBUTE11::string), '') AS ATTRIBUTE11 -- Excluded as always NULL
--,NULLIF(TRIM(ATTRIBUTE10::string), '') AS ATTRIBUTE10 -- Excluded as always NULL
--,NULLIF(TRIM(ATTRIBUTE8::string), '') AS ATTRIBUTE8 -- Excluded as always NULL
--,NULLIF(TRIM(ATTRIBUTE7::string), '') AS ATTRIBUTE7 -- Excluded as always NULL
--,NULLIF(TRIM(ATTRIBUTE6::string), '') AS ATTRIBUTE6 -- Excluded as always NULL
--,NULLIF(TRIM(ATTRIBUTE5::string), '') AS ATTRIBUTE5 -- Excluded as always NULL
--,NULLIF(TRIM(ATTRIBUTE4::string), '') AS ATTRIBUTE4 -- Excluded as always NULL
--,NULLIF(TRIM(ATTRIBUTE3::string), '') AS ATTRIBUTE3 -- Excluded as always NULL
--,NULLIF(TRIM(ATTRIBUTE2::string), '') AS ATTRIBUTE2 -- Excluded as always NULL
--,NULLIF(TRIM(ATTRIBUTE1::string), '') AS ATTRIBUTE1 -- Excluded as always NULL
--,NULLIF(TRIM(ATTRIBUTE_CATEGORY::string), '') AS ATTRIBUTE_CATEGORY -- Excluded as always NULL
NULLIF(TRIM(EXPENDITURE_TYPE::string), '') AS EXPENDITURE_TYPE
--,RATE_VARIANCE_ACCOUNT::number AS RATE_VARIANCE_ACCOUNT--excluded as always NULL
,ALLOW_COSTS_FLAG::number AS ALLOW_COSTS_FLAG
,ABSORPTION_ACCOUNT::number AS ABSORPTION_ACCOUNT
--,DEFAULT_BASIS_TYPE::number AS DEFAULT_BASIS_TYPE--excluded as always same value
--,STANDARD_RATE_FLAG::number AS STANDARD_RATE_FLAG--excluded as always same value
,AUTOCHARGE_TYPE::number AS AUTOCHARGE_TYPE
,RESOURCE_TYPE::number AS RESOURCE_TYPE
--,DEFAULT_ACTIVITY_ID::number AS DEFAULT_ACTIVITY_ID--excluded as always NULL
--,NULLIF(TRIM(UNIT_OF_MEASURE::string), '') AS UNIT_OF_MEASURE -- Excluded as always same value--excluded as always same value
--,FUNCTIONAL_CURRENCY_FLAG::number AS FUNCTIONAL_CURRENCY_FLAG--excluded as always same value
--,COST_CODE_TYPE::number AS COST_CODE_TYPE--excluded as always same value
--,PURCHASE_ITEM_ID::number AS PURCHASE_ITEM_ID--excluded as always NULL
--,COST_ELEMENT_ID::number AS COST_ELEMENT_ID--excluded as same value always
,TO_TIMESTAMP_NTZ(DISABLE_DATE::string) AS DISABLE_DATE
,INITCAP(NULLIF(TRIM(DESCRIPTION::string), '')) AS DESCRIPTION
,LAST_UPDATE_LOGIN::number AS LAST_UPDATE_LOGIN
,CREATED_BY::number AS CREATED_BY
,TO_TIMESTAMP_NTZ(CREATION_DATE::string) AS CREATION_DATE
,LAST_UPDATED_BY::number AS LAST_UPDATED_BY
,TO_TIMESTAMP_NTZ(LAST_UPDATE_DATE::string) AS LAST_UPDATE_DATE
,ORGANIZATION_ID::number AS ORGANIZATION_ID
,UPPER(NULLIF(TRIM(RESOURCE_CODE::string), '')) AS RESOURCE_CODE
,RESOURCE_ID::number AS RESOURCE_ID
--,COMPETENCE_ID::number(15,0) AS COMPETENCE_ID--excluded as always NULL
--,NULLIF(TRIM(BATCH_WINDOW_UOM::string), '') AS BATCH_WINDOW_UOM --excluded as always NULL
--,BATCH_WINDOW::number AS BATCH_WINDOW--excluded as always NULL
--,NULLIF(TRIM(BATCH_CAPACITY_UOM::string), '') AS BATCH_CAPACITY_UOM --excluded as always NULL
--,MIN_BATCH_CAPACITY::number AS MIN_BATCH_CAPACITY--excluded as always NULL
--,MAX_BATCH_CAPACITY::number AS MAX_BATCH_CAPACITY--excluded as always NULL
--,BATCHABLE::number AS BATCHABLE--excluded as always same value
--,QUALIFICATION_TYPE_ID::number(9,0) AS QUALIFICATION_TYPE_ID--excluded as always NULL
--,RATING_LEVEL_ID::number(15,0) AS RATING_LEVEL_ID--excluded as always NULL
--,SUPPLY_LOCATOR_ID::number AS SUPPLY_LOCATOR_ID--excluded as always NULL
--,NULLIF(TRIM(SUPPLY_SUBINVENTORY::string), '') AS SUPPLY_SUBINVENTORY --excluded as always NULL
--,BILLABLE_ITEM_ID::number AS BILLABLE_ITEM_ID--excluded as always NULL
FROM {{ref('prep_bom_resources')}}
QUALIFY ROW_NUMBER() OVER (PARTITION BY RESOURCE_ID ORDER BY TO_TIMESTAMP_NTZ(LAST_UPDATE_DATE) DESC) = 1

