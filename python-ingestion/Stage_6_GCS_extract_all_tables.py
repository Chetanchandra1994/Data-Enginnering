import pyodbc
import json
import base64
from decimal import Decimal
from datetime import date, datetime
from pathlib import Path

from google.cloud import storage


# ============================================================
# CONFIGURATION
# ============================================================

SQL_SERVER = r"CHETAN\SQLSERVER2022"
DATABASE = "AdventureWorksDW2022"

BATCH_SIZE = 1000

GCS_BUCKET_NAME = "advworks-dev-ingestion"


# ============================================================
# TABLE CONFIGURATION
# ============================================================

TABLES = {

    "DimCustomer": {

        "source_table": "dbo.DimCustomer",

        "gcs_folder": "dim_customer",

        "local_folder": Path(
            "output/dim_customer"
        ),

        "file_prefix": "DimCustomer_batch",

        "order_by": [
            "CustomerKey"
        ]
    },

    "DimProduct": {

        "source_table": "dbo.DimProduct",

        "gcs_folder": "dim_product",

        "local_folder": Path(
            "output/dim_product"
        ),

        "file_prefix": "DimProduct_batch",

        "order_by": [
            "ProductKey"
        ]
    }
}


# ============================================================
# JSON SERIALIZER
# ============================================================

def json_serializer(value):

    if isinstance(value, (datetime, date)):
        return value.isoformat()

    if isinstance(value, Decimal):
        return float(value)

    if isinstance(value, bytes):
        return base64.b64encode(value).decode("utf-8")

    raise TypeError(
        f"Type {type(value)} is not JSON serializable"
    )


# ============================================================
# SQL SERVER CONNECTION
# ============================================================

def create_connection():

    connection_string = (
        "DRIVER={ODBC Driver 17 for SQL Server};"
        f"SERVER={SQL_SERVER};"
        f"DATABASE={DATABASE};"
        "Trusted_Connection=yes;"
        "TrustServerCertificate=yes;"
    )

    connection = pyodbc.connect(
        connection_string
    )

    print("Connected successfully!")

    return connection


# ============================================================
# GCS CLIENT
# ============================================================

def create_gcs_client():

    client = storage.Client()

    print(
        "Connected to Google Cloud Storage successfully!"
    )

    return client


# ============================================================
# VALIDATE GCS BUCKET
# ============================================================

def validate_gcs_bucket(client):

    bucket = client.bucket(
        GCS_BUCKET_NAME
    )

    if not bucket.exists():

        raise RuntimeError(
            f"GCS bucket does not exist: "
            f"gs://{GCS_BUCKET_NAME}"
        )

    print(
        f"GCS bucket validated: "
        f"gs://{GCS_BUCKET_NAME}"
    )

    return bucket


# ============================================================
# SOURCE COUNT
# ============================================================

def get_source_count(
    connection,
    source_table
):

    query = f"""
        SELECT COUNT(*)
        FROM {source_table}
    """

    cursor = connection.cursor()

    cursor.execute(query)

    count = cursor.fetchone()[0]

    cursor.close()

    return count


# ============================================================
# GET SOURCE COLUMNS
# ============================================================

def get_columns(
    connection,
    source_table
):

    schema_name, table_name = (
        source_table.split(".")
    )

    query = """
        SELECT COLUMN_NAME
        FROM INFORMATION_SCHEMA.COLUMNS
        WHERE TABLE_SCHEMA = ?
          AND TABLE_NAME = ?
        ORDER BY ORDINAL_POSITION
    """

    cursor = connection.cursor()

    cursor.execute(
        query,
        schema_name,
        table_name
    )

    columns = [
        row[0]
        for row in cursor.fetchall()
    ]

    cursor.close()

    return columns


# ============================================================
# VALIDATE ORDER COLUMNS
# ============================================================

def validate_order_columns(
    columns,
    order_by_columns
):

    missing_columns = [

        column
        for column in order_by_columns

        if column not in columns
    ]

    if missing_columns:

        raise ValueError(
            "ORDER_BY_COLUMNS contains columns "
            f"not found in source table: "
            f"{missing_columns}"
        )


# ============================================================
# EXTRACT BATCH
# ============================================================

def extract_batch(
    connection,
    source_table,
    columns,
    order_by_columns,
    offset,
    batch_size
):

    column_list = ", ".join(
        f"[{column}]"
        for column in columns
    )

    order_by = ", ".join(
        f"[{column}]"
        for column in order_by_columns
    )

    query = f"""
        SELECT {column_list}

        FROM {source_table}

        ORDER BY {order_by}

        OFFSET ? ROWS

        FETCH NEXT ? ROWS ONLY
    """

    cursor = connection.cursor()

    cursor.execute(
        query,
        offset,
        batch_size
    )

    rows = cursor.fetchall()

    cursor.close()

    records = []

    for row in rows:

        record = dict(
            zip(columns, row)
        )

        records.append(record)

    return records


# ============================================================
# CONVERT RECORDS TO JSONL
# ============================================================

def records_to_jsonl(records):

    lines = []

    for record in records:

        lines.append(
            json.dumps(
                record,
                default=json_serializer
            )
        )

    return "\n".join(lines) + "\n"


