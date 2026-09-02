/*
NORMALIZE

Now we're moving from technical preparation to data standardization/model preparation.

For DIMCUSTOMER, we'll create:

ADVWORKS_DEV
│
├── LANDING
│   └── DIMCUSTOMER_RAW
│
├── PREPARE
│   └── DIMCUSTOMER_PREPARED
│
├── NORMALIZE
│   └── DIMCUSTOMER_NORMALIZED   ← NEXT
│
├── SCHEMATIZE
│
└── MARKETPLACE

The important distinction is:

PREPARE
    ↓
"What did the source send, converted into usable types?"

NORMALIZE
    ↓
"How should we standardize and clean this data for our warehouse?"

SCHEMATIZE
    ↓
"How should the analytical warehouse model be structured?"

MARKETPLACE
    ↓
"How should business users consume it?"

*/

-- ######################################  Stage 5 — Create NORMALIZE table  ####################################################

USE DATABASE ADVWORKS_DEV;

CREATE OR REPLACE TABLE NORMALIZE.DIMCUSTOMER_NORMALIZED
(
    CUSTOMER_KEY              INTEGER,
    GEOGRAPHY_KEY             INTEGER,
    CUSTOMER_ALTERNATE_KEY    VARCHAR(20),

    TITLE                     VARCHAR(10),
    FIRST_NAME                VARCHAR(100),
    MIDDLE_NAME               VARCHAR(100),
    LAST_NAME                 VARCHAR(100),
    NAME_STYLE                BOOLEAN,
    BIRTH_DATE                DATE,

    MARITAL_STATUS            VARCHAR(1),
    SUFFIX                    VARCHAR(10),
    GENDER                    VARCHAR(1),

    EMAIL_ADDRESS             VARCHAR(255),
    YEARLY_INCOME             NUMBER(18,2),

    TOTAL_CHILDREN            INTEGER,
    NUMBER_CHILDREN_AT_HOME   INTEGER,

    ENGLISH_EDUCATION         VARCHAR(100),
    SPANISH_EDUCATION         VARCHAR(100),
    FRENCH_EDUCATION          VARCHAR(100),

    ENGLISH_OCCUPATION        VARCHAR(100),
    SPANISH_OCCUPATION        VARCHAR(100),
    FRENCH_OCCUPATION         VARCHAR(100),

    HOUSE_OWNER_FLAG          BOOLEAN,
    NUMBER_CARS_OWNED         INTEGER,

    ADDRESS_LINE1             VARCHAR(255),
    ADDRESS_LINE2             VARCHAR(255),
    PHONE                     VARCHAR(50),

    DATE_FIRST_PURCHASE       DATE,
    COMMUTE_DISTANCE          VARCHAR(50),

    SOURCE_FILE               VARCHAR(500),
    LOAD_TIMESTAMP            TIMESTAMP_NTZ,

    NORMALIZED_TIMESTAMP      TIMESTAMP_NTZ
);

/*

Why are we adding NORMALIZED_TIMESTAMP?  
This is pipeline metadata. It tells us when the normalization step processed the record, which is useful for:

troubleshooting
auditing
pipeline monitoring
identifying when transformations occurred

*/

-- ###########################    Normalize the data. Now we'll deliberately perform some basic standardization.  ###########################

INSERT INTO ADVWORKS_DEV.NORMALIZE.DIMCUSTOMER_NORMALIZED
(
    CUSTOMER_KEY,
    GEOGRAPHY_KEY,
    CUSTOMER_ALTERNATE_KEY,

    TITLE,
    FIRST_NAME,
    MIDDLE_NAME,
    LAST_NAME,
    NAME_STYLE,
    BIRTH_DATE,

    MARITAL_STATUS,
    SUFFIX,
    GENDER,

    EMAIL_ADDRESS,
    YEARLY_INCOME,

    TOTAL_CHILDREN,
    NUMBER_CHILDREN_AT_HOME,

    ENGLISH_EDUCATION,
    SPANISH_EDUCATION,
    FRENCH_EDUCATION,

    ENGLISH_OCCUPATION,
    SPANISH_OCCUPATION,
    FRENCH_OCCUPATION,

    HOUSE_OWNER_FLAG,
    NUMBER_CARS_OWNED,

    ADDRESS_LINE1,
    ADDRESS_LINE2,
    PHONE,

    DATE_FIRST_PURCHASE,
    COMMUTE_DISTANCE,

    SOURCE_FILE,
    LOAD_TIMESTAMP,

    NORMALIZED_TIMESTAMP
)

