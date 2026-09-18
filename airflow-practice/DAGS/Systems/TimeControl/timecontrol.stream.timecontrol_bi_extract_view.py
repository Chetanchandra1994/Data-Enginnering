from __future__ import annotations
from airflow.decorators import dag, task
from datetime import datetime
import pendulum

# --- Polymorphic Imports ---
from operators.extraction import ExtractionOperator
from connectors.odbc.source.mssql_source_connector import MssqlSourceConnector
from connectors.cloud.target.snowflake_target_connector import SnowflakeTargetConnector

@dag(
    dag_id='timecontrol.stream.timecontrol_bi_extract_view',
    start_date=datetime(2025, 1, 1),
    schedule_interval="0 7 * * *",
    catchup=False,
    tags=['timecontrol', 'stream', 'snowflake', 'mssql', 'jdbc'],
    doc_md="""
    ### TimeControl BI Report Export (Polymorphic Version)
    Separates HTTP extraction logic from Snowflake storage logic while maintaining 
    stateful XCom tracking for incremental loads.
    """
)
def export_report():

    # 2. Define the Source (ODBC MSSQL)
    timecontrol_source = MssqlSourceConnector (
        conn_id='timecontrol',
        sql=f"SELECT inserted_tstmp,PSH_KEY,PSL_KEY,PSD_KEY,emp_code,emp_first,emp_last,emp_name,emp_fld1,emp_fld2,emp_fld3,emp_fld4,emp_fld5,emp_fld6,emp_fld7,emp_fld8,emp_fld9,emp_fld10,emp_fld11,emp_fld12,emp_fld15,psh_tstmp,Psh_psdate,Psh_pedate,psl_tstmp,psl_fld1,psl_fld2,psl_fld3,PSL_RAT_CD,Psd_date,psd_wedate,Hours,PSD_SUNDAY,PSD_MONDAY,PSD_TUESDAY,PSD_WEDNESDAY,PSD_THURSDAY,PSD_FRIDAY,PSD_SATURDAY,prj_name,PRJ_DESC,prj_fld2,CAC_DESC,prj_fld5,prj_fld6,chh_code,chh_desc,chh_fld3 FROM Canam.TimeControl_BI_Extract_View",
        query_mode='delta',
        delta_column='inserted_tstmp',
        xcom_key='max_inserted_tstmp'
    )
    # 3. Define the Target (Snowflake)
    # Encapsulates audit schema metadata and bulk INSERT logic
    snowflake_target = SnowflakeTargetConnector(
        conn_id='snowflake-corporate',
        target_schema='timecontrol',
        table_name='timesheet'
    )

    # 4. Orchestrate
    # Generic operator manages the handoff between source and target
    ExtractionOperator(
        task_id='call_api_for_499',
        source=timecontrol_source,
        targets=[snowflake_target]
    )


export_report_dag = export_report()