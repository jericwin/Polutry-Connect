import os, sqlite3
print('cwd', os.getcwd())
print('exists', os.path.exists('app.db'))
conn = sqlite3.connect('app.db')
cur = conn.cursor()
for table in ['users','conversations','messages']:
    cur.execute(f"SELECT * FROM {table} LIMIT 5")
    print(table, cur.fetchall())
conn.close()
