import os
from dotenv import load_dotenv

basedir = os.path.abspath(os.path.dirname(__file__))
load_dotenv(os.path.join(basedir, '.env'))


def _default_database_uri():
    database_url = os.environ.get('DATABASE_URL')
    if database_url:
        return database_url

    mysql_user = os.environ.get('MYSQL_USER') or 'root'
    mysql_password = os.environ.get('MYSQL_PASSWORD') or ''
    mysql_host = os.environ.get('MYSQL_HOST') or '127.0.0.1'
    mysql_port = os.environ.get('MYSQL_PORT') or '3306'
    mysql_db = os.environ.get('MYSQL_DATABASE') or 'poultryconnect'
    return f'mysql+pymysql://{mysql_user}:{mysql_password}@{mysql_host}:{mysql_port}/{mysql_db}?charset=utf8mb4'


class Config:
    SECRET_KEY = os.environ.get('SECRET_KEY') or 'you-will-never-guess'
    SQLALCHEMY_DATABASE_URI = _default_database_uri()
    SQLALCHEMY_TRACK_MODIFICATIONS = False

    # Other settings
    FLASK_APP = "run.py"
    FLASK_ENV = os.environ.get('FLASK_ENV') or 'development'

    # Mail settings
    MAIL_SERVER = os.environ.get('MAIL_SERVER') or 'localhost'
    MAIL_PORT = int(os.environ.get('MAIL_PORT') or 8025)
    MAIL_USE_TLS = os.environ.get('MAIL_USE_TLS', 'true').lower() in ['true', 'on', '1']
    MAIL_USERNAME = os.environ.get('MAIL_USERNAME')
    MAIL_PASSWORD = os.environ.get('MAIL_PASSWORD')
    ADMINS = [os.environ.get('MAIL_USERNAME') or 'admin@poultryconnect.com']
