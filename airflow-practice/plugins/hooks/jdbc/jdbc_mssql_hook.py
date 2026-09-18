from hooks.jdbc.jdbc_base_hook import JdbcBaseHook

class JdbcMssqlHook(JdbcBaseHook):
    DRIVER_CLASS = "com.microsoft.sqlserver.jdbc.SQLServerDriver"
    DRIVER_PATH = "/opt/airflow/drivers/mssql-jdbc.jar"

    def __init__(self, conn_id: str, database: str = None, **kwargs):
        super().__init__(conn_id=conn_id, **kwargs)
        self.database = database

    def _get_conn_url(self, conn) -> str:
        db_name = self.database or conn.schema
        return f"jdbc:sqlserver://{conn.host};databaseName={db_name};encrypt=false;trustServerCertificate=true;sslProtocol=TLSv1;"