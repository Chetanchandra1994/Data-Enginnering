import pyodbc
import json

from pathlib import Path
from datetime import date, datetime
from decimal import Decimal

from config import (
    SQL_SERVER,
    DATABASE,
    TABLE_NAME,
    BATCH_SIZE,
    OUTPUT_FOLDER
)


# --------------------------------------------------
# DATABASE CONNECTION
# --------------------------------------------------

def get_connection():

    connection = pyodbc.connect(
        "DRIVER={ODBC Driver 17 for SQL Server};"
        f"SERVER={SQL_SERVER};"
        f"DATABASE={DATABASE};"
        "Trusted_Connection=yes;"
        "TrustServerCertificate=yes;"
    )

    return connection


# --------------------------------------------------
# JSON SERIALIZER
# --------------------------------------------------

def json_serializer(value):

    if isinstance(value, (date, datetime)):
        return value.isoformat()

    if isinstance(value, Decimal):
        return float(value)

    raise TypeError(
        f"Object of type {type(value).__name__} "
        "is not JSON serializable"
    )


# --------------------------------------------------
# SOURCE RECORD COUNT
# --------------------------------------------------

def get_source_count(connection, table_name):

    cursor = connection.cursor()

    query = f"SELECT COUNT(*) FROM {table_name}"

    cursor.execute(query)

    count = cursor.fetchone()[0]

    cursor.close()

    return count


# --------------------------------------------------
# WRITE BATCH TO JSON
# --------------------------------------------------

def write_batch_to_json(
    records,
    output_folder,
    file_prefix,
    batch_number
):

    file_name = (
        f"{file_prefix}_batch_"
        f"{batch_number:03d}.json"
    )

    file_path = output_folder / file_name

    with open(
        file_path,
        "w",
        encoding="utf-8"
    ) as file:

        json.dump(
            records,
            file,
            default=json_serializer,
            indent=2
        )

    return file_path


# --------------------------------------------------
# EXTRACT TABLE IN BATCHES
# --------------------------------------------------

def extract_table(
    connection,
    table_name,
    output_folder,
    batch_size=1000
):

    cursor = connection.cursor()

    query = f"SELECT * FROM {table_name}"

    cursor.execute(query)

    columns = [
        column[0]
        for column in cursor.description
    ]

    file_prefix = table_name.split(".")[-1]

    batch_number = 1
    total_rows = 0

    while True:

        rows = cursor.fetchmany(batch_size)

        if not rows:
            break

        records = [
            dict(zip(columns, row))
            for row in rows
        ]

        file_path = write_batch_to_json(
            records=records,
            output_folder=output_folder,
            file_prefix=file_prefix,
            batch_number=batch_number
        )

        print(
            f"Batch {batch_number}: "
            f"{len(records)} records → "
            f"{file_path.name}"
        )

        total_rows += len(records)

        batch_number += 1

    cursor.close()

    return total_rows


# --------------------------------------------------
# RUN INGESTION
# --------------------------------------------------

def run_ingestion():

    base_dir = Path(__file__).resolve().parent

    output_folder = base_dir / OUTPUT_FOLDER

    output_folder.mkdir(
        exist_ok=True
    )

    connection = get_connection()

    print("Connected successfully!")

    source_count = get_source_count(
    connection,
    TABLE_NAME
)

    print(
        f"Source record count: "
        f"{source_count}"
    )

    extracted_count = extract_table(
    connection=connection,
    table_name=TABLE_NAME,
    output_folder=output_folder,
    batch_size=BATCH_SIZE
)

    print(
        f"Extracted record count: "
        f"{extracted_count}"
    )

    print(
        f"Difference: "
        f"{source_count - extracted_count}"
    )

    connection.close()


# --------------------------------------------------
# MAIN
# --------------------------------------------------

if __name__ == "__main__":

    run_ingestion()


############ Stage 1 Complete  ####################

'''
SQL Server
    ↓
Python
    ↓
Batch processing (1000 records)
    ↓
JSON serialization
    ↓
19 JSON files
    ↓
Local storage
    ↓
Reconciliation

'''