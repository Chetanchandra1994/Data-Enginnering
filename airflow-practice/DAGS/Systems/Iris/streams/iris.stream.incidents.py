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
    dag_id='iris.stream.incidents',
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
    def execute_incidents_extraction(**context):
        start_str, end_str = get_date_filters(context)
        
        table = "/IMS/Incidents"
        folder_Id = 0
        fields = "Entity|Name|Type|Reference|LagTime|Classification|Confidentiality|HigherPotentialSeverityImpact|HLVE|HOLocation|CS_Department|SpecificArea|PersonReportingEvent|Report|ImpactsCount|HumanImpactsCount|CS_Evidnces|APIcon|WorkflowImage|Creator|NotificationCount|NovCount|InvestigationsCount|StatementCount|EvidenceCount|CausesCount|UR_RAPObservationDate|UR_HumanConsq|UR_CurrentMeansOfControl|UR_Hierarchy|UR_LegalRequirements|UR_PS|UR_PO|UR_FE|UR_EvaluationResult|UR_RiskLevel|UR_PSafter|UR_POafter|UR_FEafter|UR_EvaluationResultAfter|UR_ResidualRisk|MapsData|Id|EMSEventId|CS_RobustAP|ApprovalDate|LevelNo|Owner|UnderInvests|LocalDate|LocalReportDate|Timezone|Date|ReportDate|Comments|DescribeCF|LessonsLearned|ELoss|RealCost|ERD|Estimated|NumberOfRRD|DaysLost|EstimOpeDaysLost|RealOpeDaysLost|CS_ProjectName|Severity"
        filter = filter = f"(CreatedOn >= #{start_str}# AND CreatedOn &lt; #{end_str}#) OR (ModifiedAt >= #{start_str}# AND ModifiedAt &lt; #{end_str}#)"
        csv_separator=2
        format_options=25
        format_type=3
        export_options=8        

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
            task_id="extract_incidents",
            source=ApigeeIrisSourceConnector(
                conn_id='apigee',
                endpoint=Variable.get("IRIS_URL_PATH"),
                method='POST',
                payload=payload,
                skip_if_empty=True
            ),
            targets=[
                GCSTargetConnector(conn_id='gcs-bucket-project', table_name='Incidents', gcs_path='raw/Iris'),
                BigQueryTargetConnector(conn_id='bigquery-edl-landing', bq_landing_table='Iris.Incidents')
            ]
        )
        return op.execute(context=context)

    execute_incidents_extraction()

get_data_dag()