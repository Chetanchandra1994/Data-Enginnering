{% macro alert2_pipe_inactive__condition() %}
  {% set pipe_queries = [] %}

  {% set all_sources = graph.get('sources', {}).values() %}
  {% for source in all_sources %}
    {% if source.get('config', {}).get('meta', {}).get('with_pipe') is true %}
      {% set intro = "' as pipe_name, PARSE_JSON(SYSTEM$PIPE_STATUS('" %}
      {% set pipe_name = source.database ~ '.' ~ source.schema ~ '.' ~ source.name ~ '_PIPE'  %}
      {% set outro = "')) as data WHERE data:executionState::String <> 'RUNNING'"  %}
      {% set stmt = "SELECT '" ~ pipe_name ~ intro ~ pipe_name ~ outro %}
      {% do pipe_queries.append(stmt) %}
    {% endif %}
  {% endfor %}

  {{ return(pipe_queries | join(' \nUNION\n')) }}
{% endmacro %}