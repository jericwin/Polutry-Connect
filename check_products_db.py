from app import db
from app.models import Product
from run import app

with app.app_context():
    products = Product.query.all()
    for p in products:
        print(f"Product: {p.name}, Size: {p.size}, Variety: {p.variety}, Price: {p.price}, Unit: {p.unit}")
