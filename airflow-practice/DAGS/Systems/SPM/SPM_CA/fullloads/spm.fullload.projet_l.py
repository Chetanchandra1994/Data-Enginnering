from airflow import DAG
from datetime import datetime
from operators.extraction import ExtractionOperator
from connectors.jdbc.source.progress_source_connector import ProgressSourceConnector
from connectors.cloud.target.gcs_target_connector import GCSTargetConnector
import pendulum

local_tz = pendulum.timezone("America/Toronto")

with DAG(
    dag_id='spm.fullload.projet_l',
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
        sql='SELECT ROWID AS "_rowid","entity-code" AS "entity_code", "no-projet" AS "no_projet", "no-produit" AS "no_produit", "type-fact" AS "type_fact", "stats-tmps-e"[1] AS "stats_tmps_e_1", "stats-tmps-e"[3] AS "stats_tmps_e_3", "stats-tmps-e"[7] AS "stats_tmps_e_7", "stats-tmps-e"[6] AS "stats_tmps_e_6", "stats-tmps-e"[5] AS "stats_tmps_e_5", "stats-tmps-e"[2] AS "stats_tmps_e_2", "stats-tmps-e"[4] AS "stats_tmps_e_4", "stats-tmps-is"[2] AS "stats_tmps_is_2", "stats-tmps-is"[1] AS "stats_tmps_is_1", "stats-tmps-is"[6] AS "stats_tmps_is_6", "stats-tmps-is"[4] AS "stats_tmps_is_4", "stats-tmps-is"[5] AS "stats_tmps_is_5", "stats-tmps-is"[3] AS "stats_tmps_is_3", "stats-tmps-ir"[4] AS "stats_tmps_ir_4", "stats-tmps-ir"[3] AS "stats_tmps_ir_3", "stats-tmps-ir"[2] AS "stats_tmps_ir_2", "stats-tmps-ir"[1] AS "stats_tmps_ir_1", "stats-tmps-ir"[6] AS "stats_tmps_ir_6", "stats-tmps-ir"[5] AS "stats_tmps_ir_5", "dessin-deb" AS "dessin_deb", "dessin-fin" AS "dessin_fin", "stats-unites"[2] AS "stats_unites_2", "stats-unites"[1] AS "stats_unites_1", "stats-unites"[3] AS "stats_unites_3", "stats-unites"[5] AS "stats_unites_5", "stats-unites"[4] AS "stats_unites_4", "stats-poids"[6] AS "stats_poids_6", "stats-poids"[8] AS "stats_poids_8", "stats-poids"[1] AS "stats_poids_1", "stats-poids"[2] AS "stats_poids_2", "stats-poids"[3] AS "stats_poids_3", "stats-poids"[4] AS "stats_poids_4", "stats-poids"[5] AS "stats_poids_5", "stats-poids"[7] AS "stats_poids_7", "stats-tmps-ei"[1] AS "stats_tmps_ei_1", "stats-tmps-ei"[5] AS "stats_tmps_ei_5", "stats-tmps-ei"[2] AS "stats_tmps_ei_2", "stats-tmps-ei"[3] AS "stats_tmps_ei_3", "stats-tmps-ei"[4] AS "stats_tmps_ei_4", "stats-tmps-ei"[6] AS "stats_tmps_ei_6", "complex_code" AS "complex_code", "statut" AS "statut", "d-hist-livr"[1] AS "d_hist_livr_1", "d-hist-livr"[2] AS "d_hist_livr_2", "d-hist-livr"[6] AS "d_hist_livr_6", "d-hist-livr"[5] AS "d_hist_livr_5", "d-hist-livr"[4] AS "d_hist_livr_4", "d-hist-livr"[3] AS "d_hist_livr_3", "estim_det" AS "estim_det", "type-projet" AS "type_projet", "slsmn-code" AS "slsmn_code", "ModifiedDate" AS "ModifiedDate", "mnt-facture" AS "mnt_facture", "stats-annuel"[4] AS "stats_annuel_4", "stats-annuel"[1] AS "stats_annuel_1", "stats-annuel"[3] AS "stats_annuel_3", "stats-annuel"[2] AS "stats_annuel_2", "ind-f-conn" AS "ind_f_conn", "net-sale" AS "net_sale", "pst-quoted" AS "pst_quoted", "net-u-price" AS "net_u_price", "estim_des" AS "estim_des", "desgo-q" AS "desgo_q", "waste-out" AS "waste_out", "inv-cat" AS "inv_cat", "stats-tmps-s"[3] AS "stats_tmps_s_3", "stats-tmps-s"[4] AS "stats_tmps_s_4", "stats-tmps-s"[5] AS "stats_tmps_s_5", "stats-tmps-s"[6] AS "stats_tmps_s_6", "stats-tmps-s"[2] AS "stats_tmps_s_2", "stats-tmps-s"[7] AS "stats_tmps_s_7", "stats-tmps-s"[1] AS "stats_tmps_s_1", "stats-tmps-r"[1] AS "stats_tmps_r_1", "stats-tmps-r"[2] AS "stats_tmps_r_2", "stats-tmps-r"[7] AS "stats_tmps_r_7", "stats-tmps-r"[3] AS "stats_tmps_r_3", "stats-tmps-r"[6] AS "stats_tmps_r_6", "stats-tmps-r"[4] AS "stats_tmps_r_4", "stats-tmps-r"[5] AS "stats_tmps_r_5", "dsg_cost"[2] AS "dsg_cost_2", "dsg_cost"[6] AS "dsg_cost_6", "dsg_cost"[1] AS "dsg_cost_1", "dsg_cost"[5] AS "dsg_cost_5", "dsg_cost"[4] AS "dsg_cost_4", "dsg_cost"[3] AS "dsg_cost_3", "mark-design-qty" AS "mark_design_qty", "time_procss_r" AS "time_procss_r", "cost_procss_r" AS "cost_procss_r", "stats-cost"[3] AS "stats_cost_3", "stats-cost"[2] AS "stats_cost_2", "stats-cost"[1] AS "stats_cost_1", "cmg_end_detail" AS "cmg_end_detail", "time_procss_i" AS "time_procss_i", "cost_procss_i" AS "cost_procss_i", "office_code" AS "office_code", "branch_office_code" AS "branch_office_code", "score_hrs_ton" AS "score_hrs_ton", "vendor_id" AS "vendor_id", "vendor_name" AS "vendor_name", "revenue_quantity_type_uuid" AS "revenue_quantity_type_uuid", "erector_priv_shipped_uom_transf" AS "erector_priv_shipped_uom_transf", "CreatedDate" AS "CreatedDate", "CreatedBy" AS "CreatedBy", "ModifiedBy" AS "ModifiedBy", "projet-l_uuid" AS "projet_l_uuid" FROM PUB."projet-l"',
        query_mode='default',
        limit=10000
    )

    # 2. Define the Target (GCS)
    gcs_target = GCSTargetConnector(
        conn_id='gcs-bucket-project',
        table_name='projet_l',
        gcs_path='raw/SPM_CA'
    )

    # 3. Use the Operator to run the task
    extract_data = ExtractionOperator(
        task_id='extract_projet_l',
        source=progress_source,
        targets=[gcs_target]
    )