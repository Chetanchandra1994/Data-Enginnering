{{
  config(
    materialized = "view",
    alias = "department",
    schema='spm_gdm',
    meta = {
        'table_key': 'DEPARTMENT_UUID',
        'tests': {
            'null_values':{
                'columns':[
                    'PROJECT_STEP_CODE'
                ]
            }
        }
    }
  )
}}
  SELECT
    D.DEPARTMENT_UUID::string AS DEPARTMENT_UUID
    ,NULLIF(D.DEPARTMENT_NUMBER, '')::INTEGER AS DEPARTMENT_NUMBER
    ,NULLIF(D.DEPARTMENT_NAME_ID, '')::INTEGER AS DEPARTMENT_NAME_ID
    ,R.Standard_Application_Value AS PROJECT_STEP_CODE
    ,TO_BOOLEAN(D.ACTIVE::string) AS ACTIVE
    ,TO_BOOLEAN(D.PERFORMANCE_IND_CALCULATION::string) AS PERFORMANCE_IND_CALCULATION
    ,NULLIF(TRIM(D.PERFORMANCE_IND_MASTER_DEPART_UUID::string), '') AS PERFORMANCE_IND_MASTER_DEPART_UUID
    --,DATA:"last_updated_datetime" AS LAST_UPDATED_DATETIME
    --,ROW_ID::string AS ROW_ID
    --,DATA:"src_system_operation" AS SRC_SYSTEM_OPERATION
    --,IPAAS_UPDATED_DATE::string AS IPAAS_UPDATED_DATE
    ,TO_TIMESTAMP_NTZ(D.CREATED_DATE::string) AS CREATED_DATE
    ,TO_TIMESTAMP_NTZ(D.MODIFIED_DATE::string) AS MODIFIED_DATE
    ,NULLIF(TRIM(D.CREATED_BY::string), '') AS CREATED_BY
    ,NULLIF(TRIM(D.MODIFIED_BY::string), '') AS MODIFIED_BY
from {{ref('prep_department')}} D

LEFT JOIN {{ref('gov_referencedata_rdm')}} R
ON D.DEPARTMENT_NUMBER::INTEGER = R.Business_Application_Value AND 
UPPER(R.Business_Application_Domain_Code) = 'PROJECTSTEP' AND 
UPPER(R.Standard_Domain_Application_Code) = 'PROJECTSTEP' AND
UPPER(R.Business_Application_Code) = 'SPM'
QUALIFY ROW_NUMBER() OVER (PARTITION BY TABLE_SK ORDER BY QUALIFY_TIMESTAMP DESC) = 1 AND UPPER(TRIM(SRC_SYSTEM_OPERATION::STRING)) <> 'DELETE'