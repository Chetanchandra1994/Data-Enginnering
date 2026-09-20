{{
  config(
    materialized = "view",
    alias = "event",
    schema='spm_gdm',
    meta = {
        'table_key': 'EVENT_UUID',
        'tests': {
            'null_values':{
                'columns':[
                    'EVENT_NAME_CODE'
                ]
            }
        }
    }
  )
}}

WITH event_name AS (
    SELECT
        R.Business_Application_Domain_Code,
        unnested_value.VALUE AS Business_Application_Value,
        R.Business_Application_Code,
        R.Standard_Domain_Application_Code,
        R.Standard_Application_Value    
    FROM
        {{ref('gov_referencedata_rdm')}} AS R
    LEFT JOIN LATERAL
        SPLIT_TO_TABLE(CAST(R.Business_Application_Value AS STRING), '|') AS unnested_value
    WHERE
        UPPER(R.Business_Application_Domain_Code) = 'EVENTNAME'
        AND UPPER(R.Standard_Domain_Application_Code) = 'EVENTNAME'
        AND UPPER(R.Business_Application_Code) = 'SPM'
),
project_step as (
SELECT 
    * 
FROM 
    {{ref('gov_referencedata_rdm')}}
WHERE
    UPPER(Business_Application_Domain_Code) = 'PROJECTSTEP' AND
    UPPER(Standard_Domain_Application_Code) = 'EVENTNAME' AND
    UPPER(Business_Application_Code) = 'SPM'
)
,
latest_records as (
SELECT
     E.EVENT_UUID::string AS EVENT_UUID
    ,E.DEPARTMENT_UUID::string AS DEPARTMENT_UUID
    ,NULLIF(E.EVENT_NUMBER, '')::INTEGER AS EVENT_NUMBER
    ,NULLIF(E.EVENT_NAME_ID, '')::INTEGER AS EVENT_NAME_ID
    ,TO_BOOLEAN(NULLIF(E.ACTIVE, '')::string) AS ACTIVE
    ,TO_BOOLEAN(NULLIF(E.enterprise_ERROR, '')::string) AS enterprise_ERROR
    --100% FALSE
    --,TO_BOOLEAN(NULLIF(KPI_FIRST_PASS_YIELD_EXPORT_ENABLED, '')::string) AS KPI_FIRST_PASS_YIELD_EXPORT_ENABLED
    --,ROW_ID::string AS ROW_ID
    --,IPAAS_UPDATED_DATE::string AS IPAAS_UPDATED_DATE
    ,TO_TIMESTAMP_NTZ(E.CREATED_DATE::string) AS CREATED_DATE
    ,TO_TIMESTAMP_NTZ(E.MODIFIED_DATE::string) AS MODIFIED_DATE
    ,NULLIF(TRIM(E.CREATED_BY::string), '') AS CREATED_BY
    ,NULLIF(TRIM(E.MODIFIED_BY::string), '') AS MODIFIED_BY
FROM 
    {{ref('prep_event')}} E
QUALIFY ROW_NUMBER() OVER (PARTITION BY TABLE_SK ORDER BY QUALIFY_TIMESTAMP DESC) = 1 AND UPPER(TRIM(SRC_SYSTEM_OPERATION::STRING)) <> 'DELETE')
SELECT
    E.*,
    EN.Standard_Application_Value as EVENT_NAME_CODE
FROM
    latest_records E
LEFT JOIN 
    {{ref('norm_department')}} D
    ON E.DEPARTMENT_UUID = D.DEPARTMENT_UUID
LEFT JOIN
    project_step PS
    ON D.DEPARTMENT_NUMBER = PS.Business_Application_Value
INNER JOIN
    event_name AS EN
    ON E.EVENT_NUMBER = EN.Business_Application_Value
    AND EN.Standard_Application_Value = PS.Standard_Application_Value

