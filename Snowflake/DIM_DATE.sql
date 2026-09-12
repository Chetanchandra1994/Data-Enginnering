/*
Next step: Build DIM_DATE

Before creating FACT_SALES, we should create the date dimension because your fact contains:

ORDER_DATE_KEY
DUE_DATE_KEY
SHIP_DATE_KEY

All three should eventually point to the same DIM_DATE.

Conceptually:

                 DIM_DATE
              ┌─────────────┐
              │ DATE_SK     │
              │ FULL_DATE   │
              │ YEAR        │
              │ QUARTER     │
              │ MONTH       │
              │ MONTH_NAME  │
              │ DAY         │
              │ DAY_NAME    │
              └──────┬──────┘
                     │
       ┌─────────────┼─────────────┐
       │             │             │
       ▼             ▼             ▼
 ORDER_DATE_KEY  DUE_DATE_KEY  SHIP_DATE_KEY
       │             │             │
       └─────────────┼─────────────┘
                     ▼
                FACT_SALES

This is also a good interview point: the same date dimension can play multiple roles in a fact table. These are called role-playing dimensions.

*/

-- — Determine the date range
SELECT
    MIN(ORDER_DATE) AS MIN_ORDER_DATE,
    MAX(ORDER_DATE) AS MAX_ORDER_DATE,
    MIN(DUE_DATE) AS MIN_DUE_DATE,
    MAX(DUE_DATE) AS MAX_DUE_DATE,
    MIN(SHIP_DATE) AS MIN_SHIP_DATE,
    MAX(SHIP_DATE) AS MAX_SHIP_DATE
FROM ADVWORKS_DEV.NORMALIZE.FACTINTERNETSALES_NORMALIZED;

/*
MIN_ORDER_DATE	MAX_ORDER_DATE	MIN_DUE_DATE	MAX_DUE_DATE	MIN_SHIP_DATE	MAX_SHIP_DATE
2010-12-29 00:00:00.000	2014-01-28 00:00:00.000	2011-01-10 00:00:00.000	2014-02-09 00:00:00.000	2011-01-05 00:00:00.000	2014-02-04 00:00:00.000
*/

-- check the integer date keys:
SELECT
    MIN(ORDER_DATE_KEY) AS MIN_ORDER_DATE_KEY,
    MAX(ORDER_DATE_KEY) AS MAX_ORDER_DATE_KEY,
    MIN(DUE_DATE_KEY) AS MIN_DUE_DATE_KEY,
    MAX(DUE_DATE_KEY) AS MAX_DUE_DATE_KEY,
    MIN(SHIP_DATE_KEY) AS MIN_SHIP_DATE_KEY,
    MAX(SHIP_DATE_KEY) AS MAX_SHIP_DATE_KEY
FROM ADVWORKS_DEV.NORMALIZE.FACTINTERNETSALES_NORMALIZED;
/*
MIN_ORDER_DATE_KEY	MAX_ORDER_DATE_KEY	MIN_DUE_DATE_KEY	MAX_DUE_DATE_KEY	MIN_SHIP_DATE_KEY	MAX_SHIP_DATE_KEY
20101229	20140128	20110110	20140209	20110105	20140204
*/

--- Create DIM_DATE

CREATE OR REPLACE TABLE ADVWORKS_DEV.SCHEMATIZE.DIM_DATE
(
    DATE_SK             INTEGER,
    FULL_DATE           DATE,

    DAY_OF_MONTH        INTEGER,
    DAY_OF_WEEK         INTEGER,
    DAY_NAME            VARCHAR(20),

    WEEK_OF_YEAR        INTEGER,

    MONTH_NUMBER        INTEGER,
    MONTH_NAME          VARCHAR(20),

    QUARTER_NUMBER      INTEGER,
    QUARTER_NAME        VARCHAR(10),

    YEAR_NUMBER         INTEGER,

    MONTH_YEAR          VARCHAR(7),

    IS_WEEKEND          BOOLEAN,

    CREATED_TIMESTAMP   TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP()
);

-- load data

