{% macro generate_cron_schedule_dynamic_table(warehouse) %}
    {% set task_ddl_statements = [] %}
    {% for node in graph.nodes.values() %}
        {% if node.meta is defined and ('cron_test' in node.meta or 'cron_prod' in node.meta) %}
            {% set table_name = node.database ~ '.' ~ node.schema ~ '.' ~ node.alias %}
            {% set task_name = table_name ~ '_CRON_SCHEDULE' %}
            {% if target.name == 'prod' %}
                {% set schedule = 'USING CRON' ~ ' ' ~ node.meta.cron_prod ~ ' ' ~ node.meta.timezone %}
            {% elif target.name == 'test' %}
                {% set schedule = 'USING CRON' ~ ' ' ~ node.meta.cron_test ~ ' ' ~ node.meta.timezone %}
            {% else %}
                {% set schedule = 'USING CRON' ~ ' ' ~ node.meta.cron_test ~ ' ' ~ node.meta.timezone %}
            {% endif %}

            {% set create_task_sql %}    
CREATE OR REPLACE TASK {{ task_name }}
  SCHEDULE = '{{ schedule }}'
  WAREHOUSE = '{{ warehouse }}'
  AS
    ALTER DYNAMIC TABLE {{ table_name }} REFRESH;
            {% endset %}
            {% do task_ddl_statements.append(create_task_sql) %} 
            {% set resume_task_sql = "ALTER TASK IF EXISTS " ~ task_name ~ " RESUME;" %}
            {% do task_ddl_statements.append(resume_task_sql) %}
        {% endif %}
    {% endfor %}
    {{ return(task_ddl_statements) }}
{% endmacro %}