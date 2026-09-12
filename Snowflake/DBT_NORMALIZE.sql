SELECT COUNT(*) AS ROW_COUNT
FROM ADVWORKS_DEV.NORMALIZE.FACT_INTERNET_SALES_NORMALIZE;
/*
ROW_COUNT
1000
*/

SELECT
    COUNT(*) AS TOTAL_ROWS,

    COUNT_IF(PRODUCT_KEY IS NULL) AS NULL_PRODUCT_KEY,
    COUNT_IF(CUSTOMER_KEY IS NULL) AS NULL_CUSTOMER_KEY,
    COUNT_IF(SALES_ORDER_NUMBER IS NULL) AS NULL_ORDER_NUMBER,
    COUNT_IF(SALES_ORDER_LINE_NUMBER IS NULL) AS NULL_ORDER_LINE,
    COUNT_IF(SALES_AMOUNT IS NULL) AS NULL_SALES_AMOUNT,

    COUNT(DISTINCT
        SALES_ORDER_NUMBER || '-' || SALES_ORDER_LINE_NUMBER
    ) AS DISTINCT_ORDER_LINES

FROM ADVWORKS_DEV.NORMALIZE.FACT_INTERNET_SALES_NORMALIZE;
/*
TOTAL_ROWS	NULL_PRODUCT_KEY	NULL_CUSTOMER_KEY	NULL_ORDER_NUMBER	NULL_ORDER_LINE	NULL_SALES_AMOUNT	DISTINCT_ORDER_LINES
1000	0	0	0	0	0	1000
*/

-- transformations check
SELECT
    SALES_ORDER_NUMBER,
    SALES_ORDER_LINE_NUMBER,

    UNIT_PRICE,
    EXTENDED_AMOUNT,
    SALES_AMOUNT,
    TAX_AMT,
    FREIGHT,

    ORDER_DATE,
    DUE_DATE,
    SHIP_DATE,

    CARRIER_TRACKING_NUMBER,
    CUSTOMER_PO_NUMBER,

    LOAD_TIMESTAMP,
    CREATED_TIMESTAMP,
    UPDATED_TIMESTAMP

FROM ADVWORKS_DEV.NORMALIZE.FACT_INTERNET_SALES_NORMALIZE
LIMIT 10;
/*
SALES_ORDER_NUMBER	SALES_ORDER_LINE_NUMBER	UNIT_PRICE	EXTENDED_AMOUNT	SALES_AMOUNT	TAX_AMT	FREIGHT	ORDER_DATE	DUE_DATE	SHIP_DATE	CARRIER_TRACKING_NUMBER	CUSTOMER_PO_NUMBER	LOAD_TIMESTAMP	CREATED_TIMESTAMP	UPDATED_TIMESTAMP
SO43697	1	3578.2700	3578.2700	3578.2700	286.2616	89.4568	2010-12-29 00:00:00.000	2011-01-10 00:00:00.000	2011-01-05 00:00:00.000			2026-09-08 08:34:06.735 -0700	2026-09-08 08:34:06.735 -0700	2026-09-08 08:34:06.735 -0700
SO43698	1	3399.9900	3399.9900	3399.9900	271.9992	84.9998	2010-12-29 00:00:00.000	2011-01-10 00:00:00.000	2011-01-05 00:00:00.000			2026-09-08 08:34:06.735 -0700	2026-09-08 08:34:06.735 -0700	2026-09-08 08:34:06.735 -0700
SO43699	1	3399.9900	3399.9900	3399.9900	271.9992	84.9998	2010-12-29 00:00:00.000	2011-01-10 00:00:00.000	2011-01-05 00:00:00.000			2026-09-08 08:34:06.735 -0700	2026-09-08 08:34:06.735 -0700	2026-09-08 08:34:06.735 -0700
SO43700	1	699.0982	699.0982	699.0982	55.9279	17.4775	2010-12-29 00:00:00.000	2011-01-10 00:00:00.000	2011-01-05 00:00:00.000			2026-09-08 08:34:06.735 -0700	2026-09-08 08:34:06.735 -0700	2026-09-08 08:34:06.735 -0700
SO43701	1	3399.9900	3399.9900	3399.9900	271.9992	84.9998	2010-12-29 00:00:00.000	2011-01-10 00:00:00.000	2011-01-05 00:00:00.000			2026-09-08 08:34:06.735 -0700	2026-09-08 08:34:06.735 -0700	2026-09-08 08:34:06.735 -0700
SO43702	1	3578.2700	3578.2700	3578.2700	286.2616	89.4568	2010-12-30 00:00:00.000	2011-01-11 00:00:00.000	2011-01-06 00:00:00.000			2026-09-08 08:34:06.735 -0700	2026-09-08 08:34:06.735 -0700	2026-09-08 08:34:06.735 -0700
SO43703	1	3578.2700	3578.2700	3578.2700	286.2616	89.4568	2010-12-30 00:00:00.000	2011-01-11 00:00:00.000	2011-01-06 00:00:00.000			2026-09-08 08:34:06.735 -0700	2026-09-08 08:34:06.735 -0700	2026-09-08 08:34:06.735 -0700
SO43704	1	3374.9900	3374.9900	3374.9900	269.9992	84.3748	2010-12-30 00:00:00.000	2011-01-11 00:00:00.000	2011-01-06 00:00:00.000			2026-09-08 08:34:06.735 -0700	2026-09-08 08:34:06.735 -0700	2026-09-08 08:34:06.735 -0700
SO43705	1	3399.9900	3399.9900	3399.9900	271.9992	84.9998	2010-12-30 00:00:00.000	2011-01-11 00:00:00.000	2011-01-06 00:00:00.000			2026-09-08 08:34:06.735 -0700	2026-09-08 08:34:06.735 -0700	2026-09-08 08:34:06.735 -0700
SO43706	1	3578.2700	3578.2700	3578.2700	286.2616	89.4568	2010-12-31 00:00:00.000	2011-01-12 00:00:00.000	2011-01-07 00:00:00.000			2026-09-08 08:34:06.735 -0700	2026-09-08 08:34:06.735 -0700	2026-09-08 08:34:06.735 -0700
*/

--data types check
SELECT
    COLUMN_NAME,
    DATA_TYPE,
    NUMERIC_PRECISION,
    NUMERIC_SCALE
FROM ADVWORKS_DEV.INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_SCHEMA = 'NORMALIZE'
  AND TABLE_NAME = 'FACT_INTERNET_SALES_NORMALIZE'
ORDER BY ORDINAL_POSITION;
/*
COLUMN_NAME	DATA_TYPE	NUMERIC_PRECISION	NUMERIC_SCALE
PRODUCT_KEY	NUMBER	38	0
ORDER_DATE_KEY	NUMBER	38	0
DUE_DATE_KEY	NUMBER	38	0
SHIP_DATE_KEY	NUMBER	38	0
CUSTOMER_KEY	NUMBER	38	0
PROMOTION_KEY	NUMBER	38	0
CURRENCY_KEY	NUMBER	38	0
SALES_TERRITORY_KEY	NUMBER	38	0
SALES_ORDER_NUMBER	TEXT		
SALES_ORDER_LINE_NUMBER	NUMBER	38	0
REVISION_NUMBER	NUMBER	38	0
ORDER_QUANTITY	NUMBER	38	0
UNIT_PRICE	NUMBER	19	4
EXTENDED_AMOUNT	NUMBER	19	4
UNIT_PRICE_DISCOUNT_PCT	NUMBER	19	4
DISCOUNT_AMOUNT	NUMBER	19	4
PRODUCT_STANDARD_COST	NUMBER	19	4
TOTAL_PRODUCT_COST	NUMBER	19	4
SALES_AMOUNT	NUMBER	19	4
TAX_AMT	NUMBER	19	4
FREIGHT	NUMBER	19	4
CARRIER_TRACKING_NUMBER	TEXT		
CUSTOMER_PO_NUMBER	TEXT		
ORDER_DATE	TIMESTAMP_NTZ		
DUE_DATE	TIMESTAMP_NTZ		
SHIP_DATE	TIMESTAMP_NTZ		
LOAD_TIMESTAMP	TIMESTAMP_LTZ		
CREATED_TIMESTAMP	TIMESTAMP_LTZ		
UPDATED_TIMESTAMP	TIMESTAMP_LTZ		
*/

