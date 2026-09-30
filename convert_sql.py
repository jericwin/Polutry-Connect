import re

with open('poultryconnect_mysql_ready.sql', 'r', encoding='utf-8') as f:
    lines = f.readlines()

new_lines = []
for line in lines:
    if line.startswith('PRAGMA') or line.startswith('BEGIN TRANSACTION') or line.startswith('COMMIT'):
        continue
        
    if 'sqlite_sequence' in line:
        continue
    
    # Replace double quotes for identifiers with backticks
    line = re.sub(r'"([^"]+)"', r'`\1`', line)
    
    # Replace AUTOINCREMENT with AUTO_INCREMENT
    line = line.replace('AUTOINCREMENT', 'AUTO_INCREMENT')
    
    # Remove SQLite specific boolean representation if any (mostly fine in MySQL)
    
    new_lines.append(line)

with open('poultryconnect_xampp.sql', 'w', encoding='utf-8') as f:
    # Add MySQL database creation stuff
    f.write('CREATE DATABASE IF NOT EXISTS `poultryconnect`;\n')
    f.write('USE `poultryconnect`;\n\n')
    f.write('SET foreign_key_checks = 0;\n\n')
    for line in new_lines:
        f.write(line)
    f.write('\nSET foreign_key_checks = 1;\n')
