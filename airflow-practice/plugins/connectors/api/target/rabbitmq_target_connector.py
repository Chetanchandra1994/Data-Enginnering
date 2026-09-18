import orjson
import pika
from typing import List, Any, Dict
from airflow.exceptions import AirflowSkipException
from connectors.base_connector import TargetConnector
from hooks.api.rabbitmq_hook import RabbitMQHook

class RabbitMQTargetConnector(TargetConnector):
    """
    Target connector for publishing messages to RabbitMQ queues.
    Implements the Target 'save' interface to publish messages in batch.
    Handles queue declaration, message serialization, and property resolution.
    """
    def __init__(
        self,
        conn_id: str,
        queue_name: str,
        exchange: str = '',
        durable_queue: bool = True,
        message_properties: dict | None = None
    ):
        """
        Initialize the RabbitMQ target connector.
        conn_id: Airflow connection ID for RabbitMQ.
        queue_name: Name of the queue to publish to.
        exchange: Exchange to use for publishing.
        durable_queue: Whether the queue should be durable.
        message_properties: Optional message properties (headers, etc.).
        """
        super().__init__(conn_id)
        self.queue_name = queue_name
        self.exchange = exchange
        self.durable_queue = durable_queue
        self.message_properties = message_properties or {}
        self._hook = None

    def __enter__(self):
        """
        Initialize the RabbitMQ hook for publishing.
        """
        self._hook = RabbitMQHook(conn_id=self.connection_id)
        return self

    def save(self, log: Any, data: List[Any], context: Dict[str, Any] = None):
        """
        Publish a batch of messages to the queue after resolving dynamic properties.
        Returns the number of messages published.
        """
        if not data:
            log.info("No data to publish to RabbitMQ.")
            return 0

        # Resolve queue name and properties from XCom context
        resolved_queue = self._resolve_xcom_args(self.queue_name, context)
        resolved_props = self._resolve_xcom_args(self.message_properties, context)

        log.info(f"Publishing {len(data)} messages to queue '{resolved_queue}'")
        
        self._hook.declare_queue(queue_name=resolved_queue, durable=self.durable_queue)
        
        pika_props = None
        if resolved_props:
            pika_props = pika.BasicProperties(**resolved_props)

        published_count = 0
        for msg in data:
            # Auto-serialize dicts or pass raw bytes/strings
            body = msg if isinstance(msg, (str, bytes)) else orjson.dumps(msg)
            
            self._hook.publish(
                exchange=self.exchange,
                routing_key=resolved_queue,
                message_body=body,
                properties=pika_props
            )
            published_count += 1
        
        return published_count

    def close_connection(self):
        """Standardized cleanup for Target connectors."""
        if self._hook:
            self.log.info("Closing RabbitMQ Target connection.")
            self._hook.close()