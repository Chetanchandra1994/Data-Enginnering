{% macro alert1_pipe_load_fail__condition() %}
  {% set pipe_queries = [] %}

  {% set all_sources = graph.get('sources', {}).values() %}
  {% for source in all_sources %}
    {% if source.get('config', {}).get('meta', {}).get('with_pipe') is true %}
      {% set intro = "select * from table(" %}
      {% set copy_history_function = source.database ~ ".INFORMATION_SCHEMA.COPY_HISTORY(TABLE_NAME=>'" %}
      {% set pipe_target_table_name = source.database ~ '.' ~ source.schema ~ '.' ~ source.name %}
      {% set outro = "', START_TIME=> DATEADD(hours, -2, CURRENT_TIMESTAMP()))) where status not in ('Loaded','In progress')" %}
      {% set stmt = intro ~ copy_history_function ~ pipe_target_table_name ~ outro %}
      {% do pipe_queries.append(stmt) %}
    {% endif %}
  {% endfor %}

  {{ return(pipe_queries | join(' \nUNION\n')) }}
{% endmacro %}