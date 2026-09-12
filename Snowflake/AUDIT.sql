/*
Create the Audit Schema

Run this in Snowflake:
*/
CREATE SCHEMA IF NOT EXISTS ADVWORKS_DEV.AUDIT; -- Schema AUDIT successfully created.


--Then verify:
SHOW SCHEMAS LIKE 'AUDIT' IN DATABASE ADVWORKS_DEV;
/*
created_on	name	is_default	is_current	database_name	owner	comment	options	retention_time	owner_role_type	classification_profile_database	classification_profile_schema	classification_profile	object_visibility	is_nested
2026-09-12 05:08:15.022 -0700	AUDIT	N	Y	ADVWORKS_DEV	ACCOUNTADMIN			1	ROLE					false
*/

-- — Create PIPELINE_AUDIT
CREATE OR REPLACE TABLE ADVWORKS_DEV.AUDIT.PIPELINE_AUDIT (
    RUN_ID              VARCHAR,
    PIPELINE_NAME       VARCHAR,
    ENVIRONMENT         VARCHAR,
    SOURCE_SYSTEM       VARCHAR,
    SOURCE_OBJECT       VARCHAR,
    TARGET_OBJECT       VARCHAR,
    STATUS               VARCHAR,
    START_TIME           TIMESTAMP_NTZ,
    END_TIME             TIMESTAMP_NTZ,
    ROWS_READ            NUMBER,
    ROWS_WRITTEN         NUMBER,
    ERROR_COUNT          NUMBER,
    ERROR_MESSAGE        VARCHAR,
    CREATED_AT           TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP()
);

DESC TABLE ADVWORKS_DEV.AUDIT.PIPELINE_AUDIT;
/*
name	type	kind	null?	default	primary key	unique key	check	expression	comment	policy name	privacy domain	write default
RUN_ID	VARCHAR(16777216)	COLUMN	Y		N	N						
PIPELINE_NAME	VARCHAR(16777216)	COLUMN	Y		N	N						
ENVIRONMENT	VARCHAR(16777216)	COLUMN	Y		N	N						
SOURCE_SYSTEM	VARCHAR(16777216)	COLUMN	Y		N	N						
SOURCE_OBJECT	VARCHAR(16777216)	COLUMN	Y		N	N						
TARGET_OBJECT	VARCHAR(16777216)	COLUMN	Y		N	N						
STATUS	VARCHAR(16777216)	COLUMN	Y		N	N						
START_TIME	TIMESTAMP_NTZ(9)	COLUMN	Y		N	N						
END_TIME	TIMESTAMP_NTZ(9)	COLUMN	Y		N	N						
ROWS_READ	NUMBER(38,0)	COLUMN	Y		N	N						
ROWS_WRITTEN	NUMBER(38,0)	COLUMN	Y		N	N						
ERROR_COUNT	NUMBER(38,0)	COLUMN	Y		N	N						
ERROR_MESSAGE	VARCHAR(16777216)	COLUMN	Y		N	N						
CREATED_AT	TIMESTAMP_NTZ(9)	COLUMN	Y	CURRENT_TIMESTAMP()	N	N						
*/

--— Record Our First Successful Pipeline Run

/* For this first record, we'll represent the actual DIM_CUSTOMER Snowpipe ingestion that we just validated.

Use:

Pipeline: GCS_TO_SNOWFLAKE_SNOWPIPE
Environment: DEV
Source: GCS
File: DEV_TEST_DimCustomer_001.jsonl
Target: ADVWORKS_DEV.LANDING.DIM_CUSTOMER
Status: SUCCESS
Rows written: 5000

We'll generate a unique RUN_ID using Snowflake.
*/

-- Run:
INSERT INTO ADVWORKS_DEV.AUDIT.PIPELINE_AUDIT
(
    RUN_ID,
    PIPELINE_NAME,
    ENVIRONMENT,
    SOURCE_SYSTEM,
    SOURCE_OBJECT,
    TARGET_OBJECT,
    STATUS,
    START_TIME,
    END_TIME,
    ROWS_READ,
    ROWS_WRITTEN,
    ERROR_COUNT,
    ERROR_MESSAGE
)
SELECT
    UUID_STRING(),
    'GCS_TO_SNOWFLAKE_SNOWPIPE',
    'DEV',
    'GCS',
    'dim_customer/DEV_TEST_DimCustomer_001.jsonl',
    'ADVWORKS_DEV.LANDING.DIM_CUSTOMER',
    'SUCCESS',
    CURRENT_TIMESTAMP() - INTERVAL '1 MINUTE',
    CURRENT_TIMESTAMP(),
    5000,
    5000,
    0,
    NULL;