SELECT

    CUSTOMER_KEY,

    GEOGRAPHY_KEY,

    TRIM(CUSTOMER_ALTERNATE_KEY),

    NULLIF(TRIM(TITLE), ''),

    INITCAP(TRIM(FIRST_NAME)),

    NULLIF(TRIM(MIDDLE_NAME), ''),

    INITCAP(TRIM(LAST_NAME)),

    NAME_STYLE,

    BIRTH_DATE,

    UPPER(TRIM(MARITAL_STATUS)),

    NULLIF(TRIM(SUFFIX), ''),

    UPPER(TRIM(GENDER)),

    LOWER(TRIM(EMAIL_ADDRESS)),

    YEARLY_INCOME,

    TOTAL_CHILDREN,

    NUMBER_CHILDREN_AT_HOME,

    TRIM(ENGLISH_EDUCATION),

    TRIM(SPANISH_EDUCATION),

    TRIM(FRENCH_EDUCATION),

    TRIM(ENGLISH_OCCUPATION),

    TRIM(SPANISH_OCCUPATION),

    TRIM(FRENCH_OCCUPATION),

    HOUSE_OWNER_FLAG,

    NUMBER_CARS_OWNED,

    TRIM(ADDRESS_LINE1),

    NULLIF(TRIM(ADDRESS_LINE2), ''),

    TRIM(PHONE),

    DATE_FIRST_PURCHASE,

    TRIM(COMMUTE_DISTANCE),

    SOURCE_FILE,

    LOAD_TIMESTAMP,

    CURRENT_TIMESTAMP()

FROM ADVWORKS_DEV.PREPARE.DIMCUSTOMER_PREPARED;

-- ###########################   Validate NORMALIZE   ###################################################

SELECT COUNT(*) AS NORMALIZE_COUNT
FROM ADVWORKS_DEV.NORMALIZE.DIMCUSTOMER_NORMALIZED; --18484

SELECT
    (SELECT COUNT(*)
     FROM ADVWORKS_DEV.PREPARE.DIMCUSTOMER_PREPARED)
        AS PREPARE_COUNT,

    (SELECT COUNT(*)
     FROM ADVWORKS_DEV.NORMALIZE.DIMCUSTOMER_NORMALIZED)
        AS NORMALIZE_COUNT;
/*
PREPARE_COUNT	NORMALIZE_COUNT
18484	18484
*/

-- Primary key
SELECT COUNT(*) AS NULL_CUSTOMER_KEYS
FROM ADVWORKS_DEV.NORMALIZE.DIMCUSTOMER_NORMALIZED
WHERE CUSTOMER_KEY IS NULL; -- 0

--Duplicate customers
SELECT
    CUSTOMER_KEY,
    COUNT(*) AS CNT
FROM ADVWORKS_DEV.NORMALIZE.DIMCUSTOMER_NORMALIZED
GROUP BY CUSTOMER_KEY
HAVING COUNT(*) > 1; -- Query produced no results

-- Email standardization
SELECT
    CUSTOMER_KEY,
    EMAIL_ADDRESS
FROM ADVWORKS_DEV.NORMALIZE.DIMCUSTOMER_NORMALIZED
ORDER BY CUSTOMER_KEY
LIMIT 10;
/*
CUSTOMER_KEY	EMAIL_ADDRESS
11000	jon24@adventure-works.com
11001	eugene10@adventure-works.com
11002	ruben35@adventure-works.com
11003	christy12@adventure-works.com
11004	elizabeth5@adventure-works.com
11005	julio1@adventure-works.com
11006	janet9@adventure-works.com
11007	marco14@adventure-works.com
11008	rob4@adventure-works.com
11009	shannon38@adventure-works.com
*/


/*

So we now have a clean, validated pipeline through NORMALIZE:

AdventureWorksDW2022
        ↓
Python / pyodbc
        ↓
JSONL
        ↓
Storage
        ↓
Snowflake Stage
        ↓
LANDING
  DIMCUSTOMER_RAW
        ↓
PREPARE
  DIMCUSTOMER_PREPARED
        ↓
NORMALIZE
  DIMCUSTOMER_NORMALIZED
        ↓
     NEXT
  SCHEMATIZE
        ↓
  MARKETPLACE

*/