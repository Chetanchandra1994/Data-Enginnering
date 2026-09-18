from copy import deepcopy
import os
import sys

# Add the path to your Airflow environment's utils if needed for deep_update
# In many Airflow environments, you might need to find where deep_update is located.
# For simplicity, if pydantic is installed:
# from pydantic.utils import deep_update 

# Placeholder for deep_update if the correct import path is unknown:
def deep_update(base_dict, update_dict):
    """Recursively update a dictionary."""
    for key, value in update_dict.items():
        if isinstance(value, dict) and key in base_dict:
            base_dict[key] = deep_update(base_dict[key], value)
        else:
            base_dict[key] = value
    return base_dict

# Attempt to load the default logging config from Airflow's internal template
try:
    from airflow.config_templates.airflow_local_settings import DEFAULT_LOGGING_CONFIG
except ImportError:
    print("Warning: Could not import DEFAULT_LOGGING_CONFIG. Airflow version issue?")
    DEFAULT_LOGGING_CONFIG = {} # Fallback or adjust as needed

LOGGING_CONFIG = deep_update(
    deepcopy(DEFAULT_LOGGING_CONFIG),
    {
        "loggers": {
            # 1. Silencing the Airflow Snowflake Hook: Hides the 'Running statement: INSERT INTO...' log
            "airflow.task.hooks.airflow.providers.snowflake.hooks.snowflake": {
                "handlers": ["task"], 
                "level": "ERROR", # Set to ERROR to silence INFO and WARNING
                "propagate": True,
            },
            # 2. Silencing the core Python Snowflake Connector: Hides connection/version details
            "snowflake.connector": {
                "handlers": ["task"], 
                "level": "ERROR", 
                "propagate": True,
            },
            # Optional: Silencing the base SQL Hook logger
            "airflow.task.hooks.airflow.providers.common.sql.hooks.sql": {
                "handlers": ["task"],
                "level": "ERROR",
                "propagate": True,
            },
        }
    },
)