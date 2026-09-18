from airflow.providers.postgres.hooks.postgres import PostgresHook
from hooks.base_hook import BaseHook

class Psycopg2PostgresHook(BaseHook):
    """
    Internal hook to connect to the Airflow Metadata Database.
    """
    def __init__(self, conn_id: str):
        self.conn_id = conn_id

    def get_conn(self):
        """
        Returns a standard psycopg2 connection.
        """
        hook = PostgresHook(postgres_conn_id=self.conn_id)
        return hook.get_conn()