INSERT INTO ADVWORKS_DEV.SCHEMATIZE.DIM_DATE
(
    DATE_SK,
    FULL_DATE,
    DAY_OF_MONTH,
    DAY_OF_WEEK,
    DAY_NAME,
    WEEK_OF_YEAR,
    MONTH_NUMBER,
    MONTH_NAME,
    QUARTER_NUMBER,
    QUARTER_NAME,
    YEAR_NUMBER,
    MONTH_YEAR,
    IS_WEEKEND
)
SELECT
    TO_NUMBER(TO_CHAR(DATE_VALUE, 'YYYYMMDD')) AS DATE_SK,
    DATE_VALUE AS FULL_DATE,

    DAY(DATE_VALUE) AS DAY_OF_MONTH,

    DAYOFWEEKISO(DATE_VALUE) AS DAY_OF_WEEK,

    DAYNAME(DATE_VALUE) AS DAY_NAME,

    WEEKISO(DATE_VALUE) AS WEEK_OF_YEAR,

    MONTH(DATE_VALUE) AS MONTH_NUMBER,

    MONTHNAME(DATE_VALUE) AS MONTH_NAME,

    QUARTER(DATE_VALUE) AS QUARTER_NUMBER,

    'Q' || QUARTER(DATE_VALUE) AS QUARTER_NAME,

    YEAR(DATE_VALUE) AS YEAR_NUMBER,

    TO_CHAR(DATE_VALUE, 'YYYY-MM') AS MONTH_YEAR,

    CASE
        WHEN DAYOFWEEKISO(DATE_VALUE) IN (6, 7)
        THEN TRUE
        ELSE FALSE
    END AS IS_WEEKEND

FROM
    (
        SELECT
            DATEADD(
                DAY,
                SEQ4(),
                '2010-12-29'::DATE
            ) AS DATE_VALUE
        FROM TABLE(
            GENERATOR(ROWCOUNT => 1140)
        )
    )
WHERE DATE_VALUE <= '2014-02-09'::DATE; -- 1139

-- validate
SELECT
    COUNT(*) AS ROW_COUNT,
    MIN(FULL_DATE) AS MIN_DATE,
    MAX(FULL_DATE) AS MAX_DATE,
    COUNT(DISTINCT DATE_SK) AS DISTINCT_DATE_SK,
    COUNT_IF(DATE_SK IS NULL) AS NULL_DATE_SK,
    COUNT_IF(FULL_DATE IS NULL) AS NULL_FULL_DATE
FROM ADVWORKS_DEV.SCHEMATIZE.DIM_DATE;
/*
ROW_COUNT	MIN_DATE	MAX_DATE	DISTINCT_DATE_SK	NULL_DATE_SK	NULL_FULL_DATE
1139	2010-12-29	2014-02-09	1139	0	0
*/

-- Validate that all fact dates exist
SELECT DISTINCT
    N.ORDER_DATE_KEY
FROM ADVWORKS_DEV.NORMALIZE.FACTINTERNETSALES_NORMALIZED N
LEFT JOIN ADVWORKS_DEV.SCHEMATIZE.DIM_DATE D
    ON N.ORDER_DATE_KEY = D.DATE_SK
WHERE D.DATE_SK IS NULL
ORDER BY N.ORDER_DATE_KEY; -- Query produced no results

-- Due dates
SELECT DISTINCT
    N.DUE_DATE_KEY
FROM ADVWORKS_DEV.NORMALIZE.FACTINTERNETSALES_NORMALIZED N
LEFT JOIN ADVWORKS_DEV.SCHEMATIZE.DIM_DATE D
    ON N.DUE_DATE_KEY = D.DATE_SK
WHERE D.DATE_SK IS NULL
ORDER BY N.DUE_DATE_KEY; -- Query produced no results

-- Ship dates
SELECT DISTINCT
    N.SHIP_DATE_KEY
FROM ADVWORKS_DEV.NORMALIZE.FACTINTERNETSALES_NORMALIZED N
LEFT JOIN ADVWORKS_DEV.SCHEMATIZE.DIM_DATE D
    ON N.SHIP_DATE_KEY = D.DATE_SK
WHERE D.DATE_SK IS NULL
ORDER BY N.SHIP_DATE_KEY; -- Query produced no results

/*

One important design point

Notice that we're not creating three date dimensions:

DIM_ORDER_DATE
DIM_DUE_DATE
DIM_SHIP_DATE

Instead, we have one:

DIM_DATE

and the fact will reference it three times:

                       DIM_DATE
                       DATE_SK
                          ▲
              ┌────────────┼─────────────┐
              │           │           │
              │           │           │
       ORDER_DATE_SK  DUE_DATE_SK  SHIP_DATE_SK
              │           │           │
              └──────────── ┼────────────┘
                          │
                     FACT_SALES

This is called a role-playing dimension and is a very common data-warehouse interview topic.

*/