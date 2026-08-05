from run import app
from app import db
from app.models import User, UserRole, Farm, ProductionRecord, Expense, ExpenseCategory
from datetime import date, timedelta
import random

with app.app_context():
    # 1. Create Farmer
    farmer_username = 'juan_farmer'
    farmer = User.query.filter_by(username=farmer_username).first()
    if not farmer:
        farmer = User(
            username=farmer_username,
            email='juan@example.com',
            role=UserRole.FARMER,
            first_name='Juan',
            last_name='Dela Cruz',
            phone='09123456789',
            address='San Jose, Batangas'
        )
        farmer.set_password('password123')
        db.session.add(farmer)
        db.session.commit()
    
    # 2. Create Buyer
    buyer_username = 'maria_buyer'
    buyer = User.query.filter_by(username=buyer_username).first()
    if not buyer:
        buyer = User(
            username=buyer_username,
            email='maria@example.com',
            role=UserRole.BUYER,
            first_name='Maria',
            last_name='Clara',
            phone='09987654321',
            address='Lipa City, Batangas'
        )
        buyer.set_password('password123')
        db.session.add(buyer)
        db.session.commit()

    # 3. Create a Farm for the farmer
    farm = Farm.query.filter_by(farmer_id=farmer.id).first()
    if not farm:
        farm = Farm(
            farmer_id=farmer.id,
            name='Juan Poultry Farm',
            location='San Jose, Batangas',
            description='A mid-sized layer poultry farm.',
            flock_size=5000
        )
        db.session.add(farm)
        db.session.commit()

    # 4. Add some expenses and production records for the last 7 days
    today = date.today()
    for i in range(7):
        current_date = today - timedelta(days=i)
        
        # Add expense if not exists for the date
        expense = Expense.query.filter_by(farm_id=farm.id, expense_date=current_date).first()
        if not expense:
            db.session.add(Expense(
                farm_id=farm.id,
                user_id=farmer.id,
                expense_date=current_date,
                category=random.choice(list(ExpenseCategory)),
                amount=random.uniform(500, 2000),
                description=f'Expense for {current_date}'
            ))

        # Add production record if not exists for the date
        prod = ProductionRecord.query.filter_by(farm_id=farm.id, record_date=current_date).first()
        if not prod:
            db.session.add(ProductionRecord(
                farm_id=farm.id,
                user_id=farmer.id,
                record_date=current_date,
                egg_count=random.randint(4000, 4800),
                feed_kg=random.uniform(500, 600),
                feed_cost=random.uniform(10000, 12000),
                egg_price=6.50,
                mortality=random.randint(0, 5),
                notes='Normal day'
            ))

    db.session.commit()

print(f"Accounts created successfully!")
print(f"Farmer: username={farmer_username}, email=juan@example.com, password=password123")
print(f"Buyer: username={buyer_username}, email=maria@example.com, password=password123")
