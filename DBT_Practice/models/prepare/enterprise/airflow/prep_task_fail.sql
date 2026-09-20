{{
  config(
    materialized = "view",
    alias = "task_fail",
    schema='airflow',
    tags=["airflow_task_fail"]
  )
}}

SELECT 
  DATA:"id"::integer AS ID,
  DATA:"task_id"::string as TASK_ID,
  DATA:"dag_id"::string as DAG_ID, 
  DATA:"run_id"::string as RUN_ID, 
  DATA:"map_index"::integer as MAP_INDEX, 
  TO_TIMESTAMP_TZ(DATA:"start_date"::string) as START_DATE, 
  TO_TIMESTAMP_TZ(DATA:"end_date"::string) as END_DATE, 
  DATA:"duration"::numeric AS DURATION 
FROM {{ source("landing_airflow", "TASK_FAIL") }}
-- to only take the files after the last fullLoad
WHERE 
  split(FILENAME, '_')[array_size(split(FILENAME, '_')) - 2] >=
  (SELECT min_timestamp
  FROM
      (SELECT split(FILENAME, '_')[array_size(split(FILENAME, '_')) - 2] AS min_timestamp, split(FILENAME, '/')[3] AS type_file
      FROM {{ source("landing_airflow", "TASK_FAIL") }}
      WHERE type_file LIKE 'fullload%'
      QUALIFY ROW_NUMBER() OVER (ORDER BY min_timestamp DESC) = 1)
  )