-- Validation check
SELECT
    COUNT(*) AS ROW_COUNT,
    COUNT(DISTINCT SALES_ORDER_NUMBER || '-' || SALES_ORDER_LINE_NUMBER)
        AS DISTINCT_ORDER_LINES,
    SUM(SALES_AMOUNT) AS TOTAL_SALES,
    SUM(TOTAL_PRODUCT_COST) AS TOTAL_PRODUCT_COST,
    SUM(TAX_AMT) AS TOTAL_TAX,
    SUM(FREIGHT) AS TOTAL_FREIGHT
FROM ADVWORKS_DEV.NORMALIZE.FACT_INTERNET_SALES_NORMALIZE;
/*
ROW_COUNT	DISTINCT_ORDER_LINES	TOTAL_SALES	TOTAL_PRODUCT_COST	TOTAL_TAX	TOTAL_FREIGHT
1000	1000	3223116.8784	1928831.4494	257849.3552	80577.9714
*/


SELECT
    COUNT(*) AS ROW_COUNT,
    MIN(FULL_DATE) AS MIN_DATE,
    MAX(FULL_DATE) AS MAX_DATE
FROM ADVWORKS_DEV.SCHEMATIZE.DIM_DATE;
/*
ROW_COUNT	MIN_DATE	MAX_DATE
10000	2010-01-01	2037-05-18
*/

SELECT *
FROM ADVWORKS_DEV.SCHEMATIZE.DIM_DATE
ORDER BY FULL_DATE
LIMIT 10;
/*
DATE_KEY	FULL_DATE	YEAR	QUARTER	MONTH	MONTH_NAME	WEEK_OF_YEAR	DAY_OF_MONTH	DAY_OF_WEEK	DAY_NAME	IS_WEEKEND
20100101	2010-01-01	2010	1	1	Jan	53	1	5	Fri	FALSE
20100102	2010-01-02	2010	1	1	Jan	53	2	6	Sat	FALSE
20100103	2010-01-03	2010	1	1	Jan	53	3	0	Sun	FALSE
20100104	2010-01-04	2010	1	1	Jan	1	4	1	Mon	TRUE
20100105	2010-01-05	2010	1	1	Jan	1	5	2	Tue	FALSE
20100106	2010-01-06	2010	1	1	Jan	1	6	3	Wed	FALSE
20100107	2010-01-07	2010	1	1	Jan	1	7	4	Thu	FALSE
20100108	2010-01-08	2010	1	1	Jan	1	8	5	Fri	FALSE
20100109	2010-01-09	2010	1	1	Jan	1	9	6	Sat	FALSE
20100110	2010-01-10	2010	1	1	Jan	1	10	0	Sun	FALSE
*/


SELECT
    FILE_NAME,
    STATUS,
    ROW_COUNT,
    LAST_LOAD_TIME
FROM TABLE(
    ADVWORKS_DEV.INFORMATION_SCHEMA.COPY_HISTORY(
        TABLE_NAME => 'ADVWORKS_DEV.LANDING.FACT_INTERNET_SALES',
        START_TIME => DATEADD('day', -7, CURRENT_TIMESTAMP())
    )
)
ORDER BY LAST_LOAD_TIME;
/*
FILE_NAME	STATUS	ROW_COUNT	LAST_LOAD_TIME
FactInternetSales_batch_001.jsonl	Loaded	1000	2026-09-08 00:29:58.113 -0700
Snowpipe_test_001.jsonl	Loaded	1000	2026-09-08 01:49:10.712 -0700
Snowpipe_restore_001.jsonl	Loaded	1000	2026-09-08 02:08:10.715 -0700
*/


SELECT
    COUNT(*) AS ROW_COUNT,
    COUNT(DISTINCT SALESORDERNUMBER || '-' || SALESORDERLINENUMBER) AS DISTINCT_ORDER_LINES
FROM ADVWORKS_DEV.LANDING.FACT_INTERNET_SALES;
/*
1000	1000
*/


SELECT SYSTEM$PIPE_STATUS('ADVWORKS_DEV.LANDING.PIPE_FACT_INTERNET_SALES');
/*
{"executionState":"RUNNING","pendingFileCount":0,"lastIngestedTimestamp":"2026-09-08T09:07:44.207Z","lastIngestedFilePath":"Snowpipe_restore_001.jsonl","notificationChannelName":"projects/electric-tesla-507710-k2/subscriptions/advworks-dev-gcs-events-sub","numOutstandingMessagesOnChannel":0,"lastReceivedMessageTimestamp":"2026-09-08T09:07:43.956Z","lastForwardedMessageTimestamp":"2026-09-08T09:07:46.827Z","lastPulledFromChannelTimestamp":"2026-09-09T16:03:55.503Z","lastForwardedFilePath":"advworks-dev-ingestion/fact_internet_sales/Snowpipe_restore_001.jsonl","pendingHistoryRefreshJobsCount":0}
*/

--###############################################################################################################################

-- Create Customer notification integration
CREATE OR REPLACE NOTIFICATION INTEGRATION ADVWORKS_GCS_PUBSUB_DIM_CUSTOMER_INT
  TYPE = QUEUE
  NOTIFICATION_PROVIDER = GCP_PUBSUB
  ENABLED = TRUE
  GCP_PUBSUB_SUBSCRIPTION_NAME =
    'projects/electric-tesla-507710-k2/subscriptions/advworks-dev-dim-customer-sub';
/*
Integration ADVWORKS_GCS_PUBSUB_DIM_CUSTOMER_INT successfully created.
*/


DESC NOTIFICATION INTEGRATION ADVWORKS_GCS_PUBSUB_DIM_CUSTOMER_INT;
/*
property	property_type	property_value	property_default
ENABLED	Boolean	true	true
DIRECTION	String	INBOUND	
GCP_PUBSUB_SUBSCRIPTION_NAME	String	projects/electric-tesla-507710-k2/subscriptions/advworks-dev-dim-customer-sub	
GCP_PUBSUB_SERVICE_ACCOUNT	String	kfrg30000@gcpmecentral2-1-6ca6.iam.gserviceaccount.com	
COMMENT	String		
*/

--Grant it subscriber access:
-- gcloud pubsub subscriptions add-iam-policy-binding advworks-dev-dim-customer-sub --member="serviceAccount:kfrg30000@gcpmecentral2-1-6ca6.iam.gserviceaccount.com" --role="roles/pubsub.subscriber" --project=electric-tesla-507710-k2
/*

*/

-- Create Product notification integration
CREATE OR REPLACE NOTIFICATION INTEGRATION ADVWORKS_GCS_PUBSUB_DIM_PRODUCT_INT
  TYPE = QUEUE
  NOTIFICATION_PROVIDER = GCP_PUBSUB
  ENABLED = TRUE
  GCP_PUBSUB_SUBSCRIPTION_NAME =
    'projects/electric-tesla-507710-k2/subscriptions/advworks-dev-dim-product-sub';
