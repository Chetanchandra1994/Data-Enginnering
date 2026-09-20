{% macro deploy_fullload_delete_tasks(warehouse=target.warehouse, schedule='USING CRON 0/15 * * * * UTC') %}
  {% set ddl_commands = generate_fullload_delete_tasks_ddl(warehouse=warehouse, schedule=schedule) %}
  
  {% if ddl_commands %}
    {{ log("Found " ~ (ddl_commands | length / 2) ~ " source(s) for fullload delete task deployment.", info=True) }}
    {% for cmd in ddl_commands %}
      {{ log("Executing DDL: " ~ cmd, info=True) }}
      {% do run_query(cmd) %}
    {% endfor %}
    {{ log("Successfully deployed/updated and resumed fullload delete tasks.", info=True) }}
  {% else %}
    {{ log("No sources found with 'with_fullload_delete: true' meta flag. No tasks deployed for fullload delete.", info=True) }}
  {% endif %}
{% endmacro %}