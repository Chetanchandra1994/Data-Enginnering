import os
import configparser
from flask_appbuilder.security.manager import AUTH_OAUTH

config = configparser.ConfigParser()

config.read('config.ini')

AUTH_TYPE = AUTH_OAUTH

OAUTH_CLIENT_ID = config['secrets']['OAUTH_CLIENT_ID']
OAUTH_CLIENT_SECRET = config['secrets']['OAUTH_CLIENT_SECRET']
OKTA_DOMAIN = config['secrets']['OKTA_DOMAIN']

OAUTH_PROVIDERS = [
    {
        'name': 'okta',
        'icon': 'fa-circle-o',
        'token_key': 'access_token',
        'remote_app': {
            'client_id': OAUTH_CLIENT_ID,
            'client_secret': OAUTH_CLIENT_SECRET,
            
            # 1. Use discovery to find authorize/token endpoints
            'server_metadata_url': f'{OKTA_DOMAIN}/oauth2/default/.well-known/openid-configuration',
            
            # 2. Explicitly define the base URL for the 'userinfo' endpoint
            #    (which Airflow will append '/userinfo' to)
            'api_base_url': f'{OKTA_DOMAIN}/oauth2/default/v1/',
            
            'client_kwargs': {
                'scope': 'openid profile email groups'
            },
        }
    }
]

AUTH_USER_REGISTRATION = True
AUTH_USER_REGISTRATION_ROLE = "Viewer" 
AUTH_ROLES_SYNC_AT_LOGIN = True
AUTH_ROLES_MAPPING = {
    "airflow_admins": ["Admin"],
    "airflow_users": ["User"],
    "airflow_viewers": ["Viewer"],
}