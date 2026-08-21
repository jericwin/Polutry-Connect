import sqlite3

def patch_db():
    conn = sqlite3.connect('instance/poultryconnect.db')
    cursor = conn.cursor()

    # Create FeedRecord table
    cursor.execute('''
    CREATE TABLE IF NOT EXISTS feed_records (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        farm_id INTEGER NOT NULL,
        user_id INTEGER NOT NULL,
        record_date DATE NOT NULL,
        feed_type VARCHAR(100) NOT NULL,
        feed_consumed_kg NUMERIC(8, 2) DEFAULT 0.00,
        feed_cost NUMERIC(10, 2) DEFAULT 0.00,
        notes TEXT,
        created_at DATETIME NOT NULL,
        updated_at DATETIME NOT NULL,
        FOREIGN KEY (farm_id) REFERENCES farms (id),
        FOREIGN KEY (user_id) REFERENCES users (id)
    )
    ''')

    # Create MortalityRecord table
    cursor.execute('''
    CREATE TABLE IF NOT EXISTS mortality_records (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        farm_id INTEGER NOT NULL,
        user_id INTEGER NOT NULL,
        record_date DATE NOT NULL,
        quantity_died INTEGER NOT NULL DEFAULT 0,
        reason VARCHAR(255) NOT NULL,
        notes TEXT,
        created_at DATETIME NOT NULL,
        updated_at DATETIME NOT NULL,
        FOREIGN KEY (farm_id) REFERENCES farms (id),
        FOREIGN KEY (user_id) REFERENCES users (id)
    )
    ''')

    conn.commit()
    conn.close()
    print("Database patched successfully.")

if __name__ == '__main__':
    patch_db()
