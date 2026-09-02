--##################  validations ##########################################

SELECT
    RECORD:CustomerKey::INTEGER AS CUSTOMER_KEY,
    RECORD:GeographyKey::INTEGER AS GEOGRAPHY_KEY,
    RECORD:CustomerAlternateKey::VARCHAR AS CUSTOMER_ALTERNATE_KEY,
    RECORD:FirstName::VARCHAR AS FIRST_NAME,
    RECORD:LastName::VARCHAR AS LAST_NAME,
    RECORD:BirthDate::VARCHAR AS BIRTH_DATE_RAW,
    RECORD:YearlyIncome::NUMBER(18,2) AS YEARLY_INCOME,
    RECORD:TotalChildren::INTEGER AS TOTAL_CHILDREN,
    RECORD:NumberChildrenAtHome::INTEGER AS NUMBER_CHILDREN_AT_HOME,
    RECORD:HouseOwnerFlag::VARCHAR AS HOUSE_OWNER_FLAG_RAW,
    RECORD:NumberCarsOwned::INTEGER AS NUMBER_CARS_OWNED,
    RECORD:DateFirstPurchase::VARCHAR AS DATE_FIRST_PURCHASE_RAW
FROM ADVWORKS_DEV.LANDING.DIMCUSTOMER_RAW
LIMIT 10;

/*
CUSTOMER_KEY	GEOGRAPHY_KEY	CUSTOMER_ALTERNATE_KEY	FIRST_NAME	LAST_NAME	BIRTH_DATE_RAW	YEARLY_INCOME	TOTAL_CHILDREN	NUMBER_CHILDREN_AT_HOME
26000	369	AW00026000	Connor	Lopez	1971-10-02	40000.00	0	0
26001	539	AW00026001	Nicholas	Lee	1972-09-21	50000.00	0	0
26002	548	AW00026002	Samuel	Walker	1973-04-01	50000.00	0	0
26003	307	AW00026003	Denise	Subram	1973-05-24	60000.00	0	0
26004	348	AW00026004	Arthur	Washington	1966-05-08	60000.00	1	0
26005	547	AW00026005	Elizabeth	Clark	1966-05-18	60000.00	1	0
26006	607	AW00026006	Garrett	Peterson	1965-04-22	60000.00	4	3
26007	347	AW00026007	Jesse	Morgan	1970-04-04	60000.00	4	3
26008	315	AW00026008	Jennifer	Gonzales	1970-06-19	70000.00	5	5
26009	315	AW00026009	Luis	Foster	1965-03-12	70000.00	5	5

*/

SELECT
    COUNT(*) AS TOTAL_RECORDS,

    COUNT_IF(RECORD:CustomerKey IS NULL) AS NULL_CUSTOMER_KEY,
    COUNT_IF(RECORD:GeographyKey IS NULL) AS NULL_GEOGRAPHY_KEY,
    COUNT_IF(RECORD:FirstName IS NULL) AS NULL_FIRST_NAME,
    COUNT_IF(RECORD:LastName IS NULL) AS NULL_LAST_NAME,
    COUNT_IF(RECORD:BirthDate IS NULL) AS NULL_BIRTH_DATE,
    COUNT_IF(RECORD:YearlyIncome IS NULL) AS NULL_YEARLY_INCOME,
    COUNT_IF(RECORD:DateFirstPurchase IS NULL) AS NULL_DATE_FIRST_PURCHASE
FROM ADVWORKS_DEV.LANDING.DIMCUSTOMER_RAW;
/*
TOTAL_RECORDS	NULL_CUSTOMER_KEY	NULL_GEOGRAPHY_KEY	NULL_FIRST_NAME	NULL_LAST_NAME	NULL_BIRTH_DATE	NULL_YEARLY_INCOME	NULL_DATE_FIRST_PURCHASE
18484	0	0	0	0	0	0	0

*/

--Marital status
SELECT
    RECORD:MaritalStatus::VARCHAR AS MARITAL_STATUS,
    COUNT(*) AS RECORD_COUNT
FROM ADVWORKS_DEV.LANDING.DIMCUSTOMER_RAW
GROUP BY RECORD:MaritalStatus::VARCHAR
ORDER BY RECORD_COUNT DESC;
/*
MARITAL_STATUS	RECORD_COUNT
M	10011
S	8473
*/


--Gender
SELECT
    RECORD:Gender::VARCHAR AS GENDER,
    COUNT(*) AS RECORD_COUNT
FROM ADVWORKS_DEV.LANDING.DIMCUSTOMER_RAW
GROUP BY RECORD:Gender::VARCHAR
ORDER BY RECORD_COUNT DESC;
/*
GENDER	RECORD_COUNT
M	9351
F	9133

*/


--House owner flag
SELECT
    RECORD:HouseOwnerFlag::VARCHAR AS HOUSE_OWNER_FLAG,
    COUNT(*) AS RECORD_COUNT
