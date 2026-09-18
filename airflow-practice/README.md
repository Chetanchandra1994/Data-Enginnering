# Data Extraction Platform: The "Safe Pipeline" Standard

## Overview
This platform provides a high-performance framework for moving massive datasets from distributed sources (**ODBC, JDBC, API, RabbitMQ**) into cloud targets (**GCS, BigQuery, Snowflake**). 

The architecture utilizes a **Multi-threaded Producer-Consumer** model to ensure that data extraction and cloud ingestion happen in parallel, significantly reducing total execution time.

---

## Core Architecture
The `ExtractionOperator` manages a decoupled data flow between threads:

* **Producer Thread (Background)**: 
    * Owns the source connector lifecycle (`with self.source as src`).
    * Executes the extraction loop and pushes data batches to a synchronized queue.
* **Main Thread (Consumer)**: 
    * Monitors for producer crashes via an `error_queue`.
    * Orchestrates sequential target processing (e.g., GCS -> BigQuery).
    * Manages memory by clearing batch data and triggering `gc.collect()` after every successful ingestion.



---

## The Developer Contract
To maintain stability across diverse database drivers (pyodbc, jaydebeapi), all connectors must adhere to this lifecycle:

### 1. Lifecycle Hook Requirements
| Method | Execution Thread | Responsibility |
| :--- | :--- | :--- |
| `__enter__` | **Producer** | Establishes the physical connection/session. |
| `extract()` | **Producer** | Fetches one batch. Returns `True` if data exists, `False` when finished. |
| `save()` | **Main** | Persists `bytes` to the target. Re-opened/closed **per batch**. |
| `close_connection()` | **Main** | **Final Safety Valve**: Explicitly closes cursors/sockets in the `finally` block. |
| `__exit__` | **Both** | **MUST be an empty `pass`** to prevent threads from closing shared cursors. |
| `on_pipeline_success()` | **Main** | Triggered ONLY after the final batch is confirmed by all targets. |

---

## Data Formatting Standard: NDJSON
All data passed between connectors **must be a single `bytes` object** formatted as **Newline Delimited JSON (NDJSON)**.

**Critical Rules:**
* **Single Bytes Block**: Do not return a `list[bytes]`. The source must join records with `\n`.
* **Metadata Injection**: The base `_serialize` method automatically injects `airflow_dag_id`, `airflow_run_id`, and `airflow_task_id` for auditability.
* **Serialization**: Use `orjson` with `OPT_SERIALIZE_NUMPY` to handle complex data types common in database rows.

---

## Reliability & Safety

* **Distributed Lifecycle**: The source connection is held open by the **Producer Thread**. By using an empty `__exit__`, we ensure the driver session stays active even if the thread context changes.
* **Memory Pressure Control**: We use a `Queue(maxsize=1)`. This forces the Producer to wait until the Main Thread finishes processing the current batch before fetching the next, preventing "Out of Memory" (OOM) crashes on large tables.
* **Resource Cleanup**: Because `pyodbc` and JDBC cursors can be sensitive to thread termination, `close_connection()` is called in the operator's `finally` block to ensure no orphaned sessions remain on the database.
* **Feedback Loop**: Any failure in the `save()` method of a target will trigger `on_pipeline_failure` on the source, allowing for proper NACKing (RabbitMQ) or rollback.

---

## Troubleshooting Quick-Start

| Issue | Likely Cause | Resolution |
| :--- | :--- | :--- |
| `TypeError` in Target | Source passed a `list[bytes]`. | Call `_serialize()` on the entire batch to return one `bytes` object. |
| Premature "Cursor Closed" | Inherited `__exit__` logic. | Define `def __exit__(self, ...): pass` in the leaf connector. |
| BigQuery "Start of Array" | Data starts with `[`. | Source must return NDJSON (one object per line) rather than a JSON Array. |
| Empty Producer Thread | `error_queue` not empty. | Check logs for Producer failures; exceptions are caught and re-raised in Main. |

---