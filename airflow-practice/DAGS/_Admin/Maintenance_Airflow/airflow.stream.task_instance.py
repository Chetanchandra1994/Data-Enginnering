from airflow import DAG
from connectors.psycopg2.source.postgres_source_connector import PostgresSourceConnector
from operators.extraction import ExtractionOperator
from connectors.cloud.target.gcs_target_connector import GCSTargetConnector
from datetime import datetime

with DAG(
    "airflow.stream.task_instance",
    start_date=datetime(2025, 1, 1),
    schedule_interval='@daily',
    catchup=False,
    tags=["stream", "airflow", "gcs"]
) as dag:
    
    pg_source = PostgresSourceConnector(
    conn_id="airflow-db",
    sql="SELECT * FROM task_instance",
    query_mode="delta",
    delta_column="updated_at",
    xcom_key="last_updated_at_checkpoint"
    )

    # 2. Define the Targets
    gcs_target = GCSTargetConnector(
        conn_id='gcs-bucket-project',
        table_name='task_instance',
        gcs_path='raw/airflow'
    )

    # 3. Use the Operator to run the task
    extract_data = ExtractionOperator(
        task_id=f'extract_task_instance',
        source=pg_source,
        targets=[gcs_target]
    )