from __future__ import annotations
from airflow.decorators import dag, task
from datetime import datetime, timedelta
import pendulum

from operators.extraction import ExtractionOperator
from connectors.api.source.apigee_source_connector import ApigeeSourceConnector
from connectors.cloud.target.gcs_target_connector import GCSTargetConnector
#from utils.deprecated.gcs_utils import query_bigquery_to_dataframe

@dag(
    dag_id='dynamic_http_apigee_dag',
    start_date=pendulum.datetime(2025, 1, 1, tz="UTC"),
    schedule=None,
    catchup=False,
    tags=['http', 'dynamic', 'polymorphic'],
)
def production_planning_dynamic():

    @task
    def query_schedules_from_bigquery() -> list[dict]:
        """Queries BigQuery for production schedules."""
        conn_id = "gcs-bucket-project"
        sql_query = """
            SELECT
                DATE(DATETIME(TIMESTAMP(Start_utc,'UTC') ,ENT.timezone)) Date,
                Entity,
                equipment_id,
                DPW.Working_shift_detail_uuid
            FROM
                `edl-prod-257318.dw_ProductionManagement.dim_production_workingshift` DPW 
            JOIN
                `edl-prod-257318.Common.entity` ENT ON DPW.Entity = ENT.entity_code
            JOIN
                `edl-prod-raw.SPM_CA.working_shift_detail` WSD ON DPW.Working_shift_detail_uuid = WSD.working_shift_detail_uuid
            WHERE
                DATE(start_utc) = CURRENT_DATE('UTC') AND
                start_utc - INTERVAL 1 HOUR < CURRENT_DATETIME('UTC') AND
                Start_utc > CURRENT_DATETIME('UTC') AND
                (
                    (UPPER(Entity) = '1C1' AND equipment_id IN(21,22,23,24,25,31,32) AND equipment_type = 'Shop')      
                    OR
                    (UPPER(Entity) = '1C4' AND equipment_id IN(11,12,13,14,15) AND equipment_type = 'Shop')
                    OR
                    (UPPER(Entity) = '1C5' AND equipment_id IN(11,12,13,14) AND equipment_type = 'Shop')
                )
            ORDER BY Entity, equipment_id
        """
        df = query_bigquery_to_dataframe(sql_query=sql_query, conn_id=conn_id)
        return df.to_dict('records')

    @task
    def execute_extraction_pipeline(record: dict, **context): # Capture context with **kwargs
        """
        Instantiates connectors and executes the ExtractionOperator logic.
        This bypasses XCom serialization issues by keeping objects inside the task.
        """
        entity = record['Entity']
        equipment_id = record['equipment_id']
        date_val = record['Date']
        formatted_date = (date_val + timedelta(days=1)).strftime('%Y-%m-%d')
        shift_uuid = record['Working_shift_detail_uuid']
        
        # Instantiate objects
        source_obj = ApigeeSourceConnector(
            conn_id='apigee',
            method='GET',
            endpoint=f"/v1/Entity/{entity}/ProductionLine/{equipment_id}/Date/{formatted_date}/Shift/{shift_uuid}",
            payload={'formattedDate': formatted_date},
            skip_if_empty=True
        )

        target_obj = GCSTargetConnector(
            conn_id='gcs-bucket-project',
            table_name='Schedule',
            gcs_path='raw/local_test'
        )

        # Use the ExtractionOperator as a logic container
        op = ExtractionOperator(
            task_id="dynamic_api_call",
            source=source_obj,
            targets=[target_obj]
        )
        
        # Pass the real Airflow context for XComArg resolution
        return op.execute(context=context)

    # DAG Workflow
    raw_schedules = query_schedules_from_bigquery()
    execute_extraction_pipeline.expand(record=raw_schedules)

production_planning_dynamic()