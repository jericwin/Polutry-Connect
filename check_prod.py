from app.models import Product
from run import app

with app.app_context():
    print(Product.query.all())
