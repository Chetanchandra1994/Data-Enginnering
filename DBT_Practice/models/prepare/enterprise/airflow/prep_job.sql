{{
  config(
    materialized = "view",
    alias = "job",
    schema='airflow',
    tags=["airflow_job"]
  )
}}

SELECT 
  DATA:"id"::integer AS ID,
  DATA:"dag_id"::string as DAG_ID, 
  DATA:"state"::string as STATE, 
  DATA:"job_type"::string as JOB_TYPE, 
  TO_TIMESTAMP_TZ(DATA:"start_date"::string) as START_DATE, 
  TO_TIMESTAMP_TZ(DATA:"end_date"::string) as END_DATE, 
  TO_TIMESTAMP_TZ(DATA:"latest_heartbeat"::string) as LATEST_HEARTBEAT, 
  DATA:"executor_class"::string as EXECUTOR_CLASS, 
  DATA:"hostname"::string as HOSTNAME, 
  DATA:"unixname"::string as UNIXNAME 
FROM {{ source("landing_airflow", "JOB") }}
-- to only take the files after the last fullLoad
WHERE 
  split(FILENAME, '_')[array_size(split(FILENAME, '_')) - 2] >=
  (SELECT min_timestamp
  FROM
      (SELECT split(FILENAME, '_')[array_size(split(FILENAME, '_')) - 2] AS min_timestamp, split(FILENAME, '/')[3] AS type_file
      FROM {{ source("landing_airflow", "JOB") }}
      WHERE type_file LIKE 'fullload%'
      QUALIFY ROW_NUMBER() OVER (ORDER BY min_timestamp DESC) = 1)
  )