# this is a comment
from __future__ import annotations
from airflow.models.baseoperator import BaseOperator
from airflow.utils.context import Context
from connectors.base_connector import SourceConnector, TargetConnector
from queue import Queue, Empty
from threading import Thread
import gc

class ExtractionOperator(BaseOperator):
    """
    Airflow operator to orchestrate data movement from a single source to one or more sequential targets.

    Example pipeline: RabbitMQ -> GCS (returns URI) -> BigQuery (uses URI).
    Each target receives the output of the previous target, enabling chained transformations or loads.
    """
    # Allow source and targets to be templated by Airflow
    template_fields = ("source", "targets")

    def __init__(
            self, 
            *, 
            source: SourceConnector, 
            targets: list[TargetConnector], 
            **kwargs,
            ) -> None:
        """
        Initialize the ExtractionOperator.
        source: The source connector to extract data from.
        targets: List of target connectors to sequentially process the data.
        """
        super().__init__(**kwargs)
        self.source = source
        self.targets = targets
    
    def _determine_prefix(self, ti):
        '''
        This function is responsible to determine the prefix that will be used for upload in GCS or Snowflake. It behaves in this intended order.
        1. Look for an XCOM key if configured in the configured source connector of the DAG
        2. Look for the most up to date record timestamp using the XCOM key in Airflow DB from the previous execution.
        3. If an XCOM key exists as a result of a previous execution. This means that it is a DAG configured with an XCOM key and query_mode = 'Delta'. Subsequent executions are then always a Stream.
        4. If an XCOM key doesn't exists, we check if the source connector hardcode the file_prefix (Always a Stream or a Fullloard). Otherwise, we return Fulloard because if it is a DAG first execution (Fullloard)
        '''
        source_xcom_key = getattr(self.source, 'xcom_key', None)
        last_checkpoint = ti.xcom_pull(key=source_xcom_key, include_prior_dates=True) if source_xcom_key else None
        if last_checkpoint:
            return 'stream'
        return getattr(self.source, 'file_prefix', None) or 'fullload'
        
    def execute(self, context: dict):
        target_names = ", ".join(t.__class__.__name__ for t in self.targets)
        self.log.info(f"Starting pipelined execution: {self.source.__class__.__name__} -> {target_names}")

        # Determine the investion type
        determined_prefix = self._determine_prefix(context['ti'])
        # For the found ingestion type, we inject the file_prefix in the target connector that must be shown in the filename reference (GCS or Snowflake).
        for target_obj in self.targets:
            if hasattr(target_obj, 'file_prefix'):
                target_obj.file_prefix = determined_prefix

        batch_queue = Queue(maxsize=1)
        error_queue = Queue()
        
        def producer():
            try:
                # The 'with' context here handles local __enter__ logic
                with self.source as src:
                    while src.extract(context):
                        batch_data = src.get_data()
                        batch_queue.put(batch_data)
                        src.extracted_data = None 
                    
                    batch_queue.put(None) # Signal completion
            except Exception as e:
                self.log.error(f"Producer thread failed: {str(e)}")
                error_queue.put(e)
                batch_queue.put(None)

        producer_thread = Thread(target=producer, daemon=True)
        producer_thread.start()

        final_output = None
        
        try:
            while True:
                
                # 1. Check if the producer crashed
                if not error_queue.empty():
                    raise error_queue.get()

                # 2. Wait for the next batch
                try:
                    current_data = batch_queue.get(timeout=2)
                except Empty:
                    if not producer_thread.is_alive() and error_queue.empty():
                        # Thread died without an error and without putting None in the queue
                        raise RuntimeError("Producer thread died unexpectedly.")
                    continue
                
                # 3. If None, the producer is finished
                if current_data is None:
                    # Final check for an error that might have happened at the very end
                    if not error_queue.empty():
                        raise error_queue.get()
                    break

                if not current_data:
                    self.log.info("Batch is empty. Skipping target processing for this iteration.")
                    continue
                    
                # 4. Process the batch through all targets
                for target_obj in self.targets:
                    # -----------------------------------------------------------------
                    # CHANGED LINE: Active check to intercept thread termination 
                    # before kicking off a blocking network save operation.
                    # -----------------------------------------------------------------
                    if not producer_thread.is_alive() and not error_queue.empty():
                        raise error_queue.get()

                    
                    with target_obj as tgt:
                        current_data = tgt.save(log=self.log, data=current_data, context=context)
                
                final_output = current_data
                del current_data
                gc.collect()
            
            #5. Allow post processing after extraction I.E. Call BigQuery merge once per extraction.
            for target_obj in self.targets:
                with target_obj as tgt:
                    tgt.post_process(log=self.log, data=final_output, context=context)

            # 6. Pipeline Success: Triggered ONLY after ALL batches are done    
            self.source.on_pipeline_success(context)

        except Exception as e:
            # 6. Pipeline Failure: Triggered if ANY batch or target fails
            self.source.on_pipeline_failure(e)
            raise e
        finally:
            # 7. Cleanup: Close socket/JDBC connection safely
            self.source.close_connection()
        
        self.log.info(f"Finished pipelined execution: {self.source.__class__.__name__} -> {target_names}")
        return final_output