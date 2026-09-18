from hooks.jdbc.jdbc_base_hook import JdbcBaseHook

class JdbcOracleHook(JdbcBaseHook):
    DRIVER_CLASS = "oracle.jdbc.driver.OracleDriver"
    DRIVER_PATH = "/opt/airflow/drivers/ojdbc8-12.2.0.1.jar"

    def _get_conn_url(self, conn) -> str:
        return f"jdbc:oracle:thin:@{conn.host}"