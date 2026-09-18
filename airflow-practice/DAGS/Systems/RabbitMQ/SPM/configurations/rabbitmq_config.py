"""
Central configuration file for all RabbitMQ queues to be polled.
This list is imported by the 'rabbitmq_master_poller' DAG.

You can expand Arrays from Progress table using the following configuration:
        "expand_map": {
            "field_name": {
                "delimiter": ";",
                "target_fields": ["field_name_1","field_name_2","field_name_3","field_name_4"]
            }
        }
"""

# Shared configuration values to be applied to all queues
GLOBAL_CONFIG = {
    "bucket_conn_id": "gcs-bucket-project",
    "rabbitmq_conn_id": "amqp",
    "bq_conn_id": "bigquery-edl-landing"
}


# --- 5-Minute Schedule Queues ---
# This list will be checked by the poller every 5 minutes
QUEUES_CONFIG_5_MIN = [
    {
        "queue_name": "spm.ap-term.airflow",
        "table_name": "ap_term",
        "gcs_path": "raw/SPM_CA",
        "batch_size": 500,
        "upload_to_bq": True,
        "bq_landing_table": "SPM_CA.ap_term",
        "bq_write_disposition": "WRITE_APPEND",
        "upload_to_bq_merge": True,
        "bq_merge_procedure": "SPM_CA.sp_Merge_ap_term"
    },
    {
        "queue_name": "spm.application_transfer_whs.airflow",
        "table_name": "application_transfer_whs",
        "gcs_path": "raw/SPM_CA",
        "batch_size": 500,
        "upload_to_bq": True,
        "bq_landing_table": "SPM_CA.application_transfer_whs",
        "bq_write_disposition": "WRITE_APPEND",
        "upload_to_bq_merge": True,
        "bq_merge_procedure": "SPM_CA.sp_Merge_application_transfer_whs"
    },
    {
        "queue_name": "spm.bundle_automation_stats.airflow",
        "table_name": "bundle_automation_stats",
        "gcs_path": "raw/SPM_CA",
        "batch_size": 500,
        "upload_to_bq": True,
        "bq_landing_table": "SPM_CA.bundle_automation_stats",
        "bq_write_disposition": "WRITE_APPEND",
        "upload_to_bq_merge": True,
        "bq_merge_procedure": "SPM_CA.sp_Merge_bundle_automation_stats"
    },
    {
        "queue_name": "spm.buyer.airflow",
        "table_name": "buyer",
        "gcs_path": "raw/SPM_CA",
        "batch_size": 500,
        "upload_to_bq": True,
        "bq_landing_table": "SPM_CA.buyer",
        "bq_write_disposition": "WRITE_APPEND",
        "upload_to_bq_merge": True,
        "bq_merge_procedure": "SPM_CA.sp_Merge_buyer"
    },
    {
        "queue_name": "spm.country.airflow",
        "table_name": "country",
        "gcs_path": "raw/SPM_GDM",
        "batch_size": 500,
        "upload_to_bq": True,
        "bq_landing_table": "SPM_GDM.country",
        "bq_write_disposition": "WRITE_APPEND",
        "upload_to_bq_merge": True,
        "bq_merge_procedure": "SPM_GDM.sp_Merge_country"
    },
    {
        "queue_name": "spm.currency.airflow",
        "table_name": "currency",
        "gcs_path": "raw/SPM_CA",
        "batch_size": 500,
        "upload_to_bq": True,
        "bq_landing_table": "SPM_CA.currency",
        "bq_write_disposition": "WRITE_APPEND",
        "upload_to_bq_merge": True,
        "bq_merge_procedure": "SPM_CA.sp_Merge_currency"
    },
    {
        "queue_name": "spm.customer.airflow",
        "table_name": "customer",
        "gcs_path": "raw/SPM_GDM",
        "batch_size": 500,
        "upload_to_bq": True,
        "bq_landing_table": "SPM_GDM.customer",
        "bq_write_disposition": "WRITE_APPEND",
        "upload_to_bq_merge": True,
        "bq_merge_procedure": "SPM_GDM.sp_Merge_customer"
    },
    {
        "queue_name": "spm.customer_market.airflow",
        "table_name": "customer_market",
        "gcs_path": "raw/SPM_GDM",
        "batch_size": 500,
        "upload_to_bq": True,
        "bq_landing_table": "SPM_GDM.customer_market",
        "bq_write_disposition": "WRITE_APPEND",
        "upload_to_bq_merge": True,
        "bq_merge_procedure": "SPM_GDM.sp_Merge_customer_market"
    },
    {
        "queue_name": "spm.department.airflow",
        "table_name": "department",
        "gcs_path": "raw/SPM_GDM",
        "batch_size": 500,
        "upload_to_bq": True,
        "bq_landing_table": "SPM_GDM.department",
        "bq_write_disposition": "WRITE_APPEND",
        "upload_to_bq_merge": True,
        "bq_merge_procedure": "SPM_GDM.sp_Merge_department"
    },
    {
        "queue_name": "spm.duty.airflow",
        "table_name": "duty",
        "gcs_path": "raw/SPM_CA",
        "batch_size": 500,
        "upload_to_bq": True,
        "bq_landing_table": "SPM_CA.duty",
        "bq_write_disposition": "WRITE_APPEND",
        "upload_to_bq_merge": True,
        "bq_merge_procedure": "SPM_CA.sp_Merge_duty"
    },
    {
        "queue_name": "spm.event.airflow",
        "table_name": "event",
        "gcs_path": "raw/SPM_GDM",
        "batch_size": 500,
        "upload_to_bq": True,
        "bq_landing_table": "SPM_GDM.event",
        "bq_write_disposition": "WRITE_APPEND",
        "upload_to_bq_merge": True,
        "bq_merge_procedure": "SPM_GDM.sp_Merge_event"
    },
    {
        "queue_name": "spm.global_item.airflow",
        "table_name": "global_item",
        "gcs_path": "raw/SPM_GDM",
        "batch_size": 500,
        "upload_to_bq": True,
        "bq_landing_table": "SPM_GDM.global_item",
        "bq_write_disposition": "WRITE_APPEND",
        "upload_to_bq_merge": True,
        "bq_merge_procedure": "SPM_GDM.sp_Merge_global_item"
    },
    {
        "queue_name": "spm.global_project.airflow",
        "table_name": "global_project",
        "gcs_path": "raw/SPM_GDM",
        "batch_size": 500,
        "upload_to_bq": True,
        "bq_landing_table": "SPM_GDM.global_project",
        "bq_write_disposition": "WRITE_APPEND",
        "upload_to_bq_merge": True,
        "bq_merge_procedure": "SPM_GDM.sp_Merge_global_project"
    },
    {
        "queue_name": "spm.in-tax.airflow",
        "table_name": "in_tax",
        "gcs_path": "raw/SPM_GDM",
        "batch_size": 500,
        "upload_to_bq": True,
        "bq_landing_table": "SPM_GDM.in_tax",
        "bq_write_disposition": "WRITE_APPEND",
        "upload_to_bq_merge": True,
        "bq_merge_procedure": "SPM_GDM.sp_Merge_in_tax"
    },
    {
        "queue_name": "spm.item-whs-d.airflow",
        "table_name": "item_whs_d",
        "gcs_path": "raw/SPM_CA",
        "batch_size": 500,
        "upload_to_bq": True,
        "bq_landing_table": "SPM_CA.item_whs_d",
        "bq_write_disposition": "WRITE_APPEND",
        "upload_to_bq_merge": True,
        "bq_merge_procedure": "SPM_CA.sp_Merge_item_whs_d"
    },
    {
        "queue_name": "spm.item-whs-prd.airflow",
        "table_name": "item_whs_prd",
        "gcs_path": "raw/SPM_CA",
        "batch_size": 500,
        "upload_to_bq": True,
        "bq_landing_table": "SPM_CA.item_whs_prd",
        "bq_write_disposition": "WRITE_APPEND",
        "upload_to_bq_merge": True,
        "bq_merge_procedure": "SPM_CA.sp_Merge_item_whs_prd"
    },
    {
        "queue_name": "spm.item.airflow",
        "table_name": "item",
        "gcs_path": "raw/SPM_CA",
        "batch_size": 500,
        "upload_to_bq": True,
        "bq_landing_table": "SPM_CA.item",
        "bq_write_disposition": "WRITE_APPEND",
        "upload_to_bq_merge": True,
        "bq_merge_procedure": "SPM_CA.sp_Merge_item"
    },
    {
        "queue_name": "spm.item_category.airflow",
        "table_name": "item_category",
        "gcs_path": "raw/SPM_GDM",
        "batch_size": 500,
        "upload_to_bq": True,
        "bq_landing_table": "SPM_GDM.item_category",
        "bq_write_disposition": "WRITE_APPEND",
        "upload_to_bq_merge": True,
        "bq_merge_procedure": "SPM_GDM.sp_Merge_item_category"
    },
    {
        "queue_name": "spm.item_subcategory.airflow",
        "table_name": "item_subcategory",
        "gcs_path": "raw/SPM_GDM",
        "batch_size": 500,
        "upload_to_bq": True,
        "bq_landing_table": "SPM_GDM.item_subcategory",
        "bq_write_disposition": "WRITE_APPEND",
        "upload_to_bq_merge": True,
        "bq_merge_procedure": "SPM_GDM.sp_Merge_item_subcategory"
    },
    {
        "queue_name": "spm.item_whs_d.airflow",
        "table_name": "item_whs_d",
        "gcs_path": "raw/SPM_CA",
        "batch_size": 500,
        "upload_to_bq": True,
        "bq_landing_table": "SPM_CA.item_whs_d",
        "bq_write_disposition": "WRITE_APPEND",
        "upload_to_bq_merge": True,
        "bq_merge_procedure": "SPM_CA.sp_Merge_item_whs_d"
    },
    {
        "queue_name": "spm.mark_automation_stats.airflow",
        "table_name": "mark_automation_stats",
        "gcs_path": "raw/SPM_CA",
        "batch_size": 500,
        "upload_to_bq": True,
        "bq_landing_table": "SPM_CA.mark_automation_stats",
        "bq_write_disposition": "WRITE_APPEND",
        "upload_to_bq_merge": True,
        "bq_merge_procedure": "SPM_CA.sp_Merge_mark_automation_stats"
    },
    {
        "queue_name": "spm.mark_bundle.airflow",
        "table_name": "mark_bundle",
        "gcs_path": "raw/SPM_CA",
        "batch_size": 500,
        "upload_to_bq": True,
        "bq_landing_table": "SPM_CA.mark_bundle",
        "bq_write_disposition": "WRITE_APPEND",
        "upload_to_bq_merge": True,
        "bq_merge_procedure": "SPM_CA.sp_Merge_mark_bundle"
    },
    {
        "queue_name": "spm.mark_production.airflow",
        "table_name": "mark_production",
        "gcs_path": "raw/SPM_CA",
        "batch_size": 500,
        "upload_to_bq": True,
        "bq_landing_table": "SPM_CA.mark_production",
        "bq_write_disposition": "WRITE_APPEND",
        "upload_to_bq_merge": True,
        "bq_merge_procedure": "SPM_CA.sp_Merge_mark_production"
    },
    {
        "queue_name": "spm.mark_seq.airflow",
        "table_name": "mark_seq",
        "gcs_path": "raw/SPM_CA",
        "batch_size": 500,
        "upload_to_bq": True,
        "bq_landing_table": "SPM_CA.mark_seq",
        "bq_write_disposition": "WRITE_APPEND"
    },
    {
        "queue_name": "spm.mark_shift.airflow",
        "table_name": "mark_shift",
        "gcs_path": "raw/SPM_CA",
        "batch_size": 500,
        "upload_to_bq": True,
        "bq_landing_table": "SPM_CA.mark_shift",
        "bq_write_disposition": "WRITE_APPEND",
        "upload_to_bq_merge": True,
        "bq_merge_procedure": "SPM_CA.sp_Merge_mark_shift"
    },
    {
        "queue_name": "spm.marques.airflow",
        "table_name": "marques",
        "gcs_path": "raw/SPM_CA",
        "batch_size": 500,
        "upload_to_bq": True,
        "bq_landing_table": "SPM_CA.marques",
        "bq_write_disposition": "WRITE_APPEND",
        "upload_to_bq_merge": True,
        "bq_merge_procedure": "SPM_CA.sp_Merge_marques"
    },
    {
        "queue_name": "spm.po-line.airflow",
        "table_name": "po_line",
        "gcs_path": "raw/SPM_CA",
        "batch_size": 500,
        "upload_to_bq": True,
        "bq_landing_table": "SPM_CA.po_line",
        "bq_write_disposition": "WRITE_APPEND",
        "upload_to_bq_merge": True,
        "bq_merge_procedure": "SPM_CA.sp_Merge_po_line"
    },
    {
        "queue_name": "spm.po.airflow",
        "table_name": "po",
        "gcs_path": "raw/SPM_CA",
        "batch_size": 500,
        "upload_to_bq": True,
        "bq_landing_table": "SPM_CA.po",
        "bq_write_disposition": "WRITE_APPEND",
        "upload_to_bq_merge": True,
        "bq_merge_procedure": "SPM_CA.sp_Merge_po"
    },
    {
        "queue_name": "spm.production_schedule.airflow",
        "table_name": "production_schedule",
        "gcs_path": "raw/SPM_CA",
        "batch_size": 2000,
        "upload_to_bq": True,
        "bq_landing_table": "SPM_CA.production_schedule",
        "bq_write_disposition": "WRITE_APPEND",
        "upload_to_bq_merge": True,
        "bq_merge_procedure": "SPM_CA.sp_Merge_production_schedule"
    },
    {
        "queue_name": "spm.production_schedule_mark.airflow",
        "table_name": "production_schedule_mark",
        "gcs_path": "raw/SPM_CA",
        "batch_size": 500,
        "upload_to_bq": True,
        "bq_landing_table": "SPM_CA.production_schedule_mark",
        "bq_write_disposition": "WRITE_APPEND",
        "upload_to_bq_merge": True,
        "bq_merge_procedure": "SPM_CA.sp_Merge_production_schedule_mark"
    },
    {
        "queue_name": "spm.produit-s.airflow",
        "table_name": "produit_s",
        "gcs_path": "raw/SPM_CA",
        "batch_size": 500,
        "upload_to_bq": True,
        "bq_landing_table": "SPM_CA.produit_s",
        "bq_write_disposition": "WRITE_APPEND",
        "upload_to_bq_merge": True,
        "bq_merge_procedure": "SPM_CA.sp_Merge_produit_s"
    },
    {
        "queue_name": "spm.proj-seq-lp.airflow",
        "table_name": "proj_seq_lp",
        "gcs_path": "raw/SPM_CA",
        "batch_size": 500,
        "upload_to_bq": True,
        "bq_landing_table": "SPM_CA.proj_seq_lp",
        "bq_write_disposition": "WRITE_APPEND",
        "upload_to_bq_merge": True,
        "bq_merge_procedure": "SPM_CA.sp_Merge_proj_seq_lp"
    },
    {
        "queue_name": "spm.proj_seq.airflow",
        "table_name": "proj_seq",
        "gcs_path": "raw/SPM_CA",
        "batch_size": 500,
        "upload_to_bq": True,
        "bq_landing_table": "SPM_CA.proj_seq",
        "bq_write_disposition": "WRITE_APPEND",
        "upload_to_bq_merge": True,
        "bq_merge_procedure": "SPM_CA.sp_Merge_proj_seq"
    },
    {
        "queue_name": "spm.project.airflow",
        "table_name": "project",
        "gcs_path": "raw/SPM_GDM",
        "batch_size": 500,
        "upload_to_bq": True,
        "bq_landing_table": "SPM_GDM.project",
        "bq_write_disposition": "WRITE_APPEND",
        "upload_to_bq_merge": True,
        "bq_merge_procedure": "SPM_GDM.sp_Merge_project"
    },
    {
        "queue_name": "spm.project_event.airflow",
        "table_name": "project_event",
        "gcs_path": "raw/SPM_CA",
        "batch_size": 500,
        "upload_to_bq": True,
        "bq_landing_table": "SPM_CA.project_event",
        "bq_write_disposition": "WRITE_APPEND",
        "upload_to_bq_merge": True,
        "bq_merge_procedure": "SPM_CA.sp_Merge_project_event"
    },
    {
        "queue_name": "spm.project_event_detail.airflow",
        "table_name": "project_event_detail",
        "gcs_path": "raw/SPM_CA",
        "batch_size": 500,
        "upload_to_bq": True,
        "bq_landing_table": "SPM_CA.project_event_detail",
        "bq_write_disposition": "WRITE_APPEND",
        "upload_to_bq_merge": True,
        "bq_merge_procedure": "SPM_CA.sp_Merge_project_event_detail"
    },
    {
        "queue_name": "spm.project_event_trans_type.airflow",
        "table_name": "project_event_trans_type",
        "gcs_path": "raw/SPM_GDM",
        "batch_size": 500,
        "upload_to_bq": True,
        "bq_landing_table": "SPM_GDM.project_event_trans_type",
        "bq_write_disposition": "WRITE_APPEND",
        "upload_to_bq_merge": True,
        "bq_merge_procedure": "SPM_GDM.sp_Merge_project_event_trans_type"
    },
    {
        "queue_name": "spm.projet_g.airflow",
        "table_name": "projet_g",
        "gcs_path": "raw/SPM_CA",
        "batch_size": 500,
        "upload_to_bq": True,
        "bq_landing_table": "SPM_CA.projet_g",
        "bq_write_disposition": "WRITE_APPEND",
        "upload_to_bq_merge": True,
        "bq_merge_procedure": "SPM_CA.sp_Merge_projet_g"
    },
    {
        "queue_name": "spm.qc_people.airflow",
        "table_name": "qc_people",
        "gcs_path": "raw/SPM_CA",
        "batch_size": 500,
        "upload_to_bq": True,
        "bq_landing_table": "SPM_CA.qc_people",
        "bq_write_disposition": "WRITE_APPEND",
        "upload_to_bq_merge": True,
        "bq_merge_procedure": "SPM_CA.sp_Merge_qc_people"
    },
    {
        "queue_name": "spm.qc_quotation.airflow",
        "table_name": "qc_quotation",
        "gcs_path": "raw/SPM_CA",
        "batch_size": 500,
        "upload_to_bq": True,
        "bq_landing_table": "SPM_CA.qc_quotation",
        "bq_write_disposition": "WRITE_APPEND",
        "upload_to_bq_merge": True,
        "bq_merge_procedure": "SPM_CA.sp_Merge_qc_quotation"
    },
    {
        "queue_name": "spm.qc_quotation_customer.airflow",
        "table_name": "qc_quotation_customer",
        "gcs_path": "raw/SPM_CA",
        "batch_size": 500,
        "upload_to_bq": True,
        "bq_landing_table": "SPM_CA.qc_quotation_customer",
        "bq_write_disposition": "WRITE_APPEND",
        "upload_to_bq_merge": True,
        "bq_merge_procedure": "SPM_CA.sp_Merge_qc_quotation_customer"
    },
    {
        "queue_name": "spm.qc_quotation_product_calculated.airflow",
        "table_name": "qc_quotation_product_calculated",
        "gcs_path": "raw/SPM_CA",
        "batch_size": 500,
        "upload_to_bq": True,
        "bq_landing_table": "SPM_CA.qc_quotation_product_calculated",
        "bq_write_disposition": "WRITE_APPEND"
    },
    {
        "queue_name": "spm.receipt-line.airflow",
        "table_name": "receipt_line",
        "gcs_path": "raw/SPM_CA",
        "batch_size": 500,
        "upload_to_bq": True,
        "bq_landing_table": "SPM_CA.receipt_line",
        "bq_write_disposition": "WRITE_APPEND",
        "upload_to_bq_merge": True,
        "bq_merge_procedure": "SPM_CA.sp_Merge_receipt_line"
    },
    {
        "queue_name": "spm.receipt.airflow",
        "table_name": "receipt",
        "gcs_path": "raw/SPM_CA",
        "batch_size": 500,
        "upload_to_bq": True,
        "bq_landing_table": "SPM_CA.receipt",
        "bq_write_disposition": "WRITE_APPEND",
        "upload_to_bq_merge": True,
        "bq_merge_procedure": "SPM_CA.sp_Merge_receipt"
    },
    {
        "queue_name": "spm.req-prod.airflow",
        "table_name": "req_prod",
        "gcs_path": "raw/SPM_CA",
        "batch_size": 500,
        "upload_to_bq": True,
        "bq_landing_table": "SPM_CA.req_prod",
        "bq_write_disposition": "WRITE_APPEND",
        "upload_to_bq_merge": True,
        "bq_merge_procedure": "SPM_CA.sp_Merge_req_prod"
    },
    {
        "queue_name": "spm.req_automation_stats.airflow",
        "table_name": "req_automation_stats",
        "gcs_path": "raw/SPM_CA",
        "batch_size": 500,
        "upload_to_bq": True,
        "bq_landing_table": "SPM_CA.req_automation_stats",
        "bq_write_disposition": "WRITE_APPEND",
        "upload_to_bq_merge": True,
        "bq_merge_procedure": "SPM_CA.sp_Merge_req_automation_stats"
    },
    {
        "queue_name": "spm.req_time.airflow",
        "table_name": "req_time",
        "gcs_path": "raw/SPM_CA",
        "batch_size": 500,
        "upload_to_bq": True,
        "bq_landing_table": "SPM_CA.req_time",
        "bq_write_disposition": "WRITE_APPEND",
        "upload_to_bq_merge": True,
        "bq_merge_procedure": "SPM_CA.sp_Merge_req_time"
    },
    {
        "queue_name": "spm.salesman.airflow",
        "table_name": "salesman",
        "gcs_path": "raw/SPM_GDM",
        "batch_size": 500,
        "upload_to_bq": True,
        "bq_landing_table": "SPM_GDM.salesman",
        "bq_write_disposition": "WRITE_APPEND",
        "upload_to_bq_merge": True,
        "bq_merge_procedure": "SPM_GDM.sp_Merge_salesman"
    },
    {
        "queue_name": "spm.shop.airflow",
        "table_name": "shop",
        "gcs_path": "raw/SPM_CA",
        "batch_size": 500,
        "upload_to_bq": True,
        "bq_landing_table": "SPM_CA.shop",
        "bq_write_disposition": "WRITE_APPEND",
        "upload_to_bq_merge": True,
        "bq_merge_procedure": "SPM_CA.sp_Merge_shop"
    },
    {
        "queue_name": "spm.shop_worker_modif_audit.airflow",
        "table_name": "shop_worker_modif_audit",
        "gcs_path": "raw/SPM_CA",
        "batch_size": 500,
        "upload_to_bq": True,
        "bq_landing_table": "SPM_CA.shop_worker_modif_audit",
        "bq_write_disposition": "WRITE_APPEND",
        "upload_to_bq_merge": True,
        "bq_merge_procedure": "SPM_CA.sp_Merge_shop_worker_modif_audit"
    },
    {
        "queue_name": "spm.state.airflow",
        "table_name": "state",
        "gcs_path": "raw/SPM_GDM",
        "batch_size": 500,
        "upload_to_bq": True,
        "bq_landing_table": "SPM_GDM.state",
        "bq_write_disposition": "WRITE_APPEND",
        "upload_to_bq_merge": True,
        "bq_merge_procedure": "SPM_GDM.sp_Merge_state"
    },
    {
        "queue_name": "spm.steel_grade.airflow",
        "table_name": "steel_grade",
        "gcs_path": "raw/SPM_GDM",
        "batch_size": 500,
        "upload_to_bq": True,
        "bq_landing_table": "SPM_GDM.steel_grade",
        "bq_write_disposition": "WRITE_APPEND",
        "upload_to_bq_merge": True,
        "bq_merge_procedure": "SPM_GDM.sp_Merge_steel_grade"
    },
    {
        "queue_name": "spm.uom.airflow",
        "table_name": "uom",
        "gcs_path": "raw/SPM_CA",
        "batch_size": 500
    },
    {
        "queue_name": "spm.vendor.airflow",
        "table_name": "vendor",
        "gcs_path": "raw/SPM_CA",
        "batch_size": 500,
        "upload_to_bq": True,
        "bq_landing_table": "SPM_CA.vendor",
        "bq_write_disposition": "WRITE_APPEND",
        "upload_to_bq_merge": True,
        "bq_merge_procedure": "SPM_CA.sp_Merge_vendor"
    },
    {
        "queue_name": "spm.warehouse.airflow",
        "table_name": "warehouse",
        "gcs_path": "raw/SPM_CA",
        "batch_size": 500,
        "upload_to_bq": True,
        "bq_landing_table": "SPM_CA.warehouse",
        "bq_write_disposition": "WRITE_APPEND",
        "upload_to_bq_merge": True,
        "bq_merge_procedure": "SPM_CA.sp_Merge_warehouse"
    },
    {
        "queue_name": "spm.working_shift.airflow",
        "table_name": "working_shift",
        "gcs_path": "raw/SPM_CA",
        "batch_size": 500,
        "upload_to_bq": True,
        "bq_landing_table": "SPM_CA.working_shift",
        "bq_write_disposition": "WRITE_APPEND",
        "upload_to_bq_merge": True,
        "bq_merge_procedure": "SPM_CA.sp_Merge_working_shift"
    },
    {
        "queue_name": "spm.working_shift_detail.airflow",
        "table_name": "working_shift_detail",
        "gcs_path": "raw/SPM_CA",
        "batch_size": 500,
        "upload_to_bq": True,
        "bq_landing_table": "SPM_CA.working_shift_detail",
        "bq_write_disposition": "WRITE_APPEND",
        "upload_to_bq_merge": True,
        "bq_merge_procedure": "SPM_CA.sp_Merge_working_shift_detail"
    },        
    {
        "queue_name": "spm.item-whs.airflow",
        "table_name": "item_whs",
        "gcs_path": "raw/SPM_CA",
        "batch_size": 500,
        "upload_to_bq": True,
        "bq_landing_table": "SPM_CA.item_whs",
        "bq_write_disposition": "WRITE_APPEND",
        "upload_to_bq_merge": True,
        "bq_merge_procedure": "SPM_CA.sp_Merge_item_whs"
    },
]

