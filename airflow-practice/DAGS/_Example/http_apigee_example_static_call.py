from __future__ import annotations
from airflow.decorators import dag, task
from datetime import datetime, timedelta

from operators.extraction import ExtractionOperator
from connectors.api.source.apigee_source_connector import ApigeeSourceConnector
from connectors.cloud.target.gcs_target_connector import GCSTargetConnector

@dag(
    dag_id='static_http_apigee_dag',
    start_date=datetime(2025, 1, 1),
    schedule=None,
    catchup=False
)
def static_production_planning_dag():

    @task
    def run_api_extraction(**context):
        entity = '1C1'
        equipment_id = 21
        
        # Pull the date from the context/macros manually or use Python
        execution_date = context['ds']
        target_date = (datetime.strptime(execution_date, '%Y-%m-%d') + timedelta(days=1)).strftime('%Y-%m-%d')

        # 2. Define the Source (Resolved at Runtime)
        apigee_source = ApigeeSourceConnector(
            conn_id='apigee',
            endpoint=f"/Test/Manuf/Sche_Prod/Line_Plan/ppbl/v1/Schedule/v1/Entity/{entity}/ProductionLine/{equipment_id}",
            method='GET',
            payload={'formattedDate': target_date} 
        )

        # 3. Define the Target
        gcs_target = GCSTargetConnector(
            conn_id='gcs-bucket-project',
            table_name='Schedule',
            gcs_path='raw/local_test'
        )

        # 4. Execute via Operator
        op = ExtractionOperator(
            task_id=f'call_api_{entity}',
            source=apigee_source,
            targets=[gcs_target]
        )
        return op.execute(context=context)

    run_api_extraction()

static_production_planning_dag()