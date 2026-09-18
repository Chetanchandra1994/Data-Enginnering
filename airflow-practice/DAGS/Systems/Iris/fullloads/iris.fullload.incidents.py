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
    dag_id='iris.fullload.incidents',
    start_date=datetime(2018, 1, 1, tzinfo=local_tz),
    schedule='@monthly',
    catchup=True,
    tags=['apigee', 'iris','fullload', 'gcs', 'bigquery'],
    max_active_runs=1,
)
def get_data_dag():

    @task
    def execute_incidents_extraction(**context):
        """
        Calculates dates using Python and executes the pipeline.
        This ensures the SOAP filter receives real date strings, not Jinja macros.
        """
        start_dt = context['data_interval_start']
        end_dt = context['data_interval_end']
        start_str = start_dt.strftime('%m/%d/%Y')
        end_str = end_dt.strftime('%m/%d/%Y')
        table = "/IMS/Incidents"
        folder_Id = 0
        fields="Entity|Name|Type|Reference|LagTime|Classification|Confidentiality|HigherPotentialSeverityImpact|HLVE|HOLocation|CS_Department|SpecificArea|PersonReportingEvent|Report|ImpactsCount|HumanImpactsCount|CS_Evidnces|APIcon|WorkflowImage|Creator|NotificationCount|NovCount|InvestigationsCount|StatementCount|EvidenceCount|CausesCount|UR_RAPObservationDate|UR_HumanConsq|UR_CurrentMeansOfControl|UR_Hierarchy|UR_LegalRequirements|UR_PS|UR_PO|UR_FE|UR_EvaluationResult|UR_RiskLevel|UR_PSafter|UR_POafter|UR_FEafter|UR_EvaluationResultAfter|UR_ResidualRisk|MapsData|Id|EMSEventId|CS_RobustAP|ApprovalDate|LevelNo|Owner|UnderInvests|LocalDate|LocalReportDate|Timezone|Date|ReportDate|Comments|DescribeCF|LessonsLearned|ELoss|RealCost|ERD|Estimated|NumberOfRRD|DaysLost|EstimOpeDaysLost|RealOpeDaysLost|CS_ProjectName|Severity"
        filter = f"(CreatedOn >= #{start_str}# AND CreatedOn &lt; #{end_str}#)"
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
            table_name='Incidents',
            gcs_path='raw/Iris'
        )

        bigquery_target = BigQueryTargetConnector(
                conn_id='bigquery-edl-landing',
                bq_landing_table='Iris.Incidents'
        )

        # 4. Orchestrate via the ExtractionOperator
        op = ExtractionOperator(
            task_id="export_incidents",
            source=apigee_source,
            targets=[gcs_target,bigquery_target]
        )
        
        return op.execute(context=context)

    # Execute the pipeline task
    execute_incidents_extraction()

get_data_dag()