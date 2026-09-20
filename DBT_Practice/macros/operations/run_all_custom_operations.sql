{% macro run_all_custom_operations() %}
  {{ log("Starting all custom operations execution...", info=True) }}

  {{ log("Executing: deploy_fullload_delete_tasks operation...", info=True) }}
    {% do deploy_fullload_delete_tasks() %}    
  {{ log("Completed: deploy_fullload_delete_tasks operation.", info=True) }}

  {{ log("Executing: deploy_cron_schedule_dynamic_table operation...", info=True) }}
    {% do deploy_cron_schedule_dynamic_table() %}    
  {{ log("Completed: deploy_cron_schedule_dynamic_table operation.", info=True) }}

  {{ log("Executing: deploy_custom_test_tasks operation...", info=True) }}
    {% do deploy_custom_test_tasks() %}    
  {{ log("Completed: deploy_cron_schedule_dynamic_table operation.", info=True) }}

  {{ log("Complete: all custom operations execution", info=True) }}

{% endmacro %}