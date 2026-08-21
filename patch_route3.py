import re

py_path = 'c:/Users/Windows 10 Pro/Documents/YURI/poultryconnect-main/poultryconnect/app/routes/marketplace/marketplace.py'
with open(py_path, 'r', encoding='utf-8') as f:
    content = f.read()

# Let's cleanly replace everything from @marketplace_bp.route('/order/<int:order_id>/feedback') 
# down to the end of the old order_feedback function (which might be around line 660, let's just find the next route)
# Let's do it more safely by searching for the exact block.

# First, remove the malformed @marketplace_bp.route hanging around line 567
content = re.sub(r'@marketplace_bp\.route\(\'/orders/<int:order_id>/feedback\', methods=\[\'POST\'\]\)\n@login_required\n\n', '', content)

# Remove the existing confirm_receipt if it exists
content = re.sub(r'@marketplace_bp\.route\(\'/order/<int:order_id>/confirm_receipt\', methods=\[\'POST\'\]\)\n@login_required\ndef confirm_receipt\(order_id\):.*?(?=@marketplace_bp\.route)', '', content, flags=re.DOTALL)

# Now, let's find the feedback route and replace it entirely up to the next route or the end of file
new_logic = '''@marketplace_bp.route('/order/<int:order_id>/confirm_receipt', methods=['POST'])
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

@marketplace_bp.route('/order/<int:order_id>/feedback', methods=['POST'])
@login_required
def order_feedback(order_id):
    """Submit buyer feedback for an order (3 categories: Website, Product, Delivery)."""
    _require_buyer()
    order = Order.query.get_or_404(order_id)
    
    if order.buyer_id != current_user.id:
        abort(403)
        
    if order.status.name not in ['DELIVERED', 'COMPLETED']:
        flash('You can only leave feedback on completed or delivered orders.', 'error')
        return redirect(url_for('marketplace.order_detail', order_id=order_id))
        
    # Check if feedback already submitted
    existing_fb = BuyerFeedback.query.filter_by(order_id=order_id, buyer_id=current_user.id).first()
    if existing_fb or order.rating is not None:
        flash('You have already provided feedback for this order.', 'error')
        return redirect(url_for('marketplace.order_detail', order_id=order_id))

    try:
        rating_website = int(request.form.get('rating_website', 0))
        rating_product = int(request.form.get('rating_product', 0))
        rating_delivery = int(request.form.get('rating_delivery', 0))
    except ValueError:
        flash('Invalid rating format.', 'error')
        return redirect(url_for('marketplace.order_detail', order_id=order_id))
        
    if not (1 <= rating_website <= 5) or not (1 <= rating_product <= 5) or not (1 <= rating_delivery <= 5):
        flash('Please provide a valid rating (1-5 stars) for all three categories.', 'error')
        return redirect(url_for('marketplace.order_detail', order_id=order_id))
        
    comment_website = request.form.get('comment_website', '').strip()
    comment_product = request.form.get('comment_product', '').strip()
    comment_delivery = request.form.get('comment_delivery', '').strip()
    
    order.rating = 1
    
    import json
    import os
    import google.generativeai as genai
    
    api_key = os.environ.get("GEMINI_API_KEY")
    model = None
    if api_key:
        try:
            genai.configure(api_key=api_key)
            model = genai.GenerativeModel(
                "models/gemini-3.6-flash",
                generation_config={"response_mime_type": "application/json"}
            )
        except:
            model = None

    def _process_ai(text):
        if not text or not model:
            return None
        try:
            prompt = f"""Analyze the following buyer feedback. Extract structured information and return ONLY a JSON object with these exact keys:
- "issue": A short phrase (e.g., "Delayed", "Fresh Eggs", "Good Quality").
- "sentiment": Exactly one of: "Positive", "Negative", or "Neutral".
- "keywords": An array of 2 to 5 keyword strings.
Feedback: "{text}"
"""
            response = model.generate_content(prompt)
            if response and response.text:
                return json.loads(response.text)
        except:
            return None
        return None
        
    fb_web = BuyerFeedback(
        buyer_id=current_user.id, order_id=order.id,
        category=FeedbackCategory.WEBSITE, rating=rating_website, feedback_text=comment_website or None
    )
    if comment_website:
        ai_data = _process_ai(comment_website)
        if ai_data:
            fb_web.ai_sentiment = str(ai_data.get("sentiment", ""))[:20]
            kws = ai_data.get("keywords", [])
            if isinstance(kws, list): fb_web.ai_keywords = json.dumps(kws)[:500]
    db.session.add(fb_web)
    
    primary_product_id, farmer_id = None, None
    if order.items:
        primary_product_id = order.items[0].product_id
        if order.items[0].product: farmer_id = order.items[0].product.farmer_id

    fb_prod = BuyerFeedback(
        buyer_id=current_user.id, order_id=order.id,
        product_id=primary_product_id, farmer_id=farmer_id,
        category=FeedbackCategory.PRODUCT, rating=rating_product, feedback_text=comment_product or None
    )
    if comment_product:
        ai_data = _process_ai(comment_product)
        if ai_data:
            fb_prod.ai_sentiment = str(ai_data.get("sentiment", ""))[:20]
            kws = ai_data.get("keywords", [])
            if isinstance(kws, list): fb_prod.ai_keywords = json.dumps(kws)[:500]
    db.session.add(fb_prod)
    
    fb_deliv = BuyerFeedback(
        buyer_id=current_user.id, order_id=order.id, farmer_id=farmer_id,
        category=FeedbackCategory.DELIVERY, rating=rating_delivery, feedback_text=comment_delivery or None
    )
    if comment_delivery:
        ai_data = _process_ai(comment_delivery)
        if ai_data:
            fb_deliv.ai_sentiment = str(ai_data.get("sentiment", ""))[:20]
            kws = ai_data.get("keywords", [])
            if isinstance(kws, list): fb_deliv.ai_keywords = json.dumps(kws)[:500]
    db.session.add(fb_deliv)

    db.session.commit()
    flash('Thank you for your comprehensive feedback!', 'success')
    return redirect(url_for('marketplace.order_detail', order_id=order_id))

'''

# We will just replace everything from @marketplace_bp.route('/order/<int:order_id>/feedback', methods=['POST'])
# down to eturn redirect(url_for('marketplace.order_detail', order_id=order_id)) which was the end of the old function.
# Wait, the old function might have multiple redirects. We'll use a regex that matches until the last redirect before the next route.

content = re.sub(r'@marketplace_bp\.route\(\'/order/<int:order_id>/feedback\'.*?(?=@marketplace_bp\.route)', new_logic, content, flags=re.DOTALL)

with open(py_path, 'w', encoding='utf-8') as f:
    f.write(content)

print("Updated file")