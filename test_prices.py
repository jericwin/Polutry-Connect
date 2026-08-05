from app import db
from app.models import User, Product, ProductUnit
from run import app

with app.app_context():
    farmer = User.query.filter_by(username='juan_farmer').first()
    farmer_products = Product.query.filter_by(farmer_id=farmer.id, is_available=True).all()
    selling_prices = {}
    for p in farmer_products:
        print(f"Product: {p.name}, Size: {p.size}, Variety: {p.variety}, Price: {p.price}, Unit: {p.unit}")
        if p.size and p.variety:
            price_per_egg = float(p.price) / 30 if p.unit == ProductUnit.TRAY else float(p.price)
            if p.size.value not in selling_prices:
                selling_prices[p.size.value] = {}
            selling_prices[p.size.value][p.variety.value] = round(price_per_egg, 2)
    print("Selling prices dict:", selling_prices)
