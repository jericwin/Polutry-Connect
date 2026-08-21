import random
from datetime import datetime, timedelta, timezone
from app import create_app, db
from app.models import User, Farm, ProductionRecord, Expense, ExpenseCategory, SalesRecord

app = create_app()

with app.app_context():
    # Get the first farmer
    farmer = User.query.filter_by(role='farmer').first()
    if not farmer:
        print("No farmer found. Please register a farmer first.")
        exit(1)

    print(f"Seeding data for farmer: {farmer.username} (ID: {farmer.id})")

    # Define some dummy farms
    dummy_farms = [
        {"name": "Sunrise Hills Poultry", "location": "Batangas", "flock_size": 15000},
        {"name": "Green Valley Layers", "location": "Laguna", "flock_size": 4500},
        {"name": "Backyard Coops", "location": "Quezon", "flock_size": 800},
    ]

    # Create farms
    created_farms = []
    for f_data in dummy_farms:
        existing = Farm.query.filter_by(name=f_data['name'], farmer_id=farmer.id).first()
        if not existing:
            new_farm = Farm(
                name=f_data['name'],
                location=f_data['location'],
                flock_size=f_data['flock_size'],
                farmer_id=farmer.id
            )
            db.session.add(new_farm)
            created_farms.append(new_farm)
        else:
            created_farms.append(existing)
            
    db.session.commit()
    print(f"Ensured {len(created_farms)} farms exist.")

    # Seed data for the current month
    today = datetime.now(timezone.utc)
    month_start = today.replace(day=1)
    categories = list(ExpenseCategory)
        
    for farm in created_farms:
        print(f"Seeding records for {farm.name}...")
        
        # Calculate expected daily production based on flock size (e.g. 85% lay rate)
        lay_rate = random.uniform(0.80, 0.90)
        daily_eggs = int(farm.flock_size * lay_rate)
        
        # Add records for the last 15 days of the current month up to today
        for i in range(15):
            record_date = today - timedelta(days=i)
            if record_date < month_start:
                continue
                
            # Production
            prod = ProductionRecord.query.filter_by(farm_id=farm.id, record_date=record_date.date()).first()
            if not prod:
                prod = ProductionRecord(
                    farm_id=farm.id,
                    user_id=farmer.id,
                    record_date=record_date.date(),
                    egg_count=int(daily_eggs * random.uniform(0.9, 1.1)),
                    notes="Auto-seeded"
                )
                db.session.add(prod)
                
            # Expenses (every 3 days)
            if i % 3 == 0 and categories:
                cat = random.choice(categories)
                amount = random.uniform(1000, 5000) * (farm.flock_size / 1000)
                exp = Expense(
                    farm_id=farm.id,
                    user_id=farmer.id,
                    category=cat,
                    amount=amount,
                    expense_date=record_date.date(),
                    description=f"Auto-seeded {cat.name} expense"
                )
                db.session.add(exp)
                
            # Sales (every 2 days)
            if i % 2 == 0:
                eggs_sold = int(daily_eggs * random.uniform(1.5, 2.0))
                price_per_egg = random.uniform(6.5, 8.5)
                sale = SalesRecord(
                    farm_id=farm.id,
                    user_id=farmer.id,
                    sale_date=record_date.date(),
                    quantity_sold=eggs_sold,
                    price_per_egg=price_per_egg,
                    total_revenue=eggs_sold * price_per_egg,
                    buyer_name="Local Market",
                    notes="Auto-seeded"
                )
                db.session.add(sale)
                
    db.session.commit()
    print("Successfully seeded real-looking data!")
