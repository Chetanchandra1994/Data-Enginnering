{{
  config(
    full_refresh = true,
    materialized="dynamic_table",
    target_lag="6 hour",
    snowflake_warehouse= var('task_warehouse'),
    alias = "AIRFLOW_TASK_EXECUTION",
    schema= "DATAPRODUCTS_BRONZE",
    post_hook = "ALTER DYNAMIC TABLE {{ this }} SET LOG_LEVEL = ERROR",
    tags=["airflow_task_execution"]
  )
}}

SELECT
    -- 1. IDENTIFIERS
    ti.DAG_ID,
    ti.TASK_ID,
    ti.RUN_ID,
    ti.MAP_INDEX,
    ti.TRY_NUMBER,
    ti.HOSTNAME,
    ti.OPERATOR,
    ti.POOL,
    ti.POOL_SLOTS,
    -- 2. TIMESTAMPS
    dr.DATA_INTERVAL_END AS LOGICAL_DATE,
    dr.QUEUED_AT AS DAG_QUEUED_AT,
    ti.QUEUED_DTTM AS TASK_QUEUED_AT,
    ti.START_DATE AS EXECUTION_START,
    ti.END_DATE AS EXECUTION_END,
    -- 3. LATENCY METRICS
    -- Scheduler Lag: Time from data interval to DAG queuing
    DATEDIFF('ms', dr.DATA_INTERVAL_END, dr.QUEUED_AT)/1000 AS SCHEDULER_OVERHEAD_SEC,    
    -- Worker Pickup Delay: Time spent in RabbitMQ/Queue
    DATEDIFF('ms', ti.QUEUED_DTTM, ti.START_DATE)/1000 AS QUEUE_WAIT_SEC,    
    -- Task Duration: Pure execution time
    ti.DURATION AS EXECUTION_DURATION_SEC,    
    -- Total Business Latency
    DATEDIFF('ms', dr.DATA_INTERVAL_END, ti.END_DATE)/1000 AS TOTAL_TURNAROUND_SEC,
    -- 4. CONTEXT & STATE
    ti.STATE AS TASK_STATE,
    dr.STATE AS DAG_STATE,
    dr.RUN_TYPE,
    ti.PRIORITY_WEIGHT,
    ti.EXTERNAL_EXECUTOR_ID AS K8S_POD_NAME,    
    -- 5. FAILURE METADATA
    CASE WHEN tf.TASK_ID IS NOT NULL THEN TRUE ELSE FALSE END AS HAD_FAILURE,
    tf.DURATION AS FAILURE_DURATION_SEC,
    -- 6. WORKER HEALTH
    j.LATEST_HEARTBEAT AS WORKER_LAST_HEARTBEAT,
    DATEDIFF('ms', j.START_DATE, j.END_DATE)/1000 AS WORKER_UPTIME_SEC

FROM 
    {{ ref('norm_task_instance') }} ti
LEFT JOIN 
    {{ ref('norm_dag_run') }} dr 
ON 
    ti.RUN_ID = dr.RUN_ID AND 
    ti.DAG_ID = dr.DAG_ID
LEFT JOIN 
    {{ ref('norm_task_fail') }} tf 
ON 
    ti.TASK_ID = tf.TASK_ID AND 
    ti.RUN_ID = tf.RUN_ID AND 
    ti.MAP_INDEX = tf.MAP_INDEX
LEFT JOIN 
    {{ ref('norm_job') }} j 
ON 
    ti.JOB_ID = j.ID