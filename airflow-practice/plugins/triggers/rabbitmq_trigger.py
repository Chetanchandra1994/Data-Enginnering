import aio_pika
import asyncio
from airflow.hooks.base import BaseHook
from triggers.base_trigger import BaseMessageTrigger

class RabbitMQMessageTrigger(BaseMessageTrigger):
    """
    Child Trigger class specifically for RabbitMQ.
    """

    async def _get_connection_url(self):
        """Builds the AMQP URI from Airflow's connection manager."""
        conn = await asyncio.to_thread(BaseHook.get_connection, self.conn_id)
        return f"amqp://{conn.login}:{conn.password}@{conn.host}:{conn.port or 5672}/{conn.schema or ''}"

    async def has_messages(self) -> bool:
        """
        Implementation of the RabbitMQ-specific check.
        Uses resource_id as the queue_name.
        """
        url = await self._get_connection_url()
        try:
            connection = await aio_pika.connect_robust(url)
            async with connection:
                channel = await connection.channel()
                # Passive check: resource_id acts as the queue_name here
                queue = await channel.declare_queue(self.resource_id, passive=True)
                return queue.declaration_result.message_count > 0
        except (aio_pika.exceptions.ChannelNotFoundEntity, 
                aio_pika.exceptions.AMQPConnectionError):
            return False