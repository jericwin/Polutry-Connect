import os
import re

buyer_py_path = 'c:/Users/Windows 10 Pro/Documents/YURI/poultryconnect-main/poultryconnect/app/routes/dashboard/buyer.py'
with open(buyer_py_path, 'r', encoding='utf-8') as f:
    content = f.read()

# Add Product and OrderItem import
content = content.replace('from app.models import UserRole, Order, BuyerFeedback, FeedbackCategory', 'from app.models import UserRole, Order, BuyerFeedback, FeedbackCategory, Product, OrderItem')

# Update POST logic to handle product_id and farmer_id
post_logic_replacement = '''        category_str = request.form.get('category', '').lower()
        feedback_text = request.form.get('feedback_text', '').strip()
        rating_str = request.form.get('rating', '0')
        order_id = request.form.get('order_id')
        product_id = request.form.get('product_id')

        try:
            rating = int(rating_str)
        except ValueError:
            rating = 0

        if not feedback_text:
            flash("Feedback text is required.", "error")
            return redirect(url_for('buyer.feedback'))

        # Map string category to enum
        try:
            category = FeedbackCategory(category_str)
        except ValueError:
            category = FeedbackCategory.SERVICE

        order = None
        product = None
        farmer_id = None

        if category == FeedbackCategory.PRODUCT:
            if product_id:
                try:
                    product = Product.query.get(int(product_id))
                    if product:
                        farmer_id = product.farmer_id
                except ValueError:
                    pass
        else:
            if order_id:
                try:
                    order = Order.query.get(int(order_id))
                    if order and order.buyer_id == current_user.id:
                        if order.items.count() > 0:
                            farmer_id = order.items[0].product.farmer_id
                    else:
                        order = None
                except ValueError:
                    order = None

        new_feedback = BuyerFeedback(
            buyer_id=current_user.id,
            order_id=order.id if order else None,
            product_id=product.id if product else None,
            farmer_id=farmer_id,
            category=category,
            rating=rating if 1 <= rating <= 5 else None,
            feedback_text=feedback_text
        )'''

# Replace the specific block of POST code
content = re.sub(r'        category_str = request.form.get.*?rating_str = request.form.get.*?feedback_text=feedback_text\n        \)', post_logic_replacement, content, flags=re.DOTALL)

# Update GET logic to fetch products
get_logic_replacement = '''    # Get recent completed orders for the dropdown
    recent_orders = Order.query.filter_by(buyer_id=current_user.id).filter(
        Order.status.in_(['DELIVERED', 'COMPLETED'])
    ).order_by(Order.created_at.desc()).limit(15).all()

    # Get recent products purchased by the buyer
    recent_products = db.session.query(Product).join(OrderItem).join(Order).filter(
        Order.buyer_id == current_user.id
    ).distinct().limit(20).all()

    return render_template(
        'buyer/feedback.html',
        feedbacks=feedbacks,
        current_category=status_filter,
        recent_orders=recent_orders,
        recent_products=recent_products
    )'''

content = re.sub(r'    # Get recent completed orders for the dropdown.*?return render_template\(\s*\'buyer/feedback.html\',\s*feedbacks=feedbacks,\s*current_category=status_filter,\s*recent_orders=recent_orders\s*\)', get_logic_replacement, content, flags=re.DOTALL)

with open(buyer_py_path, 'w', encoding='utf-8') as f:
    f.write(content)

print("Updated buyer.py")