# --- 15-Minute Schedule Queues ---
# This list will ONLY be checked by the poller on 15-minute intervals
# (e.g., :00, :15, :30, :45)
QUEUES_CONFIG_15_MIN = [
    {
        "queue_name": "spm.projet-e.airflow",
        "table_name": "projet_e",
        "gcs_path": "raw/SPM_CA",
        "batch_size": 500
    },
    {
        "queue_name": "spm.ess-tranx.airflow",
        "table_name": "ess_tranx",
        "gcs_path": "raw/SPM_CA",
        "batch_size": 500
    },
    {
        "queue_name": "spm.application_transfer.airflow",
        "table_name": "application_transfer",
        "gcs_path": "raw/SPM_GDM",
        "batch_size": 500,
        "upload_to_bq": True,
        "bq_landing_table": "SPM_GDM.application_transfer",
        "bq_write_disposition": "WRITE_APPEND",
        "upload_to_bq_merge": True,
        "bq_merge_procedure": "SPM_GDM.sp_Merge_application_transfer"
    },    
    {
        "queue_name": "spm.qc_quotation_product.airflow",
        "table_name": "qc_quotation_product",
        "gcs_path": "raw/SPM_CA",
        "batch_size": 500
    },    
    {
        "queue_name": "spm.data_name.airflow",
        "table_name": "data_name",
        "gcs_path": "raw/SPM_GDM",
        "batch_size": 500,
        "upload_to_bq": True,
        "bq_landing_table": "SPM_GDM.data_name",
        "bq_write_disposition": "WRITE_APPEND",
        "upload_to_bq_merge": True,
        "bq_merge_procedure": "SPM_GDM.sp_Merge_data_name"
    },
    {
        "queue_name": "spm.dck_wa_a.airflow",
        "table_name": "dck_wa_a",
        "gcs_path": "raw/SPM_CA",
        "batch_size": 500,
        "upload_to_bq": True,
        "bq_landing_table": "SPM_CA.dck_wa_a",
        "bq_write_disposition": "WRITE_APPEND"
    },
    {
        "queue_name": "spm.item_tech.airflow",
        "table_name": "item_tech",
        "gcs_path": "raw/SPM_CA",
        "batch_size": 500,
        "upload_to_bq": True,
        "bq_landing_table": "SPM_CA.item_tech",
        "bq_write_disposition": "WRITE_APPEND",
        "upload_to_bq_merge": True,
        "bq_merge_procedure": "SPM_CA.sp_Merge_item_tech"
    }
]

