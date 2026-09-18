from airflow import DAG
from datetime import datetime
from operators.extraction import ExtractionOperator
from connectors.jdbc.source.progress_source_connector import ProgressSourceConnector
from connectors.cloud.target.gcs_target_connector import GCSTargetConnector
import pendulum

local_tz = pendulum.timezone("America/Toronto")

with DAG(
    dag_id='spm.fullload.projet_e',
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
        sql='SELECT ROWID AS "_rowid","no-projet" AS "no_projet", "d-estime" AS "d_estime", "d-ouverture" AS "d_ouverture", "d-livraison" AS "d_livraison", "d-app-credit" AS "d_app_credit", "d-d-design" AS "d_d_design", "d-f-design" AS "d_f_design", "d-d-detail" AS "d_d_detail", "d-f-detail" AS "d_f_detail", "d-d-prod" AS "d_d_prod", "d-f-prod" AS "d_f_prod", "d-d-livre" AS "d_d_livre", "d-f-livre" AS "d_f_livre", "denonciation" AS "denonciation", "impr-histo" AS "impr_histo", "d-plans" AS "d_plans", "d-plans-sd" AS "d_plans_sd", "appr-canam" AS "appr_canam", "d-app-canam" AS "d_app_canam", "d-saisie" AS "d_saisie", "d-contrat" AS "d_contrat", "type-appr" AS "type_appr", "no-appr-cre" AS "no_appr_cre", "no-detailer" AS "no_detailer", "mesure" AS "mesure", "no-peinture" AS "no_peinture", "arc-air" AS "arc_air", "design-bridg" AS "design_bridg", "splice-top" AS "splice_top", "splice-bot" AS "splice_bot", "impr-ingen" AS "impr_ingen", "man_auto_cred" AS "man_auto_cred", "d-inactif" AS "d_inactif", "t-saisie" AS "t_saisie", "usager" AS "usager", "finishing-code" AS "finishing_code", "sloped-shoes" AS "sloped_shoes", "deep-shoes" AS "deep_shoes", "splices" AS "splices", "spec-loads" AS "spec_loads", "spec-deflect" AS "spec_deflect", "uplift" AS "uplift", "stand-seam" AS "stand_seam", "eng-seal-req" AS "eng_seal_req", "spec-inspect" AS "spec_inspect", "dwg-avail" AS "dwg_avail", "moments" AS "moments", "spec-camber" AS "spec_camber", "csqe-bb" AS "csqe_bb", "spec-holes" AS "spec_holes", "spec-conn" AS "spec_conn", "spec-brdg" AS "spec_brdg", "cklist" AS "cklist", "d_histo" AS "d_histo", "production_doc_archived" AS "production_doc_archived", "production_doc_archived_by" AS "production_doc_archived_by", "production_doc_archived_date" AS "production_doc_archived_date", "no-agent-ct" AS "no_agent_ct", "CreatedDate" AS "CreatedDate", "ModifiedDate" AS "ModifiedDate", "CreatedBy" AS "CreatedBy", "ModifiedBy" AS "ModifiedBy", "projet-e_uuid" AS "projet_e_uuid" FROM PUB."projet-e"',
        query_mode='default'
    )

    # 2. Define the Target (GCS)
    gcs_target = GCSTargetConnector(
        conn_id='gcs-bucket-project',
        table_name='projet_e',
        gcs_path='raw/SPM_CA'
    )

    # 3. Use the Operator to run the task
    extract_data = ExtractionOperator(
        task_id='extract_projet_e',
        source=progress_source,
        targets=[gcs_target]
    )