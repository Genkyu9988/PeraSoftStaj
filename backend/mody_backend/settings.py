"""Single-workspace LOCAL development API. Not an internet deployment config."""
import json
import os
from pathlib import Path

BASE_DIR = Path(__file__).resolve().parent.parent
config_file = BASE_DIR / '.local.json'
local = json.loads(config_file.read_text(encoding='utf-8')) if config_file.exists() else {}
SECRET_KEY = os.environ.get('MODY_SECRET_KEY', local.get('secret_key', ''))
API_TOKEN = os.environ.get('MODY_API_TOKEN', local.get('api_token', ''))
database_path = os.environ.get('MODY_DATABASE_PATH', local.get('database_path', ''))
if not SECRET_KEY or not API_TOKEN or not database_path:
    raise RuntimeError('Run configure_local.py with an existing Mody AI v2 database first.')
if not Path(database_path).is_file():
    raise RuntimeError('Configured Mody AI database does not exist; refusing to create an empty replacement.')
DEBUG = False
ALLOWED_HOSTS = ['127.0.0.1', 'localhost', '10.0.2.2', '[::1]', 'testserver']
ROOT_URLCONF = 'mody_backend.urls'
WSGI_APPLICATION = 'mody_backend.wsgi.application'
INSTALLED_APPS = ['mody_api']
MIDDLEWARE = ['django.middleware.security.SecurityMiddleware', 'django.middleware.common.CommonMiddleware']
DATABASES = {'default': {'ENGINE': 'django.db.backends.sqlite3', 'NAME': database_path,
                          'OPTIONS': {'timeout': 10}}}
DEFAULT_AUTO_FIELD = 'django.db.models.BigAutoField'
USE_TZ = True
TIME_ZONE = 'UTC'
DATA_UPLOAD_MAX_MEMORY_SIZE = 2 * 1024 * 1024
APPEND_SLASH = False
