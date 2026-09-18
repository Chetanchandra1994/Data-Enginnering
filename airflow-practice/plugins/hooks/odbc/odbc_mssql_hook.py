import pyodbc
from hooks.base_hook import BaseHook

class OdbcMssqlHook(BaseHook):
    def __init__(self, conn_id, database=None):
        self.conn_id = conn_id
        self.database = database

    def get_conn(self):
        conn = self.get_connection_metadata()
        
        conn_str = (
            f"DRIVER={{ODBC Driver 18 for SQL Server}};"
            f"SERVER={conn.host};"
            f"DATABASE={self.database or conn.schema};"
            f"UID={conn.login};"
            f"PWD={conn.password};"
            f"Encrypt=yes;"
            f"TrustServerCertificate=yes;"
            f"ConnectRetryCount=3;"
            f"ConnectRetryInterval=10;"
            f"KeepAlive=30;"
        )

        self.log.info("Attempting to connect to ODBC URL: %s", conn_str)
        
        return pyodbc.connect(conn_str, timeout=900)