/*
status
Integration ADVWORKS_GCS_PUBSUB_DIM_PRODUCT_INT successfully created.
*/

DESC NOTIFICATION INTEGRATION ADVWORKS_GCS_PUBSUB_DIM_PRODUCT_INT;
/*
property	property_type	property_value	property_default
ENABLED	Boolean	true	true
DIRECTION	String	INBOUND	
GCP_PUBSUB_SUBSCRIPTION_NAME	String	projects/electric-tesla-507710-k2/subscriptions/advworks-dev-dim-product-sub	
GCP_PUBSUB_SERVICE_ACCOUNT	String	kfrg30000@gcpmecentral2-1-6ca6.iam.gserviceaccount.com	
COMMENT	String		
*/


--Grant it subscriber access:
-- gcloud pubsub subscriptions add-iam-policy-binding advworks-dev-dim-product-sub --member="serviceAccount:kfrg30000@gcpmecentral2-1-6ca6.iam.gserviceaccount.com" --role="roles/pubsub.subscriber" --project=electric-tesla-507710-k2


USE DATABASE ADVWORKS_DEV;
USE SCHEMA LANDING;

CREATE OR REPLACE TABLE DIM_CUSTOMER (
    RAW_DATA VARIANT,
    SOURCE_FILE VARCHAR,
    LOAD_TIMESTAMP TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP()
);

CREATE OR REPLACE TABLE DIM_PRODUCT (
    RAW_DATA VARIANT,
    SOURCE_FILE VARCHAR,
    LOAD_TIMESTAMP TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP()
);

--Step 8 — Create Customer file format and stage
----------------------------------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FILE FORMAT ADVWORKS_DEV.LANDING.FF_DIM_CUSTOMER_JSONL
    TYPE = JSON
    STRIP_OUTER_ARRAY = FALSE;

-- stage

CREATE OR REPLACE STAGE ADVWORKS_DEV.LANDING.STG_DIM_CUSTOMER
    URL = 'gcs://advworks-dev-ingestion/dim_customer/'
    STORAGE_INTEGRATION = ADVWORKS_GCS_INT
    FILE_FORMAT = ADVWORKS_DEV.LANDING.FF_DIM_CUSTOMER_JSONL; --Stage area STG_DIM_CUSTOMER successfully created.


--Step 9 — Create Product file format and stage
----------------------------------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FILE FORMAT ADVWORKS_DEV.LANDING.FF_DIM_PRODUCT_JSONL
    TYPE = JSON
    STRIP_OUTER_ARRAY = FALSE;

-- stage

CREATE OR REPLACE STAGE ADVWORKS_DEV.LANDING.STG_DIM_PRODUCT
    URL = 'gcs://advworks-dev-ingestion/dim_product/'
    STORAGE_INTEGRATION = ADVWORKS_GCS_INT
    FILE_FORMAT = ADVWORKS_DEV.LANDING.FF_DIM_PRODUCT_JSONL; --Stage area STG_DIM_PRODUCT successfully created.


CREATE OR REPLACE STORAGE INTEGRATION ADVWORKS_GCS_INT
  TYPE = EXTERNAL_STAGE
  STORAGE_PROVIDER = 'GCS'
  ENABLED = TRUE
  STORAGE_ALLOWED_LOCATIONS = (
      'gcs://advworks-dev-ingestion/fact_internet_sales/',
      'gcs://advworks-dev-ingestion/dim_customer/',
      'gcs://advworks-dev-ingestion/dim_product/'
  );

DESC INTEGRATION ADVWORKS_GCS_INT;
/*
property	property_type	property_value	property_default
ENABLED	Boolean	true	true
STORAGE_PROVIDER	String	GCS	
STORAGE_ALLOWED_LOCATIONS	List	gcs://advworks-dev-ingestion/fact_internet_sales/,gcs://advworks-dev-ingestion/dim_customer/,gcs://advworks-dev-ingestion/dim_product/	[]
STORAGE_BLOCKED_LOCATIONS	List		[]
USE_PRIVATELINK_ENDPOINT	Boolean	false	false
STORAGE_GCP_SERVICE_ACCOUNT	String	kerg30000@gcpmecentral2-1-6ca6.iam.gserviceaccount.com	
COMMENT	String		
*/

----------------------------------------------------------------------------------------------------------

--Step 10 — Create Customer Snowpipe
----------------------------------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE PIPE ADVWORKS_DEV.LANDING.PIPE_DIM_CUSTOMER
  AUTO_INGEST = TRUE
  INTEGRATION = 'ADVWORKS_GCS_PUBSUB_DIM_CUSTOMER_INT'
AS
COPY INTO ADVWORKS_DEV.LANDING.DIM_CUSTOMER
(
    RAW_DATA,
    SOURCE_FILE
)
FROM (
    SELECT
        $1,
        METADATA$FILENAME
    FROM @ADVWORKS_DEV.LANDING.STG_DIM_CUSTOMER
);
----------------------------------------------------------------------------------------------------------------------------------------------
--Step 11 — Create Product Snowpipe
----------------------------------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE PIPE ADVWORKS_DEV.LANDING.PIPE_DIM_PRODUCT
  AUTO_INGEST = TRUE
  INTEGRATION = 'ADVWORKS_GCS_PUBSUB_DIM_PRODUCT_INT'
AS
COPY INTO ADVWORKS_DEV.LANDING.DIM_PRODUCT
(
    RAW_DATA,
    SOURCE_FILE
)
FROM (
    SELECT
        $1,
        METADATA$FILENAME
    FROM @ADVWORKS_DEV.LANDING.STG_DIM_PRODUCT
);
----------------------------------------------------------------------------------------------------------------------------------------------
--Step 12 — Verify the Snowpipes
----------------------------------------------------------------------------------------------------------------------------------------------

--Customer:

SHOW PIPES LIKE 'PIPE_DIM_CUSTOMER' IN SCHEMA ADVWORKS_DEV.LANDING;
/*
created_on	name	database_name	schema_name	definition	owner	notification_channel	comment	integration	pattern	error_integration	owner_role_type	invalid_reason	kind	is_snowflake_managed
2026-09-09 09:34:35.577 -0700	PIPE_DIM_CUSTOMER	ADVWORKS_DEV	LANDING	COPY INTO ADVWORKS_DEV.LANDING.DIM_CUSTOMER
(
    RAW_DATA,
    SOURCE_FILE
)
FROM (
    SELECT
        $1,
        METADATA$FILENAME
    FROM @ADVWORKS_DEV.LANDING.STG_DIM_CUSTOMER
)	ACCOUNTADMIN	projects/electric-tesla-507710-k2/subscriptions/advworks-dev-dim-customer-sub		ADVWORKS_GCS_PUBSUB_DIM_CUSTOMER_INT			ROLE		STAGE	false
*/

--Product:

SHOW PIPES LIKE 'PIPE_DIM_PRODUCT' IN SCHEMA ADVWORKS_DEV.LANDING;
/*
created_on	name	database_name	schema_name	definition	owner	notification_channel	comment	integration	pattern	error_integration	owner_role_type	invalid_reason	kind	is_snowflake_managed
2026-09-09 09:35:06.419 -0700	PIPE_DIM_PRODUCT	ADVWORKS_DEV	LANDING	COPY INTO ADVWORKS_DEV.LANDING.DIM_PRODUCT
(
    RAW_DATA,
    SOURCE_FILE
)
FROM (
    SELECT
        $1,
        METADATA$FILENAME
    FROM @ADVWORKS_DEV.LANDING.STG_DIM_PRODUCT
)	ACCOUNTADMIN	projects/electric-tesla-507710-k2/subscriptions/advworks-dev-dim-product-sub		ADVWORKS_GCS_PUBSUB_DIM_PRODUCT_INT			ROLE		STAGE	false
*/

