import pyodbc
import json
# import os
from pathlib import Path
from datetime import date, datetime
from decimal import Decimal

def json_serializer(value):

    if isinstance(value, (date, datetime)):
        return value.isoformat()

    if isinstance(value, Decimal):
        return float(value)

    raise TypeError(
        f"Object of type {type(value).__name__} "
        "is not JSON serializable"
    )


connection = pyodbc.connect(
    "DRIVER={ODBC Driver 17 for SQL Server};"
    r"SERVER=CHETAN\SQLSERVER2022;"
    "DATABASE=AdventureWorksDW2022;"
    "Trusted_Connection=yes;"
    "TrustServerCertificate=yes;"
)

print("Connected successfully!")

cursor = connection.cursor()

cursor.execute("""
    SELECT 
        CustomerKey,
        CustomerAlternateKey,
        FirstName,
        MiddleName,
        LastName,
        BirthDate,
        Gender,
        EmailAddress,
        YearlyIncome,
        NumberCarsOwned,
        DateFirstPurchase
    FROM dbo.DimCustomer
""")

columns = [column[0] for column in cursor.description]

batch_size = 1000
batch_number = 1
total_rows = 0

# output_folder = "output"
# os.makedirs(output_folder, exist_ok=True)

BASE_DIR = Path(__file__).resolve().parent

OUTPUT_FOLDER = BASE_DIR / "output"

OUTPUT_FOLDER.mkdir(exist_ok=True)

while True:

    rows = cursor.fetchmany(batch_size)

    if not rows:
        break

    records = [
        dict(zip(columns, row))
        for row in rows
    ]

    json_data = json.dumps(
        records,
        #default=str,
        default= json_serializer,
        indent=2
    )

    # file_path = os.path.join(output_folder,file_name)

    # Create a new filename for each batch
    file_name = f"customer_batch_{batch_number:03d}.json"

    # Create the full path for this batch
    file_path = OUTPUT_FOLDER / file_name

    with open(file_path, "w", encoding="utf-8") as file:
        file.write(json_data)

    print(
        f"Batch {batch_number}: "
        f"{len(records)} records → {file_path}"
    )

    total_rows += len(records)
    batch_number += 1

print(f"Total records processed: {total_rows}")

connection.close()


######################    Stage 1  ################################
'''
┌─────────────────────────────┐
│ SQL Server                  │
│ AdventureWorksDW2022        │
│ dbo.DimCustomer             │
│                             │
│ 18,484 records              │
└──────────────┬──────────────┘
               │
               │ pyodbc
               ▼
┌─────────────────────────────┐
│ Python Extraction           │
│                             │
│ cursor.execute()            │
│ cursor.description          │
│ fetchmany(1000)             │
└──────────────┬──────────────┘
               │
               ▼
┌─────────────────────────────┐
│ JSON Serialization          │
│                             │
│ date → ISO string           │
│ Decimal → JSON number       │
└──────────────┬──────────────┘
               │
               ▼
┌─────────────────────────────┐
│ 19 JSON Files               │
│                             │
│ 18 × 1000 records           │
│ 1 × 484 records             │
│ Total = 18,484              │
└─────────────────────────────┘
'''


######################    Stage 1  ################################
'''
┌─────────────────────────────┐
│ SQL Server                  │
│ AdventureWorksDW2022        │
│ dbo.DimCustomer             │
│                             │
│ 18,484 records              │
└──────────────┬──────────────┘
               │
               │ pyodbc
               ▼
┌─────────────────────────────┐
│ Python Extraction           │
│                             │
│ cursor.execute()            │
│ cursor.description          │
│ fetchmany(1000)             │
└──────────────┬──────────────┘
               │
               ▼
┌─────────────────────────────┐
│ JSON Serialization          │
│                             │
│ date → ISO string           │
│ Decimal → JSON number       │
└──────────────┬──────────────┘
               │
               ▼
┌─────────────────────────────┐
│ 19 JSON Files               │
│                             │
│ 18 × 1000 records           │
│ 1 × 484 records             │
│ Total = 18,484              │
└─────────────────────────────┘
'''

