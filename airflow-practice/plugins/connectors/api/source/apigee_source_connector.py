from typing import Any
from connectors.api.api_base_connector import StatefulApiConnector
from hooks.api.apigee_oauth2_hook import ApigeeOAuth2Hook

class ApigeeSourceConnector(StatefulApiConnector):
    """Generic connector for standard APIs managed by Apigee."""
    
    def __init__(self, conn_id, endpoint, method="GET", payload=None, headers=None, **kwargs):
        super().__init__(conn_id, **kwargs)
        self.endpoint = endpoint
        self.method = method
        self.payload = payload

        self.headers = headers or {}
        
        self._payload_strategies = {
            dict: self._prepare_json,
            str: self._prepare_xml,
            type(None): lambda p, h, ctx: (None, h)
        }

    def __enter__(self):
        self.hook = ApigeeOAuth2Hook(conn_id=self.connection_id)
        return self

    def _prepare_json(self, payload, headers, context):
        headers.setdefault("Content-Type", "application/json")
        return self._resolve_xcom_args(payload, context), headers

    def _prepare_xml(self, payload, headers, context):
        headers.setdefault("Content-Type", "application/xml")
        return self._resolve_xcom_args(payload, context), headers

    def _execute_api_call(self, context: dict) -> Any:
        """Implementation of the mandatory execution contract."""
        strategy = self._payload_strategies.get(type(self.payload), self._prepare_xml)
        payload, headers = strategy(self.payload, self.headers, context)

        return self.hook.run(
            endpoint=self.endpoint,
            method=self.method,
            payload=payload,
            headers=headers,
        )