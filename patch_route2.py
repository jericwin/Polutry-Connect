import re

py_path = 'c:/Users/Windows 10 Pro/Documents/YURI/poultryconnect-main/poultryconnect/app/routes/marketplace/marketplace.py'
with open(py_path, 'r', encoding='utf-8') as f:
    content = f.read()

# Add confirm_receipt route
new_route = '''
@marketplace_bp.route('/order/<int:order_id>/confirm_receipt', methods=['POST'])
@login_required
def confirm_receipt(order_id):
    """Buyer confirms receipt of order."""
    _require_buyer()
    order = Order.query.get_or_404(order_id)
    
    if order.buyer_id != current_user.id:
        abort(403)
        
    if order.status.name != 'DELIVERED':
        flash('You can only confirm receipt of delivered orders.', 'error')
        return redirect(url_for('marketplace.order_detail', order_id=order_id))
        
    order.status = OrderStatus.COMPLETED
    db.session.commit()
    
    flash('Order marked as received. Thank you!', 'success')
    return redirect(url_for('marketplace.order_detail', order_id=order_id, feedback='auto'))
'''

# Find a good place to insert it, e.g., after order_detail
content = re.sub(r'(def order_feedback\()', new_route + r'\n@marketplace_bp.route(\'/order/<int:order_id>/feedback\', methods=[\'POST\'])\n@login_required\n\1', content)

with open(py_path, 'w', encoding='utf-8') as f:
    f.write(content)

print("Updated route")