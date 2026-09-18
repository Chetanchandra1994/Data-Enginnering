from airflow import DAG
from datetime import datetime
from operators.extraction import ExtractionOperator
from connectors.jdbc.source.progress_source_connector import ProgressSourceConnector
from connectors.cloud.target.gcs_target_connector import GCSTargetConnector
import pendulum

local_tz = pendulum.timezone("America/Toronto")

with DAG(
    dag_id='spm.fullload.qc_quotation',
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
        sql='SELECT ROWID AS "_rowid", ConfidenceRating AS "ConfidenceRating", CreatedBy AS "CreatedBy", CreatedDate AS "CreatedDate", DeliveryBranchOfficeCode AS "DeliveryBranchOfficeCode", DeliveryOfficeCode AS "DeliveryOfficeCode", DraftingContract AS "DraftingContract", EstimationTargetDateTime AS "EstimationTargetDateTime", ExtraCredit AS "ExtraCredit", IsNationalAccount AS "IsNationalAccount", LastLoadedEstimationBudgetFormat AS "LastLoadedEstimationBudgetFormat", LastLoadedEstimationFileDateTime AS "LastLoadedEstimationFileDateTime", LastLoadedEstimationFileLoadBy AS "LastLoadedEstimationFileLoadBy", LastLoadedEstimationFileName AS "LastLoadedEstimationFileName", LostPriceDelta AS "LostPriceDelta", LostToComptNo AS "LostToComptNo", ModifiedBy AS "ModifiedBy", ModifiedDate AS "ModifiedDate", OpportunityDelieveryDateSpan AS "OpportunityDelieveryDateSpan", OpportunityDelieveryDateSpanMax AS "OpportunityDelieveryDateSpanMax", OpportunityDelieveryDateSpanMin AS "OpportunityDelieveryDateSpanMin", OpportunityRating AS "OpportunityRating", OpportunityStage AS "OpportunityStage", OpportunityStatus AS "OpportunityStatus", ProjectType AS "ProjectType", QuotationMainProduct AS "QuotationMainProduct", QuotationSentDate AS "QuotationSentDate", QuotationTypeUUID AS "QuotationTypeUUID", SignatoryApprovalStatus AS "SignatoryApprovalStatus", SignatoryApprovedAmount AS "SignatoryApprovedAmount", active AS "active", addend AS "addend", addend_date AS "addend_date", addend_desc AS "addend_desc", "adresse-liv"[1] AS "adresse_liv_1", "adresse-liv"[2] AS "adresse_liv_2", "adresse-liv"[3] AS "adresse_liv_3", apply_fee AS "apply_fee", approval_type AS "approval_type", bid_customer_uuid AS "bid_customer_uuid", bid_date AS "bid_date", branch_office_code AS "branch_office_code", century AS "century", city AS "city", class_categ AS "class_categ", class_code AS "class_code", complx_code AS "complx_code", contract_customer_uuid AS "contract_customer_uuid", contrc_buyer_contact_uuid AS "contrc_buyer_contact_uuid", contrc_compt_no AS "contrc_compt_no", contrc_compt_office_code AS "contrc_compt_office_code", contrc_date AS "contrc_date", contrc_note AS "contrc_note", contrc_proj_manager_contact_uuid AS "contrc_proj_manager_contact_uuid", country AS "country", county_code AS "county_code", "currency-cod" AS "currency_cod", "d-estime" AS "d_estime", "d-livraison" AS "d_livraison", deck AS "deck", deck_calc_soft AS "deck_calc_soft", design_code AS "design_code", design_date AS "design_date", design_desc AS "design_desc", domestic_steel_only AS "domestic_steel_only", drawing_due_back AS "drawing_due_back", drawing_due_in AS "drawing_due_in", drawing_due_out AS "drawing_due_out", dsg_entity_code AS "dsg_entity_code", dummy AS "dummy", erector_privilege_included AS "erector_privilege_included", estimation_include_design AS "estimation_include_design", estimt_init_code AS "estimt_init_code", estimt_ship_date AS "estimt_ship_date", exchgn_rate AS "exchgn_rate", "fob-code" AS "fob_code", follow_date AS "follow_date", follow_up AS "follow_up", gc_close_date AS "gc_close_date", general_note AS "general_note", hot AS "hot", input_by_init_code AS "input_by_init_code", input_by_name AS "input_by_name", inscrp_date AS "inscrp_date", issued_for AS "issued_for", "job-no" AS "job_no", last_update_date AS "last_update_date", last_update_time AS "last_update_time", lead AS "lead", lead_prospector_init_code AS "lead_prospector_init_code", leed_certified AS "leed_certified", longest AS "longest", lost_date AS "lost_date", lost_status_comment AS "lost_status_comment", mark_qty AS "mark_qty", markup_opening_fee AS "markup_opening_fee", markup_price AS "markup_price", "markup_price_$" AS "markup_price_dlr", "markup_price_%" AS "markup_price_pct", markup_rounding AS "markup_rounding", markup_weight AS "markup_weight", "markup_weight_%" AS "markup_weight_pct", master_job_no AS "master_job_no", memo AS "memo", mesure AS "mesure", mill_test_required AS "mill_test_required", nb_alt AS "nb_alt", "no-bon-achat" AS "no_bon_achat", "no-contrat-v" AS "no_contrat_v", "no-projet" AS "no_projet", "nom-contact" AS "nom_contact", office_code AS "office_code", opening_fee AS "opening_fee", po_date AS "po_date", price AS "price", "proj-name" AS "proj_name", proj_coord AS "proj_coord", projct_step AS "projct_step", projct_surface AS "projct_surface", propst_no AS "propst_no", "public" AS "public", quotation_uuid AS "quotation_uuid", recall_date AS "recall_date", round_to_factor AS "round_to_factor", sale_terr_code AS "sale_terr_code", salesm_init_code AS "salesm_init_code", ship_terr_code AS "ship_terr_code", show_addresses_on_fps AS "show_addresses_on_fps", specfc AS "specfc", specfc_date AS "specfc_date", specfc_desc AS "specfc_desc", special_elements_note AS "special_elements_note", spm_date AS "spm_date", spm_entity_code AS "spm_entity_code", st AS "st", standing_id AS "standing_id", status1 AS "status1", status1_no AS "status1_no", status2 AS "status2", status2_no AS "status2_no", status_contrc AS "status_contrc", transfer_date AS "transfer_date", user_code AS "user_code", ves_entry_completed_user_code AS "ves_entry_completed_user_code", weight_increase_comment AS "weight_increase_comment", xtra_no AS "xtra_no", zip_code AS "zip_code" FROM PUB."qc_quotation"',
        query_mode='default',
        limit=10000
    )

    # 2. Define the Targets
    gcs_target = GCSTargetConnector(
        conn_id='gcs-bucket-project',
        table_name='qc_quotation',
        gcs_path='raw/SPM_CA'
    )

    # 3. Use the Operator to run the task
    extract_data = ExtractionOperator(
        task_id='extract_qc_quotation',
        source=progress_source,
        targets=[gcs_target]
    )