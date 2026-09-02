import pyodbc
import json
import base64
from datetime import date, datetime
from decimal import Decimal
from pathlib import Path

from config import (
    SQL_SERVER,
    DATABASE,
    TABLE_NAME,
    BATCH_SIZE,
    STORAGE_FOLDER,
    STORAGE_PREFIX,
    OUTPUT_FOLDER
)

from storage.storage_manager import upload_file


# --------------------------------------------------
# SERIALIZER
# --------------------------------------------------

def json_serializer(value):
    """
    Convert SQL Server data types into JSON-compatible values.
    """

    # DATE / DATETIME
    if isinstance(value, (date, datetime)):
        return value.isoformat()

    # DECIMAL / NUMERIC
    if isinstance(value, Decimal):
        return float(value)

    # BINARY / VARBINARY
    if isinstance(value, bytes):
        return base64.b64encode(value).decode("utf-8")

    return value


# --------------------------------------------------
# DATABASE CONNECTION
# --------------------------------------------------

def create_connection():
    """
    Create connection to SQL Server.
    """

    connection_string = (
        "DRIVER={ODBC Driver 17 for SQL Server};"
        f"SERVER={SQL_SERVER};"
        f"DATABASE={DATABASE};"
        "Trusted_Connection=yes;"
    )

    connection = pyodbc.connect(connection_string)

    return connection


# --------------------------------------------------
# GET SOURCE RECORD COUNT
# --------------------------------------------------

def get_source_count(connection):
    """
    Get total number of records from the source table.
    """

    cursor = connection.cursor()

    query = f"""
        SELECT COUNT(*)
        FROM {TABLE_NAME}
    """

    cursor.execute(query)

    count = cursor.fetchone()[0]

    cursor.close()

    return count


# --------------------------------------------------
# EXTRACT BATCH
# --------------------------------------------------

def extract_batch(
    connection,
    offset,
    batch_size
):
    """
    Extract one batch of records from SQL Server.
    """

    cursor = connection.cursor()

    query = f"""
        SELECT *
        FROM {TABLE_NAME}
        ORDER BY 1
        OFFSET ? ROWS
        FETCH NEXT ? ROWS ONLY
    """

    cursor.execute(
        query,
        offset,
        batch_size
    )

    columns = [
        column[0]
        for column in cursor.description
    ]

    rows = cursor.fetchall()

    records = []

    for row in rows:

        record = {}

        for column_name, value in zip(columns, row):

            record[column_name] = json_serializer(value)

        records.append(record)

    cursor.close()

    return records


# --------------------------------------------------
# WRITE JSONL
# --------------------------------------------------

def write_jsonl(
    records,
    file_path
):
    """
    Write records in JSON Lines format.

    One JSON object = one physical line.
    """

    with open(
        file_path,
        "w",
        encoding="utf-8"
    ) as file:

        for record in records:

            json_line = json.dumps(
                record,
                ensure_ascii=False
            )

            file.write(
                json_line + "\n"
            )


# --------------------------------------------------
# RUN INGESTION
# --------------------------------------------------

