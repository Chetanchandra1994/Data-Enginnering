from typing import Any, List, Dict
from connectors.api.source.apigee_source_connector import ApigeeSourceConnector
from hooks.api.apigee_oauth2_hook import ApigeeOAuth2Hook
import orjson
import csv
import pendulum
import io
import time

class ApigeeInforSourceConnector(ApigeeSourceConnector):
    def __init__(self, conn_id, endpoint, method="GET", table=None, delta_column=None, headers=None, **kwargs):
        super().__init__(conn_id=conn_id, endpoint=endpoint, method=method, headers=headers, **kwargs)
        self.table = table
        self.delta_column = delta_column
        self._payload_strategies = {
            dict: self._prepare_json,
            str: self._prepare_text,
            type(None): lambda p, h, ctx: (None, h)
        }

    def __enter__(self):
        self.hook = ApigeeOAuth2Hook(conn_id=self.connection_id)
        return self

    def _prepare_json(self, payload, headers, context):
        headers.setdefault("Content-Type", "application/json")
        return self._resolve_xcom_args(payload, context), headers

    def _prepare_text(self, payload, headers, context):
        headers.setdefault("Content-Type", "text/plain")
        return self._resolve_xcom_args(payload, context), headers

    def _build_dynamic_query(self, context: dict) -> str:
        """Builds the SQL query dynamically based on the context."""
        if self.delta_column is None:
            return f"SELECT * FROM {self.table}"

        # Otherwise, build a delta query.
        last_success_date = context.get('prev_start_date_success')
        self.log.info(f"last_success_date for delta query: {last_success_date}")

        # For the first run, use a recent time to avoid a full table scan.
        # For subsequent runs, use the last successful run's start time.
        start_date = last_success_date or pendulum.now('America/Toronto').subtract(minutes=5)
        formatted_date = start_date.strftime('%Y-%m-%d %H:%M:%S')
        
        return f"SELECT * FROM {self.table} WHERE {self.delta_column} > '{formatted_date}'"

    def _prepare_request_data(self, context: dict) -> tuple[Any, dict]:
        """Determines the payload strategy and prepares payload and headers."""
        strategy = self._payload_strategies.get(type(self.payload), self._prepare_text)
        payload, headers = strategy(self.payload, self.headers, context)
        return payload, headers

    def _submit_job(self, payload: Any, headers: dict) -> str:
        """Submits the query job to Apigee and returns the queryId."""
        job_response = self.hook.run(
            endpoint=self.endpoint + "/jobs",
            method=self.method,
            payload=payload,
            headers=headers,
        )
        query_id = job_response.get('queryId')
        if not query_id:
            raise ValueError(f"Failed to get queryId from job submission response: {job_response}")
        self.log.info(f"Successfully submitted job with queryId: {query_id}")
        return query_id

    def _wait_for_job_completion(self, query_id: str, headers: dict):
        """Polls the job status until it's finished or fails."""
        status = 'RUNNING'
        while status == 'RUNNING':
            job_response = self.hook.run(
                endpoint=f"{self.endpoint}/jobs/{query_id}/status/?timeout=0",
                method='GET',
                headers=headers,
            )
            status = job_response.get('status')
            if not status:
                raise Exception(f"Could not retrieve status for job {query_id}. Response: {job_response}")
            
            self.log.info(f"Query status for job {query_id}: {status}")

            if status == 'RUNNING':
                self.log.info("Job is still running, waiting for 15 seconds...")
                time.sleep(15)
            elif status != 'FINISHED':
                raise Exception(f"Job {query_id} did not finish successfully. Final status: {status}")

    def _fetch_job_results(self, query_id: str, headers: dict) -> List[Dict]:
        """Fetches all results for a completed job, handling pagination."""
        all_records = []
        offset = 0
        limit = 5000
        
        while True:
            self.log.info(f"Fetching results for job {query_id} with offset {offset} and limit {limit}...")
            csv_results = self.hook.run(
                endpoint=f"{self.endpoint}/jobs/{query_id}/result/?offset={offset}&limit={limit}&queryExecutor=datalake",
                method='GET',
                headers=headers,
            )
            
            records = self._parse_csv_to_json(csv_results, query_id)
            
            if not records:
                self.log.info(f"No more records found for job {query_id}. Total records fetched: {len(all_records)}")
                break
            
            all_records.extend(records)
            offset += limit

        return all_records

    def _parse_csv_to_json(self, csv_data: str, query_id: str) -> List[Dict]:
        """Converts CSV response to a list of dictionaries and adds src_system_operation."""
        try:
            csv_file = io.StringIO(csv_data)
            reader = csv.DictReader(csv_file)
            records = []
            is_stream = self.delta_column is not None
            
            for record in reader:
                status = record.get('STATUS', '').upper()
                if status == 'DELETED':
                    record['src_system_operation'] = 'Delete'
                elif is_stream and status == 'UPDATED':
                    record['src_system_operation'] = 'Update'
                else:
                    record['src_system_operation'] = 'Insert'

                records.append(record)
            self.log.info(f"Successfully converted CSV for job {query_id}.")
            return records
        except Exception as e:
            self.log.error(f"Failed to parse CSV response for job {query_id}: {e}")
            raise ValueError(f"Expected CSV response for job {query_id} but failed to parse it.") from e

    def _execute_api_call(self, context: dict) -> Any:
        """Implementation of the mandatory execution steps"""
        self.payload = self._build_dynamic_query(context)
        payload, headers = self._prepare_request_data(context)
        query_id = self._submit_job(payload, headers)
        self._wait_for_job_completion(query_id, headers)
        return self._fetch_job_results(query_id, headers)