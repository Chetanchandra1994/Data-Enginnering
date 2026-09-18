from airflow import DAG
from airflow.models import Variable
from datetime import datetime

from operators.extraction import ExtractionOperator
from connectors.jdbc.source.mssql_source_connector import MssqlSourceConnector
from connectors.cloud.target.gcs_target_connector import GCSTargetConnector
from connectors.cloud.target.bigquery_target_connector import BigQueryTargetConnector

with DAG(
    dag_id='cmd.fullload.vtbx_cmd_project',
    start_date=datetime(2026, 1, 1),
    schedule_interval="0 11 * * *",
    catchup=False,
    tags=['jdbc', 'mssql','cmd', 'fullload', 'gcs', 'bigquery'] 
) as dag:
        
    # 2. Define the Source (MSSQL)
    mssql_source = MssqlSourceConnector(
        conn_id='cmd',
        database='DWIntegrationProd',
        sql=f"SELECT CustomFamilyEnglish, CustomGroupEnglish, DateBegin, DateEnd, EntityCode, ProductionWeekBeginDt, ProjectInactiveDate, QuotedDirectTime, QuotedWeightLbs, ReqIssuedToProducedEstimatedTime, ReqIssuedToProducedWeightLbs, yearweekSPM,CONVERT(varchar, GETUTCDATE(), 121) + '000 UTC' AS CreatedDate FROM DWIntegrationProd.Integration.VTBX_CMD_Project WHERE yearweekSPM > (YEAR(GETDATE())-1) * 100 AND DateEnd = '9999-12-31'",
        query_mode='default'
    )

    # 3. Orchestrate with ExtractionOperator
    ExtractionOperator(
        task_id=f'extract_VTBX_CMD_Project',
        source=mssql_source,
        targets=[
            GCSTargetConnector(
                conn_id='gcs-bucket-project',
                gcs_path='raw/CMD',
                table_name='VTBX_CMD_Project'
            ),
            BigQueryTargetConnector(
                conn_id='bigquery-edl-landing',
                bq_landing_table='DW_SQLServer_Integration.VTBX_CMD_Project',
                bq_merge_procedure='DW_SQLServer_Integration.sp_sync_VTBX_CMD_Project'
            )
        ]
    )