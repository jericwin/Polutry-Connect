"""
Export the current database (SQLite or MySQL) to poultryconnect_xampp.sql
in MySQL/MariaDB format — importable in phpMyAdmin (XAMPP) and TiDB.

Run:  python scripts/export_mysql_dump.py
"""
import os
import sys
from datetime import date, datetime
from decimal import Decimal

ROOT = os.path.abspath(os.path.join(os.path.dirname(__file__), '..'))
sys.path.insert(0, ROOT)

from sqlalchemy.dialects import mysql
from sqlalchemy.schema import CreateTable

from app import create_app, db

OUT = os.path.join(ROOT, 'poultryconnect_xampp.sql')


def lit(v):
    if v is None:
        return 'NULL'
    if isinstance(v, bool):
        return '1' if v else '0'
    if isinstance(v, (int, float, Decimal)):
        return str(v)
    if hasattr(v, 'value'):  # enum
        v = v.value
    if isinstance(v, datetime):
        return "'" + v.strftime('%Y-%m-%d %H:%M:%S') + "'"
    if isinstance(v, date):
        return "'" + v.isoformat() + "'"
    if isinstance(v, (bytes, bytearray, memoryview)):
        b = bytes(v)
        return '0x' + b.hex() if b else "''"
    s = str(v).replace('\\', '\\\\').replace("'", "\\'").replace('\n', '\\n').replace('\r', '\\r')
    return "'" + s + "'"


def main():
    app = create_app()
    with app.app_context():
        dialect = mysql.dialect()
        out = [
            '-- ========================================================',
            '-- PoultryConnect Database Dump for XAMPP (MySQL / MariaDB)',
            '-- Compatible with phpMyAdmin, MariaDB 10.4+, MySQL 5.7/8.0, TiDB',
            '-- Database: `poultryconnect`',
            f'-- Generated {datetime.now():%Y-%m-%d %H:%M} by scripts/export_mysql_dump.py',
            '-- ========================================================',
            '',
            'SET NAMES utf8mb4;',
            "SET TIME_ZONE='+00:00';",
            'SET FOREIGN_KEY_CHECKS=0;',
            "SET SQL_MODE='NO_AUTO_VALUE_ON_ZERO';",
            '',
            'CREATE DATABASE IF NOT EXISTS `poultryconnect` DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;',
            'USE `poultryconnect`;',
            '',
        ]
        tables = db.metadata.sorted_tables
        for t in reversed(tables):
            out.append(f'DROP TABLE IF EXISTS `{t.name}`;')
        out.append('')
        for t in tables:
            ddl = str(CreateTable(t).compile(dialect=dialect)).strip()
            out.append(f'-- Table `{t.name}`')
            out.append(ddl + ' ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;')
            rows = db.session.execute(t.select()).fetchall()
            cols = [c.name for c in t.columns]
            if rows:
                col_list = ', '.join(f'`{c}`' for c in cols)
                for i in range(0, len(rows), 200):
                    chunk = rows[i:i + 200]
                    vals = ',\n  '.join('(' + ', '.join(lit(v) for v in r) + ')' for r in chunk)
                    out.append(f'INSERT INTO `{t.name}` ({col_list}) VALUES\n  {vals};')
            out.append('')
        out.append('SET FOREIGN_KEY_CHECKS=1;')
        with open(OUT, 'w', encoding='utf-8', newline='\n') as f:
            f.write('\n'.join(out) + '\n')
        print(f'Wrote {OUT} ({os.path.getsize(OUT) // 1024} KB, {len(tables)} tables)')


if __name__ == '__main__':
    main()
