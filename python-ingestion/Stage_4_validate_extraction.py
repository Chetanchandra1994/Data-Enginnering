import json
from pathlib import Path


TABLE_NAME = "FactInternetSales"

FOLDER = (
    Path("storage_bucket")
    / "raw"
    / TABLE_NAME
)


records = []

files = sorted(
    FOLDER.glob(
        f"{TABLE_NAME}_batch_*.jsonl"
    )
)


print("=" * 50)
print("EXTRACTION VALIDATION")
print("=" * 50)

print(f"Files found: {len(files)}")


for file in files:

    with open(
        file,
        "r",
        encoding="utf-8"
    ) as f:

        for line in f:

            records.append(
                json.loads(line)
            )


total_rows = len(records)


unique_order_lines = len(
    {
        (
            record["SalesOrderNumber"],
            record["SalesOrderLineNumber"]
        )
        for record in records
    }
)


print(
    f"Total extracted rows: "
    f"{total_rows}"
)

print(
    f"Distinct order lines: "
    f"{unique_order_lines}"
)

print(
    f"Duplicate order lines: "
    f"{total_rows - unique_order_lines}"
)


if total_rows == 60398:
    print("PASS: Row count is correct.")
else:
    print("FAIL: Row count is incorrect.")


if unique_order_lines == 60398:
    print(
        "PASS: Order-line grain is unique."
    )
else:
    print(
        "FAIL: Duplicate order lines detected."
    )