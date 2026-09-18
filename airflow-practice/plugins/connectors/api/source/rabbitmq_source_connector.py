import orjson
import base64
import logging
from typing import Any, List, Dict

# High-level Sparkplug B library
import pysparkplug as psp
from pysparkplug import MessageType
from connectors.api.api_base_connector import ApiBaseConnector
from hooks.api.rabbitmq_hook import RabbitMQHook
import datetime
import struct

class RabbitMQSourceConnector(ApiBaseConnector):
    def __init__(self, conn_id: str, queue_name: str, batch_size: int = 500, expand_map: dict = None, **kwargs):
        super().__init__(conn_id=conn_id, **kwargs)
        self.queue_name = queue_name
        self.batch_size = batch_size
        self.expand_map = expand_map or {}
        self.hook = None
        self._method_frame = None
        self.file_prefix = 'stream'

    def __enter__(self):
        self.hook = RabbitMQHook(conn_id=self.connection_id)
        return self

    def _transform_record(self, record: dict) -> dict:
        """Splits fields based on expand_map configuration."""
        for source_field, config in self.expand_map.items():
            if source_field in record and record[source_field]:
                values = str(record[source_field]).split(config['delimiter'])
                target_fields = config['target_fields']
                for i, field_name in enumerate(target_fields):
                    record[field_name] = values[i] if i < len(values) else None
                del record[source_field]
        return record

    def _decode_sparkplug(self, body: bytes, routing_key: str) -> List[Dict[str, Any]]:
        """
        Generic Sparkplug B Decoder. 
        Works for NBIRTH, DBIRTH, DDATA, and NDEATH by dynamically finding metrics.
        """
        raw_b64 = base64.b64encode(body).decode('utf-8')
        
        try:
            # 1. Flexible Type Search
            parts = routing_key.replace('/', '.').split('.')
            msg_type_enum = None
            for part in parts:
                try:
                    msg_type_enum = MessageType(part)
                    break 
                except ValueError:
                    continue

            if not msg_type_enum:
                self.log.warning(f"SPB WARNING: Unknown type in '{routing_key}'. Preserving raw.")
                return [{"routing_key": routing_key, "raw_payload": raw_b64, "is_decoded": False, "error": "Unknown Type"}]

            # 2. Decode the binary using the class associated with the found type
            payload = msg_type_enum.payload.decode(body)

            # 3. Consolidate Metrics (Handles metrics lists AND NDEATH/DDEATH status objects)
            # We look for '.metrics' first, then fall back to the death-specific 'bd_seq_metric'
            metrics = getattr(payload, 'metrics', [])
            if not metrics and hasattr(payload, 'bd_seq_metric'):
                metrics = [payload.bd_seq_metric]

            base_record = {
                "routing_key": routing_key,
                "raw_payload": raw_b64,
                "spb_message_type": msg_type_enum.value,
                "spb_timestamp": payload.timestamp,
                "spb_seq": getattr(payload, 'seq', None),
                "is_decoded": True
            }

            if not metrics:
                return [base_record]

            # 4. Universal Flattening
            records = []
            for metric in metrics:
                row = base_record.copy()
                row.update({
                    "metric_name": metric.name,
                    "metric_datatype": str(metric.datatype),
                    "metric_value": metric.value,
                    "metric_timestamp": getattr(metric, 'timestamp', payload.timestamp)
                })
                records.append(row)
            return records

        except Exception as e:
            self.log.warning(f"SPB DECODE FAILURE: {routing_key}. Error: {e}")
            return [{
                "routing_key": routing_key, 
                "raw_payload": raw_b64, 
                "is_decoded": False, 
                "error_message": str(e)
            }]
    
    def _decode_json(self, body: bytes, routing_key: str, type: str, headers: str) -> List[Dict[str, Any]]:
        """STRICT JSON Decoder. Pipeline fails on error to trigger Requeue."""
        data = orjson.loads(body)
        records = data if isinstance(data, list) else [data]
        parsed_headers = headers or {}
        for r in records:
            r["routing_key"] = routing_key
            r["src_system_operation"] = type
            r["DataEventTimestamp"] = parsed_headers.get("DataEventTimestamp")
        return records

    def _execute_api_call(self, context: dict) -> List[Dict[str, Any]]:
        """
        Implementation of the execution contract.
        Returns the raw message batch and saves the method_frame for ACK/NACK logic.
        """
        resolved_queue = self._resolve_xcom_args(self.queue_name, context)
        messages, method_frame = self.hook.get_batch(resolved_queue, self.batch_size)
        self._method_frame = method_frame

        #Temp debug for qc_quotation null column
        for record in messages:   
            self.log.info(f"Raw Record: {record}")

        if not messages:
            return None 

        all_records = []
        for method, properties, body in messages:
            routing_key = method.routing_key

            if not body or len(body) == 0:
                            self.log.info(f"Empty message body from {routing_key}")
                            all_records.append({
                                "routing_key": routing_key,
                                "raw_payload": "0 bytes payload"
                            })
                            continue

            is_spb = routing_key.startswith("spBv1") or properties.content_type == 'application/x-protobuf'
            
            if is_spb:
                all_records.extend(self._decode_sparkplug(body, routing_key))
            else:
                all_records.extend(self._decode_json(body, routing_key, properties.type, properties.headers))

        return all_records

    def extract(self, context: dict) -> bool:
        """
        Overridden extract method to apply transformations before serialization.
        """
        if self._has_run:
            return False

        raw_result = self._execute_api_call(context)

        if self._should_skip(raw_result):
            return False

        transformed_data = [self._transform_record(m) for m in raw_result]
        self.extracted_data = self._process_and_track_metadata(transformed_data, context)
        
        self._has_run = True 
        return True
    
    def __exit__(self, exc_type, exc_val, exc_tb):
        pass

    def on_pipeline_success(self, context):
        if self.hook and self._method_frame:
            self.log.info(f"ACKing RabbitMQ tag {self._method_frame.delivery_tag}")
            self.hook.ack(self._method_frame, multiple=True)

    def on_pipeline_failure(self, error):
        if self.hook and self._method_frame:
            self.log.error(f"Pipeline failed, NACKing to requeue: {error}")
            self.hook.nack(self._method_frame, multiple=True, requeue=True)

    def close_connection(self):
        if self.hook:
            self.hook.close()