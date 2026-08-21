import sqlite3

def patch_db():
    conn = sqlite3.connect('instance/poultryconnect.db')
    cursor = conn.cursor()
    try:
        cursor.execute("ALTER TABLE orders ADD COLUMN payment_method VARCHAR(50) NOT NULL DEFAULT 'COD';")
    except sqlite3.OperationalError as e:
        print(f"payment_method: {e}")
        
    try:
        cursor.execute("ALTER TABLE orders ADD COLUMN payment_date DATETIME;")
    except sqlite3.OperationalError as e:
        print(f"payment_date: {e}")

    conn.commit()
    conn.close()
    print("Database patched successfully.")

if __name__ == "__main__":
    patch_db()
