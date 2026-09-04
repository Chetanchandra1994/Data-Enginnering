{{ assert_no_orphans(
    ref('fact_internet_sales'),
    ref('dim_product'),
    'PRODUCT_KEY',
    'PRODUCT_KEY'
) }}