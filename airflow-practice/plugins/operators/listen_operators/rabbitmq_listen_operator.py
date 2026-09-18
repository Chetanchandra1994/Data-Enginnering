from triggers.rabbitmq_trigger import RabbitMQMessageTrigger
from operators.message_listen_operator import MessageListenOperator

class RabbitMQListenOperator(MessageListenOperator):
    """
    RabbitMQ implementation of the MessageListenOperator.
    """
    def get_trigger(self):
        return RabbitMQMessageTrigger(
            conn_id=self.message_source.connection_id,
            resource_id=self.message_source.queue_name, # Map queue_name to resource_id
            poke_interval=self.poke_interval
        )