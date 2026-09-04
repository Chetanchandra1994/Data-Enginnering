{% macro assert_no_nulls(model, column_name) %}

    SELECT *

    FROM {{ model }}

    WHERE {{ column_name }} IS NULL

{% endmacro %}


{% macro assert_unique_combination(model, columns) %}

    SELECT
        {{ columns | join(', ') }},
        COUNT(*) AS duplicate_count

    FROM {{ model }}

    GROUP BY
        {{ columns | join(', ') }}

    HAVING COUNT(*) > 1

{% endmacro %}


{% macro assert_no_orphans(
    child_model,
    parent_model,
    child_key,
    parent_key
) %}

    SELECT
        c.{{ child_key }}

    FROM {{ child_model }} c

    LEFT JOIN {{ parent_model }} p

        ON c.{{ child_key }} = p.{{ parent_key }}

    WHERE p.{{ parent_key }} IS NULL

{% endmacro %}