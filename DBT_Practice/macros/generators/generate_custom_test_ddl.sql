{% macro generate_custom_test_ddl(warehouse=target.warehouse) %}
    {% set task_ddl_statements = [] %}
    {% set governance_db = get_governance_database() %}
    {% set etl_event_detail_table = governance_db ~ '.DATA_QUALITY.ETL_EVENT_DETAIL' %}

    {% set cron_base_schedule = namespace(val='0 10 * * *') %}

    {% for node in graph.nodes.values() %}
        {% if node.meta is defined and 'tests' in node.meta %}
            {% for test_name, test_config in node.meta.tests.items() %}
                {% set current_schedule = 'USING CRON ' ~ cron_base_schedule.val ~ ' UTC'%}
                {{ log("cron schedule: " ~ current_schedule, info=True) }}

                {# Common arguments for all test generation macros #}
                {% set common_args = {
                    'warehouse': warehouse,
                    'schedule': current_schedule,
                    'table': node.alias,
                    'key': node.meta.table_key,
                    'table_name': node.database ~ '.' ~ node.schema ~ '.' ~ node.alias,
                    'etl_event_detail_table': etl_event_detail_table,
                    'governance_db': governance_db
                } %}

                {# Add specific arguments for tests that need them #}
                {% if test_name in ['unexpected_values', 'null_values'] %}
                    {% do common_args.update({'values': test_config}) %}
                {% endif %}

                {{ log(common_args, info=True) }}

                {# Dynamically call the macro for the specific test #}
                {% set macro_name = 'generate_' ~ test_name ~ '_test_ddl' %}
                {% set test_macro = context[macro_name] %}
                {% set task_ddl = test_macro(**common_args) %}
                {% do task_ddl_statements.append(task_ddl) %}

                {% set cron_base_schedule.val = increment_cron_minute(cron_str=cron_base_schedule.val) %}
            {% endfor %}
        {% endif %}
    {% endfor %}
    {{ log("task_ddl_statements length: " ~ task_ddl_statements | length, info=True) }}
    {{ return(task_ddl_statements) }}
{% endmacro %}