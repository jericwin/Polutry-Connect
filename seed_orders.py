from app import create_app, db
from app.models import User, Farm, Product, Order, OrderItem, ProductSize, ProductVariety, ProductUnit, OrderStatus, UserRole
from werkzeug.security import generate_password_hash
from decimal import Decimal
import random

app = create_app()
with app.app_context():
    # 1. Create a fake buyer
    buyer = User.query.filter_by(username='demo_buyer').first()
    if not buyer:
        buyer = User(
            username='demo_buyer',
            email='demo_buyer@example.com',
            password_hash=generate_password_hash('password123'),
            role=UserRole.BUYER,
            first_name='Demo',
            last_name='Buyer',
            phone='09123456789',
            address='123 Market St.',
            landmark='Near Plaza'
        )
        db.session.add(buyer)
        db.session.commit()
        print("Created demo_buyer.")
    else:
        print("Buyer demo_buyer already exists.")
    
    # 2. Find a farmer
    farmers = User.query.filter_by(role=UserRole.FARMER).all()
    if not farmers:
        print("No farmer found to receive orders!")
        exit(1)
        
    for farmer in farmers:
        farm = Farm.query.filter_by(farmer_id=farmer.id).first()
        if not farm:
            continue

        # 3. Create products if none exist
        products = Product.query.filter_by(farmer_id=farmer.id).all()
        if not products:
            p1 = Product(
                farmer_id=farmer.id, farm_id=farm.id, name="Premium Large Brown Eggs",
                description="Fresh daily harvest", size=ProductSize.LARGE, variety=ProductVariety.BROWN,
                unit=ProductUnit.TRAY, price=Decimal('220.00'), stock=100, is_available=True
            )
            p2 = Product(
                farmer_id=farmer.id, farm_id=farm.id, name="Medium White Eggs",
                description="Great for baking", size=ProductSize.MEDIUM, variety=ProductVariety.WHITE,
                unit=ProductUnit.TRAY, price=Decimal('180.00'), stock=50, is_available=True
            )
            db.session.add_all([p1, p2])
            db.session.commit()
            products = [p1, p2]
            print(f"Created sample products for {farmer.username}.")
            
        # 4. Create sample orders
        existing_orders = db.session.query(Order).join(OrderItem).filter(OrderItem.product_id == products[0].id).all()
        if len(existing_orders) < 3:
            statuses = [OrderStatus.PENDING, OrderStatus.CONFIRMED, OrderStatus.SHIPPED, OrderStatus.PENDING]
            for i, status in enumerate(statuses):
                order = Order(
                    buyer_id=buyer.id,
                    total_amount=Decimal('0.00'),
                    status=status,
                    delivery_address='123 Market St., Cityville',
                    contact_phone='09123456789',
                    notes=f'Mock Order {i+1} for {farmer.username}'
                )
                db.session.add(order)
                db.session.flush()
                
                # Add random items
                total = Decimal('0.00')
                for p in products:
                    if random.choice([True, False]):
                        qty = random.randint(1, 3)
                        oi = OrderItem(
                            order_id=order.id, product_id=p.id, quantity=qty, unit_price=p.price
                        )
                        db.session.add(oi)
                        total += (p.price * qty)
                
                if total == Decimal('0.00'):
                    oi = OrderItem(order_id=order.id, product_id=products[0].id, quantity=1, unit_price=products[0].price)
                    db.session.add(oi)
                    total = products[0].price
                    
                order.total_amount = total
                
            db.session.commit()
            print(f"Created mock orders for {farmer.username}.")

print("Seeding complete.")
