from airflow import DAG
from datetime import datetime
from operators.extraction import ExtractionOperator
from connectors.jdbc.source.progress_source_connector import ProgressSourceConnector
from connectors.cloud.target.gcs_target_connector import GCSTargetConnector
from connectors.cloud.target.bigquery_target_connector import BigQueryTargetConnector
import pendulum

local_tz = pendulum.timezone("America/Toronto")

with DAG(
    dag_id='spm.fullload.projet_g',
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
        sql='SELECT ROWID AS "_rowid","no-projet" AS "no_projet", "entity-code" AS "entity_code", "nom-projet-l" AS "nom_projet_l", "nom-projet-c" AS "nom_projet_c", "cust-no" AS "cust_no", "no-estime" AS "no_estime", "no-proj-cli" AS "no_proj_cli", "nom-contact" AS "nom_contact", "no-bon-achat" AS "no_bon_achat", "no-contrat-v" AS "no_contrat_v", "type-projet" AS "type_projet", "douane-proj" AS "douane_proj", "statut-proj" AS "statut_proj", "terr-code" AS "terr_code", "pst-license" AS "pst_license", "fst-license" AS "fst_license", "adresse-liv"[2] AS "adresse_liv_2", "adresse-liv"[1] AS "adresse_liv_1", "adresse-liv"[3] AS "adresse_liv_3", "details-liv"[2] AS "details_liv_2", "details-liv"[1] AS "details_liv_1", "details-liv"[3] AS "details_liv_3", "fob-code" AS "fob_code", "lieu-fab" AS "lieu_fab", "slsmn-code" AS "slsmn_code", "nbr-plancher" AS "nbr_plancher", "resp-ordon" AS "resp_ordon", "seq-facture" AS "seq_facture", "ord-prod" AS "ord_prod", "hold-rate" AS "hold_rate", "waste-str"[1] AS "waste_str_1", "waste-str"[2] AS "waste_str_2", "nbr-design" AS "nbr_design", "nbr-famil" AS "nbr_famil", "no-catg" AS "no_catg", "term-code" AS "term_code", "city-to" AS "city_to", "area-to" AS "area_to", "manager" AS "manager", "pos-tag" AS "pos_tag", "sequencing" AS "sequencing", "job-no" AS "job_no", "nb-ship"[1] AS "nb_ship_1", "nb-ship"[2] AS "nb_ship_2", "nb-escort" AS "nb_escort", "longest" AS "longest", "job-site"[2] AS "job_site_2", "job-site"[3] AS "job_site_3", "job-site"[1] AS "job_site_1", "follow-mark" AS "follow_mark", "trans-mark" AS "trans_mark", "entity-ste" AS "entity_ste", "no-estime-esf" AS "no_estime_esf", "mark_type" AS "mark_type", "pdm_file" AS "pdm_file", "follow_div" AS "follow_div", "bolt_resp" AS "bolt_resp", "site_phone" AS "site_phone", "site_fax" AS "site_fax", "form_entity" AS "form_entity", "proj_coord" AS "proj_coord", "paint_date" AS "paint_date", "bolt_included" AS "bolt_included", "joist_plant" AS "joist_plant", "sequnc_dates"[2] AS "sequnc_dates_2", "sequnc_dates"[1] AS "sequnc_dates_1", "sequnc_dates"[3] AS "sequnc_dates_3", "sequnc_weeks"[1] AS "sequnc_weeks_1", "sequnc_weeks"[2] AS "sequnc_weeks_2", "sequnc_weeks"[3] AS "sequnc_weeks_3", "cmg_source_template" AS "cmg_source_template", "cmg_assoc_proj" AS "cmg_assoc_proj", "cmg_transf_time" AS "cmg_transf_time", "cmg_transfer" AS "cmg_transfer", "cmg_transf_date" AS "cmg_transf_date", "cmg_check_amt" AS "cmg_check_amt", "cmg_city" AS "cmg_city", "county_code" AS "county_code", "cmg_state" AS "cmg_state", "cmg_zip_code" AS "cmg_zip_code", "cmg_country" AS "cmg_country", "exchgn_rate" AS "exchgn_rate", "ship_trf_date" AS "ship_trf_date", "ship_trf_time" AS "ship_trf_time", "budget_trf_date" AS "budget_trf_date", "budget_trf_time" AS "budget_trf_time", "cmg_credit_comm" AS "cmg_credit_comm", "invoice_print_style" AS "invoice_print_style", "lst_bcklog" AS "lst_bcklog", "sales_stat" AS "sales_stat", "quottn_access" AS "quottn_access", "branch_office_code" AS "branch_office_code", "mli" AS "mli", "is_abm_page_line" AS "is_abm_page_line", "abm_follow_up" AS "abm_follow_up", "drwg_office_code" AS "drwg_office_code", "buyer_code" AS "buyer_code", "kronos_trf_date" AS "kronos_trf_date", "waste_cost"[2] AS "waste_cost_2", "waste_cost"[1] AS "waste_cost_1", "office_code" AS "office_code", "max_deck_bundl_weight" AS "max_deck_bundl_weight", "max_deck_bundl_pieces" AS "max_deck_bundl_pieces", "deck_bundl_pieces_tolerance" AS "deck_bundl_pieces_tolerance", "budget_valid_date" AS "budget_valid_date", "chiefs_engineer" AS "chiefs_engineer", "chiefs_detailer" AS "chiefs_detailer", "shipping_coordinators" AS "shipping_coordinators", "gdm_project_id" AS "gdm_project_id", "quotation_sent_date" AS "quotation_sent_date", "price_expiration_date" AS "price_expiration_date", "no_splice_top_bot" AS "no_splice_top_bot", "drawing_due_in" AS "drawing_due_in", "special_elements" AS "special_elements", "special_elements_comments" AS "special_elements_comments", "priority_code" AS "priority_code", "rollbar_expected_back_date" AS "rollbar_expected_back_date", "rollbar_actual_back_date" AS "rollbar_actual_back_date", "is_layout_job" AS "is_layout_job", "rollbar_follow_up_date" AS "rollbar_follow_up_date", "contact_email" AS "contact_email", "list_on_hambro_schedule" AS "list_on_hambro_schedule", "set_off_information" AS "set_off_information", "cmg_invoice_style" AS "cmg_invoice_style", "po_no_trans_oracle" AS "po_no_trans_oracle", "weight_increase_comment" AS "weight_increase_comment", "layout_process_code" AS "layout_process_code", "shipping_comments" AS "shipping_comments", "rollbar_comment" AS "rollbar_comment", "estimation_include_design" AS "estimation_include_design", "leed_certified" AS "leed_certified", "dsms_transfer" AS "dsms_transfer", "design_completed_date" AS "design_completed_date", "financial_comments" AS "financial_comments", "project_status_code" AS "project_status_code", "project_status_comment" AS "project_status_comment", "project_status_updated_by" AS "project_status_updated_by", "project_status_updated_datetime" AS "project_status_updated_datetime", "business_unit_id" AS "business_unit_id", "preparation_follow_up" AS "preparation_follow_up", "prep_follow_up_marks_filter" AS "prep_follow_up_marks_filter", "taxation_address" AS "taxation_address", "CreatedDate" AS "CreatedDate", "ModifiedDate" AS "ModifiedDate", "CreatedBy" AS "CreatedBy", "ModifiedBy" AS "ModifiedBy", "projet-g_uuid" AS "projet_g_uuid" FROM PUB."projet-g"',
        query_mode='default',
        limit=10000
    )

    # 2. Define the Target (GCS)
    gcs_target = GCSTargetConnector(
        conn_id='gcs-bucket-project',
        table_name='projet_g',
        gcs_path='raw/SPM_CA'
    )

    bq_target = BigQueryTargetConnector(
        conn_id='bigquery-edl-landing',
        bq_landing_table='SPM_CA.projet_g',
        bq_merge_procedure='SPM_CA.sp_Merge_projet_g'
    )

    # 3. Use the Operator to run the task
    extract_data = ExtractionOperator(
        task_id='extract_projet_g',
        source=progress_source,
        targets=[gcs_target, bq_target]
    )