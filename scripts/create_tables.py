import os
import sys

# Ensure project root is on sys.path so `app` package can be imported
ROOT = os.path.abspath(os.path.join(os.path.dirname(__file__), '..'))
if ROOT not in sys.path:
    sys.path.insert(0, ROOT)

from app import create_app, db

app = create_app()

with app.app_context():
    db.create_all()
    print('create_all completed')
