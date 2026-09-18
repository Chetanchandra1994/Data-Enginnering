"""
Central configuration file for all Oracle tables to be polled.
This list is imported by the 'oracle_master_poller' DAG.
"""

# Shared configuration values to be applied to all tables
GLOBAL_CONFIG = {
    "bucket_conn_id": "gcs-bucket-project",
    "oracle_conn_id": "oracleebs",
    "bq_conn_id": "bigquery-edl-landing"
}

# --- 5 AM Daily Schedules ---
# This list will be checked by the poller every day at 5 AM
TABLES_CONFIG_5_AM = [
    {
        "table_name": "GL_PERIODS",
        "gcs_path": "raw/OracleEBS",
        "upload_to_bq": True,
        "bq_landing_table": "ORA_PROD.GL_PERIODS",
        "sql": "SELECT * FROM GL.GL_PERIODS",
        "query_mode": "delta",
        "delta_column": "LAST_UPDATE_DATE",
        "upload_to_bq_merge": True,
        "bq_merge_procedure": "ORA_PROD.sp_Merge_GL_PERIODS"
    },
    {
        "table_name": "EMPLOYEE_INCOME_TEMP",
        "gcs_path": "raw/OracleEBS",
        "upload_to_bq": True,
        "bq_landing_table": "ORA_PROD.EMPLOYEE_INCOME_TEMP",
        "sql": "SELECT * FROM ORA_BOOMI.EMPLOYEE_INCOME_TEMP",
        "query_mode": "default"
    },
    {
        "table_name": "HZ_PARTIES",
        "gcs_path": "raw/OracleEBS",
        "sql": "SELECT * FROM AR.HZ_PARTIES",
        "query_mode": "delta",
        "delta_column": "LAST_UPDATE_DATE",
        "upload_to_bq": False,  # Set to True if you want it to flow to BigQuery later
        "xcom_key":"ebs.stream.hz_parties"
    },
	{
        "table_name": "AR_COLLECTORS",
        "gcs_path": "raw/OracleEBS",
        "sql": "SELECT * FROM AR.AR_COLLECTORS",
        "query_mode": "delta",
        "delta_column": "LAST_UPDATE_DATE",
        "upload_to_bq": False,  # Set to True if you want it to flow to BigQuery later
        "xcom_key":"ebs.stream.ar_collectors"
    },
    {
        "table_name": "HZ_CUSTOMER_PROFILES",
        "gcs_path": "raw/OracleEBS",
        "sql": "SELECT * FROM AR.HZ_CUSTOMER_PROFILES",
        "query_mode": "delta",
        "delta_column": "LAST_UPDATE_DATE",
        "upload_to_bq": False,  # Set to True if you want it to flow to BigQuery later
        "xcom_key":"ebs.stream.hz_customer_profiles"
    },
    {
        "table_name": "HZ_CUST_SITE_USES_ALL",
        "gcs_path": "raw/OracleEBS",
        "sql": "SELECT * FROM AR.HZ_CUST_SITE_USES_ALL",
        "query_mode": "delta",
        "delta_column": "LAST_UPDATE_DATE",
        "upload_to_bq": False,  # Set to True if you want it to flow to BigQuery later
        "xcom_key":"ebs.stream.hz_cust_site_uses_all"
    }
]

