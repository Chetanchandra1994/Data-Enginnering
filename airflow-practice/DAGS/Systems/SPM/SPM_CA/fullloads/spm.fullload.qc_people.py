from airflow import DAG
from datetime import datetime
from operators.extraction import ExtractionOperator
from connectors.jdbc.source.progress_source_connector import ProgressSourceConnector
from connectors.cloud.target.gcs_target_connector import GCSTargetConnector
from connectors.cloud.target.bigquery_target_connector import BigQueryTargetConnector
import pendulum

local_tz = pendulum.timezone("America/Toronto")

with DAG(
    dag_id='spm.fullload.qc_people',
    start_date=datetime(2026, 3, 12, tzinfo=local_tz), 
    schedule=None,
    catchup=False,
    tags=["jdbc", "spm", "progress", "gcs", "fullload", "bigquery"],
    max_active_runs=1
) as dag:

    # 1. Define the Source (Progress DB)
    progress_source = ProgressSourceConnector(
        conn_id='acct',
        database='acct',
        sql='SELECT ROWID AS "_rowid", "dsg_entity_code", "init_code", "salesm", "estimt", "user_code", "spm_salesm_code", "dummy", "active", "prospector", "office_code", "CreatedDate", "ModifiedDate", "CreatedBy", "ModifiedBy" FROM PUB."qc_people"',
        query_mode='default'
    )

    # 2. Define the Target (GCS)
    gcs_target = GCSTargetConnector(
        conn_id='gcs-bucket-project',
        table_name='qc_people',
        gcs_path='raw/SPM_CA'
    )

    bq_target = BigQueryTargetConnector(
        conn_id='bigquery-edl-landing',
        bq_landing_table='SPM_CA.qc_people',
        bq_merge_procedure='SPM_CA.sp_Merge_qc_people'
    )

    # 3. Use the Operator to run the task
    extract_data = ExtractionOperator(
        task_id='extract_qc_people',
        source=progress_source,
        targets=[gcs_target, bq_target]
    )