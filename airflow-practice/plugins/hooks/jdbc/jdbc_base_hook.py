import jaydebeapi
from typing import List
from hooks.base_hook import BaseHook
from airflow.exceptions import AirflowException

class JdbcBaseHook(BaseHook):
    """
    Abstract-style hook for all JDBC connections using JayDeBeApi.
    Subclasses only need to define DRIVER_CLASS, DRIVER_PATH, and _get_conn_url.
    """
    DRIVER_CLASS = None
    DRIVER_PATH = None

    def _get_conn_url(self, conn) -> str:
        """Override in subclasses to build the specific JDBC URL string."""
        raise NotImplementedError

    def get_conn(self) -> jaydebeapi.Connection:
        conn_metadata = self.get_connection_metadata()
        conn_url = self._get_conn_url(conn_metadata)
        
        self.log.info(f"Connecting to {self.DRIVER_CLASS} at {conn_url}")
        return jaydebeapi.connect(
            jclassname=self.DRIVER_CLASS,
            url=conn_url,
            driver_args=[conn_metadata.login, conn_metadata.password],
            jars=[self.DRIVER_PATH],
        )