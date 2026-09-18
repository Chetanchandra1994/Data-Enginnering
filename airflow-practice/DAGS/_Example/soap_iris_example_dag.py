from __future__ import annotations
from datetime import datetime, timedelta
from airflow.decorators import dag, task
import pendulum
import textwrap

from operators.extraction import ExtractionOperator
from connectors.api.source.apigee_custom.apigee_iris_source_connector import ApigeeIrisSourceConnector
from connectors.cloud.target.gcs_target_connector import GCSTargetConnector

@dag(
    dag_id='iris_soap_dag',
    start_date=pendulum.datetime(2025, 1, 1, tz="UTC"),
    schedule=None,
    catchup=False,
    tags=['soap', 'iris'],
)
def get_data_dag():

    @task
    def execute_soap_extraction(**context):
        """
        Calculates dates using Python and executes the pipeline.
        This ensures the SOAP filter receives real date strings, not Jinja macros.
        """
        # 1. Calculate Dates using Python (Standard for TaskFlow)
        execution_date = context['logical_date']
        today_str = execution_date.strftime('%m/%d/%Y')
        three_days_ago_str = (execution_date - timedelta(days=3)).strftime('%m/%d/%Y')

        table = "/IMS/Incidents"
        folder_Id = 0
        #Empty for all
        fields=""
        filter = f"(CreatedOn >= #{three_days_ago_str}# AND CreatedOn &lt; #{today_str}#) OR (ModifiedAt >= #{three_days_ago_str}# AND ModifiedAt &lt; #{today_str}#)"
        csv_separtor=2
        format_options=25
        format_type=3
        export_options=8

        soap_payload = textwrap.dedent(f"""<soapenv:Body>
                                            <enab:ExportData soapenv:encodingStyle="http://schemas.xmlsoap.org/soap/encoding/">
                                                <Table xsi:type="xsd:string">{table}</Table>
                                                <FolderId xsi:type="xsd:int">{folder_Id}</FolderId>
                                                <Fields xsi:type="xsd:string">{fields}</Fields>
                                                <Filter xsi:type="xsd:string">{filter}</Filter>
                                                <CSVSeparator xsi:type="xsd:int">{csv_separtor}</CSVSeparator>
                                                <FormatOptions xsi:type="xsd:int">{format_options}</FormatOptions>
                                                <FormatType xsi:type="xsd:int">{format_type}</FormatType>
                                                <ExportOptions xsi:type="xsd:int">{export_options}</ExportOptions>
                                            </enab:ExportData>
                                        </soapenv:Body>""").strip()

        # 2. Define the SOAP Source with the proper filter
        apigee_source = ApigeeIrisSourceConnector(
            conn_id='apigee',
            endpoint="/test/iris/go.aspx?u=wsvce",
            method='POST',
            payload=soap_payload,
            skip_if_empty=True,
            empty_check_key='records'
        )
        # 3. Define the Target
        gcs_target = GCSTargetConnector(
            conn_id='gcs-bucket-project',
            table_name='IrisIncidents',
            gcs_path='raw/local_test'
        )

        # 4. Orchestrate via the ExtractionOperator
        # We manually call .execute() to maintain the polymorphic interface
        op = ExtractionOperator(
            task_id="export_data_from_iris",
            source=apigee_source,
            targets=[gcs_target]
        )
        
        return op.execute(context=context)

    # Execute the pipeline task
    execute_soap_extraction()

get_data_dag()