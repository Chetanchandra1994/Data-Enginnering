{{
  config(
    materialized = "view",
    alias = "task_instance",
    schema='airflow',
    tags=["airflow_task_instance"]
  )
}}

SELECT 
  DATA:"task_id"::string as TASK_ID,
  DATA:"dag_id"::string as DAG_ID, 
  DATA:"run_id"::string as RUN_ID, 
  DATA:"map_index"::integer as MAP_INDEX, 
  TO_TIMESTAMP_TZ(DATA:"start_date"::string) as START_DATE, 
  TO_TIMESTAMP_TZ(DATA:"end_date"::string) as END_DATE, 
  DATA:"duration"::numeric AS DURATION, 
  DATA:"state"::string as STATE, 
  DATA:"try_number"::integer AS TRY_NUMBER, 
  DATA:"max_tries"::integer as MAX_TRIES, 
  DATA:"hostname"::string as HOSTNAME, 
  DATA:"unixname"::string as UNIXNAME, 
  DATA:"job_id"::integer as JOB_ID, 
  DATA:"pool"::string as POOL, 
  DATA:"pool_slots"::integer as POOL_SLOTS, 
  DATA:"queue"::string AS QUEUE, 
  DATA:"priority_weight"::integer AS PRIORITY_WEIGHT, 
  DATA:"operator"::string as OPERATOR, 
  DATA:"custom_operator_name"::string as CUSTOM_OPERATOR_NAME, 
  TO_TIMESTAMP_TZ(DATA:"queued_dttm"::string) as QUEUED_DTTM, 
  DATA:"queued_by_job_id"::string as QUEUED_BY_JOB_ID, 
  DATA:"pid"::string as PID, 
  DATA:"executor"::string AS EXECUTOR,
  TO_TIMESTAMP_TZ(DATA:"updated_at"::string) AS UPDATED_AT, 
  DATA:"rendered_map_index"::string AS RENDERED_MAP_INDEX, 
  DATA:"external_executor_id"::string AS EXTERNAL_EXECUTOR_ID, 
  DATA:"trigger_id"::string AS TRIGGER_ID, 
  DATA:"trigger_timeout"::string AS TRIGGER_TIMEOUT, 
  DATA:"next_method"::string AS NEXT_METHOD, 
  DATA:"next_kwargs"::string AS NEXT_KWARGS, 
  DATA:"task_display_name"::string AS TASK_DISPLAY_NAME
FROM {{ source("landing_airflow", "TASK_INSTANCE") }}
-- to only take the files after the last fullLoad
WHERE 
  split(FILENAME, '_')[array_size(split(FILENAME, '_')) - 2] >=
  (SELECT min_timestamp
  FROM
      (SELECT split(FILENAME, '_')[array_size(split(FILENAME, '_')) - 2] AS min_timestamp, split(FILENAME, '/')[3] AS type_file
      FROM {{ source("landing_airflow", "TASK_INSTANCE") }}
      WHERE type_file LIKE 'fullload%'
      QUALIFY ROW_NUMBER() OVER (ORDER BY min_timestamp DESC) = 1)
  )