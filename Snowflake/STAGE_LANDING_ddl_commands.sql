CREATE DATABASE IF NOT EXISTS ADVWORKS_DEV;

CREATE SCHEMA IF NOT EXISTS ADVWORKS_DEV.LANDING;
CREATE SCHEMA IF NOT EXISTS ADVWORKS_DEV.PREPARE;
CREATE SCHEMA IF NOT EXISTS ADVWORKS_DEV.NORMALIZE;
CREATE SCHEMA IF NOT EXISTS ADVWORKS_DEV.SCHEMATIZE;
CREATE SCHEMA IF NOT EXISTS ADVWORKS_DEV.MARKETPLACE;

SHOW DATABASES;

SHOW SCHEMAS IN DATABASE ADVWORKS_DEV;

USE WAREHOUSE ETL_WH_DEV;

SELECT CURRENT_WAREHOUSE();

SELECT
    CURRENT_ACCOUNT(),
    CURRENT_USER(),
    CURRENT_ROLE(),
    CURRENT_REGION();

SELECT CURRENT_WAREHOUSE();

SHOW WAREHOUSES;

USE DATABASE ADVWORKS_DEV;

USE SCHEMA LANDING;

CREATE OR REPLACE STAGE DIMCUSTOMER_STAGE
    FILE_FORMAT = (
        TYPE = JSON
    );
CREATE OR REPLACE STAGE DIMPRODUCT_STAGE
    FILE_FORMAT = (
        TYPE = JSON
    );
CREATE OR REPLACE STAGE FACTINTERNETSALES_STAGE
    FILE_FORMAT = (
        TYPE = JSON
    );

SHOW STAGES;
DESC STAGE DIMCUSTOMER_STAGE;
LIST @DIMCUSTOMER_STAGE;
LIST @ADVWORKS_DEV.LANDING.DIMCUSTOMER_STAGE;

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

--#######################################################################################################################
CREATE OR REPLACE TABLE ADVWORKS_DEV.LANDING.DIMPRODUCT_RAW
(
    RECORD VARIANT,
    SOURCE_FILE VARCHAR,
    LOAD_TIMESTAMP TIMESTAMP_NTZ
);
CREATE OR REPLACE TABLE ADVWORKS_DEV.LANDING.FACTINTERNETSALES_RAW
(
    RECORD VARIANT,
    SOURCE_FILE VARCHAR,
    LOAD_TIMESTAMP TIMESTAMP_NTZ
);

--— Load JSONL into LANDING
COPY INTO ADVWORKS_DEV.LANDING.DIMPRODUCT_RAW
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
    FROM @ADVWORKS_DEV.LANDING.DIMPRODUCT_STAGE
)
FILE_FORMAT = (
    TYPE = JSON
);

COPY INTO ADVWORKS_DEV.LANDING.FACTINTERNETSALES_RAW
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
    FROM @ADVWORKS_DEV.LANDING.FACTINTERNETSALES_STAGE
)
FILE_FORMAT = (
    TYPE = JSON
);

--validate
SELECT COUNT(*) AS LANDING_COUNT
FROM ADVWORKS_DEV.LANDING.FACTINTERNETSALES_RAW; --60398

SELECT
    SOURCE_FILE,
    COUNT(*) AS RECORD_COUNT
FROM ADVWORKS_DEV.LANDING.FACTINTERNETSALES_RAW
GROUP BY SOURCE_FILE
ORDER BY SOURCE_FILE;
/*
SOURCE_FILE	RECORD_COUNT
FactInternetSales_batch_001.jsonl	5000
FactInternetSales_batch_002.jsonl	5000
FactInternetSales_batch_003.jsonl	5000
FactInternetSales_batch_004.jsonl	5000
FactInternetSales_batch_005.jsonl	5000
FactInternetSales_batch_006.jsonl	5000
FactInternetSales_batch_007.jsonl	5000
FactInternetSales_batch_008.jsonl	5000
FactInternetSales_batch_009.jsonl	5000
FactInternetSales_batch_010.jsonl	5000
FactInternetSales_batch_011.jsonl	5000
FactInternetSales_batch_012.jsonl	5000
FactInternetSales_batch_013.jsonl	398
*/

