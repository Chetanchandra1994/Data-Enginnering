import pyodbc
import json
import base64
from decimal import Decimal
from datetime import date, datetime
from pathlib import Path


# ============================================================
# CONFIGURATION
# ============================================================

SQL_SERVER = r"CHETAN\SQLSERVER2022"
DATABASE = "AdventureWorksDW2022"

TABLE_NAME = "dbo.FactInternetSales"

BATCH_SIZE = 1000

STORAGE_FOLDER = Path("output/fact_internet_sales")

ORDER_BY_COLUMNS = [
    "SalesOrderNumber",
    "SalesOrderLineNumber"
]


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

    connection = pyodbc.connect(connection_string)

    print("Connected successfully!")

    return connection


# ============================================================
# SOURCE COUNT
# ============================================================

def get_source_count(connection):

    query = f"""
        SELECT COUNT(*)
        FROM {TABLE_NAME}
    """

    cursor = connection.cursor()

    cursor.execute(query)

    count = cursor.fetchone()[0]

    cursor.close()

    return count


# ============================================================
# GET SOURCE COLUMNS
# ============================================================

def get_columns(connection):

    query = """
        SELECT COLUMN_NAME
        FROM INFORMATION_SCHEMA.COLUMNS
        WHERE TABLE_SCHEMA = ?
          AND TABLE_NAME = ?
        ORDER BY ORDINAL_POSITION
    """

    schema_name, table_name = TABLE_NAME.split(".")

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

def validate_order_columns(columns):

    missing_columns = [
        column
        for column in ORDER_BY_COLUMNS
        if column not in columns
    ]

    if missing_columns:

        raise ValueError(
            "ORDER_BY_COLUMNS contains columns "
            f"not found in source table: {missing_columns}"
        )


# ============================================================
# EXTRACT BATCH
# ============================================================

def extract_batch(
    connection,
    columns,
    offset,
    batch_size
):

    column_list = ", ".join(
        f"[{column}]"
        for column in columns
    )

    order_by = ", ".join(
        f"[{column}]"
        for column in ORDER_BY_COLUMNS
    )

    query = f"""
        SELECT {column_list}
        FROM {TABLE_NAME}
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
# WRITE JSONL
# ============================================================

def write_jsonl(records, output_file):

    with open(
        output_file,
        "w",
        encoding="utf-8"
    ) as file:

        for record in records:

            file.write(
                json.dumps(
                    record,
                    default=json_serializer
                )
                + "\n"
            )


# ============================================================
# MAIN INGESTION
# ============================================================

def run_ingestion():

    print("=" * 60)
    print("STAGE 6 - FACT INTERNET SALES EXTRACTION")
    print("=" * 60)

    connection = create_connection()

    source_count = get_source_count(connection)

    print(
        f"Source record count: {source_count}"
    )

    columns = get_columns(connection)

    print(
        f"Source columns discovered: {len(columns)}"
    )

    print(
        "Columns:"
    )

    for column in columns:
        print(f"  - {column}")

    validate_order_columns(columns)

    print(
        f"Table: {TABLE_NAME}"
    )

    print(
        "ORDER BY: "
        + ", ".join(ORDER_BY_COLUMNS)
    )

    STORAGE_FOLDER.mkdir(
        parents=True,
        exist_ok=True
    )

    extracted_count = 0
    batch_number = 1
    offset = 0

    while offset < source_count:

        records = extract_batch(
            connection,
            columns,
            offset,
            BATCH_SIZE
        )

        if not records:
            break

        filename = (
            f"FactInternetSales_batch_"
            f"{batch_number:03d}.jsonl"
        )

        output_file = (
            STORAGE_FOLDER / filename
        )

        write_jsonl(
            records,
            output_file
        )

        record_count = len(records)

        extracted_count += record_count

        print(
            f"Batch {batch_number:03d}: "
            f"{record_count} records -> "
            f"{filename}"
        )

        offset += BATCH_SIZE
        batch_number += 1

    connection.close()

    print()
    print("-" * 60)
    print("INGESTION VALIDATION")
    print("-" * 60)

    print(
        f"Source count:    {source_count}"
    )

    print(
        f"Extracted count: {extracted_count}"
    )

    difference = (
        source_count - extracted_count
    )

    print(
        f"Difference:      {difference}"
    )

    if difference == 0:

        print()
        print(
            "SUCCESS: Source and extracted "
            "record counts match."
        )

    else:

        print()
        raise Exception(
            "FAILED: Source and extracted "
            "record counts do not match."
        )


if __name__ == "__main__":
    run_ingestion()