# --- 6 AM Daily Schedules ---
# This list will be checked by the poller every day at 6 AM
TABLES_CONFIG_6_AM = [
    {
        "table_name": "CM50_PO_SUPPLIER_V",
        "gcs_path": "raw/OracleEBS",
        "sql": "SELECT * FROM APPS.CM50_PO_SUPPLIER_V",
        "query_mode": "delta",
        "delta_column": "POV_LAST_UPDATE_DATE",
        "upload_to_bq": False,  # Set to True if you want it to flow to BigQuery later
        "xcom_key":"ebs.stream.cm50_po_supplier_v_delta"
    },
    {
        "table_name": "FND_FLEX_VALUES",
        "gcs_path": "raw/OracleEBS",
        "sql": "SELECT * FROM APPLSYS.FND_FLEX_VALUES",
        "query_mode": "delta",
        "delta_column": "LAST_UPDATE_DATE",
        "upload_to_bq": False,  # Set to True if you want it to flow to BigQuery later
        "xcom_key":"ebs.stream.fnd_flex_values_delta"
    },
    {
        "table_name": "CM50_PO_SUPPLIER_SITE_V",
        "gcs_path": "raw/OracleEBS",
        "sql": "SELECT * FROM APPS.CM50_PO_SUPPLIER_SITE_V",
        "query_mode": "delta",
        "delta_column": "PVS_LAST_UPDATE_DATE",
        "upload_to_bq": False,  # Set to True if you want it to flow to BigQuery later
        "xcom_key":"ebs.stream.cm50_po_supplier_site_v_delta"
    },
    {
        "table_name": "HZ_PARTY_SITES",
        "gcs_path": "raw/OracleEBS",
        "sql": "SELECT * FROM AR.HZ_PARTY_SITES",
        "query_mode": "delta",
        "delta_column": "LAST_UPDATE_DATE",
        "upload_to_bq": False,  # Set to True if you want it to flow to BigQuery later
        "xcom_key":"ebs.stream.hz_party_sites"
    },
    {
        "table_name": "PA_SEGMENT_VALUE_LOOKUP_SETS",
        "gcs_path": "raw/OracleEBS",
        "sql": "SELECT * FROM PA.PA_SEGMENT_VALUE_LOOKUP_SETS ",
        "query_mode": "delta",
        "delta_column": "LAST_UPDATE_DATE",
        "upload_to_bq": False,  # Set to True if you want it to flow to BigQuery later
        "xcom_key":"ebs.stream.pa_segment_value_lookup_sets"   
    }     
]

## 8AM Schedule

TABLES_CONFIG_8_AM=[
    {
        "table_name": "CM50_AP_INVOICE_PAYMENTS_V",
        "gcs_path": "raw/OracleEBS",
        "sql": "SELECT * FROM APPS.CM50_AP_INVOICE_PAYMENTS_V",
        "query_mode": "delta",
        "delta_column": "APP_LAST_UPDATE_DATE",
        "upload_to_bq": False,  # Set to True if you want it to flow to BigQuery later
        "xcom_key":"ebs.stream.cm50_ap_invoice_payments_v"   
    },
    {
        "table_name": "APPS.CM50_AP_INVOICES_ALL_V",
        "gcs_path": "raw/OracleEBS",
        "sql": "SELECT * FROM APPS.CM50_AP_INVOICES_ALL_V",
        "query_mode": "delta",
        "delta_column": "AIA_LAST_UPDATE_DATE",
        "upload_to_bq": False,  # Set to True if you want it to flow to BigQuery later
        "xcom_key":"ebs.stream.cm50_ap_invoices_all_v",
        "limit":100000 
    }


]

## 12PM Schedule

TABLES_CONFIG_12_PM = [
    {
        "table_name": "FND_FLEX_VALUES_TL",
        "gcs_path": "raw/OracleEBS",
        "sql": "SELECT * FROM APPLSYS.FND_FLEX_VALUES_TL",
        "query_mode": "delta",
        "delta_column": "LAST_UPDATE_DATE",
        "upload_to_bq": False,  # Set to True if you want it to flow to BigQuery later
        "xcom_key":"ebs.stream.fnd_flex_values_tl_delta"
    }    
]

## 10AM Schedule

TABLES_CONFIG_10_AM = [
    {
        "table_name": "PER_ORG_STRUCTURE_ELEMENTS_V",
        "gcs_path": "raw/OracleEBS",
        "sql": "SELECT * FROM APPS.PER_ORG_STRUCTURE_ELEMENTS_V",
        "query_mode": "delta",
        "delta_column": "LAST_UPDATE_DATE",
        "upload_to_bq": False,  # Set to True if you want it to flow to BigQuery later
        "xcom_key":"ebs.stream.per_org_structure_elements_v_delta"
    }
]