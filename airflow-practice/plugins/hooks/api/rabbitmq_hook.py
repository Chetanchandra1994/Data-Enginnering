from __future__ import annotations

from typing import Any

import pika
import ssl
from hooks.base_hook import BaseHook
from airflow.exceptions import AirflowException

class RabbitMQHook(BaseHook):

    def __init__(self, conn_id: str = "rabbitmq_default", **kwargs) -> None:
        super().__init__(conn_id=conn_id, **kwargs)
        self.connection: pika.BlockingConnection | None = None
        self.channel: pika.channel.Channel | None = None

    def __enter__(self):
        """Allows using 'with RabbitMQHook(...) as hook:'"""
        return self

    def _get_conn_params(self) -> pika.ConnectionParameters:
        conn = self.get_connection_metadata()
        credentials = pika.PlainCredentials(conn.login, conn.password)
        ssl_options = None
        if conn.port == 5671:
            context = ssl.create_default_context()
            ssl_options = pika.SSLOptions(context)
        
        return pika.ConnectionParameters(
            host=conn.host,
            port=conn.port,
            virtual_host=conn.schema or "/",
            credentials=credentials,
            ssl_options=ssl_options,
            heartbeat=0
        )

    def get_conn(self) -> pika.channel.Channel:
        """
        Establishes a connection and channel to RabbitMQ.
        Caches the channel for reuse.
        """
        if self.channel and self.channel.is_open:
            self.log.info("Using cached RabbitMQ channel.")
            return self.channel

        if not self.connection or self.connection.is_closed:
            self.log.info("Connecting to RabbitMQ...")
            conn_params = self._get_conn_params()
            self.connection = pika.BlockingConnection(conn_params)
            self.log.info("Successfully connected to RabbitMQ.")

        self.channel = self.connection.channel()
        self.log.info("RabbitMQ channel opened.")
        return self.channel

    def declare_queue(self, queue_name: str, durable: bool = True, passive: bool = False):
        """
        Declares a queue.

        :param queue_name: The name of the queue.
        :param durable: Whether the queue should survive a broker restart.
        :param passive: If True, only check if the queue exists.
        """
        channel = self.get_conn()
        self.log.info(f"Declaring queue '{queue_name}' (durable={durable}, passive={passive})")
        return channel.queue_declare(queue=queue_name, durable=durable, passive=passive)

    def publish(
        self,
        exchange: str,
        routing_key: str,
        message_body: str | bytes,
        properties: pika.BasicProperties | None = None
    ):
        """
        Publishes a single message to RabbitMQ.

        :param exchange: The exchange to publish to.
        :param routing_key: The routing key (often the queue name).
        :param message_body: The message body to publish.
        :param properties: pika.BasicProperties for the message (e.g., delivery_mode).
        """
        channel = self.get_conn()
        try:
            channel.basic_publish(
                exchange=exchange,
                routing_key=routing_key,
                body=message_body,
                properties=properties
            )
        except Exception as e:
            self.log.error(f"Failed to publish message: {e}", exc_info=True)
            raise

    def get_batch(
        self, queue_name: str, batch_size: int, durable_queue: bool = True
    ) -> tuple[list[tuple[Any, Any, bytes]], Any | None]:
        """
        Consumes a batch of messages from a queue without auto-acknowledging.

        :param queue_name: The name of the queue.
        :param batch_size: The maximum number of messages to retrieve.
        :param durable_queue: Whether the queue should be declared as durable.
        :return: A tuple containing:
                 1. A list of messages (method_frame, properties, body).
                 2. The method_frame of the *last* message, for acknowledgment.
        """
        channel = self.get_conn()
        
        try:
            # Passively declare to get message count.
            # This assumes the queue exists and is durable (matching sensor logic).
            queue_state = self.declare_queue(
                queue_name=queue_name, passive=True, durable=durable_queue
            )
            message_count = queue_state.method.message_count

            if message_count == 0:
                self.log.info(f"No messages in queue '{queue_name}'.")
                return [], None

            self.log.info(f"Found {message_count} messages in queue '{queue_name}'. Consuming up to {batch_size}.")
            
            messages_to_process = []
            final_method_frame = None

            for method_frame, properties, body in channel.consume(queue_name, auto_ack=False):
                messages_to_process.append((method_frame, properties, body))
                final_method_frame = method_frame
                
                # Stop consuming if we hit the batch size or consume all available messages
                current_delivery_tag = method_frame.delivery_tag
                if current_delivery_tag >= batch_size or current_delivery_tag == message_count:
                    channel.stop_consuming()
                    break
            
            self.log.info(f"Consumed {len(messages_to_process)} messages.")
            return messages_to_process, final_method_frame

        except Exception as e:
            self.log.error(f"Error while consuming from queue '{queue_name}': {e}", exc_info=True)
            return [], None # Return empty on error

    def ack(self, method_frame: Any, multiple: bool = True):
        """
        Acknowledge one or more messages.

        :param method_frame: The method_frame of the message to ack (or the last
                             message if multiple=True).
        :param multiple: Whether to acknowledge all messages up to this one.
        """
        channel = self.get_conn()
        if channel and channel.is_open and method_frame and method_frame.delivery_tag:
            self.log.info(f"Acknowledging message(s) up to delivery tag {method_frame.delivery_tag} (multiple={multiple}).")
            channel.basic_ack(delivery_tag=method_frame.delivery_tag, multiple=multiple)
        else:
            self.log.warning("ACK called without a valid channel or method_frame, skipping.")

    def nack(self, method_frame: Any, multiple: bool = True, requeue: bool = True):
        """
        Negative-acknowledge (reject) one or more messages.

        :param method_frame: The method_frame of the message to nack.
        :param multiple: Whether to nack all messages up to this one.
        :param requeue: Whether to requeue the message(s).
        """
        channel = self.get_conn()
        if channel and channel.is_open and method_frame and method_frame.delivery_tag:
            self.log.info(f"NACK-ing message(s) up to delivery tag {method_frame.delivery_tag} (multiple={multiple}, requeue={requeue}).")
            channel.basic_nack(delivery_tag=method_frame.delivery_tag, multiple=multiple, requeue=requeue)
        else:
            self.log.warning("NACK called without a valid channel or method_frame, skipping.")

    def close(self):
        """
        Closes the channel and connection.
        """
        if self.channel and self.channel.is_open:
            self.channel.close()
            self.log.info("RabbitMQ channel closed.")
        if self.connection and self.connection.is_open:
            self.connection.close()
            self.log.info("RabbitMQ connection closed.")

    def get_message_count(self, queue_name: str, durable: bool = True) -> int:
        """
        Gets the number of messages in a queue using a passive declaration.
        This is the method the poller DAG needs.

        :param queue_name: The name of the queue.
        :param durable: Whether the queue is expected to be durable.
        :return: The number of messages in the queue.
        """
        channel = self.get_conn()
        try:
            # Passively declare to get queue state, including message count. This does not create a queue.
            queue_state = self.declare_queue(
                queue_name=queue_name, durable=durable, passive=True
            )
            message_count = queue_state.method.message_count
            self.log.info(f"Queue '{queue_name}' has {message_count} messages.")
            return message_count
        except Exception as e:
            self.log.warning(f"Could not get message count for '{queue_name}': {e}")
            return 0