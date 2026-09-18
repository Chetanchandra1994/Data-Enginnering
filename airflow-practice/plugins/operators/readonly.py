from airflow.models.baseoperator import BaseOperator
import json

class ReadOnly(BaseOperator):
    """
    Simpler operator for small datasets. 
    Extracts all data and returns it for XCom storage.
    """
    def __init__(self, *, source, **kwargs):
        super().__init__(**kwargs)
        self.source = source

    def execute(self, context):
        all_records = []
        
        with self.source as src:
            while src.extract(context):
                batch_bytes = src.get_data()
                
                if not batch_bytes:
                    continue

                try:
                    decoded_str = batch_bytes.decode('utf-8')
                    for line in decoded_str.splitlines():
                        if line.strip():
                            all_records.append(json.loads(line))
                except Exception as e:
                    self.log.error(f"Error parsing batch data: {e}")
                    raise

        self.log.info(f"Successfully retrieved {len(all_records)} records as a list of dictionaries.")
        
        return all_records