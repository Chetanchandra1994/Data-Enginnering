# config.py

# --------------------------------------------------
# SQL SERVER
# --------------------------------------------------

SQL_SERVER = r"CHETAN\SQLSERVER2022"
DATABASE = "AdventureWorksDW2022"

# Table we want to ingest
TABLE_NAME = "dbo.DimCustomer"
#TABLE_NAME = "dbo.DimProduct"
#TABLE_NAME = "dbo.DimProductCategory"
#TABLE_NAME = "dbo.DimProductSubcategory"


# --------------------------------------------------
# INGESTION
# --------------------------------------------------

BATCH_SIZE = 5000


# --------------------------------------------------
# LOCAL STORAGE
# --------------------------------------------------

OUTPUT_FOLDER = "output"

STORAGE_FOLDER = "storage_bucket"

STORAGE_PREFIX = "raw"