# ============================================================
# WRITE LOCAL JSONL
# ============================================================

def write_local_jsonl(
    records,
    output_file
):

    with open(
        output_file,
        "w",
        encoding="utf-8"
    ) as file:

        file.write(
            records_to_jsonl(records)
        )


# ============================================================
# UPLOAD JSONL TO GCS
# ============================================================

def upload_to_gcs(
    bucket,
    records,
    gcs_folder,
    filename
):

    blob_name = (
        f"{gcs_folder}/"
        f"{filename}"
    )

    blob = bucket.blob(
        blob_name
    )

    jsonl_data = records_to_jsonl(
        records
    )

    blob.upload_from_string(
        jsonl_data,
        content_type="application/json"
    )

    print(
        f"Uploaded to GCS: "
        f"gs://{GCS_BUCKET_NAME}/"
        f"{blob_name}"
    )

    return blob_name


# ============================================================
# INGEST ONE TABLE
# ============================================================

def ingest_table(
    connection,
    bucket,
    table_name,
    config
):

    print()
    print("=" * 70)
    print(
        f"INGESTING {table_name}"
    )
    print("=" * 70)

    source_table = config[
        "source_table"
    ]

    gcs_folder = config[
        "gcs_folder"
    ]

    local_folder = config[
        "local_folder"
    ]

    file_prefix = config[
        "file_prefix"
    ]

    order_by_columns = config[
        "order_by"
    ]

    # --------------------------------------------------------
    # SOURCE COUNT
    # --------------------------------------------------------

    source_count = get_source_count(
        connection,
        source_table
    )

    print(
        f"Source table: {source_table}"
    )

    print(
        f"Source record count: "
        f"{source_count}"
    )

    # --------------------------------------------------------
    # COLUMNS
    # --------------------------------------------------------

    columns = get_columns(
        connection,
        source_table
    )

    print(
        f"Source columns discovered: "
        f"{len(columns)}"
    )

    for column in columns:

        print(
            f"  - {column}"
        )

    # --------------------------------------------------------
    # VALIDATE ORDER
    # --------------------------------------------------------

    validate_order_columns(
        columns,
        order_by_columns
    )

    print(
        "ORDER BY: "
        + ", ".join(order_by_columns)
    )

    # --------------------------------------------------------
    # LOCAL FOLDER
    # --------------------------------------------------------

    local_folder.mkdir(
        parents=True,
        exist_ok=True
    )

    # --------------------------------------------------------
    # BATCH PROCESSING
    # --------------------------------------------------------

    extracted_count = 0

    batch_number = 1

    offset = 0

    while offset < source_count:

        records = extract_batch(
            connection,
            source_table,
            columns,
            order_by_columns,
            offset,
            BATCH_SIZE
        )

        if not records:

            break

        filename = (
            f"{file_prefix}_"
            f"{batch_number:03d}.jsonl"
        )

        # ----------------------------------------------------
        # LOCAL COPY
        # ----------------------------------------------------

        output_file = (
            local_folder /
            filename
        )

        write_local_jsonl(
            records,
            output_file
        )

        # ----------------------------------------------------
        # GCS UPLOAD
        # ----------------------------------------------------

        upload_to_gcs(
            bucket,
            records,
            gcs_folder,
            filename
        )

        # ----------------------------------------------------
        # VALIDATION
        # ----------------------------------------------------

        record_count = len(records)

        extracted_count += record_count

        print(
            f"Batch "
            f"{batch_number:03d}: "
            f"{record_count} records"
        )

        offset += BATCH_SIZE

        batch_number += 1

    # --------------------------------------------------------
    # FINAL VALIDATION
    # --------------------------------------------------------

    print()
    print("-" * 70)
    print(
        f"{table_name} INGESTION VALIDATION"
    )
    print("-" * 70)

    print(
        f"Source count:    "
        f"{source_count}"
    )

    print(
        f"Extracted count: "
        f"{extracted_count}"
    )

    difference = (
        source_count -
        extracted_count
    )

    print(
        f"Difference:      "
        f"{difference}"
    )

    if difference != 0:

        raise Exception(
            f"{table_name}: "
            "Source and extracted "
            "counts do not match."
        )

    print()
    print(
        f"SUCCESS: {table_name} "
        "ingestion completed."
    )


# ============================================================
# MAIN
# ============================================================

def run_ingestion():

    print("=" * 70)
    print(
        "STAGE 6 - DIMENSION GCS INGESTION"
    )
    print("=" * 70)

    connection = create_connection()

    gcs_client = create_gcs_client()

    bucket = validate_gcs_bucket(
        gcs_client
    )

    try:

        for table_name, config in TABLES.items():

            ingest_table(
                connection,
                bucket,
                table_name,
                config
            )

    finally:

        connection.close()

    print()
    print("=" * 70)
    print(
        "ALL DIMENSION INGESTION COMPLETED"
    )
    print("=" * 70)


# ============================================================
# ENTRY POINT
# ============================================================

if __name__ == "__main__":

    run_ingestion()