from airflow import DAG
from datetime import datetime

from operators.extraction import ExtractionOperator
from connectors.jdbc.source.oracle_source_connector import OracleSourceConnector
from connectors.cloud.target.gcs_target_connector import GCSTargetConnector

with DAG(
    dag_id='jdbc_oracle_example_dag',
    start_date=datetime(2023, 1, 1),
    schedule_interval=None,
    catchup=False,
    tags=['jdbc', 'oracle'],
) as dag:

    # 1. Define the Source (Oracle)
    oracle_source = OracleSourceConnector(
        conn_id='oracleebs',
        sql="SELECT DISTINCT TZNAME FROM V$TIMEZONE_NAMES ORDER BY TZNAME",
        query_mode='default'
    )

    # 2. Define the Target (GCS)
    gcs_target = GCSTargetConnector(
        conn_id='gcs-bucket-project',
        table_name='TIMEZONE_NAMES',
        gcs_path='raw/OracleEBS'
    )

    # 3. Orchestrate with ExtractionOperator
    get_version_task = ExtractionOperator(
        task_id='select_timezone_names',
        source=oracle_source,
        targets=[gcs_target]
    )