-- We want:

-- executionState = RUNNING
-- invalid_reason = blank

---------------------------------------------------------------
--Step 14 — Check LANDING after Snowpipe ingestion
----------------------------------------------------------------------------------------------------------------------------------------------

--Customer:

SELECT
    COUNT(*) AS ROW_COUNT,
    COUNT(DISTINCT RAW_DATA:"CustomerKey"::NUMBER) AS DISTINCT_CUSTOMERS
FROM ADVWORKS_DEV.LANDING.DIM_CUSTOMER;
/*
ROW_COUNT	DISTINCT_CUSTOMERS
0	0
*/

-- Expected:

-- ROW_COUNT       18484
-- DISTINCT_CUSTOMERS 18484

--Product:

SELECT
    COUNT(*) AS ROW_COUNT,
    COUNT(DISTINCT RAW_DATA:"ProductKey"::NUMBER) AS DISTINCT_PRODUCTS
FROM ADVWORKS_DEV.LANDING.DIM_PRODUCT;
/*
ROW_COUNT	DISTINCT_PRODUCTS
0	0
*/

-- Expected:

-- ROW_COUNT       606
-- DISTINCT_PRODUCTS 606
-- ----------------------------------------------------------------------------------------------------------------------------------------------
--Step 15 — Check Snowpipe history
----------------------------------------------------------------------------------------------------------------------------------------------

--Customer:

SELECT
    FILE_NAME,
    STATUS,
    ROW_COUNT,
    LAST_LOAD_TIME
FROM TABLE(
    ADVWORKS_DEV.INFORMATION_SCHEMA.COPY_HISTORY(
        TABLE_NAME => 'ADVWORKS_DEV.LANDING.DIM_CUSTOMER',
        START_TIME => DATEADD('day', -7, CURRENT_TIMESTAMP())
    )
)
ORDER BY LAST_LOAD_TIME; --Query produced no results
/*

*/

--Product:

SELECT
    FILE_NAME,
    STATUS,
    ROW_COUNT,
    LAST_LOAD_TIME
FROM TABLE(
    ADVWORKS_DEV.INFORMATION_SCHEMA.COPY_HISTORY(
        TABLE_NAME => 'ADVWORKS_DEV.LANDING.DIM_PRODUCT',
        START_TIME => DATEADD('day', -7, CURRENT_TIMESTAMP())
    )
)
ORDER BY LAST_LOAD_TIME; -- Query produced no results
/*

*/
--############################################################################################################################################

SELECT COUNT(*) AS FACT_ROWS
FROM ADVWORKS_DEV.NORMALIZE.FACT_INTERNET_SALES_NORMALIZE;
/*
FACT_ROWS
1000
*/


SELECT COUNT(*) AS PRODUCT_ROWS
FROM ADVWORKS_DEV.NORMALIZE.DIM_PRODUCT_NORMALIZE;
/*
PRODUCT_ROWS
0
*/


SELECT COUNT(*) AS UNMATCHED_PRODUCT_KEYS
FROM ADVWORKS_DEV.NORMALIZE.FACT_INTERNET_SALES_NORMALIZE f
LEFT JOIN ADVWORKS_DEV.NORMALIZE.DIM_PRODUCT_NORMALIZE p
    ON f.PRODUCT_KEY = p.PRODUCT_KEY
WHERE p.PRODUCT_KEY IS NULL;
/*
UNMATCHED_PRODUCT_KEYS
1000
*/


SELECT DISTINCT f.PRODUCT_KEY
FROM ADVWORKS_DEV.NORMALIZE.FACT_INTERNET_SALES_NORMALIZE f
LEFT JOIN ADVWORKS_DEV.NORMALIZE.DIM_PRODUCT_NORMALIZE p
    ON f.PRODUCT_KEY = p.PRODUCT_KEY
WHERE p.PRODUCT_KEY IS NULL
ORDER BY f.PRODUCT_KEY;
/*
PRODUCT_KEY
310
311
312
313
314
320
322
324
326
328
330
332
334
336
338
340
342
344
345
346
347
348
349
350
351
*/

SELECT COUNT(*) AS ROW_COUNT
FROM ADVWORKS_DEV.LANDING.DIM_PRODUCT;
/*
ROW_COUNT
0
*/


SELECT COUNT(*) AS ROW_COUNT
FROM ADVWORKS_DEV.PREPARE.DIM_PRODUCT_PREPARE;
/*
ROW_COUNT
0
*/


SELECT COUNT(*) AS ROW_COUNT
FROM ADVWORKS_DEV.NORMALIZE.DIM_PRODUCT_NORMALIZE;
/*ROW_COUNT
0
*/



LIST @ADVWORKS_DEV.LANDING.STG_DIM_PRODUCT;
/*
name	size	md5	last_modified
gcs://advworks-dev-ingestion/dim_product/DimProduct_batch_001.jsonl	7465069	0c062f1880bc40f5fc1d8b64d90362b9	Wed, 9 Sep 2026 16:17:45 GMT
*/


LIST @ADVWORKS_DEV.LANDING.STG_DIM_CUSTOMER;
/*
name	size	md5	last_modified
gcs://advworks-dev-ingestion/dim_customer/DimCustomer_batch_001.jsonl	804959	fa32d5f8291689da76ae9bd1969b70be	Wed, 9 Sep 2026 16:16:53 GMT
gcs://advworks-dev-ingestion/dim_customer/DimCustomer_batch_002.jsonl	804528	40bd935a3d18e5fbf933b79437e7febe	Wed, 9 Sep 2026 16:16:55 GMT
gcs://advworks-dev-ingestion/dim_customer/DimCustomer_batch_003.jsonl	803630	566a007c6555f8d2af1013fe374ed0b2	Wed, 9 Sep 2026 16:16:59 GMT
gcs://advworks-dev-ingestion/dim_customer/DimCustomer_batch_004.jsonl	806319	f9bc8b4a543aaaae32c7db8679ed42ae	Wed, 9 Sep 2026 16:17:02 GMT
gcs://advworks-dev-ingestion/dim_customer/DimCustomer_batch_005.jsonl	802759	e10d5b2cdcf909fc997aa7a520621093	Wed, 9 Sep 2026 16:17:04 GMT
gcs://advworks-dev-ingestion/dim_customer/DimCustomer_batch_006.jsonl	804602	11b66dc078c6120017a4506084d5afe2	Wed, 9 Sep 2026 16:17:07 GMT
gcs://advworks-dev-ingestion/dim_customer/DimCustomer_batch_007.jsonl	803756	c09f3d6ad9107f762ae7eb25ee6078e8	Wed, 9 Sep 2026 16:17:10 GMT
gcs://advworks-dev-ingestion/dim_customer/DimCustomer_batch_008.jsonl	805607	215fe65a382a06a22f4e455d67a424ce	Wed, 9 Sep 2026 16:17:12 GMT
gcs://advworks-dev-ingestion/dim_customer/DimCustomer_batch_009.jsonl	804225	f268054906e3084500980a5942adf3bb	Wed, 9 Sep 2026 16:17:15 GMT
gcs://advworks-dev-ingestion/dim_customer/DimCustomer_batch_010.jsonl	804804	1c1f1d7aca07e9ac18042943f4d2d2c0	Wed, 9 Sep 2026 16:17:17 GMT
gcs://advworks-dev-ingestion/dim_customer/DimCustomer_batch_011.jsonl	803305	1f12aeb6dae249ceca060adcfec155ac	Wed, 9 Sep 2026 16:17:20 GMT
gcs://advworks-dev-ingestion/dim_customer/DimCustomer_batch_012.jsonl	805178	bb1c0bbada472946287e42c845862f7e	Wed, 9 Sep 2026 16:17:22 GMT
gcs://advworks-dev-ingestion/dim_customer/DimCustomer_batch_013.jsonl	805017	d5e38b03448e481aa4a567fd9fbdbaec	Wed, 9 Sep 2026 16:17:25 GMT
gcs://advworks-dev-ingestion/dim_customer/DimCustomer_batch_014.jsonl	804314	828ad96f478fdbeef1eb58b4f603c9f6	Wed, 9 Sep 2026 16:17:27 GMT
gcs://advworks-dev-ingestion/dim_customer/DimCustomer_batch_015.jsonl	806337	b2bb5579a718ab10b7d35a107ee7f41d	Wed, 9 Sep 2026 16:17:30 GMT
gcs://advworks-dev-ingestion/dim_customer/DimCustomer_batch_016.jsonl	806309	1236b64c4ed86c3f003ed1723ec050e5	Wed, 9 Sep 2026 16:17:32 GMT
gcs://advworks-dev-ingestion/dim_customer/DimCustomer_batch_017.jsonl	805963	22c35b694b1a48bc723b6a659e184487	Wed, 9 Sep 2026 16:17:35 GMT
gcs://advworks-dev-ingestion/dim_customer/DimCustomer_batch_018.jsonl	805728	02d4691b37cb500a8e2f25a502f61568	Wed, 9 Sep 2026 16:17:38 GMT
gcs://advworks-dev-ingestion/dim_customer/DimCustomer_batch_019.jsonl	389575	3ea526316abb33f90e668bd96ad9f7de	Wed, 9 Sep 2026 16:17:40 GMT
*/

