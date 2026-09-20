{{
  config(
    materialized = "view",
    alias = "per_org_structure_elements_v",
    schema='EBS'
  )
}}

SELECT
--PROGRAM_UPDATE_DATE::string AS  PROGRAM_UPDATE_DATE           -- column entirely NULL
--,PROGRAM_ID::string AS  PROGRAM_ID                            -- column entirely NULL
--,PROGRAM_APPLICATION_ID::string AS  PROGRAM_APPLICATION_ID    -- column entirely NULL
--,REQUEST_ID::string AS  REQUEST_ID                            -- column entirely NULL
--,
UPPER(NULLIF(TRIM(D_CHILD_NAME::string), '')) AS  D_CHILD_NAME
,ORGANIZATION_ID_CHILD::number(15,0) AS  ORGANIZATION_ID_CHILD
--,ORG_STRUCTURE_VERSION_ID::number AS  ORG_STRUCTURE_VERSION_ID    --Contains 1 for all records
,UPPER(NULLIF(TRIM(D_PARENT_NAME::string), '')) AS  D_PARENT_NAME
,ORGANIZATION_ID_PARENT::number(15,0) AS  ORGANIZATION_ID_PARENT
--,BUSINESS_GROUP_ID::number(15,0) AS  BUSINESS_GROUP_ID            --Contains 0 for all records
,ORG_STRUCTURE_ELEMENT_ID::number(15,0) AS  ORG_STRUCTURE_ELEMENT_ID
--,ROW_ID::string AS  ROW_ID                                        -- we shouldn't use it except for debug
,UPPER(NULLIF(TRIM(POSITION_CONTROL_ENABLED_FLAG::string), '')) AS  POSITION_CONTROL_ENABLED_FLAG
,TO_TIMESTAMP_NTZ(CREATION_DATE::string) AS  CREATION_DATE
,CREATED_BY::number(15,0) AS  CREATED_BY
,TO_TIMESTAMP_NTZ(LAST_UPDATE_DATE::string) AS  LAST_UPDATE_DATE
,LAST_UPDATE_LOGIN::number(15,0) AS  LAST_UPDATE_LOGIN
,LAST_UPDATED_BY::number(15,0) AS  LAST_UPDATED_BY
--, NULLIF(TRIM(SRC_SYSTEM_OPERATION),'')::string AS  SRC_SYSTEM_OPERATION
FROM {{ref('prep_per_org_structure_elements_v')}}
QUALIFY ROW_NUMBER() OVER (PARTITION BY ORG_STRUCTURE_ELEMENT_ID ORDER BY TO_TIMESTAMP_NTZ(LAST_UPDATE_DATE) DESC) = 1