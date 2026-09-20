{{
  config(
    materialized = "view",
    alias = "job",
    schema='airflow',
    tags=["airflow_job"]
  )
}}

SELECT 
  ID,
  DAG_ID, 
  STATE, 
  JOB_TYPE, 
  START_DATE, 
  END_DATE, 
  LATEST_HEARTBEAT, 
  EXECUTOR_CLASS, 
  HOSTNAME, 
  UNIXNAME 
FROM
  {{ref('prep_job')}}