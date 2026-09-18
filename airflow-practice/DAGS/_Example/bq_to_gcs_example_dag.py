from airflow import DAG
from datetime import datetime

from operators.extraction import ExtractionOperator
from connectors.cloud.source.bigquery_source_connector import BigquerySourceConnector
from connectors.cloud.target.gcs_target_connector import GCSTargetConnector

with DAG(
    dag_id='bq_to_gcs_example_dag',
    start_date=datetime(2023, 1, 1),
    schedule_interval=None,
    catchup=False,
    tags=['bq', 'gcs']
) as dag:

    # 1. Define the Source (BQ)
    # This encapsulates BQ connection and Delta/XCom logic
    bigquery_source = BigquerySourceConnector(
        conn_id='bigquery-edl-landing',
        query="SELECT * FROM `bigquery-255612.SPM_CA.projet_g`",
        query_mode='delta',
        delta_column='ipaas_updated_date',
        xcom_key='bq_to_gcs_example_dag_ipaas_updated_date'
    )

    # 2. Define the Target (GCS)
    # This handles project resolution and URI generation
    gcs_target = GCSTargetConnector(
        conn_id='gcs-bucket-project',
        table_name='projet_g',
        gcs_path='raw/local_test'
    )

    # 3. Orchestrate with ExtractionOperator
    # Note: targets must be a list to support multi-target pipelines (Option C2)
    get_version_task = ExtractionOperator(
        task_id='select_projet_g',
        source=bigquery_source,
        targets=[gcs_target]
    )