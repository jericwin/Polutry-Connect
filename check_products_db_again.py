from app import db
from app.models import Product
from run import app

with app.app_context():
    products = Product.query.all()
    for p in products:
        price_per_egg = float(p.price) / 30 if p.unit.value == 'tray' else float(p.price)
        print(f"Product: {p.name}, Price: {p.price}, Unit: {p.unit}, PerEgg: {price_per_egg:.2f}")
