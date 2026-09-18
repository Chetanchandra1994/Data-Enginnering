import orjson
from airflow.models.baseoperator import BaseOperator
from airflow.api.common.trigger_dag import trigger_dag
from operators.extraction import ExtractionOperator

class MessageListenOperator(BaseOperator):
    """
    Master Operator for listening to message triggers and processing via ExtractionOperator.
    """
    def __init__(self, message_source, source, targets, poke_interval=30,trigger_dag_on_success=False, **kwargs):
        super().__init__(**kwargs)
        self.message_source = message_source  # The trigger SourceConnector (e.g., RabbitMQSourceConnector)
        self.source = source                  # The  source API Connector (e.g., ApigeeSourceConnector)
        self.targets = targets                # List of target connectors
        self.poke_interval = poke_interval
        self.trigger_dag_on_success = trigger_dag_on_success

    def get_trigger(self):
        """Must be implemented by child classes to return the specific Trigger."""
        raise NotImplementedError("Child classes must implement get_trigger()")

    def execute(self, context, event=None):
        # 1. DEFER PHASE
        if event is None:
            self.defer(
                trigger=self.get_trigger(),
                method_name="execute"
            )

        # 2. WORKER PHASE
        if event["status"] == "success":
            with self.message_source as src:
                if src.extract(context):
                    # Standardized data retrieval
                    raw_bytes = src.get_data()
                    trigger_msg = orjson.loads(raw_bytes.splitlines()[0])
                    
                    # Mapping for Jinja and API Source
                    context['params']['mq_data'] = trigger_msg
                    self.source.triggerer_data = trigger_msg
                    
                    # Render templates for endpoint and payload
                    self.source.endpoint = self.render_template(self.source.endpoint, context)
                    if getattr(self.source, 'payload', None):
                        self.source.payload = self.render_template(self.source.payload, context)

                    pipeline = ExtractionOperator(
                        task_id=self.task_id,
                        source=self.source,
                        targets=self.targets
                    )
                    
                    try:
                        result = pipeline.execute(context=context)
                        src.on_pipeline_success(context=context)
                        return result
                    except Exception as e:
                        src.on_pipeline_failure(e)
                        raise e
                    finally:
                        if self.trigger_dag_on_success:
                             self.log.info(f"Self-trigger enabled. Restarting DAG: {context['dag'].dag_id}")
                             trigger_dag(dag_id=context['dag'].dag_id)