ALTER PIPE ADVWORKS_DEV.LANDING.PIPE_DIM_PRODUCT REFRESH PREFIX = 'dim_product/'; --Query produced no results
/*

*/


ALTER PIPE ADVWORKS_DEV.LANDING.PIPE_DIM_CUSTOMER REFRESH PREFIX = 'dim_customer/'; --Query produced no results

/*

*/



SELECT COUNT(*) AS ROW_COUNT
FROM ADVWORKS_DEV.LANDING.DIM_PRODUCT; -- 0
/*

*/



SELECT COUNT(*) AS ROW_COUNT
FROM ADVWORKS_DEV.LANDING.DIM_CUSTOMER; -- 0
/*

*/



DESC NOTIFICATION INTEGRATION ADVWORKS_GCS_PUBSUB_DIM_PRODUCT_INT;
/*
property	property_type	property_value	property_default
ENABLED	Boolean	true	true
DIRECTION	String	INBOUND	
GCP_PUBSUB_SUBSCRIPTION_NAME	String	projects/electric-tesla-507710-k2/subscriptions/advworks-dev-dim-product-sub	
GCP_PUBSUB_SERVICE_ACCOUNT	String	******@gcpmecentral2-1-6ca6.iam.gserviceaccount.com	
COMMENT	String		
*/
/*
PS C:\Users\Admin> gcloud pubsub subscriptions add-iam-policy-binding advworks-dev-dim-customer-sub --member="serviceAccount:*******gcpmecentral2-1-6ca6.iam.gserviceaccount.com" --role="roles/pubsub.subscriber" --project=electric-tesla-507710-k2
Updated IAM policy for subscription [advworks-dev-dim-customer-sub].
bindings:
- members:
  - serviceAccount::*******@gcpmecentral2-1-6ca6.iam.gserviceaccount.com
  role: roles/pubsub.subscriber
etag: BwZbD0TMMck=
version: 1
PS C:\Users\Admin>
PS C:\Users\Admin>
PS C:\Users\Admin> gcloud pubsub subscriptions add-iam-policy-binding advworks-dev-dim-product-sub --member="serviceAccount:*******@gcpmecentral2-1-6ca6.iam.gserviceaccount.com" --role="roles/pubsub.subscriber" --project=electric-tesla-507710-k2
Updated IAM policy for subscription [advworks-dev-dim-product-sub].
bindings:
- members:
  - serviceAccount::*******@gcpmecentral2-1-6ca6.iam.gserviceaccount.com
  role: roles/pubsub.subscriber
etag: BwZbD08fAjg=
version: 1
*/

SELECT SYSTEM$PIPE_STATUS('ADVWORKS_DEV.LANDING.PIPE_DIM_PRODUCT');
/*
SYSTEM$PIPE_STATUS('ADVWORKS_DEV.LANDING.PIPE_DIM_PRODUCT')
{"executionState":"RUNNING","pendingFileCount":0,"notificationChannelName":"projects/electric-tesla-507710-k2/subscriptions/advworks-dev-dim-product-sub","numOutstandingMessagesOnChannel":0,"lastPulledFromChannelTimestamp":"2026-09-09T17:17:04.744Z","pendingHistoryRefreshJobsCount":0}
*/


SELECT SYSTEM$PIPE_STATUS('ADVWORKS_DEV.LANDING.PIPE_DIM_CUSTOMER');
/*
SYSTEM$PIPE_STATUS('ADVWORKS_DEV.LANDING.PIPE_DIM_CUSTOMER')
{"executionState":"RUNNING","pendingFileCount":0,"notificationChannelName":"projects/electric-tesla-507710-k2/subscriptions/advworks-dev-dim-customer-sub","numOutstandingMessagesOnChannel":0,"lastPulledFromChannelTimestamp":"2026-09-09T17:17:13.436Z","pendingHistoryRefreshJobsCount":0}
*/

DESC NOTIFICATION INTEGRATION ADVWORKS_GCS_PUBSUB_DIM_PRODUCT_INT;
/*
property	property_type	property_value	property_default
ENABLED	Boolean	true	true
DIRECTION	String	INBOUND	
GCP_PUBSUB_SUBSCRIPTION_NAME	String	projects/electric-tesla-507710-k2/subscriptions/advworks-dev-dim-product-sub	
GCP_PUBSUB_SERVICE_ACCOUNT	String	kfrg30000@gcpmecentral2-1-6ca6.iam.gserviceaccount.com	
COMMENT	String		
*/

DESC NOTIFICATION INTEGRATION ADVWORKS_GCS_PUBSUB_DIM_CUSTOMER_INT;
/*
property	property_type	property_value	property_default
ENABLED	Boolean	true	true
DIRECTION	String	INBOUND	
GCP_PUBSUB_SUBSCRIPTION_NAME	String	projects/electric-tesla-507710-k2/subscriptions/advworks-dev-dim-customer-sub	
GCP_PUBSUB_SERVICE_ACCOUNT	String	kfrg30000@gcpmecentral2-1-6ca6.iam.gserviceaccount.com	
COMMENT	String		
*/

ALTER PIPE ADVWORKS_DEV.LANDING.PIPE_DIM_PRODUCT REFRESH; 
/*
File	Status
DimProduct_batch_001.jsonl	SENT
*/

SELECT SYSTEM$PIPE_STATUS('ADVWORKS_DEV.LANDING.PIPE_DIM_PRODUCT');
/*
SYSTEM$PIPE_STATUS('ADVWORKS_DEV.LANDING.PIPE_DIM_PRODUCT')
{"executionState":"RUNNING","pendingFileCount":0,"notificationChannelName":"projects/electric-tesla-507710-k2/subscriptions/advworks-dev-dim-product-sub","numOutstandingMessagesOnChannel":0,"lastPulledFromChannelTimestamp":"2026-09-09T17:24:29.724Z","pendingHistoryRefreshJobsCount":0}
*/