FROM ADVWORKS_DEV.LANDING.DIMCUSTOMER_RAW
GROUP BY RECORD:HouseOwnerFlag::VARCHAR
ORDER BY RECORD_COUNT DESC;
/*
HOUSE_OWNER_FLAG	RECORD_COUNT
1	12502
0	5982

*/


--Commute distance
SELECT
    RECORD:CommuteDistance::VARCHAR AS COMMUTE_DISTANCE,
    COUNT(*) AS RECORD_COUNT
FROM ADVWORKS_DEV.LANDING.DIMCUSTOMER_RAW
GROUP BY RECORD:CommuteDistance::VARCHAR
ORDER BY RECORD_COUNT DESC;
/*
COMMUTE_DISTANCE	RECORD_COUNT
0-1 Miles	6310
2-5 Miles	3234
1-2 Miles	3232
5-10 Miles	3214
10+ Miles	2494

*/

--#############################################  Create the PREPARE table #######################################################

USE DATABASE ADVWORKS_DEV;

CREATE OR REPLACE TABLE PREPARE.DIMCUSTOMER_PREPARED
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
    LOAD_TIMESTAMP            TIMESTAMP_NTZ
);

--############################################## Load LANDING → PREPARE   ##############################################

with raw_dim_customer as (
select * from ADVWORKS_DEV.LANDING.DIMCUSTOMER_RAW
)
SELECT
RECORD:CustomerKey::INTEGER,

    RECORD:GeographyKey::INTEGER,

    RECORD:CustomerAlternateKey::VARCHAR,

    RECORD:Title::VARCHAR,

    RECORD:FirstName::VARCHAR,

    RECORD:MiddleName::VARCHAR,

    RECORD:LastName::VARCHAR,

    RECORD:NameStyle::BOOLEAN,

    TRY_TO_DATE(
        RECORD:BirthDate::VARCHAR
    ),

    RECORD:MaritalStatus::VARCHAR,

    RECORD:Suffix::VARCHAR,

    RECORD:Gender::VARCHAR,

    RECORD:EmailAddress::VARCHAR,

    RECORD:YearlyIncome::NUMBER(18,2),

    RECORD:TotalChildren::INTEGER,

    RECORD:NumberChildrenAtHome::INTEGER,

    RECORD:EnglishEducation::VARCHAR,

    RECORD:SpanishEducation::VARCHAR,

    RECORD:FrenchEducation::VARCHAR,

    RECORD:EnglishOccupation::VARCHAR,

    RECORD:SpanishOccupation::VARCHAR,

    RECORD:FrenchOccupation::VARCHAR,

    CASE
        WHEN RECORD:HouseOwnerFlag::VARCHAR = '1'
            THEN TRUE

        WHEN RECORD:HouseOwnerFlag::VARCHAR = '0'
            THEN FALSE

        ELSE NULL
    END,

    RECORD:NumberCarsOwned::INTEGER,

    RECORD:AddressLine1::VARCHAR,

    RECORD:AddressLine2::VARCHAR,

    RECORD:Phone::VARCHAR,

    TRY_TO_DATE(
        RECORD:DateFirstPurchase::VARCHAR
    ),

    RECORD:CommuteDistance::VARCHAR,

    SOURCE_FILE,

    LOAD_TIMESTAMP
    
    FROM raw_dim_customer;

    -- ##################################################################################################################

INSERT INTO ADVWORKS_DEV.PREPARE.DIMCUSTOMER_PREPARED
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
    LOAD_TIMESTAMP
)

SELECT

    RECORD:CustomerKey::INTEGER,

    RECORD:GeographyKey::INTEGER,

    RECORD:CustomerAlternateKey::VARCHAR,

    RECORD:Title::VARCHAR,

    RECORD:FirstName::VARCHAR,

    RECORD:MiddleName::VARCHAR,

    RECORD:LastName::VARCHAR,

    RECORD:NameStyle::BOOLEAN,

    TRY_TO_DATE(
        RECORD:BirthDate::VARCHAR
    ),

    RECORD:MaritalStatus::VARCHAR,

    RECORD:Suffix::VARCHAR,

    RECORD:Gender::VARCHAR,

    RECORD:EmailAddress::VARCHAR,

    RECORD:YearlyIncome::NUMBER(18,2),

    RECORD:TotalChildren::INTEGER,

    RECORD:NumberChildrenAtHome::INTEGER,

    RECORD:EnglishEducation::VARCHAR,

    RECORD:SpanishEducation::VARCHAR,

    RECORD:FrenchEducation::VARCHAR,

    RECORD:EnglishOccupation::VARCHAR,

    RECORD:SpanishOccupation::VARCHAR,

    RECORD:FrenchOccupation::VARCHAR,

    CASE
        WHEN RECORD:HouseOwnerFlag::VARCHAR = '1'
            THEN TRUE

        WHEN RECORD:HouseOwnerFlag::VARCHAR = '0'
            THEN FALSE

        ELSE NULL
    END,

    RECORD:NumberCarsOwned::INTEGER,

    RECORD:AddressLine1::VARCHAR,

    RECORD:AddressLine2::VARCHAR,

    RECORD:Phone::VARCHAR,

    TRY_TO_DATE(
        RECORD:DateFirstPurchase::VARCHAR
    ),

    RECORD:CommuteDistance::VARCHAR,

    SOURCE_FILE,

    LOAD_TIMESTAMP

