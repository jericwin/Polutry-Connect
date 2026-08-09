import random
from datetime import datetime, timedelta
from app import create_app, db
from app.models import User, Farm, Expense, ExpenseCategory, ExpenseFrequency

app = create_app()
with app.app_context():
    farmer = User.query.filter_by(email='farmer@demo.com').first()
    farm = Farm.query.filter_by(farmer_id=farmer.id).first()
    
    if not farmer or not farm:
        print("Required seed data not found.")
        exit(1)
        
    categories = list(ExpenseCategory)
    frequencies = list(ExpenseFrequency)
    base_date = datetime.utcnow().date() - timedelta(days=30)
    
    count = 0
    # Add a daily feed expense
    feed_exp = Expense(
        farm_id=farm.id,
        user_id=farmer.id,
        expense_date=base_date,
        category=ExpenseCategory.FEED,
        frequency=ExpenseFrequency.DAILY,
        amount=15000.00,
        description="Daily Feed Cost (Seeded)"
    )
    db.session.add(feed_exp)
    count += 1
    
    # Add some random one-time expenses
    for i in range(15):
        exp_date = base_date + timedelta(days=random.randint(0, 30))
        cat = random.choice(categories)
        
        amt = random.uniform(500, 5000)
        
        exp = Expense(
            farm_id=farm.id,
            user_id=farmer.id,
            expense_date=exp_date,
            category=cat,
            frequency=ExpenseFrequency.ONE_TIME,
            amount=round(amt, 2),
            description=f"Seeded expense - {cat.value}"
        )
        db.session.add(exp)
        count += 1
            
    db.session.commit()
    print(f"Added {count} expenses successfully!")