-- Inspect the JSON
SELECT
    RECORD:ProductKey::INTEGER AS PRODUCT_KEY,
    RECORD:CustomerKey::INTEGER AS CUSTOMER_KEY,
    RECORD:OrderDateKey::INTEGER AS ORDER_DATE_KEY,
    RECORD:SalesOrderNumber::VARCHAR AS SALES_ORDER_NUMBER,
    RECORD:SalesOrderLineNumber::INTEGER AS SALES_ORDER_LINE_NUMBER,
    RECORD:SalesAmount::NUMBER(18,2) AS SALES_AMOUNT,
    SOURCE_FILE
FROM ADVWORKS_DEV.LANDING.FACTINTERNETSALES_RAW
ORDER BY SALES_ORDER_NUMBER
LIMIT 10;
/*
PRODUCT_KEY	CUSTOMER_KEY	ORDER_DATE_KEY	SALES_ORDER_NUMBER	SALES_ORDER_LINE_NUMBER	SALES_AMOUNT	SOURCE_FILE
310	21768	20101229	SO43697	1	3578.27	FactInternetSales_batch_003.jsonl
346	28389	20101229	SO43698	1	3399.99	FactInternetSales_batch_003.jsonl
346	25863	20101229	SO43699	1	3399.99	FactInternetSales_batch_003.jsonl
336	14501	20101229	SO43700	1	699.10	FactInternetSales_batch_003.jsonl
346	11003	20101229	SO43701	1	3399.99	FactInternetSales_batch_003.jsonl
311	27645	20101230	SO43702	1	3578.27	FactInternetSales_batch_003.jsonl
310	16624	20101230	SO43703	1	3578.27	FactInternetSales_batch_003.jsonl
351	11005	20101230	SO43704	1	3374.99	FactInternetSales_batch_003.jsonl
344	11011	20101230	SO43705	1	3399.99	FactInternetSales_batch_003.jsonl
312	27621	20101231	SO43706	1	3578.27	FactInternetSales_batch_003.jsonl
*/

SELECT
    RECORD,
    SOURCE_FILE,
    LOAD_TIMESTAMP
FROM LANDING.DIMPRODUCT_RAW
LIMIT 10;
--#######################################################################################################################

SELECT COUNT(*) AS LANDING_COUNT
FROM ADVWORKS_DEV.LANDING.DIMCUSTOMER_RAW;

SELECT COUNT(*) AS LANDING_COUNT
FROM ADVWORKS_DEV.LANDING.DIMPRODUCT_RAW;

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

TRUNCATE TABLE ADVWORKS_DEV.LANDING.FACTINTERNETSALES_RAW;
SELECT COUNT(*)
FROM ADVWORKS_DEV.LANDING.FACTINTERNETSALES_RAW;

LIST @ADVWORKS_DEV.LANDING.FACTINTERNETSALES_STAGE;

-- name	size	md5	last_modified
-- factinternetsales_stage/FactInternetSales_batch_001.jsonl	3292480	2815efa6e93cc271ae5c344cdb4432d8	Thu, 3 Sep 2026 16:32:49 GMT
-- factinternetsales_stage/FactInternetSales_batch_002.jsonl	3281872	e8a26379c1d8b947661dd85041ee798b	Thu, 3 Sep 2026 16:32:49 GMT
-- factinternetsales_stage/FactInternetSales_batch_003.jsonl	3351568	95ace076fe137ee2d090dc04dee30df4	Thu, 3 Sep 2026 16:32:49 GMT
-- factinternetsales_stage/FactInternetSales_batch_004.jsonl	3357648	f9e0b2dc32b65f0f20ee51d363c20548	Thu, 3 Sep 2026 16:32:49 GMT
-- factinternetsales_stage/FactInternetSales_batch_005.jsonl	3275888	f852f6002deb22802f127d117b61b6a1	Thu, 3 Sep 2026 16:32:49 GMT
-- factinternetsales_stage/FactInternetSales_batch_006.jsonl	3267568	fe473ed972e5412592fbd9d2a62a7ce4	Thu, 3 Sep 2026 16:32:52 GMT
-- factinternetsales_stage/FactInternetSales_batch_007.jsonl	3266000	79850ee1c0c4d6d6b5930850592f391f	Thu, 3 Sep 2026 16:32:55 GMT
-- factinternetsales_stage/FactInternetSales_batch_008.jsonl	3280560	fe577627c9310537846f6aadbc09e035	Thu, 3 Sep 2026 16:32:55 GMT
-- factinternetsales_stage/FactInternetSales_batch_009.jsonl	3270704	adcf8fa9ae3300390a82b852d64ec533	Thu, 3 Sep 2026 16:32:55 GMT
-- factinternetsales_stage/FactInternetSales_batch_010.jsonl	3274144	4b384baa9111df41a79e56b89a2d0fff	Thu, 3 Sep 2026 16:32:55 GMT
-- factinternetsales_stage/FactInternetSales_batch_011.jsonl	3274288	7a8b10dff4fa96953640b062ca97ded9	Thu, 3 Sep 2026 16:32:56 GMT
-- factinternetsales_stage/FactInternetSales_batch_012.jsonl	3336208	e4ac1086af332ce5ba169a9226a63398	Thu, 3 Sep 2026 16:32:57 GMT
-- factinternetsales_stage/FactInternetSales_batch_013.jsonl	264848	db92f289ced62fcb3fb9924ebc0d5290	Thu, 3 Sep 2026 16:32:56 GMT

