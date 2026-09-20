{{
  config(
    full_refresh = true,
    materialized="dynamic_table",
    target_lag="downstream",
    snowflake_warehouse= var('task_warehouse'),
    alias = "dim_Event_Type",
    schema= "dimensions",
    post_hook = "ALTER DYNAMIC TABLE {{ this }} SET LOG_LEVEL = ERROR",
    meta = {
    'table_key': 'EVENT_TYPE_SK',
    'tests': {
      'unique_sk':{}    
    }
  }
  )
}}


SELECT 
    {{ dbt_utils.generate_surrogate_key(["d.PROJECT_STEP_CODE","e.EVENT_NAME_CODE"]) }} as EVENT_TYPE_SK 
    ,d.PROJECT_STEP_CODE as PROJECT_STEP_CODE
    ,e.EVENT_NAME_CODE as EVENT_NAME_CODE
    ,'spm' as ORIGIN_APPLICATION_CODE -- to do RDM

FROM {{ref('norm_event')}} e 
LEFT JOIN {{ref('norm_department')}} d
ON d.DEPARTMENT_UUID = e.DEPARTMENT_UUID 