SELECT COUNT(*) AS ROW_COUNT
FROM ADVWORKS_DEV.LANDING.DIM_PRODUCT; --606

ALTER PIPE ADVWORKS_DEV.LANDING.PIPE_DIM_CUSTOMER REFRESH;
/*
File	Status
DimCustomer_batch_001.jsonl	SENT
DimCustomer_batch_002.jsonl	SENT
DimCustomer_batch_003.jsonl	SENT
DimCustomer_batch_004.jsonl	SENT
DimCustomer_batch_005.jsonl	SENT
DimCustomer_batch_006.jsonl	SENT
DimCustomer_batch_007.jsonl	SENT
DimCustomer_batch_008.jsonl	SENT
DimCustomer_batch_009.jsonl	SENT
DimCustomer_batch_010.jsonl	SENT
DimCustomer_batch_011.jsonl	SENT
DimCustomer_batch_012.jsonl	SENT
DimCustomer_batch_013.jsonl	SENT
DimCustomer_batch_014.jsonl	SENT
DimCustomer_batch_015.jsonl	SENT
DimCustomer_batch_016.jsonl	SENT
DimCustomer_batch_017.jsonl	SENT
DimCustomer_batch_018.jsonl	SENT
DimCustomer_batch_019.jsonl	SENT
*/

SELECT SYSTEM$PIPE_STATUS('ADVWORKS_DEV.LANDING.PIPE_DIM_CUSTOMER');
/*
SYSTEM$PIPE_STATUS('ADVWORKS_DEV.LANDING.PIPE_DIM_CUSTOMER')
{"executionState":"RUNNING","pendingFileCount":19,"notificationChannelName":"projects/electric-tesla-507710-k2/subscriptions/advworks-dev-dim-customer-sub","numOutstandingMessagesOnChannel":0,"lastPulledFromChannelTimestamp":"2026-09-09T17:25:13.433Z","pendingHistoryRefreshJobsCount":0}
*/


SELECT COUNT(*) AS ROW_COUNT
FROM ADVWORKS_DEV.LANDING.DIM_CUSTOMER; 
/*
ROW_COUNT
18484
*/

SELECT
    FILE_NAME,
    STATUS,
    ROW_COUNT,
    LAST_LOAD_TIME
FROM TABLE(
    ADVWORKS_DEV.INFORMATION_SCHEMA.COPY_HISTORY(
        TABLE_NAME => 'ADVWORKS_DEV.LANDING.DIM_PRODUCT',
        START_TIME => DATEADD('day', -7, CURRENT_TIMESTAMP())
    )
)
ORDER BY LAST_LOAD_TIME;
/*
FILE_NAME	STATUS	ROW_COUNT	LAST_LOAD_TIME
DimProduct_batch_001.jsonl	Loaded	606	2026-09-09 10:24:34.507 -0700
*/

SELECT
    FILE_NAME,
    STATUS,
    ROW_COUNT,
    LAST_LOAD_TIME
FROM TABLE(
    ADVWORKS_DEV.INFORMATION_SCHEMA.COPY_HISTORY(
        TABLE_NAME => 'ADVWORKS_DEV.LANDING.DIM_CUSTOMER',
        START_TIME => DATEADD('day', -7, CURRENT_TIMESTAMP())
    )
)
ORDER BY LAST_LOAD_TIME;
/*
FILE_NAME	STATUS	ROW_COUNT	LAST_LOAD_TIME
DimCustomer_batch_004.jsonl	Loaded	1000	2026-09-09 10:25:46.690 -0700
DimCustomer_batch_005.jsonl	Loaded	1000	2026-09-09 10:25:46.690 -0700
DimCustomer_batch_015.jsonl	Loaded	1000	2026-09-09 10:25:46.690 -0700
DimCustomer_batch_009.jsonl	Loaded	1000	2026-09-09 10:25:46.690 -0700
DimCustomer_batch_014.jsonl	Loaded	1000	2026-09-09 10:25:46.690 -0700
DimCustomer_batch_007.jsonl	Loaded	1000	2026-09-09 10:25:46.690 -0700
DimCustomer_batch_002.jsonl	Loaded	1000	2026-09-09 10:25:46.690 -0700
DimCustomer_batch_013.jsonl	Loaded	1000	2026-09-09 10:25:46.690 -0700
DimCustomer_batch_019.jsonl	Loaded	484	2026-09-09 10:25:46.690 -0700
DimCustomer_batch_008.jsonl	Loaded	1000	2026-09-09 10:25:46.690 -0700
DimCustomer_batch_006.jsonl	Loaded	1000	2026-09-09 10:25:46.690 -0700
DimCustomer_batch_016.jsonl	Loaded	1000	2026-09-09 10:25:46.690 -0700
DimCustomer_batch_017.jsonl	Loaded	1000	2026-09-09 10:25:46.690 -0700
DimCustomer_batch_010.jsonl	Loaded	1000	2026-09-09 10:25:46.690 -0700
DimCustomer_batch_012.jsonl	Loaded	1000	2026-09-09 10:25:46.690 -0700
DimCustomer_batch_003.jsonl	Loaded	1000	2026-09-09 10:25:46.690 -0700
DimCustomer_batch_001.jsonl	Loaded	1000	2026-09-09 10:25:46.690 -0700
DimCustomer_batch_011.jsonl	Loaded	1000	2026-09-09 10:25:46.690 -0700
DimCustomer_batch_018.jsonl	Loaded	1000	2026-09-09 10:25:46.690 -0700
*/

--#########################################################################################################################

SELECT SYSTEM$PIPE_STATUS('ADVWORKS_TEST.LANDING.PIPE_FACT_INTERNET_SALES');
/*
SYSTEM$PIPE_STATUS('ADVWORKS_TEST.LANDING.PIPE_FACT_INTERNET_SALES')
{"executionState":"RUNNING","pendingFileCount":0,"notificationChannelName":"projects/electric-tesla-507710-k2/subscriptions/test-gcs-events-sub","numOutstandingMessagesOnChannel":0,"lastPulledFromChannelTimestamp":"2026-09-10T17:32:16.408Z","pendingHistoryRefreshJobsCount":0}
*/

SELECT SYSTEM$PIPE_STATUS('ADVWORKS_TEST.LANDING.PIPE_DIM_CUSTOMER');
/*
SYSTEM$PIPE_STATUS('ADVWORKS_TEST.LANDING.PIPE_DIM_CUSTOMER')
{"executionState":"RUNNING","pendingFileCount":0,"notificationChannelName":"projects/electric-tesla-507710-k2/subscriptions/test-gcs-events-sub","numOutstandingMessagesOnChannel":0,"lastPulledFromChannelTimestamp":"2026-09-10T17:38:41.408Z","pendingHistoryRefreshJobsCount":0}
*/

SELECT SYSTEM$PIPE_STATUS('ADVWORKS_TEST.LANDING.PIPE_DIM_PRODUCT');
/*
SYSTEM$PIPE_STATUS('ADVWORKS_TEST.LANDING.PIPE_DIM_PRODUCT')
{"executionState":"RUNNING","pendingFileCount":0,"notificationChannelName":"projects/electric-tesla-507710-k2/subscriptions/test-gcs-events-sub","numOutstandingMessagesOnChannel":0,"lastPulledFromChannelTimestamp":"2026-09-10T17:33:16.428Z","pendingHistoryRefreshJobsCount":0}
*/

SELECT COUNT(*) FROM ADVWORKS_TEST.LANDING.FACT_INTERNET_SALES;
/*
COUNT(*)
0
*/


