from app import db
from app.models import User, ProductionRecord
from run import app

with app.app_context():
    farmer = User.query.filter_by(username='juan_farmer').first()
    records = ProductionRecord.query.filter_by(farmer_id=farmer.id).all() if hasattr(ProductionRecord, 'farmer_id') else ProductionRecord.query.all()
    for r in records:
        print(f"Date: {r.record_date}, Count: {r.egg_count}, Price: {r.egg_price}")
