{{ assert_unique_combination(
    ref('fact_internet_sales'),
    ['SALES_ORDER_NUMBER', 'SALES_ORDER_LINE_NUMBER']
) }}


-- This validates:

-- SalesOrderNumber + SalesOrderLineNumber

-- is unique.

-- Your expected result:

-- 60398 rows
-- 60398 unique order lines