SELECT COUNT(*) FROM ADVWORKS_TEST.LANDING.DIM_PRODUCT;
/*
COUNT(*)
0
*/

SELECT SYSTEM$PIPE_STATUS('ADVWORKS_TEST.LANDING.PIPE_DIM_PRODUCT');
/*
SYSTEM$PIPE_STATUS('ADVWORKS_TEST.LANDING.PIPE_DIM_PRODUCT')
{"executionState":"RUNNING","pendingFileCount":0,"notificationChannelName":"projects/electric-tesla-507710-k2/subscriptions/test-gcs-events-sub","numOutstandingMessagesOnChannel":0,"lastPulledFromChannelTimestamp":"2026-09-10T17:33:16.428Z","pendingHistoryRefreshJobsCount":0}
*/

SELECT COUNT(*) FROM ADVWORKS_TEST.LANDING.DIM_CUSTOMER;
/*
COUNT(*)
1000
*/


SELECT SOURCE_FILE, LOAD_TIMESTAMP, RAW_DATA
FROM ADVWORKS_TEST.LANDING.DIM_CUSTOMER
ORDER BY LOAD_TIMESTAMP DESC
LIMIT 5;
/*
SOURCE_FILE	LOAD_TIMESTAMP	RAW_DATA
dim_customer/terraform_test_customer_001.jsonl	2026-09-10 10:40:37.897	{
  "AddressLine1": "3761 N. 14th St",
  "AddressLine2": null,
  "BirthDate": "1971-10-06",
  "CommuteDistance": "1-2 Miles",
  "CustomerAlternateKey": "AW00011000",
  "CustomerKey": 11000,
  "DateFirstPurchase": "2011-01-19",
  "EmailAddress": "jon24@adventure-works.com",
  "EnglishEducation": "Bachelors",
  "EnglishOccupation": "Professional",
  "FirstName": "Jon",
  "FrenchEducation": "Bac + 4",
  "FrenchOccupation": "Cadre",
  "Gender": "M",
  "GeographyKey": 26,
  "HouseOwnerFlag": "1",
  "LastName": "Yang",
  "MaritalStatus": "M",
  "MiddleName": "V",
  "NameStyle": false,
  "NumberCarsOwned": 0,
  "NumberChildrenAtHome": 0,
  "Phone": "1 (11) 500 555-0162",
  "SpanishEducation": "Licenciatura",
  "SpanishOccupation": "Profesional",
  "Suffix": null,
  "Title": null,
  "TotalChildren": 2,
  "YearlyIncome": 90000
}
dim_customer/terraform_test_customer_001.jsonl	2026-09-10 10:40:37.897	{
  "AddressLine1": "2243 W St.",
  "AddressLine2": null,
  "BirthDate": "1976-05-10",
  "CommuteDistance": "0-1 Miles",
  "CustomerAlternateKey": "AW00011001",
  "CustomerKey": 11001,
  "DateFirstPurchase": "2011-01-15",
  "EmailAddress": "eugene10@adventure-works.com",
  "EnglishEducation": "Bachelors",
  "EnglishOccupation": "Professional",
  "FirstName": "Eugene",
  "FrenchEducation": "Bac + 4",
  "FrenchOccupation": "Cadre",
  "Gender": "M",
  "GeographyKey": 37,
  "HouseOwnerFlag": "0",
  "LastName": "Huang",
  "MaritalStatus": "S",
  "MiddleName": "L",
  "NameStyle": false,
  "NumberCarsOwned": 1,
  "NumberChildrenAtHome": 3,
  "Phone": "1 (11) 500 555-0110",
  "SpanishEducation": "Licenciatura",
  "SpanishOccupation": "Profesional",
  "Suffix": null,
  "Title": null,
  "TotalChildren": 3,
  "YearlyIncome": 60000
}
dim_customer/terraform_test_customer_001.jsonl	2026-09-10 10:40:37.897	{
  "AddressLine1": "5844 Linden Land",
  "AddressLine2": null,
  "BirthDate": "1971-02-09",
  "CommuteDistance": "2-5 Miles",
  "CustomerAlternateKey": "AW00011002",
  "CustomerKey": 11002,
  "DateFirstPurchase": "2011-01-07",
  "EmailAddress": "ruben35@adventure-works.com",
  "EnglishEducation": "Bachelors",
  "EnglishOccupation": "Professional",
  "FirstName": "Ruben",
  "FrenchEducation": "Bac + 4",
  "FrenchOccupation": "Cadre",
  "Gender": "M",
  "GeographyKey": 31,
  "HouseOwnerFlag": "1",
  "LastName": "Torres",
  "MaritalStatus": "M",
  "MiddleName": null,
  "NameStyle": false,
  "NumberCarsOwned": 1,
  "NumberChildrenAtHome": 3,
  "Phone": "1 (11) 500 555-0184",
  "SpanishEducation": "Licenciatura",
  "SpanishOccupation": "Profesional",
  "Suffix": null,
  "Title": null,
  "TotalChildren": 3,
  "YearlyIncome": 60000
}
dim_customer/terraform_test_customer_001.jsonl	2026-09-10 10:40:37.897	{
  "AddressLine1": "1825 Village Pl.",
  "AddressLine2": null,
  "BirthDate": "1973-08-14",
  "CommuteDistance": "5-10 Miles",
  "CustomerAlternateKey": "AW00011003",
  "CustomerKey": 11003,
  "DateFirstPurchase": "2010-12-29",
  "EmailAddress": "christy12@adventure-works.com",
  "EnglishEducation": "Bachelors",
  "EnglishOccupation": "Professional",
  "FirstName": "Christy",
  "FrenchEducation": "Bac + 4",
  "FrenchOccupation": "Cadre",
  "Gender": "F",
  "GeographyKey": 11,
  "HouseOwnerFlag": "0",
  "LastName": "Zhu",
  "MaritalStatus": "S",
  "MiddleName": null,
  "NameStyle": false,
  "NumberCarsOwned": 1,
  "NumberChildrenAtHome": 0,
  "Phone": "1 (11) 500 555-0162",
  "SpanishEducation": "Licenciatura",
  "SpanishOccupation": "Profesional",
  "Suffix": null,
  "Title": null,
  "TotalChildren": 0,
  "YearlyIncome": 70000
}
dim_customer/terraform_test_customer_001.jsonl	2026-09-10 10:40:37.897	{
  "AddressLine1": "7553 Harness Circle",
  "AddressLine2": null,
  "BirthDate": "1979-08-05",
  "CommuteDistance": "1-2 Miles",
  "CustomerAlternateKey": "AW00011004",
  "CustomerKey": 11004,
  "DateFirstPurchase": "2011-01-23",
  "EmailAddress": "elizabeth5@adventure-works.com",
  "EnglishEducation": "Bachelors",
  "EnglishOccupation": "Professional",
  "FirstName": "Elizabeth",
  "FrenchEducation": "Bac + 4",
  "FrenchOccupation": "Cadre",
  "Gender": "F",
  "GeographyKey": 19,
  "HouseOwnerFlag": "1",
  "LastName": "Johnson",
  "MaritalStatus": "S",
  "MiddleName": null,
  "NameStyle": false,
  "NumberCarsOwned": 4,
  "NumberChildrenAtHome": 5,
  "Phone": "1 (11) 500 555-0131",
  "SpanishEducation": "Licenciatura",
  "SpanishOccupation": "Profesional",
  "Suffix": null,
  "Title": null,
  "TotalChildren": 5,
  "YearlyIncome": 80000
}
*/

DROP TABLE IF EXISTS ADVWORKS_DEV.LANDING.FACT_INTERNET_SALES;

