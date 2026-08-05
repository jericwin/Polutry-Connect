from app import db
from app.models import Product, ProductionRecord
from run import app

with app.app_context():
    products = Product.query.all()
    print("Products:", [(p.name, p.price, p.unit) for p in products])
    
    records = ProductionRecord.query.all()
    print("Records:", [(r.record_date, r.egg_price) for r in records[-5:]])
