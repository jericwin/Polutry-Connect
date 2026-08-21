import re

py_path = 'c:/Users/Windows 10 Pro/Documents/YURI/poultryconnect-main/poultryconnect/app/routes/marketplace/marketplace.py'
with open(py_path, 'r', encoding='utf-8') as f:
    content = f.read()

search_query = "query = BuyerFeedback.query.filter_by(farmer_id=current_user.id)"
replace_query = '''from app.models import Order, OrderItem, Product
    order_ids = db.session.query(Order.id).join(OrderItem).join(Product).filter(Product.farmer_id == current_user.id).subquery()
    query = BuyerFeedback.query.filter(BuyerFeedback.order_id.in_(order_ids))'''

content = content.replace(search_query, replace_query)

search_all_fbs = "all_fbs = BuyerFeedback.query.filter_by(farmer_id=current_user.id).all()"
replace_all_fbs = "all_fbs = BuyerFeedback.query.filter(BuyerFeedback.order_id.in_(order_ids)).all()"
content = content.replace(search_all_fbs, replace_all_fbs)

with open(py_path, 'w', encoding='utf-8') as f:
    f.write(content)

print("Updated backend query")