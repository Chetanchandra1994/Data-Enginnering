--Create the LANDING raw table
--Now we're going to use one of the most important concepts in your Canam-style architecture:
--Raw data should initially remain raw.
--We don't want to immediately create 30 typed columns.
--Instead, we'll initially land each JSON record as a Snowflake VARIANT.

CREATE OR REPLACE TABLE ADVWORKS_DEV.LANDING.DIMCUSTOMER_RAW
(
    RECORD VARIANT,
    SOURCE_FILE VARCHAR,
    LOAD_TIMESTAMP TIMESTAMP_NTZ
);

--— Load JSONL into LANDING
COPY INTO ADVWORKS_DEV.LANDING.DIMCUSTOMER_RAW
(
    RECORD,
    SOURCE_FILE,
    LOAD_TIMESTAMP
)
FROM
(
    SELECT
        $1,
        METADATA$FILENAME,
        CURRENT_TIMESTAMP()
    FROM @ADVWORKS_DEV.LANDING.DIMCUSTOMER_STAGE
)
FILE_FORMAT = (
    TYPE = JSON
);

SELECT COUNT(*) AS LANDING_COUNT
FROM ADVWORKS_DEV.LANDING.DIMCUSTOMER_RAW;

SELECT
    RECORD:CustomerKey::INTEGER AS CUSTOMER_KEY,
    RECORD:FirstName::VARCHAR AS FIRST_NAME,
    RECORD:LastName::VARCHAR AS LAST_NAME,
    SOURCE_FILE,
    LOAD_TIMESTAMP
FROM ADVWORKS_DEV.LANDING.DIMCUSTOMER_RAW
LIMIT 10;

SELECT
    SOURCE_FILE,
    COUNT(*) AS RECORD_COUNT
FROM ADVWORKS_DEV.LANDING.DIMCUSTOMER_RAW
GROUP BY SOURCE_FILE
ORDER BY SOURCE_FILE;

SELECT
    RECORD:CustomerKey::INTEGER AS CUSTOMER_KEY,
    COUNT(*) AS CNT
FROM ADVWORKS_DEV.LANDING.DIMCUSTOMER_RAW
GROUP BY RECORD:CustomerKey::INTEGER
HAVING COUNT(*) > 1
ORDER BY CNT DESC; --Query produced no results

SELECT
    MIN(RECORD:CustomerKey::INTEGER) AS MIN_CUSTOMER_KEY,
    MAX(RECORD:CustomerKey::INTEGER) AS MAX_CUSTOMER_KEY,
    COUNT(DISTINCT RECORD:CustomerKey::INTEGER) AS DISTINCT_CUSTOMERS
FROM ADVWORKS_DEV.LANDING.DIMCUSTOMER_RAW;
/*
MIN_CUSTOMER_KEY	MAX_CUSTOMER_KEY	DISTINCT_CUSTOMERS
11000	29483	18484
*/
/*

Why this design is important for your interview

You can now explain:

"I extracted source data from SQL Server in batches using Python and wrote it as JSONL files. The files were then landed in cloud/object storage. Snowflake ingests the raw JSON into a VARIANT-based landing table, preserving the original payload while capturing source-file metadata and load timestamp. Downstream layers then perform standardization and modeling."

That's considerably closer to a real data-engineering architecture than simply loading CSV into a Snowflake table.

Our target architecture from here

After this step we'll build:

                    SOURCE
                       │
                       ▼
              SQL Server / SSMS
                       │
                       ▼
                Python / pyodbc
                       │
                 Batch 5,000
                       │
                       ▼
                    JSONL
                       │
                       ▼
             ┌─────────────────┐
             │ Local Storage   │
             │ GCS simulation  │
             └────────┬────────┘
                      │
                      ▼
          ┌───────────────────────┐
          │ Snowflake Stage       │
          │ DIMCUSTOMER_STAGE     │
          └───────────┬───────────┘
                      │
                 COPY INTO
                      │
                      ▼
          ┌───────────────────────┐
          │ LANDING               │
          │ DIMCUSTOMER_RAW       │
          │                       │
          │ RECORD VARIANT        │
          │ SOURCE_FILE           │
          │ LOAD_TIMESTAMP        │
          └───────────┬───────────┘
                      │
                      ▼
                   PREPARE
                      │
                      ▼
                  NORMALIZE
                      │
                      ▼
                 SCHEMATIZE
                      │
                      ▼
                 MARKETPLACE
                      │
                      ▼
                    dbt
                      │
                      ▼
                  Tableau

*/