import sqlite3
import os

db_path = 'c:/Users/Windows 10 Pro/Documents/YURI/poultryconnect-main/poultryconnect/instance/poultryconnect.db'
sql_path = 'c:/Users/Windows 10 Pro/Documents/YURI/poultryconnect-main/poultryconnect/new_poultryconnect.sql'

con = sqlite3.connect(db_path)
with open(sql_path, 'w', encoding='utf-8') as f:
    for line in con.iterdump():
        f.write('%s\n' % line)
con.close()
print("Database dumped successfully.")