{% macro deploy_custom_test_tasks(warehouse=target.warehouse) %}
  {% set ddl_commands = generate_custom_test_ddl(warehouse=warehouse) %}
  
  {% if ddl_commands %}
    {{ log("Found " ~ (ddl_commands | length) ~ " source(s) for custom test task deployment.", info=True) }}
    {% for each_test in ddl_commands %}
      {% for statement in each_test %}
        {#
        {{ log(statement, info=True) }}
        #}
        {% do run_query(statement) %}
      {% endfor %}
    {% endfor %}
    {{ log("Successfully deployed/updated and resumed custom test tasks.", info=True) }}
  {% else %}
    {{ log("No tests to deploy found.", info=True) }}
  {% endif %}
{% endmacro %}