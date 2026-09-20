{{
  config(
    materialized = "view",
    alias = "dag_run",
    schema='airflow',
    tags=["airflow_dag_run"]
  )
}}

SELECT 
    ID, 
    DAG_ID, 
    QUEUED_AT, 
    EXECUTION_DATE, 
    START_DATE, 
    END_DATE, 
    STATE, 
    RUN_ID, 
    CREATING_JOB_ID, 
    EXTERNAL_TRIGGER, 
    RUN_TYPE,
    DATA_INTERVAL_START, 
    DATA_INTERVAL_END, 
    LAST_SCHEDULING_DECISION,
    UPDATED_AT, 
    CLEAR_NUMBER
FROM 
  {{ref('prep_dag_run')}}