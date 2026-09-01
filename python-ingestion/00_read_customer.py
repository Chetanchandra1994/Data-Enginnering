import pyodbc
import json
from datetime import date
from decimal import Decimal

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

while True:

    rows = cursor.fetchmany(batch_size)

    if not rows:
        break

    records = [
        dict(zip(columns, row))
        for row in rows
    ]

    # json_data = json.dumps(records, default = str)

    print(
        f"Batch {batch_number}: "
        f"{len(records)} records"
    )

    total_rows += len(records)
    batch_number += 1

print(f"Total records processed: {total_rows}")
print(records[0])
connection.close()