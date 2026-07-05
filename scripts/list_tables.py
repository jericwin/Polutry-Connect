import sqlite3, os

DB = os.path.abspath(os.path.join(os.path.dirname(__file__), '..', 'app.db'))
conn = sqlite3.connect(DB)
rows = [r[0] for r in conn.execute("SELECT name FROM sqlite_master WHERE type='table'")]
print(rows)
