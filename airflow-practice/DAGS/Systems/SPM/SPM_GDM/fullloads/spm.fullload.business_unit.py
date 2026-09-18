from airflow import DAG
from datetime import datetime
from operators.extraction import ExtractionOperator
from connectors.jdbc.source.progress_source_connector import ProgressSourceConnector
from connectors.cloud.target.gcs_target_connector import GCSTargetConnector
import pendulum

local_tz = pendulum.timezone("America/Toronto")

with DAG(
    dag_id='spm.fullload.business_unit',
    start_date=datetime(2026, 3, 12, tzinfo=local_tz),
    schedule='0 6 * * *',
    catchup=False,
    tags=["jdbc", "spm", "progress", "gcs", "fullload"],
    max_active_runs=1,
    default_args={"executor": "CeleryExecutor"}
) as dag:

    # 1. Define the Source (Progress DB)
    progress_source = ProgressSourceConnector(
        conn_id='gdm',
        database='gdm',
        sql='SELECT * FROM PUB."business_unit"',
        query_mode='default'
    )

    # 2. Define the Target (GCS)
    gcs_target = GCSTargetConnector(
        conn_id='gcs-bucket-project',
        table_name='business_unit',
        gcs_path='raw/SPM_GDM'
    )

    # 3. Use the Operator to run the task
    extract_data = ExtractionOperator(
        task_id='extract_business_unit',
        source=progress_source,
        targets=[gcs_target]
    )