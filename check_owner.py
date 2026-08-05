from app import db
from app.models import Product, User
from run import app

with app.app_context():
    p = Product.query.filter_by(name='Egg').first()
    if p:
        u = User.query.get(p.farmer_id)
        print(f"Product owner: {u.username}")
