from __future__ import annotations
from datetime import datetime, timedelta
from airflow.decorators import dag, task
import pendulum
import textwrap
from operators.extraction import ExtractionOperator
from connectors.api.source.apigee_custom.apigee_iris_source_connector import ApigeeIrisSourceConnector
from connectors.cloud.target.gcs_target_connector import GCSTargetConnector
from connectors.cloud.target.bigquery_target_connector import BigQueryTargetConnector
from airflow.models import Variable

local_tz = pendulum.timezone("America/Toronto")

@dag(
    dag_id='iris.stream.entities',
    start_date=datetime(2025, 1, 1, tzinfo=local_tz),
    schedule='0 5 * * *',
    catchup=False,
    tags=['apigee', 'iris','stream', 'gcs', 'bigquery'],
)
def get_data_dag():

    @task
    def execute_entities_extraction(**context):
        """
        Calculates dates using Python and executes the pipeline.
        This ensures the SOAP filter receives real date strings, not Jinja macros.
        """

        table = "/sd/entities"
        folder_Id = 0
        fields=""
        filter = ""
        csv_separator=2
        format_options=25
        format_type=3
        export_options=8

        soap_payload = textwrap.dedent(f"""<soapenv:Body>
                                            <enab:ExportData soapenv:encodingStyle="http://schemas.xmlsoap.org/soap/encoding/">
                                                <Table xsi:type="xsd:string">{table}</Table>
                                                <FolderId xsi:type="xsd:int">{folder_Id}</FolderId>
                                                <Fields xsi:type="xsd:string">{fields}</Fields>
                                                <Filter xsi:type="xsd:string">{filter}</Filter>
                                                <CSVSeparator xsi:type="xsd:int">{csv_separator}</CSVSeparator>
                                                <FormatOptions xsi:type="xsd:int">{format_options}</FormatOptions>
                                                <FormatType xsi:type="xsd:int">{format_type}</FormatType>
                                                <ExportOptions xsi:type="xsd:int">{export_options}</ExportOptions>
                                            </enab:ExportData>
                                        </soapenv:Body>""").strip()

        # 2. Define the SOAP Source with the proper filter
        apigee_source = ApigeeIrisSourceConnector(
            conn_id='apigee',
            endpoint=Variable.get("IRIS_URL_PATH"),
            method='POST',
            payload=soap_payload,
            skip_if_empty=True,
            empty_check_key='records'
        )
        # 3. Define the Target
        gcs_target = GCSTargetConnector(
            conn_id='gcs-bucket-project',
            table_name='Entities',
            gcs_path='raw/Iris'
        )

        bigquery_target = BigQueryTargetConnector(
                conn_id='bigquery-edl-landing',
                bq_landing_table='Iris.Entities'
        )

        # 4. Orchestrate via the ExtractionOperator
        op = ExtractionOperator(
            task_id="extract_entities",
            source=apigee_source,
            targets=[gcs_target,bigquery_target]
        )
        
        return op.execute(context=context)

    # Execute the pipeline task
    execute_entities_extraction()

get_data_dag()