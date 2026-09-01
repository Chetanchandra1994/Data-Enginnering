import pyodbc

connection = pyodbc.connect(
    "DRIVER={ODBC Driver 17 for SQL Server};"
    r"SERVER=CHETAN\SQLSERVER2022;"
    "DATABASE=AdventureWorksDW2022;"
    "Trusted_Connection=yes;"
    "TrustServerCertificate=yes;"
)

print("Connected successfully!")

connection.close()