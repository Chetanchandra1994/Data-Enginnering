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
    dag_id='iris.stream.impacts',
    start_date=datetime(2025, 1, 1, tzinfo=local_tz),
    schedule='0 5 * * *',
    catchup=False,
    max_active_runs=1,
    tags=['apigee', 'iris','stream', 'gcs', 'bigquery'],
)
def get_data_dag():

    def get_date_filters(context):
        """Helper to calculate the 3-day sliding window."""
        end_dt = context['data_interval_end']
        start_dt = end_dt - timedelta(days=3)
        return start_dt.strftime('%m/%d/%Y'), end_dt.strftime('%m/%d/%Y')

    @task
    def execute_impacts_extraction(**context):
        start_str, end_str = get_date_filters(context)
        
        table = "/IMS/Impacts"
        folder_Id = 0
        fields = ""
        filter = f"(LocalDate &gt; #{start_str}# AND LocalDate &lt; #{end_str}#)"
        csv_separator=2
        format_options=25
        format_type=3
        export_options=3       

        payload = textwrap.dedent(f"""<soapenv:Body>
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


        op = ExtractionOperator(
            task_id="extract_impacts",
            source=ApigeeIrisSourceConnector(
                conn_id='apigee',
                endpoint=Variable.get("IRIS_URL_PATH"),
                method='POST',
                payload=payload,
                skip_if_empty=True
            ),
            targets=[
                GCSTargetConnector(conn_id='gcs-bucket-project', table_name='Impacts', gcs_path='raw/Iris'),
                BigQueryTargetConnector(conn_id='bigquery-edl-landing', bq_landing_table='Iris.Impacts')
            ]
        )
        return op.execute(context=context)

    execute_impacts_extraction()

get_data_dag()