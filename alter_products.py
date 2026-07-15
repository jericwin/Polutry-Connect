from app import create_app, db
from sqlalchemy import text

app = create_app()
with app.app_context():
    db.session.execute(text("ALTER TABLE products DROP COLUMN category, ADD COLUMN size ENUM('small', 'medium', 'large') NOT NULL DEFAULT 'medium', ADD COLUMN variety ENUM('brown', 'white') NOT NULL DEFAULT 'brown'"))
    db.session.commit()
    print("Altered products table successfully.")
