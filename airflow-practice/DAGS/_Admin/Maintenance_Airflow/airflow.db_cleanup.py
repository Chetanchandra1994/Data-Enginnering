from airflow import DAG
from airflow.operators.bash import BashOperator
from datetime import datetime

# Define the retention period in days
LOG_MAX_RETENTION_DAYS = 30

with DAG(
    "airflow.db_cleanup",
    start_date=datetime(2025, 1, 1),
    schedule_interval='@daily',
    catchup=False,
    tags=["airflow"],
    doc_md="""
    ### Airflow DB Cleanup DAG
    Runs `airflow db clean` to prune old metadata.
    """
) as dag:
    
    TABLES_TO_CLEAN = (
        "task_instance,task_instance_history,task_reschedule,task_fail,"
        "dag_run,dataset_event,sla_miss,import_error,log,job,session,"
        "trigger,callback_request,dag,celery_taskmeta,celery_tasksetmeta"
    )

    CLEAN_COMMAND = f"""
            echo "Cleaning DB data older than {LOG_MAX_RETENTION_DAYS} days (Excluding XCom)."
            
            CLEAN_DATE="{{{{ macros.ds_add(ds, -{LOG_MAX_RETENTION_DAYS}) }}}} 00:00:00"
            
            airflow db clean \
                --clean-before-timestamp "$CLEAN_DATE" \
                --tables "{TABLES_TO_CLEAN}" \
                --skip-archive \
                --yes
    """

    clean_db_task = BashOperator(
        task_id="clean_airflow_database",
        bash_command=CLEAN_COMMAND,
    )