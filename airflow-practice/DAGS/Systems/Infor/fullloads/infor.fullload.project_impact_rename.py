from __future__ import annotations
from datetime import datetime
from airflow.decorators import dag, task
import pendulum
from operators.extraction import ExtractionOperator
from connectors.api.source.apigee_custom.apigee_infor_source_connector import ApigeeInforSourceConnector
from connectors.cloud.target.gcs_target_connector import GCSTargetConnector
from airflow.models import Variable
from connectors.cloud.target.bigquery_target_connector import BigQueryTargetConnector

local_tz = pendulum.timezone("America/Toronto")

@dag(
    dag_id='infor.fullload.project_impact_rename',
    start_date=datetime(2025, 1, 1, tzinfo=local_tz),
    schedule=None,
    catchup=False,
    tags=['infor','fullload', 'gcs', 'bigquery', 'apigee']
)
def get_data_dag():
    @task
    def extract_project_impact_data(**context):
        # 1. Define the Source Connector
        # This connector sends a SQL query to a custom Apigee endpoint for Infor.
        apigee_source = ApigeeInforSourceConnector(
            conn_id='apigee',
            endpoint=Variable.get("INFOR_URL_PATH"),
            method='POST',
            table="LN_PROJECT_IMPACT"
        )

        # 2. Define the Target Connector
        # This connector will save the extracted data to a GCS bucket.
        gcs_target = GCSTargetConnector(
            conn_id='gcs-bucket-project',
            table_name='project_impact',
            gcs_path='raw/Infor'
        )

        bq_target = BigQueryTargetConnector(
            conn_id='bigquery-fast-track',
            bq_landing_table=f'{Variable.get("INFOR_BIGQUERY_DATASET")}.ImpactByLocation_Transient',
            bq_merge_procedure=f'{Variable.get("INFOR_BIGQUERY_DATASET")}.sp_Merge_ImpactByLocation_Transient'
        )

        # 3. Instantiate and run the ExtractionOperator
        # The operator manages the data flow from the source to the target(s).
        op = ExtractionOperator(
            task_id="extract_project_impact",
            source=apigee_source,
            targets=[gcs_target, bq_target]
        )
        
        return op.execute(context=context)

    # Execute the pipeline task
    extract_project_impact_data()

get_data_dag()