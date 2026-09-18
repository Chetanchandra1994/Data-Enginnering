from airflow import DAG
from datetime import datetime
from operators.extraction import ExtractionOperator
from connectors.jdbc.source.progress_source_connector import ProgressSourceConnector
from connectors.cloud.target.gcs_target_connector import GCSTargetConnector
import pendulum

local_tz = pendulum.timezone("America/Toronto")

with DAG(
    dag_id='spm.fullload.ess_tranx',
    start_date=datetime(2026, 3, 12, tzinfo=local_tz),
    schedule=None,
    catchup=False,
    tags=["jdbc", "spm", "progress", "gcs", "fullload"],
    max_active_runs=1
) as dag:

    # 1. Define the Source (Progress DB)
    progress_source = ProgressSourceConnector(
        conn_id='acct',
        database='acct',
        sql='SELECT ROWID AS "_rowid","entity-code" AS "entity_code", "line-no" AS "line_no", "mnt-depense" AS "mnt_depense", "mnt-revenu" AS "mnt_revenu", "no-projet" AS "no_projet", "prd" AS "prd", "quantity" AS "quantity", "trans-date" AS "trans_date", "yr" AS "yr", "seq-no" AS "seq_no", "contract_no" AS "contract_no", "office_code" AS "office_code", "branch_office_code" AS "branch_office_code", "weight" AS "weight", "area" AS "area", "vendor_id" AS "vendor_id", "vendor_name" AS "vendor_name", "exp-marg" AS "exp_marg", "CreatedDate" AS "CreatedDate", "ModifiedDate" AS "ModifiedDate", "CreatedBy" AS "CreatedBy", "ModifiedBy" AS "ModifiedBy", "ess-tranx_uuid" AS "ess_tranx_uuid" FROM PUB."ess-tranx"',
        query_mode='default'
    )

    # 2. Define the Target (GCS)
    gcs_target = GCSTargetConnector(
        conn_id='gcs-bucket-project',
        table_name='ess_tranx',
        gcs_path='raw/SPM_CA'
    )

    # 3. Use the Operator to run the task
    extract_data = ExtractionOperator(
        task_id='extract_ess_tranx',
        source=progress_source,
        targets=[gcs_target]
    )