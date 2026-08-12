import random
from datetime import datetime, timedelta
from app import create_app, db
from app.models import (User, Farm, ProductionRecord, Expense, SalesRecord, 
                        Product, Order, OrderItem, UserRole, ExpenseCategory, ExpenseFrequency,
                        ProductSize, ProductVariety, ProductUnit, OrderStatus)

app = create_app()

with app.app_context():
    print("Clearing database...")
    db.session.execute(db.text("SET FOREIGN_KEY_CHECKS = 0;"))
    
    tables = [
        'messages', 'conversations', 'notifications', 'order_items', 'orders',
        'products', 'sales_records', 'expenses', 'production_records', 'farms', 'users'
    ]
    
    for table in tables:
        db.session.execute(db.text(f"TRUNCATE TABLE {table};"))
        
    db.session.execute(db.text("SET FOREIGN_KEY_CHECKS = 1;"))
    db.session.commit()

    print("Creating Farmer...")
    farmer = User(
        username='jdelacruz',
        email='farmer@poultryconnect.com',
        role=UserRole.FARMER,
        first_name='Juan',
        last_name='Dela Cruz',
        phone='09171234567',
        address='San Jose, Batangas'
    )
    farmer.set_password('password123')
    db.session.add(farmer)
    
    print("Creating Buyer...")
    buyer = User(
        username='mreyes',
        email='buyer@poultryconnect.com',
        role=UserRole.BUYER,
        first_name='Maria',
        last_name='Reyes',
        phone='09189876543',
        address='Quezon City, Metro Manila'
    )
    buyer.set_password('password123')
    db.session.add(buyer)
    db.session.commit()

    print("Creating Farm...")
    farm = Farm(
        farmer_id=farmer.id,
        name='Sunny Side Poultry Farm',
        location='San Jose, Batangas',
        description='A mid-sized farm focusing on high-quality brown eggs.',
        flock_size=5000
    )
    db.session.add(farm)
    db.session.commit()

    print("Creating Products...")
    products_to_add = [
        Product(farmer_id=farmer.id, farm_id=farm.id, name='Fresh Brown Eggs (Small)', description='Freshly harvested small brown eggs.', size=ProductSize.SMALL, variety=ProductVariety.BROWN, unit=ProductUnit.TRAY, price=170.00, stock=100),
        Product(farmer_id=farmer.id, farm_id=farm.id, name='Fresh Brown Eggs (Medium)', description='Freshly harvested medium brown eggs.', size=ProductSize.MEDIUM, variety=ProductVariety.BROWN, unit=ProductUnit.TRAY, price=190.00, stock=300),
        Product(farmer_id=farmer.id, farm_id=farm.id, name='Fresh Brown Eggs (Large)', description='Freshly harvested large brown eggs.', size=ProductSize.LARGE, variety=ProductVariety.BROWN, unit=ProductUnit.TRAY, price=210.00, stock=200),
        
        Product(farmer_id=farmer.id, farm_id=farm.id, name='Fresh White Eggs (Small)', description='Freshly harvested small white eggs.', size=ProductSize.SMALL, variety=ProductVariety.WHITE, unit=ProductUnit.TRAY, price=165.00, stock=120),
        Product(farmer_id=farmer.id, farm_id=farm.id, name='Fresh White Eggs (Medium)', description='Freshly harvested medium white eggs.', size=ProductSize.MEDIUM, variety=ProductVariety.WHITE, unit=ProductUnit.TRAY, price=185.00, stock=250),
        Product(farmer_id=farmer.id, farm_id=farm.id, name='Fresh White Eggs (Large)', description='Freshly harvested large white eggs.', size=ProductSize.LARGE, variety=ProductVariety.WHITE, unit=ProductUnit.TRAY, price=205.00, stock=180),
    ]
    
    for p in products_to_add:
        db.session.add(p)
    db.session.commit()

    print("Generating past 3 months of data (expenses, production)...")
    end_date = datetime.utcnow().date()
    start_date = end_date - timedelta(days=90)
    
    for i in range(90):
        current_date = start_date + timedelta(days=i)
        
        # Feed expense (every 7 days)
        if i % 7 == 0:
            exp = Expense(
                farm_id=farm.id,
                user_id=farmer.id,
                expense_date=current_date,
                category=ExpenseCategory.FEED,
                amount=random.uniform(15000, 20000),
                description='Weekly feed supply'
            )
            db.session.add(exp)
            
        # Labor expense (every 15 days)
        if i % 15 == 0:
            exp = Expense(
                farm_id=farm.id,
                user_id=farmer.id,
                expense_date=current_date,
                category=ExpenseCategory.LABOR,
                amount=random.uniform(10000, 12000),
                description='Farm hand wages'
            )
            db.session.add(exp)
            
        # Utilities (monthly)
        if current_date.day == 1:
             exp = Expense(
                farm_id=farm.id,
                user_id=farmer.id,
                expense_date=current_date,
                category=ExpenseCategory.UTILITIES,
                amount=random.uniform(5000, 7000),
                description='Electricity and water bill'
            )
             db.session.add(exp)
             
        # Daily production record (generate 2 records per day for different products to avoid unique constraint violation)
        selected_products = random.sample(products_to_add, 2)
        for sel_product in selected_products:
            egg_count = random.randint(1500, 2500)
            prod = ProductionRecord(
                farm_id=farm.id,
                user_id=farmer.id,
                record_date=current_date,
                egg_count=egg_count,
                size=sel_product.size,
                variety=sel_product.variety,
                feed_kg=random.uniform(250, 300),
                feed_cost=random.uniform(1000, 1250), # Approximate daily feed cost
                egg_price=sel_product.price / 30, # price per egg (tray is 30)
                mortality=random.randint(0, 2)
            )
            db.session.add(prod)
             
    print("Generating Orders and Sales...")
    for _ in range(70):
        order_date = start_date + timedelta(days=random.randint(0, 90))
        # Random time
        order_time = datetime.combine(order_date, datetime.min.time()) + timedelta(hours=random.randint(8, 18))
        
        sel_product = random.choice(products_to_add)
        qty = random.randint(5, 50) # In trays
        
        # We will make most orders delivered so they count as sales, some pending/confirmed
        days_ago = (end_date - order_date).days
        if days_ago < 3:
            status = random.choice([OrderStatus.PENDING, OrderStatus.CONFIRMED, OrderStatus.SHIPPED])
        else:
            status = OrderStatus.DELIVERED
            
        total_amt = sel_product.price * qty
        
        order = Order(
            buyer_id=buyer.id,
            total_amount=total_amt,
            status=status,
            delivery_address=buyer.address,
            contact_phone=buyer.phone,
            created_at=order_time,
            updated_at=order_time
        )
        db.session.add(order)
        db.session.flush()
        
        item = OrderItem(
            order_id=order.id,
            product_id=sel_product.id,
            quantity=qty,
            unit_price=sel_product.price
        )
        db.session.add(item)
        
        if status == OrderStatus.DELIVERED:
            # Sales Record
            sale = SalesRecord(
                farm_id=farm.id,
                user_id=farmer.id,
                sale_date=order_date,
                quantity_sold=qty * 30, # Convert trays to pieces for sales record
                price_per_egg=sel_product.price / 30,
                total_revenue=total_amt,
                buyer_name=f"{buyer.first_name} {buyer.last_name}",
                created_at=order_time
            )
            db.session.add(sale)

    db.session.commit()
    print("=========================================")
    print("Database seeded successfully with expanded realistic data!")
    print(f"Farmer: {farmer.email} / password123")
    print(f"Buyer: {buyer.email} / password123")
    print("=========================================")
