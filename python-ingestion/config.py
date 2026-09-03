# config.py

# --------------------------------------------------
# SQL SERVER
# --------------------------------------------------

SQL_SERVER = r"CHETAN\SQLSERVER2022"
DATABASE = "AdventureWorksDW2022"

# Table we want to ingest
#TABLE_NAME = "dbo.DimCustomer"
#TABLE_NAME = "dbo.DimProduct"
#TABLE_NAME = "dbo.DimProductCategory"
#TABLE_NAME = "dbo.DimProductSubcategory"
TABLE_NAME = "dbo.FactInternetSales"

# Deterministic ordering for batch extraction
ORDER_BY_COLUMNS = [
    "SalesOrderNumber",
    "SalesOrderLineNumber"
]


# --------------------------------------------------
# INGESTION
# --------------------------------------------------

BATCH_SIZE = 5000


# # --------------------------------------------------
# # LOCAL STORAGE
# # --------------------------------------------------

# OUTPUT_FOLDER = "output"

# STORAGE_FOLDER = "storage_bucket"

# STORAGE_PREFIX = "raw"

# --------------------------------------------------
# STORAGE
# --------------------------------------------------

# Storage backend
# Currently supported:
#   local
#   gcs (will be implemented later)
STORAGE_TYPE = "local"

# Local storage
STORAGE_FOLDER = "storage_bucket"

# Common storage path
STORAGE_PREFIX = "raw"

# Local output folder
OUTPUT_FOLDER = "output"