# --- HOURLY Schedule Queues ---
# This list will be checked by the poller every hour.
QUEUES_CONFIG_HOURLY = [
    {
        "queue_name": "spm.projet_l.airflow",
        "table_name": "projet_l",
        "gcs_path": "raw/SPM_CA",
        "batch_size": 500
    },
    {
        "queue_name": "spm.people.airflow",
        "table_name": "people",
        "gcs_path": "raw/SPM_GDM",
        "batch_size": 500,
        "upload_to_bq": True,
        "bq_landing_table": "SPM_GDM.people",
        "bq_write_disposition": "WRITE_APPEND",
        "upload_to_bq_merge": True,
        "bq_merge_procedure": "SPM_GDM.sp_Merge_people"
    }
]

# --- Daily Schedule Queues ---
# This list will be checked by the poller once per day at 11 AM UTC.
# 11 AM UTC is 6 AM EDT
QUEUES_CONFIG_DAILY = [
    {
        "queue_name": "spm.qc_competitor.airflow",
        "table_name": "qc_competitor",
        "gcs_path": "raw/SPM_CA",
        "batch_size": 500
    },
    {
        "queue_name": "spm.in_control.airflow",
        "table_name": "in_control",
        "gcs_path": "raw/SPM_CA",
        "batch_size": 500
    },
    {
        "queue_name": "spm.ess_trans.airflow",
        "table_name": "ess_trans",
        "gcs_path": "raw/SPM_CA",
        "batch_size": 500
    },
    {
        "queue_name": "spm.projetx_l.airflow",
        "table_name": "projetx_l",
        "gcs_path": "raw/SPM_CA",
        "batch_size": 500
    },
    {
        "queue_name": "spm.qc_branch_office.airflow",
        "table_name": "qc_branch_office",
        "gcs_path": "raw/SPM_GDM",
        "batch_size": 500
    },
    {
        "queue_name": "spm.ess_line.airflow",
        "table_name": "ess_line",
        "gcs_path": "raw/SPM_CA",
        "batch_size": 500
    },
    {
        "queue_name": "spm.projetx_g.airflow",
        "table_name": "projetx_g",
        "gcs_path": "raw/SPM_CA",
        "batch_size": 500
    },
    {
        "queue_name": "spm.qc_office.airflow",
        "table_name": "qc_office",
        "gcs_path": "raw/SPM_GDM",
        "batch_size": 500
    }, 
    {
        "queue_name": "spm.customer_type.airflow",
        "table_name": "customer_type",
        "gcs_path": "raw/SPM_GDM",
        "batch_size": 500,
        "upload_to_bq": True,
        "bq_landing_table": "SPM_GDM.customer_type",
        "bq_write_disposition": "WRITE_APPEND",
        "upload_to_bq_merge": True,
        "bq_merge_procedure": "SPM_GDM.sp_Merge_customer_type"
    },
    {
        "queue_name": "spm.project_event_sales_group.airflow",
        "table_name": "project_event_sales_group",
        "gcs_path": "raw/SPM_CA",
        "batch_size": 500,
        "upload_to_bq": True,
        "bq_landing_table": "SPM_CA.project_event_sales_group",
        "bq_write_disposition": "WRITE_APPEND",
        "upload_to_bq_merge": True,
        "bq_merge_procedure": "SPM_CA.sp_Merge_project_event_sales_group"
    }
]