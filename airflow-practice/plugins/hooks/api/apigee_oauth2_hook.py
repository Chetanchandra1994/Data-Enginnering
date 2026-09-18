from __future__ import annotations
import requests
from airflow.exceptions import AirflowException
from hooks.base_hook import BaseHook
from requests.auth import HTTPBasicAuth

class ApigeeOAuth2Hook(BaseHook):
    """Hook for OAuth2 Client Credentials requests used by Apigee."""
    
    def __init__(self, conn_id: str, **kwargs):
        super().__init__(conn_id=conn_id, **kwargs)
        self.access_token = None

    def get_conn(self):
        return self.get_connection(self.conn_id)

    def _get_access_token(self) -> str:
        if self.access_token:
            return self.access_token

        conn = self.get_connection_metadata()
        client_id = conn.login     
        client_secret = conn.password
        token_url = conn.extra_dejson.get('token_url')

        if not token_url:
            raise AirflowException(f"The 'token_url' was not found in connection '{self.conn_id}'.")

        try:
            auth = HTTPBasicAuth(client_id, client_secret)
            response = requests.post(token_url, auth=auth, data={'grant_type': 'client_credentials'})
            response.raise_for_status()
            self.access_token = response.json()['access_token']
            return self.access_token
        except requests.exceptions.RequestException as e:
            self.log.error(f"Failed to retrieve access token: {e}")
            raise e

    def run(self, endpoint: str, method: str = "GET", payload: dict | str | None = None, headers: dict | None = None) -> dict | str:
        """
        Executes an authenticated request against the Apigee endpoint.
        """
        conn = self.get_connection_metadata()
        api_base_url = conn.host
        token = self._get_access_token()

        full_url = api_base_url.rstrip('/') + '/' + endpoint.lstrip('/')
        final_headers = {'Authorization': f'Bearer {token}'}
        if headers:
            final_headers.update(headers)

        request_args = {
            "method": method.upper(), 
            "url": full_url, 
            "headers": final_headers,
            "timeout": 300
        }
    
        # Handle different payload types (JSON, XML, or Query Params)
        if payload:
            if method.upper() == "GET":
                request_args["params"] = payload
            elif "json" in final_headers.get("Content-Type", "").lower():
                request_args["json"] = payload
            else:
                request_args["data"] = payload
        
        self.log.info(f"Calling endpoint {full_url}")
        self.log.info(f"With headers {final_headers} and with payload: {payload}")
        
        response = requests.request(**request_args)
        response.raise_for_status()
        
        content_type = response.headers.get("Content-Type", "").lower()
        return response.json() if "application/json" in content_type else response.text