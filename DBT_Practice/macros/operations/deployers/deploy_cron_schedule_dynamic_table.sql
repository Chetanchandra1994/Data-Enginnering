{% macro deploy_cron_schedule_dynamic_table(warehouse=target.warehouse) %}
  {% set ddl_commands = generate_cron_schedule_dynamic_table(warehouse=warehouse) %}
  
  {% if ddl_commands %}
    {% for cmd in ddl_commands %}
      {{ log("Executing DDL: " ~ cmd, info=True) }}
      {% do run_query(cmd) %}
    {% endfor %}
  {% else %}
    {{ log("No sources found with meta.schedule set to custom", info=True) }}
  {% endif %}
{% endmacro %}