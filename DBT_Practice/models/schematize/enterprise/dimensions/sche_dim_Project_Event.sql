{{
  config(
    full_refresh = true,
    materialized="dynamic_table",
    target_lag="downstream",
    snowflake_warehouse= var('task_warehouse'),
    alias = "dim_Project_Event",
    schema= "dimensions",
    post_hook = "ALTER DYNAMIC TABLE {{ this }} SET LOG_LEVEL = ERROR",
    meta = {
      'table_key': 'PROJECT_EVENT_SK',
      'tests': {
        'unique_sk':{},
        'null_values':{
          'columns':[
              'TRANSACTION_TRANSFER_DATE_KEY'
          ]
        }  
      }
    }
  )
}}


SELECT
    {{ dbt_utils.generate_surrogate_key(['pe.NO_PROJET', 'pe.SEQUENCE']) }} as PROJECT_EVENT_SK
    ,pe.NO_PROJET as PROJECT_CODE
    ,pe.SEQUENCE as PROJECT_EVENT_CODE
    ,pe.TRANSACTION_TRANSFER_STATUS_CODE as TRANSACTION_TRANSFER_STATUS_CODE
    ,{{ target.name }}_ENTERPRISE_SCHEMATIZE.PUBLIC.format_date_key(pe.CREDIT_PAYMENT_TRANSFER_DATETIME, 'YYYY-MM-DD HH24:MI:SS.FF') as TRANSACTION_TRANSFER_DATE_KEY
    ,pe.CREDIT_PAYMENT_TRANSFER_DATETIME as TRANSACTION_TRANSFER_DATETIME 
    ,tt.TRANSACTION_TYPE_CODE as TRANSACTION_TYPE_CODE
    ,pe.PROVISION_TRANSFER_STATUS_CODE as PROVISION_TRANSFER_STATUS_CODE
    ,{{ target.name }}_ENTERPRISE_SCHEMATIZE.PUBLIC.format_date_key(pe.PROVISION_TRANSFER_DATETIME, 'YYYY-MM-DD HH24:MI:SS.FF')  as PROVISION_TRANSFER_DATE_KEY
    ,pe.PROVISION_TRANSFER_DATETIME as PROVISION_TRANSFER_DATETIME 
    ,{{ target.name }}_ENTERPRISE_SCHEMATIZE.PUBLIC.format_date_key(pe.CREATION_DATETIME, 'YYYY-MM-DD HH24:MI:SS.FF')   as PROJECT_EVENT_CREATION_DATE_KEY
    ,pe.CREATION_DATETIME as PROJECT_EVENT_CREATION_DATETIME 

	,DECODE(UPPER(pe.CREDIT_PAYMENT_INCLUDES_TAXES),
            'NOT_INCLUDED', false,
            'INCLUDED', true,
            NULL) as INCLUDES_TAXES

	,NULLIF(pe.NO_POIDS, 0) as REQUISITION_NUMBER
	,NULLIF(pe.NO_MEMO, 0) as BOL_NUMBER
    ,ps.SEQ_DIV as DIVISION_NAME 
	,pe.DESCRIPTION

FROM {{ref('norm_project_event')}} pe

LEFT JOIN {{ref('norm_proj_seq')}} ps
ON pe.NO_PROJET = ps.NO_PROJET AND pe.SEQ_NO = ps.SEQ_NO

LEFT JOIN {{ref('norm_project_event_trans_type')}} tt
ON pe.PROJECT_EVENT_TRANS_TYPE_UUID = tt.PROJECT_EVENT_TRANS_TYPE_UUID