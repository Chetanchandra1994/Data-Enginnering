SELECT
    f.ORDER_DATE

FROM {{ ref('fact_internet_sales') }} f

LEFT JOIN {{ ref('dim_date') }} d
    ON f.ORDER_DATE::DATE = d.FULL_DATE

WHERE d.FULL_DATE IS NULL


/*

                    DBT
                     │
             ┌───────┴────────┐
             │                │
           MODELS            TESTS
             │                │
             │                ▼
             │          data_quality.sql
             │                │
             │       ┌────────┼────────┐
             │       │        │        │
             │       ▼        ▼        ▼
             │     NULL    UNIQUE   ORPHAN
             │
             ▼
        MARKETPLACE

*/