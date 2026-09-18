from airflow import DAG
from datetime import datetime
from operators.extraction import ExtractionOperator
from connectors.jdbc.source.progress_source_connector import ProgressSourceConnector
from connectors.cloud.target.gcs_target_connector import GCSTargetConnector
from connectors.cloud.target.bigquery_target_connector import BigQueryTargetConnector
import pendulum

local_tz = pendulum.timezone("America/Toronto")

with DAG(
    dag_id='spm.stream.data_events',
    start_date=datetime(2026, 3, 12, tzinfo=local_tz), 
    schedule='*/5 * * * *',
    catchup=False,
    tags=["jdbc", "spm", "progress", "gcs", "stream", "bigquery"],
    max_active_runs=1,
    default_args={"executor": "CeleryExecutor"}
) as dag:

    # 1. Define the Source (Progress DB)
    progress_source = ProgressSourceConnector(
        conn_id='gdm',
        database='gdm',
        sql="SELECT IndexedDataEventsUUID as \"DataEventsUUID\", TableName, \"Action\", RecordRowID, SUBSTRING(REPLACE(RTRIM(CAST(\"CreatedDate\" AS CHARACTER(26))), ' ', 'T'), 1, 19) + '.' + SUBSTRING(REPLACE(RTRIM(CAST(\"CreatedDate\" AS CHARACTER(26))), ' ', 'T'), 21, 6) + '000' as \"CreatedDate\", CreatedDate as \"DeltaCreatedDate\", Body FROM PUB.IndexedDataEvents",
        delta_column='DeltaCreatedDate',
        query_mode='delta',
        xcom_key='data_events_delta'
    )

    # 2. Define the Target (GCS)
    gcs_target = GCSTargetConnector(
        conn_id='gcs-bucket-project',
        table_name='DataEvents',
        gcs_path='raw/SPM_GDM'
    )

    # 3. Define the Target (BQ)
    bq_target = BigQueryTargetConnector(
        conn_id='bigquery-edl-landing',
        bq_landing_table='SPM_GDM.dataEvents',
        bq_merge_procedure='SPM_GDM.sp_Merge_dataEvents'
    )

    # 4. Use the Operator to run the task
    extract_data = ExtractionOperator(
        task_id='item_data_events',
        source=progress_source,
        targets=[gcs_target, bq_target]
    )