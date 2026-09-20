import os
from flask import Flask, redirect, url_for, session, send_from_directory
from werkzeug.middleware.proxy_fix import ProxyFix
from authlib.integrations.flask_client import OAuth

app = Flask(__name__)
app.secret_key = os.environ.get("SECRET_KEY", "notfound")
app.wsgi_app = ProxyFix(app.wsgi_app, x_proto=1, x_host=1)

# 1. Okta Configuration (Using Env Vars for safety)
oauth = OAuth(app)
oauth.register(
    name='okta',
    client_id=os.environ.get("OAUTH_CLIENT_ID", "notfound"),
    client_secret=os.environ.get("OAUTH_CLIENT_SECRET", "notfound"),
    server_metadata_url=os.environ.get("SERVER_METADATA_URL", "notfound"),
    client_kwargs={'scope': 'openid profile email'}
)

# 2. Optimized Static Serving from 'target' folder
DOCS_DIR = 'target'

@app.route('/')
def index():
    if not session.get('user'):
        return redirect(url_for('login'))
    return send_from_directory(DOCS_DIR, 'index.html')

@app.route('/<path:path>')
def serve_docs(path):
    if not session.get('user'):
        return "Unauthorized", 401
    return send_from_directory(DOCS_DIR, path)

# 3. Auth Routes
@app.route('/login')
def login():
    redirect_uri = url_for('auth', _external=True)
    return oauth.okta.authorize_redirect(redirect_uri)

@app.route('/authorization-code/callback')
def auth():
    token = oauth.okta.authorize_access_token()
    session['user'] = token.get('userinfo')
    return redirect(url_for('index'))

@app.route('/logout')
def logout():
    session.pop('user', None)
    return redirect('/')

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=int(os.environ.get('PORT', 8080)))