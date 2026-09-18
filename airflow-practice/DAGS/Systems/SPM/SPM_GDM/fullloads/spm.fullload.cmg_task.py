from airflow import DAG
from datetime import datetime
from operators.extraction import ExtractionOperator
from connectors.jdbc.source.progress_source_connector import ProgressSourceConnector
from connectors.cloud.target.gcs_target_connector import GCSTargetConnector
import pendulum

local_tz = pendulum.timezone("America/Toronto")

with DAG(
    dag_id='spm.fullload.cmg_task',
    start_date=datetime(2026, 3, 12, tzinfo=local_tz), 
    schedule='0 5 * * *',
    catchup=False,
    tags=["jdbc", "spm", "progress", "gcs", "fullload"],
    max_active_runs=1
) as dag:

    # 1. Define the Source (Progress DB)
    progress_source = ProgressSourceConnector(
        conn_id='gdm',
        database='gdm',
        sql='SELECT ROWID AS "_rowid","task_name"[2] AS "task_name_2", "task_name"[1] AS "task_name_1", "task_number" AS "task_number", "active" AS "active", "task_family"[1] AS "task_family_1", "task_family"[2] AS "task_family_2", "sales_group_code" AS "sales_group_code" FROM PUB."cmg_task"',
        query_mode='default'
    )

    # 2. Define the Target (GCS)
    gcs_target = GCSTargetConnector(
        conn_id='gcs-bucket-project',
        table_name='cmg_task',
        gcs_path='raw/SPM_GDM'
    )

    # 3. Use the Operator to run the task
    extract_data = ExtractionOperator(
        task_id='extract_cmg_task',
        source=progress_source,
        targets=[gcs_target]
    )