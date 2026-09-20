{{
  config(
    materialized = "view",
    alias = "task_fail",
    schema='airflow',
    tags=["airflow_task_fail"]
  )
}}

SELECT 
  ID,
  TASK_ID,
  DAG_ID, 
  RUN_ID, 
  MAP_INDEX, 
  START_DATE, 
  END_DATE, 
  DURATION 
FROM
  {{ref('prep_task_fail')}}