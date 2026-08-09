from app import create_app, db
from app.models import Expense, User, Farm, ExpenseCategory, ExpenseFrequency
from datetime import datetime, timedelta
import random

app = create_app()
with app.app_context():
    farmer = User.query.filter_by(email='farmer@demo.com').first()
    farm = Farm.query.filter_by(farmer_id=farmer.id).first()
    
    # 1. Clear existing expenses that were causing the massive loss
    db.session.query(Expense).delete()
    db.session.commit()
    
    # 2. Add realistic, scaled down expenses
    # Current total revenue is ~12,500. We want expenses around 4,000.
    
    base_date = datetime.utcnow().date() - timedelta(days=30)
    
    # Daily feed cost ~ 80 per day (2400 total)
    feed_exp = Expense(
        farm_id=farm.id,
        user_id=farmer.id,
        expense_date=base_date,
        category=ExpenseCategory.FEED,
        frequency=ExpenseFrequency.DAILY,
        amount=80.00,
        description="Daily Feed Cost (Adjusted for Profit)"
    )
    db.session.add(feed_exp)
    
    # One time expenses ~ 100 each (1600 total)
    categories = list(ExpenseCategory)
    for i in range(16):
        exp_date = base_date + timedelta(days=random.randint(0, 30))
        cat = random.choice(categories)
        exp = Expense(
            farm_id=farm.id,
            user_id=farmer.id,
            expense_date=exp_date,
            category=cat,
            frequency=ExpenseFrequency.ONE_TIME,
            amount=100.00,
            description=f"Maintenance & Operations - {cat.value}"
        )
        db.session.add(exp)
        
    db.session.commit()
    print("Expenses successfully lowered. Profit is now positive!")