REMOVE @ADVWORKS_DEV.LANDING.FACTINTERNETSALES_STAGE;
LIST @ADVWORKS_DEV.LANDING.FACTINTERNETSALES_STAGE;

TRUNCATE TABLE ADVWORKS_DEV.LANDING.FACTINTERNETSALES_RAW;

COPY INTO ADVWORKS_DEV.LANDING.FACTINTERNETSALES_RAW
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
    FROM @ADVWORKS_DEV.LANDING.FACTINTERNETSALES_STAGE
)
FILE_FORMAT = (
    TYPE = JSON
);

/*
file	status	rows_parsed	rows_loaded	error_limit	errors_seen	first_error	first_error_line	first_error_character	first_error_column_name
factinternetsales_stage/FactInternetSales_batch_005.jsonl	LOADED	5000	5000	1	0				
factinternetsales_stage/FactInternetSales_batch_004.jsonl	LOADED	5000	5000	1	0				
factinternetsales_stage/FactInternetSales_batch_007.jsonl	LOADED	5000	5000	1	0				
factinternetsales_stage/FactInternetSales_batch_002.jsonl	LOADED	5000	5000	1	0				
factinternetsales_stage/FactInternetSales_batch_013.jsonl	LOADED	398	398	1	0				
factinternetsales_stage/FactInternetSales_batch_001.jsonl	LOADED	5000	5000	1	0				
factinternetsales_stage/FactInternetSales_batch_011.jsonl	LOADED	5000	5000	1	0				
factinternetsales_stage/FactInternetSales_batch_003.jsonl	LOADED	5000	5000	1	0				
factinternetsales_stage/FactInternetSales_batch_009.jsonl	LOADED	5000	5000	1	0				
factinternetsales_stage/FactInternetSales_batch_006.jsonl	LOADED	5000	5000	1	0				
factinternetsales_stage/FactInternetSales_batch_012.jsonl	LOADED	5000	5000	1	0				
factinternetsales_stage/FactInternetSales_batch_008.jsonl	LOADED	5000	5000	1	0				
factinternetsales_stage/FactInternetSales_batch_010.jsonl	LOADED	5000	5000	1	0				
*/

-- 1. Row count
SELECT COUNT(*) AS LANDING_COUNT
FROM ADVWORKS_DEV.LANDING.FACTINTERNETSALES_RAW; -- 60398

-- 2. Validate order-line grain
SELECT
    COUNT(*) AS TOTAL_ROWS,
    COUNT(DISTINCT CONCAT(
        RECORD:SalesOrderNumber::VARCHAR,
        '|',
        RECORD:SalesOrderLineNumber::INTEGER
    )) AS DISTINCT_ORDER_LINES
FROM ADVWORKS_DEV.LANDING.FACTINTERNETSALES_RAW;

/*
TOTAL_ROWS	DISTINCT_ORDER_LINES
60398	60398
*/

-- duplicate
SELECT
    RECORD:SalesOrderNumber::VARCHAR AS SALES_ORDER_NUMBER,
    RECORD:SalesOrderLineNumber::INTEGER AS SALES_ORDER_LINE_NUMBER,
    COUNT(*) AS ROW_COUNT
FROM ADVWORKS_DEV.LANDING.FACTINTERNETSALES_RAW
GROUP BY
    RECORD:SalesOrderNumber::VARCHAR,
    RECORD:SalesOrderLineNumber::INTEGER
HAVING COUNT(*) > 1
ORDER BY SALES_ORDER_NUMBER; -- Query produced no results