FROM ADVWORKS_DEV.LANDING.DIMCUSTOMER_RAW;


-- Verify record count

SELECT COUNT(*) AS PREPARE_COUNT
FROM ADVWORKS_DEV.PREPARE.DIMCUSTOMER_PREPARED; -- 18484

SELECT
    (SELECT COUNT(*)
     FROM ADVWORKS_DEV.LANDING.DIMCUSTOMER_RAW)
        AS LANDING_COUNT,

    (SELECT COUNT(*)
     FROM ADVWORKS_DEV.PREPARE.DIMCUSTOMER_PREPARED)
        AS PREPARE_COUNT;
/*
LANDING_COUNT	PREPARE_COUNT
18484	18484
*/

SELECT
    CUSTOMER_KEY,
    GEOGRAPHY_KEY,
    CUSTOMER_ALTERNATE_KEY,
    FIRST_NAME,
    LAST_NAME,
    BIRTH_DATE,
    YEARLY_INCOME,
    TOTAL_CHILDREN,
    NUMBER_CHILDREN_AT_HOME,
    HOUSE_OWNER_FLAG,
    NUMBER_CARS_OWNED,
    DATE_FIRST_PURCHASE,
    COMMUTE_DISTANCE,
    SOURCE_FILE,
    LOAD_TIMESTAMP
FROM ADVWORKS_DEV.PREPARE.DIMCUSTOMER_PREPARED
ORDER BY CUSTOMER_KEY
LIMIT 10;

--Verify the actual Snowflake data types. This is a useful exercise.


DESC TABLE ADVWORKS_DEV.PREPARE.DIMCUSTOMER_PREPARED;

-- Check NULL primary key
SELECT COUNT(*) AS NULL_CUSTOMER_KEYS
FROM ADVWORKS_DEV.PREPARE.DIMCUSTOMER_PREPARED
WHERE CUSTOMER_KEY IS NULL; -- 0

-- Check duplicate keys
SELECT
    CUSTOMER_KEY,
    COUNT(*) AS CNT
FROM ADVWORKS_DEV.PREPARE.DIMCUSTOMER_PREPARED
GROUP BY CUSTOMER_KEY
HAVING COUNT(*) > 1; -- Query produced no results

-- Check house-owner conversion
SELECT
    HOUSE_OWNER_FLAG,
    COUNT(*) AS RECORD_COUNT
FROM ADVWORKS_DEV.PREPARE.DIMCUSTOMER_PREPARED
GROUP BY HOUSE_OWNER_FLAG
ORDER BY HOUSE_OWNER_FLAG;

-- Check date conversion
SELECT
    COUNT(*) AS INVALID_BIRTH_DATES
FROM ADVWORKS_DEV.PREPARE.DIMCUSTOMER_PREPARED
WHERE BIRTH_DATE IS NULL; -- 0

SELECT
    COUNT(*) AS INVALID_PURCHASE_DATES
FROM ADVWORKS_DEV.PREPARE.DIMCUSTOMER_PREPARED
WHERE DATE_FIRST_PURCHASE IS NULL; -- 0

/*

We now have a genuine two-layer warehouse:

                 LANDING
                    │
                    │ raw
                    ▼
        ┌────────────────────────┐
        │ DIMCUSTOMER_RAW        │
        │                        │
        │ RECORD VARIANT         │
        │ SOURCE_FILE            │
        │ LOAD_TIMESTAMP         │
        └────────────┬───────────┘
                     │
                     │ transformation
                     ▼
                 PREPARE
                     │
                     ▼
        ┌────────────────────────┐
        │ DIMCUSTOMER_PREPARED   │
        │                        │
        │ Typed columns          │
        │ DATE                   │
        │ INTEGER                │
        │ NUMBER                 │
        │ BOOLEAN                │
        │ VARCHAR                │
        └────────────────────────┘


AdventureWorksDW2022
        │
        ▼
Python / pyodbc
        │
        ▼
JSONL batches
        │
        ▼
Local Storage Bucket
        │
        ▼
Snowflake Internal Stage
        │
        ▼
LANDING.DIMCUSTOMER_RAW
        │
        │  JSON → typed columns
        ▼
PREPARE.DIMCUSTOMER_PREPARED
        │
        ▼
      NEXT
        │
        ▼
NORMALIZE
*/