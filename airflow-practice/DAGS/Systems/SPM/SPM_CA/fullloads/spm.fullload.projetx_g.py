from airflow import DAG
from datetime import datetime
from operators.extraction import ExtractionOperator
from connectors.jdbc.source.progress_source_connector import ProgressSourceConnector
from connectors.cloud.target.gcs_target_connector import GCSTargetConnector
import pendulum

local_tz = pendulum.timezone("America/Toronto")

with DAG(
    dag_id='spm.fullload.projetx_g',
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
        sql='SELECT ROWID AS "_rowid","no-projet" AS "no_projet", "no-estime" AS "no_estime", "entity-code" AS "entity_code", "no-bon-achat" AS "no_bon_achat", "d-saisie" AS "d_saisie", "t-saisie" AS "t_saisie", "usager" AS "usager", "d-livraison" AS "d_livraison", "form-impr" AS "form_impr", "type-appr" AS "type_appr", "no-appr-cre" AS "no_appr_cre", "d-app-credit" AS "d_app_credit", "ord-prod" AS "ord_prod", "generation" AS "generation", "seq-no" AS "seq_no", "genere" AS "genere", "no-catg" AS "no_catg", "proj_transf" AS "proj_transf", "sold_date" AS "sold_date", "revision_type" AS "revision_type", "approved_by" AS "approved_by", "approved_date" AS "approved_date", "approved_time" AS "approved_time", "approval_status" AS "approval_status", "gdm_extra_code" AS "gdm_extra_code", "price_expiration_date" AS "price_expiration_date", "quotation_sent_date" AS "quotation_sent_date", "no-agent-ct" AS "no_agent_ct", "erector_privilege_parent_proj_id" AS "erector_privilege_parent_proj_id", "financial_comments" AS "financial_comments", "official_budget" AS "official_budget", "estimated_last_shipping_date" AS "estimated_last_shipping_date", "CMICPotentialChangeItemNumber" AS "CMICPotentialChangeItemNumber", "CreatedDate" AS "CreatedDate", "ModifiedDate" AS "ModifiedDate", "CreatedBy" AS "CreatedBy", "ModifiedBy" AS "ModifiedBy", "projetx-g_uuid" AS "projetx_g_uuid" FROM PUB."projetx-g"',
        query_mode='default'
    )

    # 2. Define the Target (GCS)
    gcs_target = GCSTargetConnector(
        conn_id='gcs-bucket-project',
        table_name='projetx_g',
        gcs_path='raw/SPM_CA'
    )

    # 3. Use the Operator to run the task
    extract_data = ExtractionOperator(
        task_id='extract_projetx_g',
        source=progress_source,
        targets=[gcs_target]
    )