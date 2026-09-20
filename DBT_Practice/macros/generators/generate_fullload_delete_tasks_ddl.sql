{% macro generate_fullload_delete_tasks_ddl(warehouse, schedule) %}
  {% set task_ddl_statements = [] %}
  {% set sources = graph.get('sources', {}).values() %}

  {% for source in sources %}
    {% set is_full_load = source.get('config', {}).get('meta', {}).get('with_fullload_delete', false) %}

    {% if is_full_load is true %}
      {% set from_source = source.database ~ '.' ~ source.schema ~ '.' ~ source.name %}
      {% set task_name = source.database ~ '.' ~ source.schema ~ '.' ~ source.name ~ '_DELETE_PREVIOUS_FULLLOAD' %}

      {% set create_task_sql %}
CREATE OR REPLACE TASK {{ task_name }}
  WAREHOUSE = '{{ warehouse }}'
  SCHEDULE = '{{ schedule }}'
AS
DELETE FROM {{ from_source }}
WHERE
  SPLIT(FILENAME, '_')[ARRAY_SIZE(SPLIT(FILENAME, '_')) - 2] < (
    SELECT MIN_TIMESTAMP
    FROM (
      SELECT
        SPLIT(FILENAME, '_')[ARRAY_SIZE(SPLIT(FILENAME, '_')) - 2] AS MIN_TIMESTAMP,
        SPLIT(FILENAME, '/')[3] AS TYPE_FILE
      FROM {{ from_source }}
      WHERE TYPE_FILE LIKE 'fullload%'
      QUALIFY ROW_NUMBER() OVER (ORDER BY MIN_TIMESTAMP DESC) = 1
    ) AS LATEST_FULLLOAD_INFO
  );
      {% endset %}
      {% do task_ddl_statements.append(create_task_sql) %}
      
      {% set resume_task_sql = "ALTER TASK IF EXISTS " ~ task_name ~ " RESUME;" %}
      {% do task_ddl_statements.append(resume_task_sql) %}
    {% endif %}
  {% endfor %}

  {{ return(task_ddl_statements) }}
{% endmacro %}