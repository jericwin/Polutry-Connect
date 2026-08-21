from app import create_app, db
from app.models import Order, BuyerFeedback, FeedbackCategory

app = create_app()
with app.app_context():
    db.create_all()
    
    orders_with_feedback = Order.query.filter(Order.feedback_text != None).all()
    count = 0
    for order in orders_with_feedback:
        # Check if already migrated
        if not BuyerFeedback.query.filter_by(order_id=order.id).first():
            # Try to map existing category
            cat = FeedbackCategory.PRODUCT
            if order.feedback_category:
                cat_lower = order.feedback_category.lower()
                if 'delivery' in cat_lower or 'shipping' in cat_lower:
                    cat = FeedbackCategory.DELIVERY
                elif 'service' in cat_lower or 'helpful' in cat_lower or 'support' in cat_lower:
                    cat = FeedbackCategory.SERVICE
                    
            new_feedback = BuyerFeedback(
                buyer_id=order.buyer_id,
                order_id=order.id,
                category=cat,
                rating=order.rating,
                feedback_text=order.feedback_text,
                ai_issue=order.feedback_issue,
                ai_sentiment=order.feedback_sentiment,
                ai_keywords=order.feedback_keywords
            )
            db.session.add(new_feedback)
            count += 1
            
    db.session.commit()
    print(f"Migrated {count} feedback records.")