def run_ingestion():

    print("==========================================")
    print("STAGE 3 - SQL SERVER TO STORAGE")
    print("JSONL INGESTION")
    print("==========================================")

    # ----------------------------------------------
    # CONNECT TO SQL SERVER
    # ----------------------------------------------

    connection = create_connection()

    print("Connected successfully!")

    # ----------------------------------------------
    # SOURCE COUNT
    # ----------------------------------------------

    source_count = get_source_count(connection)

    print(
        f"Source record count: {source_count}"
    )

    # ----------------------------------------------
    # TABLE NAME
    # ----------------------------------------------

    table_name_only = TABLE_NAME.split(".")[-1]

    # ----------------------------------------------
    # STORAGE PATH
    # ----------------------------------------------

    storage_path = (
        Path(STORAGE_FOLDER)
        / STORAGE_PREFIX
        / table_name_only
    )

    storage_path.mkdir(
        parents=True,
        exist_ok=True
    )

    # ----------------------------------------------
    # OUTPUT PATH
    # ----------------------------------------------

    output_path = Path(OUTPUT_FOLDER)

    output_path.mkdir(
        parents=True,
        exist_ok=True
    )

    # ----------------------------------------------
    # BATCH PROCESSING
    # ----------------------------------------------

    offset = 0
    batch_number = 1

    total_extracted = 0

    while offset < source_count:

        # ------------------------------------------
        # EXTRACT
        # ------------------------------------------

        records = extract_batch(
            connection=connection,
            offset=offset,
            batch_size=BATCH_SIZE
        )

        if not records:
            break

        # ------------------------------------------
        # FILE NAME
        # ------------------------------------------

        file_name = (
            f"{table_name_only}"
            f"_batch_{batch_number:03d}.jsonl"
        )

        local_file = (
            output_path / file_name
        )

        # ------------------------------------------
        # WRITE JSONL
        # ------------------------------------------

        write_jsonl(
            records=records,
            file_path=local_file
        )

        # ------------------------------------------
        # UPLOAD TO STORAGE
        # ------------------------------------------

        destination_file = upload_file(
            source_file=local_file,
            destination_folder=storage_path
        )

        # ------------------------------------------
        # COUNTERS
        # ------------------------------------------

        batch_count = len(records)

        total_extracted += batch_count

        # ------------------------------------------
        # LOGGING
        # ------------------------------------------

        logical_storage_path = (
            f"storage/"
            f"{STORAGE_PREFIX}/"
            f"{table_name_only}/"
        )

        print(
            f"Batch {batch_number}: "
            f"{batch_count} records → "
            f"{file_name} → "
            f"{destination_file} → "
            f"{logical_storage_path}"
        )

        # ------------------------------------------
        # NEXT BATCH
        # ------------------------------------------

        offset += batch_count
        batch_number += 1

    # ----------------------------------------------
    # CLOSE CONNECTION
    # ----------------------------------------------

    connection.close()

    # ----------------------------------------------
    # VALIDATION
    # ----------------------------------------------

    print()
    print("------------------------------------------")
    print("INGESTION VALIDATION")
    print("------------------------------------------")

    print(
        f"Extracted record count: "
        f"{total_extracted}"
    )

    print(
        f"Difference: "
        f"{source_count - total_extracted}"
    )

    if source_count == total_extracted:

        print(
            "SUCCESS: Source and extracted "
            "record counts match."
        )

    else:

        print(
            "WARNING: Source and extracted "
            "record counts DO NOT match."
        )


# --------------------------------------------------
# MAIN
# --------------------------------------------------

if __name__ == "__main__":

    run_ingestion()


"""
┌──────────────────────────────┐
│ AdventureWorksDW2022         │
│ SQL Server                   │
└──────────────┬───────────────┘
               │
               │ SQL / pyodbc
               ▼
┌──────────────────────────────┐
│ Stage_3_extract_customer.py  │
│                              │
│ • Extract                    │
│ • Batch                      │
│ • Serialize                  │
│ • Write JSONL                │
└──────────────┬───────────────┘
               │
               ▼
┌──────────────────────────────┐
│ storage_manager.py           │
│                              │
│ Storage abstraction          │
└──────────────┬───────────────┘
               │
               ▼
┌──────────────────────────────┐
│ local_storage.py             │
│                              │
│ Local GCS simulation          │
└──────────────┬───────────────┘
               │
               ▼
┌──────────────────────────────┐
│ storage_bucket               │
│                              │
│ raw/                         │
│   DimCustomer/               │
│     batch_001.jsonl          │
│     batch_002.jsonl          │
│     batch_003.jsonl          │
│     batch_004.jsonl          │
└──────────────────────────────┘

"""