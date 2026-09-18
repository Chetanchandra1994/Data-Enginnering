import asyncio
from typing import Any, Dict, Tuple
from airflow.triggers.base import BaseTrigger, TriggerEvent

class BaseMessageTrigger(BaseTrigger):
    """
    Master Trigger class for polling any remote resource.
    """
    def __init__(self, conn_id: str, resource_id: str, poke_interval: int = 30):
        super().__init__()
        self.conn_id = conn_id
        self.resource_id = resource_id  # Abstract: Queue, Topic, Path, etc.
        self.poke_interval = poke_interval

    #This is mandatory for Airflow triggers, it allows to reconstruct the Trigger object on the Triggerer
    def serialize(self) -> Tuple[str, Dict[str, Any]]:
        """
        Dynamically serializes and logs the module path for GCE/Local debugging.
        """
        module_path = self.__class__.__module__
        class_name = self.__class__.__name__
        full_classpath = f"{module_path}.{class_name}"

        return (
            full_classpath,
            {
                "conn_id": self.conn_id,
                "resource_id": self.resource_id,
                "poke_interval": self.poke_interval,
            }
        )

    async def has_messages(self) -> bool:
        """Abstract method to be implemented by child classes."""
        raise NotImplementedError("Child classes must implement has_messages()")

    async def run(self):
        """Standardized loop logic for all message triggers."""
        while True:
            try:
                if await self.has_messages():
                    yield TriggerEvent({"status": "success"})
                    return
            except Exception as e:
                print(f"Trigger polling error: {e}")
            
            await asyncio.sleep(self.poke_interval)