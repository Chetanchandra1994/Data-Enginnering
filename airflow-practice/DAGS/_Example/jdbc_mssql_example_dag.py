from airflow import DAG
from datetime import datetime

from operators.extraction import ExtractionOperator
from connectors.jdbc.source.mssql_source_connector import MssqlSourceConnector
from connectors.cloud.target.gcs_target_connector import GCSTargetConnector

with DAG(
    dag_id='jdbc_mssql_example_dag',
    start_date=datetime(2023, 1, 1),
    schedule_interval=None,
    catchup=False,
    tags=['jdbc', 'mssql']
) as dag:

    # 1. Define the Source (MSSQL)
    # This encapsulates JDBC connection and Delta/XCom logic
    mssql_source = MssqlSourceConnector(
        conn_id='ssis-db',
        database='CanamTaskManagementTest',
        sql="SELECT @@VERSION", # Updated to a standard SELECT for extraction
        query_mode='delta',
        delta_column='StatusUpdateDateTime',
        xcom_key='mssql_ctm_projects_delta' # Explicit key for tracking
    )

    # 2. Define the Target (GCS)
    # This handles project resolution and URI generation
    gcs_target = GCSTargetConnector(
        conn_id='gcs-bucket-project',
        table_name='CTMProjects',
        gcs_path='raw/local_test'
    )

    # 3. Orchestrate with ExtractionOperator
    # Note: targets must be a list to support multi-target pipelines (Option C2)
    get_version_task = ExtractionOperator(
        task_id='select_version',
        source=mssql_source,
        targets=[gcs_target]
    )