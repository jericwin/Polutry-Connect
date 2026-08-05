from app import db
from app.models import User, ProductionRecord
from run import app
from datetime import date
from app.routes.dashboard.dashboard import _build_market_intelligence

with app.app_context():
    farmer = User.query.filter_by(username='juan_farmer').first()
    records = ProductionRecord.query.filter_by(user_id=farmer.id).all()
    res = _build_market_intelligence(records, 15000, 1, date.today())
    print("Matrix:", res.get('pricing_matrix'))
    print("Avg selling price:", res.get('avg_selling_price'))
    print("Base cost:", res.get('base_cost_per_egg'))
    print("selling_prices:", res.get('selling_prices'))
