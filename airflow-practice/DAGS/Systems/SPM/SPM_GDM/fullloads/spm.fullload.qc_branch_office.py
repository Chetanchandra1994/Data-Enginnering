from airflow import DAG
from datetime import datetime
from operators.extraction import ExtractionOperator
from connectors.jdbc.source.progress_source_connector import ProgressSourceConnector
from connectors.cloud.target.gcs_target_connector import GCSTargetConnector
import pendulum

local_tz = pendulum.timezone("America/Toronto")

with DAG(
    dag_id='spm.fullload.qc_branch_office',
    start_date=datetime(2026, 3, 12, tzinfo=local_tz),
    schedule=None,
    catchup=False,
    tags=["jdbc", "spm", "progress", "gcs", "fullload"],
    max_active_runs=1
) as dag:

    # 1. Define the Source (Progress DB)
    progress_source = ProgressSourceConnector(
        conn_id='gdm',
        database='gdm',
        sql='SELECT ROWID AS "_rowid","office_code" AS "office_code", "branch_office_code" AS "branch_office_code", "addrss1" AS "addrss1", "addrss2" AS "addrss2", "city" AS "city", "st" AS "st", "country" AS "country", "zip_code" AS "zip_code", "name" AS "name", "phone" AS "phone", "fax" AS "fax", "active" AS "active", "tax" AS "tax", "toll_free" AS "toll_free", "deck_calc_soft" AS "deck_calc_soft", "qc_branch_officeUUID" AS "qc_branch_officeUUID", "CreatedDate" AS "CreatedDate", "ModifiedDate" AS "ModifiedDate", "CreatedBy" AS "CreatedBy", "ModifiedBy" AS "ModifiedBy" FROM PUB."qc_branch_office"',
        query_mode='default'
    )

    # 2. Define the Target (GCS)
    gcs_target = GCSTargetConnector(
        conn_id='gcs-bucket-project',
        table_name='qc_branch_office',
        gcs_path='raw/SPM_GDM'
    )

    # 3. Use the Operator to run the task
    extract_data = ExtractionOperator(
        task_id='extract_qc_branch_office',
        source=progress_source,
        targets=[gcs_target]
    )