from airflow import DAG
from datetime import datetime
from operators.extraction import ExtractionOperator
from connectors.jdbc.source.progress_source_connector import ProgressSourceConnector
from connectors.cloud.target.gcs_target_connector import GCSTargetConnector

with DAG(
    dag_id='jdbc_progress_example_dag',
    start_date=datetime(2023, 1, 1),
    schedule_interval=None,
    catchup=False,
    tags=['jdbc', 'migration'],
) as dag:

    # 1. Define the Source (Progress DB)
    progress_source = ProgressSourceConnector(
        conn_id='acct',
        database='acct',
        sql='SELECT * FROM PUB."working_shift_detail"',
        query_mode='default'
    )

    # 2. Define the Target (GCS)
    gcs_target = GCSTargetConnector(
        conn_id='gcs-bucket-project',
        table_name='produit_s',
        gcs_path='raw/local_test'
    )

    # 3. Use the Orchestrator to run the task
    get_version_task = ExtractionOperator(
        task_id='select_produit_s',
        source=progress_source,
        targets=[gcs_target]
    )