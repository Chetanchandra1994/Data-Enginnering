from airflow import DAG
from datetime import datetime
from operators.extraction import ExtractionOperator
from connectors.jdbc.source.progress_source_connector import ProgressSourceConnector
from connectors.cloud.target.gcs_target_connector import GCSTargetConnector
import pendulum

local_tz = pendulum.timezone("America/Toronto")

with DAG(
    dag_id='spm.fullload.in_control',
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
        sql='SELECT ROWID AS "_rowid", "in-entity" AS "in_entity", "in-yr" AS "in_yr", "in-prd" AS "in_prd", "number-prd" AS "number_prd", "whs-code" AS "whs_code", "uom-code" AS "uom_code", "cost-method" AS "cost_method", "break-code" AS "break_code", "prod-group" AS "prod_group", "pr-gp-length" AS "pr_gp_length", "entity-inv" AS "entity_inv", "entity-wip" AS "entity_wip", mli, "allow-bo" AS "allow_bo", "misc-code" AS "misc_code", "gl-physical" AS "gl_physical", "view-login" AS "view_login", "udm-alt" AS "udm_alt", facteur, "coil-group" AS "coil_group", mesure, deck_group, desgo_versant, slit_group, duty_free_rate, CreatedDate, ModifiedDate, CreatedBy, ModifiedBy, "in-control_uuid" FROM PUB."in-control"',
        query_mode='default'
    )

    # 2. Define the Target (GCS)
    gcs_target = GCSTargetConnector(
        conn_id='gcs-bucket-project',
        table_name='in_control',
        gcs_path='raw/SPM_CA'
    )

    # 3. Use the Operator to run the task
    extract_data = ExtractionOperator(
        task_id='extract_in_control',
        source=progress_source,
        targets=[gcs_target]
    )