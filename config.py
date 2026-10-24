import os
import ssl
import re
from dotenv import load_dotenv

basedir = os.path.abspath(os.path.dirname(__file__))
load_dotenv(os.path.join(basedir, '.env'))


def _default_database_uri():
    database_url = os.environ.get('DATABASE_URL')
    if database_url:
        # Vercel and cloud providers often provide 'mysql://', but we need 'mysql+pymysql://'
        if database_url.startswith('mysql://'):
            database_url = database_url.replace('mysql://', 'mysql+pymysql://', 1)
        
        # pymysql does not support the 'ssl-mode' keyword argument in the URL
        if 'ssl-mode=' in database_url:
            database_url = database_url.replace('?ssl-mode=REQUIRED', '')
            database_url = database_url.replace('&ssl-mode=REQUIRED', '')
            database_url = re.sub(r'[?&]ssl-mode=[^&]*', '', database_url)

        return database_url

    db_user = os.environ.get('DB_USER') or os.environ.get('MYSQL_USER') or 'root'
    db_password = os.environ.get('DB_PASSWORD') or os.environ.get('MYSQL_PASSWORD') or ''
    db_host = os.environ.get('DB_HOST') or os.environ.get('MYSQL_HOST') or '127.0.0.1'
    db_port = os.environ.get('DB_PORT') or os.environ.get('MYSQL_PORT') or '3306'
    db_name = os.environ.get('DB_NAME') or os.environ.get('MYSQL_DATABASE') or 'poultryconnect'
    return f'mysql+pymysql://{db_user}:{db_password}@{db_host}:{db_port}/{db_name}?charset=utf8mb4'


def _engine_options(database_uri):
    if database_uri.startswith('sqlite'):
        return {}
    
    # Secure SSL context for TiDB Serverless and cloud MySQL
    ssl_ctx = ssl.create_default_context()
    ssl_ctx.check_hostname = False
    ssl_ctx.verify_mode = ssl.CERT_NONE

    return {
        'connect_args': {
            'ssl': ssl_ctx
        },
        'pool_recycle': 280,
        'pool_pre_ping': True,
    }


class Config:
    SECRET_KEY = os.environ.get('SECRET_KEY') or 'poultryconnect-secret-production-key-2026'
    SQLALCHEMY_DATABASE_URI = _default_database_uri()
    SQLALCHEMY_ENGINE_OPTIONS = _engine_options(SQLALCHEMY_DATABASE_URI)
    SQLALCHEMY_TRACK_MODIFICATIONS = False

    # Other settings
    FLASK_APP = "run.py"
    FLASK_ENV = os.environ.get('FLASK_ENV') or 'production'

    # Mail settings
    MAIL_SERVER = os.environ.get('MAIL_SERVER') or 'localhost'
    MAIL_PORT = int(os.environ.get('MAIL_PORT') or 8025)
    MAIL_USE_TLS = os.environ.get('MAIL_USE_TLS', 'true').lower() in ['true', 'on', '1']
    MAIL_USERNAME = os.environ.get('MAIL_USERNAME')
    MAIL_PASSWORD = os.environ.get('MAIL_PASSWORD')
    ADMINS = [os.environ.get('MAIL_USERNAME') or 'admin@poultryconnect.com']

