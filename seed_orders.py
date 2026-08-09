import random
from datetime import datetime, timedelta
from app import create_app, db
from app.models import User, Product, Order, OrderItem, OrderStatus, SalesRecord

app = create_app()
with app.app_context():
    farmer = User.query.filter_by(email='farmer@demo.com').first()
    buyer = User.query.filter_by(email='buyer@demo.com').first()
    product = Product.query.filter_by(farmer_id=farmer.id).first()
    
    if not farmer or not buyer or not product:
        print("Required seed data not found.")
        exit(1)
        
    statuses = list(OrderStatus)
    base_date = datetime.utcnow() - timedelta(days=30)
    
    count = 0
    for i in range(50):
        # random date in last 30 days
        order_date = base_date + timedelta(days=random.randint(0, 30), hours=random.randint(0, 23))
        
        qty = random.randint(1, 10)
        status = random.choice(statuses)
        
        order = Order(
            buyer_id=buyer.id,
            total_amount=product.price * qty,
            status=status,
            delivery_address=buyer.address,
            contact_phone=buyer.phone,
            notes=f"Seed order {i+1}",
            created_at=order_date,
            updated_at=order_date
        )
        db.session.add(order)
        db.session.flush()
        
        order_item = OrderItem(
            order_id=order.id,
            product_id=product.id,
            quantity=qty,
            unit_price=product.price
        )
        db.session.add(order_item)
        
        # If delivered, also create a SalesRecord to populate analytics properly
        if status == OrderStatus.DELIVERED:
            sales_record = SalesRecord(
                farm_id=product.farm_id,
                user_id=farmer.id,
                sale_date=order_date.date(),
                quantity_sold=qty,
                price_per_egg=product.price,
                total_revenue=product.price * qty,
                buyer_name=f"{buyer.first_name} {buyer.last_name}",
                notes=f"{product.name} (Order #{order.id})",
                created_at=order_date
            )
            db.session.add(sales_record)
            
        count += 1
            
    db.session.commit()
    print(f"Added {count} orders successfully!")
