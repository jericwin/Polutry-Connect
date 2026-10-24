import ssl
import re
import pymysql

ctx = ssl.create_default_context()
ctx.check_hostname = False
ctx.verify_mode = ssl.CERT_NONE

conn = pymysql.connect(
    host='gateway01.us-east-1.prod.aws.tidbcloud.com',
    port=4000,
    user='4PnsQcfcVN9Q18M.root',
    password='vSJUHqipn9jEF6Az',
    database='poultryconnect',
    ssl=ctx,
    autocommit=True
)
cur = conn.cursor()

with open('poultryconnect_xampp.sql', 'r', encoding='utf-8') as f:
    sql_text = f.read()

# Split statements by semicolon, being careful of strings
# We can filter out comments and LOCK/UNLOCK
lines = []
for line in sql_text.splitlines():
    stripped = line.strip()
    if not stripped:
        continue
    if stripped.startswith('--') or stripped.startswith('/*'):
        continue
    if stripped.upper().startswith('LOCK TABLES') or stripped.upper().startswith('UNLOCK TABLES'):
        continue
    if stripped.upper().startswith('CREATE DATABASE') or stripped.upper().startswith('USE '):
        continue
    lines.append(line)

clean_sql = '\n'.join(lines)

# Split by ';' followed by newline or end of line
raw_stmts = clean_sql.split(';')
stmts = [s.strip() for s in raw_stmts if s.strip()]

print(f"Total statements to execute: {len(stmts)}")

executed = 0
errors = 0
for stmt in stmts:
    try:
        cur.execute(stmt)
        executed += 1
    except Exception as e:
        errors += 1
        print(f"Error on statement: {stmt[:60]}... => {e}")

print(f"Finished! Successfully executed {executed} statements, {errors} errors.")

cur.execute("SHOW TABLES")
tables = cur.fetchall()
print(f"Tables in poultryconnect ({len(tables)}):", [t[0] for t in tables])

for t in tables:
    t_name = t[0]
    cur.execute(f"SELECT COUNT(*) FROM `{t_name}`")
    count = cur.fetchone()[0]
    print(f"  - {t_name}: {count} rows")

conn.close()
