{{
  config(
    materialized = "view",
    alias = "dag_run",
    schema='airflow',
    tags=["airflow_dag_run"]
  )
}}

SELECT 
    DATA:"id"::integer AS ID, 
    DATA:"dag_id"::string AS DAG_ID, 
    TO_TIMESTAMP_TZ(DATA:"queued_at"::string) AS QUEUED_AT, 
    TO_TIMESTAMP_TZ(DATA:"execution_date"::string) AS EXECUTION_DATE, 
    TO_TIMESTAMP_TZ(DATA:"start_date"::string) AS START_DATE, 
    TO_TIMESTAMP_TZ(DATA:"end_date"::string) AS END_DATE, 
    DATA:"state"::string AS STATE, 
    DATA:"run_id"::string AS RUN_ID, 
    DATA:"creating_job_id"::integer AS CREATING_JOB_ID, 
    TO_BOOLEAN(DATA:"external_trigger"::string) AS EXTERNAL_TRIGGER, 
    DATA:"run_type"::string AS RUN_TYPE,
    TO_TIMESTAMP_TZ(DATA:"data_interval_start"::string) AS DATA_INTERVAL_START, 
    TO_TIMESTAMP_TZ(DATA:"data_interval_end"::string) AS DATA_INTERVAL_END, 
    TO_TIMESTAMP_TZ(DATA:"last_scheduling_decision"::string) AS LAST_SCHEDULING_DECISION,
    TO_TIMESTAMP_TZ(DATA:"updated_at"::string) AS UPDATED_AT, 
    DATA:"clear_number"::integer AS CLEAR_NUMBER
FROM {{ source("landing_airflow", "DAG_RUN") }}
-- to only take the files after the last fullLoad
WHERE 
  split(FILENAME, '_')[array_size(split(FILENAME, '_')) - 2] >=
  (SELECT min_timestamp
  FROM
      (SELECT split(FILENAME, '_')[array_size(split(FILENAME, '_')) - 2] AS min_timestamp, split(FILENAME, '/')[3] AS type_file
      FROM {{ source("landing_airflow", "DAG_RUN") }}
      WHERE type_file LIKE 'fullload%'
      QUALIFY ROW_NUMBER() OVER (ORDER BY min_timestamp DESC) = 1)
  )