DROP TABLE IF EXISTS ADVWORKS_DEV.LANDING.DIM_CUSTOMER;

DROP TABLE IF EXISTS ADVWORKS_DEV.LANDING.DIM_PRODUCT;

DROP PIPE IF EXISTS ADVWORKS_DEV.LANDING.PIPE_DIM_CUSTOMER;

DROP PIPE IF EXISTS ADVWORKS_DEV.LANDING.PIPE_DIM_PRODUCT;

DROP PIPE IF EXISTS ADVWORKS_DEV.LANDING.PIPE_FACT_INTERNET_SALES;

SHOW PIPES IN SCHEMA ADVWORKS_DEV.LANDING;
/*
created_on	name	database_name	schema_name	definition	owner	notification_channel	comment	integration	pattern	error_integration	owner_role_type	invalid_reason	kind	is_snowflake_managed
2026-09-11 13:30:50.963 -0700	PIPE_DIM_CUSTOMER	ADVWORKS_DEV	LANDING	COPY INTO ADVWORKS_DEV.LANDING.DIM_CUSTOMER
(
  RAW_DATA,
  SOURCE_FILE
)
FROM (
  SELECT
    $1,
    METADATA$FILENAME
  FROM @ADVWORKS_DEV.LANDING.STAGE_DIM_CUSTOMER
)
FILE_FORMAT = (
  FORMAT_NAME = 'ADVWORKS_DEV.LANDING.FF_DIM_CUSTOMER_JSON_FF'
)
ON_ERROR = 'CONTINUE'	ACCOUNTADMIN	projects/electric-tesla-507710-k2/subscriptions/dev-gcs-events-sub		DEV_GCS_PUBSUB_INT			ROLE		STAGE	false
2026-09-11 13:30:50.963 -0700	PIPE_DIM_PRODUCT	ADVWORKS_DEV	LANDING	COPY INTO ADVWORKS_DEV.LANDING.DIM_PRODUCT
(
  RAW_DATA,
  SOURCE_FILE
)
FROM (
  SELECT
    $1,
    METADATA$FILENAME
  FROM @ADVWORKS_DEV.LANDING.STAGE_DIM_PRODUCT
)
FILE_FORMAT = (
  FORMAT_NAME = 'ADVWORKS_DEV.LANDING.FF_DIM_PRODUCT_JSON_FF'
)
ON_ERROR = 'CONTINUE'	ACCOUNTADMIN	projects/electric-tesla-507710-k2/subscriptions/dev-gcs-events-sub		DEV_GCS_PUBSUB_INT			ROLE		STAGE	false
2026-09-11 13:30:50.964 -0700	PIPE_FACT_INTERNET_SALES	ADVWORKS_DEV	LANDING	COPY INTO ADVWORKS_DEV.LANDING.FACT_INTERNET_SALES
(
  RAW_DATA,
  SOURCE_FILE
)
FROM (
  SELECT
    $1,
    METADATA$FILENAME
  FROM @ADVWORKS_DEV.LANDING.STAGE_FACT_INTERNET_SALES
)
FILE_FORMAT = (
  FORMAT_NAME = 'ADVWORKS_DEV.LANDING.FF_FACT_INTERNET_SALES_JSON_FF'
)
ON_ERROR = 'CONTINUE'	ACCOUNTADMIN	projects/electric-tesla-507710-k2/subscriptions/dev-gcs-events-sub		DEV_GCS_PUBSUB_INT			ROLE		STAGE	false
*/

SELECT
    "name",
    "database_name",
    "schema_name",
    "definition",
    "notification_channel"
FROM TABLE(RESULT_SCAN(LAST_QUERY_ID()));
/*
name	database_name	schema_name	definition	notification_channel
PIPE_DIM_CUSTOMER	ADVWORKS_DEV	LANDING	COPY INTO ADVWORKS_DEV.LANDING.DIM_CUSTOMER
(
  RAW_DATA,
  SOURCE_FILE
)
FROM (
  SELECT
    $1,
    METADATA$FILENAME
  FROM @ADVWORKS_DEV.LANDING.STAGE_DIM_CUSTOMER
)
FILE_FORMAT = (
  FORMAT_NAME = 'ADVWORKS_DEV.LANDING.FF_DIM_CUSTOMER_JSON_FF'
)
ON_ERROR = 'CONTINUE'	projects/electric-tesla-507710-k2/subscriptions/dev-gcs-events-sub
PIPE_DIM_PRODUCT	ADVWORKS_DEV	LANDING	COPY INTO ADVWORKS_DEV.LANDING.DIM_PRODUCT
(
  RAW_DATA,
  SOURCE_FILE
)
FROM (
  SELECT
    $1,
    METADATA$FILENAME
  FROM @ADVWORKS_DEV.LANDING.STAGE_DIM_PRODUCT
)
FILE_FORMAT = (
  FORMAT_NAME = 'ADVWORKS_DEV.LANDING.FF_DIM_PRODUCT_JSON_FF'
)
ON_ERROR = 'CONTINUE'	projects/electric-tesla-507710-k2/subscriptions/dev-gcs-events-sub
PIPE_FACT_INTERNET_SALES	ADVWORKS_DEV	LANDING	COPY INTO ADVWORKS_DEV.LANDING.FACT_INTERNET_SALES
(
  RAW_DATA,
  SOURCE_FILE
)
FROM (
  SELECT
    $1,
    METADATA$FILENAME
  FROM @ADVWORKS_DEV.LANDING.STAGE_FACT_INTERNET_SALES
)
FILE_FORMAT = (
  FORMAT_NAME = 'ADVWORKS_DEV.LANDING.FF_FACT_INTERNET_SALES_JSON_FF'
)
ON_ERROR = 'CONTINUE'	projects/electric-tesla-507710-k2/subscriptions/dev-gcs-events-sub
*/

SELECT
    TABLE_NAME,
    COLUMN_NAME,
    DATA_TYPE
FROM ADVWORKS_DEV.INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_SCHEMA = 'LANDING'
  AND TABLE_NAME IN ('FACT_INTERNET_SALES', 'DIM_CUSTOMER', 'DIM_PRODUCT')
ORDER BY TABLE_NAME, ORDINAL_POSITION;
/*
TABLE_NAME	COLUMN_NAME	DATA_TYPE
DIM_CUSTOMER	RAW_DATA	VARIANT
DIM_CUSTOMER	SOURCE_FILE	TEXT
DIM_CUSTOMER	LOAD_TIMESTAMP	TIMESTAMP_NTZ
DIM_PRODUCT	RAW_DATA	VARIANT
DIM_PRODUCT	SOURCE_FILE	TEXT
DIM_PRODUCT	LOAD_TIMESTAMP	TIMESTAMP_NTZ
FACT_INTERNET_SALES	RAW_DATA	VARIANT
FACT_INTERNET_SALES	SOURCE_FILE	TEXT
FACT_INTERNET_SALES	LOAD_TIMESTAMP	TIMESTAMP_NTZ
*/

SELECT 'FACT_INTERNET_SALES' AS TABLE_NAME, COUNT(*) AS ROW_COUNT
FROM ADVWORKS_DEV.LANDING.FACT_INTERNET_SALES
UNION ALL
SELECT 'DIM_CUSTOMER', COUNT(*)
FROM ADVWORKS_DEV.LANDING.DIM_CUSTOMER
UNION ALL
SELECT 'DIM_PRODUCT', COUNT(*)
FROM ADVWORKS_DEV.LANDING.DIM_PRODUCT;
/*
TABLE_NAME	ROW_COUNT
FACT_INTERNET_SALES	0
DIM_CUSTOMER	0
DIM_PRODUCT	0
*/


/*

*/