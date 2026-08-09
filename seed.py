import random
from datetime import date, timedelta
from werkzeug.security import generate_password_hash
from app import create_app, db
from app.models import (
    User, Farm, ProductionRecord, UserRole, ProductSize, ProductVariety, 
    Product, Order, OrderItem, OrderStatus, ProductUnit
)

app = create_app()

with app.app_context():
    # 1. Create Farmer
    farmer = User.query.filter_by(email='farmer@demo.com').first()
    if not farmer:
        farmer = User(
            username='demo_farmer_2026',
            email='farmer@demo.com',
            password_hash=generate_password_hash('password123'),
            role=UserRole('farmer'),
            first_name='Juan',
            last_name='Dela Cruz',
            phone='09123456789',
            address='Brgy. San Jose, Batangas',
            is_active=True
        )
        db.session.add(farmer)
        db.session.commit()
    
    # 2. Create Buyer
    buyer = User.query.filter_by(email='buyer@demo.com').first()
    if not buyer:
        buyer = User(
            username='demo_buyer_2026',
            email='buyer@demo.com',
            password_hash=generate_password_hash('password123'),
            role=UserRole('buyer'),
            first_name='Maria',
            last_name='Clara',
            phone='09987654321',
            address='Makati City',
            is_active=True
        )
        db.session.add(buyer)
        db.session.commit()

    # 3. Create Farm
    farm = Farm.query.filter_by(farmer_id=farmer.id).first()
    if not farm:
        farm = Farm(
            farmer_id=farmer.id,
            name='Sunny Ridge Poultry',
            location='Batangas',
            flock_size=5000,
            is_active=True
        )
        db.session.add(farm)
        db.session.commit()
    
    # 4. Generate 50 Production Records
    sizes = [e for e in ProductSize]
    varieties = [e for e in ProductVariety]
    
    # Check if already seeded
    if ProductionRecord.query.filter_by(farm_id=farm.id).count() < 50:
        base_date = date.today() - timedelta(days=50)
        for i in range(50):
            current_date = base_date + timedelta(days=i)
            # Pick a random size/variety combo to seed
            size = random.choice(sizes)
            variety = random.choice(varieties)
            
            # Check if this exact combo exists for the day (to respect unique constraint)
            exists = ProductionRecord.query.filter_by(
                farm_id=farm.id, record_date=current_date, size=size, variety=variety
            ).first()
            
            if not exists:
                pr = ProductionRecord(
                    farm_id=farm.id,
                    user_id=farmer.id,
                    record_date=current_date,
                    egg_count=random.randint(4000, 4800),
                    size=size,
                    variety=variety,
                    feed_kg=random.uniform(500, 550),
                    feed_cost=random.uniform(15000, 16000),
                    egg_price=random.uniform(6.5, 8.5),
                    mortality=random.randint(0, 5),
                    notes="Daily routine check."
                )
                db.session.add(pr)
        
        db.session.commit()

    # 5. Create a Product in the Marketplace
    product = Product.query.filter_by(farmer_id=farmer.id, size=ProductSize.LARGE, variety=ProductVariety.BROWN).first()
    if not product:
        product = Product(
            farmer_id=farmer.id,
            farm_id=farm.id,
            name="Fresh Large Brown Eggs",
            description="Farm fresh brown eggs collected daily.",
            size=ProductSize.LARGE,
            variety=ProductVariety.BROWN,
            unit=ProductUnit.TRAY,
            price=210.00, # per tray
            stock=100,
            location=farm.location,
            is_available=True
        )
        db.session.add(product)
        db.session.commit()

    # 6. Create some Orders
    if Order.query.filter_by(buyer_id=buyer.id).count() == 0:
        for _ in range(3):
            order = Order(
                buyer_id=buyer.id,
                total_amount=product.price * 2,
                status=random.choice(list(OrderStatus)),
                delivery_address=buyer.address,
                contact_phone=buyer.phone,
                notes="Handle with care"
            )
            db.session.add(order)
            db.session.flush()
            
            order_item = OrderItem(
                order_id=order.id,
                product_id=product.id,
                quantity=2,
                unit_price=product.price
            )
            db.session.add(order_item)
        db.session.commit()
    
    print("Database seeded successfully with farmer@demo.com and buyer@demo.com!")
