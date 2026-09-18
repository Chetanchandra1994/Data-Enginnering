from airflow import DAG
from airflow.models import Variable
from datetime import datetime

from operators.extraction import ExtractionOperator
from connectors.jdbc.source.mssql_source_connector import MssqlSourceConnector
from connectors.cloud.target.gcs_target_connector import GCSTargetConnector
from connectors.cloud.target.bigquery_target_connector import BigQueryTargetConnector

with DAG(
    dag_id='cmd.fullload.satrequisitionheader',
    start_date=datetime(2026, 1, 1),
    schedule_interval="0 11 * * *",
    catchup=False,
    tags=['jdbc', 'mssql','cmd', 'fullload', 'gcs', 'bigquery'] 
) as dag:
        
    # 2. Define the Source (MSSQL)
    mssql_source = MssqlSourceConnector(
        conn_id='cmd',
        database='DWIntegrationProd',
        sql=f"SELECT CreateDate, DateBeginETL, DateEndETL, DateShop, DeleteDate, EstimatedTimeByReq, IdHubRequisitionHeader, IdSatRequisitionHeader, IssuedToShopDate, NoJobShop, Purge_Method, SourceSystem, TotalProductionTimeByReq,CONVERT(varchar, GETUTCDATE(), 121) + '000 UTC' AS CreatedDate FROM DWIntegrationProd.Integration.SatRequisitionHeader WHERE DateBeginETL > GETDATE() - 7 OR DateEndETL > GETDATE() - 7",
        query_mode='default'
    )

    # 3. Orchestrate with ExtractionOperator
    ExtractionOperator(
        task_id=f'extract_SatRequisitionHeader',
        source=mssql_source,
        targets=[
            GCSTargetConnector(
                conn_id='gcs-bucket-project',
                gcs_path='raw/CMD',
                table_name='SatRequisitionHeader'
            ),
            BigQueryTargetConnector(
                conn_id='bigquery-edl-landing',
                bq_landing_table='DW_SQLServer_Integration.SatRequisitionHeader',
                bq_merge_procedure='DW_SQLServer_Integration.sp_merge_sat_requisition_header'
            )
        ]
    )