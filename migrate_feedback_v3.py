from app import create_app, db
from app.models import Order, BuyerFeedback, FeedbackCategory, User, Product
import sqlalchemy

app = create_app()
with app.app_context():
    try:
        db.session.execute(sqlalchemy.text('ALTER TABLE buyer_feedback ADD COLUMN product_id INTEGER REFERENCES products(id)'))
    except Exception as e:
        print(f'Error adding product_id: {e}')
    
    try:
        db.session.execute(sqlalchemy.text('ALTER TABLE buyer_feedback ADD COLUMN farmer_id INTEGER REFERENCES users(id)'))
    except Exception as e:
        print(f'Error adding farmer_id: {e}')

    db.session.commit()

    feedbacks = BuyerFeedback.query.all()
    count = 0
    for fb in feedbacks:
        if fb.order_id and not fb.farmer_id:
            order = Order.query.get(fb.order_id)
            if order and order.items:
                product = order.items[0].product
                if product:
                    fb.farmer_id = product.farmer_id
                    count += 1
    db.session.commit()
    print(f"Migrated {count} records with farmer_id.")