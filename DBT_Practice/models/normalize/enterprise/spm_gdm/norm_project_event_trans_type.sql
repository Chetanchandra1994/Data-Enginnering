{{
  config(
    materialized = "view",
    alias = "project_event_trans_type",
    schema='spm_gdm',
    meta = {
        'table_key': 'PROJECT_EVENT_TRANS_TYPE_UUID',
        'tests': {
            'null_values':{
                'columns':[
                    'TRANSACTION_TYPE_CODE'
                ]
            }
        }
    }
  )
}}
  SELECT
    PROJECT_EVENT_TRANS_TYPE_UUID::string AS PROJECT_EVENT_TRANS_TYPE_UUID
    ,PROJECT_EVENT_TRANS_TYPE_CODE::string AS PROJECT_EVENT_TRANS_TYPE_CODE
    --RDM TRANSACTIONTYPE CODE
    ,R1.Standard_Application_Value AS TRANSACTION_TYPE_CODE
    ,NULLIF(PROJECT_EVENT_TRANS_TYPE_NAME_ID, '')::INTEGER AS PROJECT_EVENT_TRANS_TYPE_NAME_ID
    --100% True
    --,TO_BOOLEAN(NULLIF(ACTIVE, '')::string) AS ACTIVE
    --,ROW_ID::string AS ROW_ID
    --,IPAAS_UPDATED_DATE::string AS IPAAS_UPDATED_DATE
    ,TO_TIMESTAMP_NTZ(CREATED_DATE::string) AS CREATED_DATE
    ,TO_TIMESTAMP_NTZ(MODIFIED_DATE::string) AS MODIFIED_DATE
    ,NULLIF(TRIM(CREATED_BY::string), '') AS CREATED_BY
    ,NULLIF(TRIM(MODIFIED_BY::string), '') AS MODIFIED_BY
from {{ref('prep_project_event_trans_type')}}
LEFT JOIN {{ref('gov_referencedata_rdm')}} R1
ON UPPER(PROJECT_EVENT_TRANS_TYPE_NAME_ID) = UPPER(R1.Business_Application_Value) AND 
UPPER(R1.Business_Application_Domain_Code) = 'TRANSACTIONTYPE' AND 
UPPER(R1.Business_Application_Code) = 'SPM'
QUALIFY ROW_NUMBER() OVER (PARTITION BY TABLE_SK ORDER BY QUALIFY_TIMESTAMP DESC) = 1 AND UPPER(TRIM(SRC_SYSTEM_OPERATION::STRING)) <> 'DELETE'