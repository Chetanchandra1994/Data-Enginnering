{{ assert_no_orphans(
    ref('fact_internet_sales'),
    ref('dim_customer'),
    'CUSTOMER_KEY',
    'CUSTOMER_KEY'
) }}