import pendulum
from airflow.decorators import dag, task
from airflow.operators.trigger_dagrun import TriggerDagRunOperator
from airflow.models.dag import DagModel
import logging
from hooks.api.rabbitmq_hook import RabbitMQHook
from Systems.RabbitMQ.SPM.configurations.rabbitmq_config import GLOBAL_CONFIG, QUEUES_CONFIG_5_MIN, QUEUES_CONFIG_15_MIN, QUEUES_CONFIG_HOURLY, QUEUES_CONFIG_DAILY
from datetime import datetime

local_tz = pendulum.timezone("America/Toronto")

def _create_master_poller_dag(dag_id: str, schedule: str, queue_configs: list[dict]):
    """
    Dynamically creates a Master Poller DAG for a specific schedule.

    :param dag_id: The unique ID for the generated DAG.
    :param schedule: The cron schedule for the DAG.
    :param queue_configs: The list of queue configurations to poll.
    """
    @dag(
        dag_id=dag_id,
        start_date=datetime(2025, 1, 1, tzinfo=local_tz),
        schedule=schedule,
        catchup=False,
        tags=["rabbitmq", "master", "spm", "progress"],
        max_active_runs=1,
        default_args={"executor": "CeleryExecutor"}
    )
    def master_poller_dag():
        """
        Master Poller DAG: Checks RabbitMQ queues and triggers the corresponding
        processing DAG if messages are present.
        """
        @task
        def find_queues_with_messages() -> list[str]:
            """
            Connects to RabbitMQ, checks each queue for messages, and returns
            a list of DAG IDs to be triggered.
            """
            conn_id = GLOBAL_CONFIG.get("rabbitmq_conn_id")
            hook = RabbitMQHook(conn_id=conn_id)
            dags_to_trigger = []

            try:
                for q_conf in queue_configs:
                    queue_name = q_conf.get("queue_name")
                    if hook.get_message_count(queue_name) > 0:
                        table_name = q_conf.get("table_name")
                        dag_id_to_trigger = f"spm.stream.{table_name}".replace("-", "_").lower() 
                        
                        # Check if the DAG is paused in the Airflow UI
                        dag_model = DagModel.get_dagmodel(dag_id_to_trigger)
                        if dag_model and dag_model.is_paused:
                            logging.info(f"DAG '{dag_id_to_trigger}' is paused. Skipping trigger.")
                        else:
                            dags_to_trigger.append(dag_id_to_trigger)
            finally:
                hook.close()

            return dags_to_trigger

        trigger_dags = TriggerDagRunOperator.partial(task_id="trigger_worker_dags").expand(trigger_dag_id=find_queues_with_messages())
        trigger_dags.map_index_template = "{{ task.trigger_dag_id }}"

    return master_poller_dag()

# Create a master poller for each schedule configuration
_create_master_poller_dag("spm.master.5min", "*/5 * * * *", QUEUES_CONFIG_5_MIN)
_create_master_poller_dag("spm.master.15min", "*/15 * * * *", QUEUES_CONFIG_15_MIN)
_create_master_poller_dag("spm.master.hourly", "0 * * * *", QUEUES_CONFIG_HOURLY)
_create_master_poller_dag("spm.master.daily", "0 6 * * *", QUEUES_CONFIG_DAILY)