/*
number of rows inserted
1
*/

--Then verify:

SELECT
    RUN_ID,
    PIPELINE_NAME,
    ENVIRONMENT,
    SOURCE_OBJECT,
    TARGET_OBJECT,
    STATUS,
    ROWS_READ,
    ROWS_WRITTEN,
    ERROR_COUNT,
    START_TIME,
    END_TIME
FROM ADVWORKS_DEV.AUDIT.PIPELINE_AUDIT
ORDER BY CREATED_AT DESC;
/*
RUN_ID	PIPELINE_NAME	ENVIRONMENT	SOURCE_OBJECT	TARGET_OBJECT	STATUS	ROWS_READ	ROWS_WRITTEN	ERROR_COUNT	START_TIME	END_TIME
d5358bad-6c47-4a19-8502-7cb80e81693b	GCS_TO_SNOWFLAKE_SNOWPIPE	DEV	dim_customer/DEV_TEST_DimCustomer_001.jsonl	ADVWORKS_DEV.LANDING.DIM_CUSTOMER	SUCCESS	5000	5000	0	2026-09-12 06:20:23.632	2026-09-12 06:21:23.632
*/


/*
What we're demonstrating

We're creating this relationship:

GCS file
   │
   ▼
Snowpipe
   │
   ▼
LANDING.DIM_CUSTOMER
   │
   ▼
PIPELINE_AUDIT

So instead of simply knowing:

"There are 5,000 rows."

we can eventually answer:

Which pipeline loaded them, from which source, into which target, when, with how many rows, and whether it succeeded?

That's the foundation for production observability.
*/

/*
##############################################################################################
— Record a Failed Pipeline Run

Before moving on, we need to understand how production pipelines capture failures.

We'll deliberately insert a simulated failure into the audit table.

This is better than intentionally breaking Snowpipe and wasting time troubleshooting infrastructure.
*/
-- Run:

INSERT INTO ADVWORKS_DEV.AUDIT.PIPELINE_AUDIT
(
    RUN_ID,
    PIPELINE_NAME,
    ENVIRONMENT,
    SOURCE_SYSTEM,
    SOURCE_OBJECT,
    TARGET_OBJECT,
    STATUS,
    START_TIME,
    END_TIME,
    ROWS_READ,
    ROWS_WRITTEN,
    ERROR_COUNT,
    ERROR_MESSAGE
)
SELECT
    UUID_STRING(),
    'GCS_TO_SNOWFLAKE_SNOWPIPE',
    'DEV',
    'GCS',
    'dim_customer/INVALID_FILE.jsonl',
    'ADVWORKS_DEV.LANDING.DIM_CUSTOMER',
    'FAILED',
    CURRENT_TIMESTAMP() - INTERVAL '30 SECONDS',
    CURRENT_TIMESTAMP(),
    0,
    0,
    1,
    'Source file could not be processed';


/*

*/

-- Then query:

SELECT
    RUN_ID,
    SOURCE_OBJECT,
    STATUS,
    ROWS_READ,
    ROWS_WRITTEN,
    ERROR_COUNT,
    ERROR_MESSAGE
FROM ADVWORKS_DEV.AUDIT.PIPELINE_AUDIT
ORDER BY CREATED_AT DESC;
/*
RUN_ID	SOURCE_OBJECT	STATUS	ROWS_READ	ROWS_WRITTEN	ERROR_COUNT	ERROR_MESSAGE
4a65f595-7084-4adb-bfcf-7c13e4cccb8c	dim_customer/INVALID_FILE.jsonl	FAILED	0	0	1	Source file could not be processed
d5358bad-6c47-4a19-8502-7cb80e81693b	dim_customer/DEV_TEST_DimCustomer_001.jsonl	SUCCESS	5000	5000	0	
*/


/*

Why this matters

Now our audit table represents both:

SUCCESS
FAILED

which gives us the foundation for:

                   PIPELINE
                      │
              ┌───────┴───────┐
              │               │
           SUCCESS           FAILED
              │               │
        rows written      error captured
              │               │
              └───────┬───────┘
                      ↓
                 AUDIT TABLE

*/

