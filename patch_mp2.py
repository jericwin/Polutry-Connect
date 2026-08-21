import re

py_path = 'c:/Users/Windows 10 Pro/Documents/YURI/poultryconnect-main/poultryconnect/app/routes/marketplace/marketplace.py'
with open(py_path, 'r', encoding='utf-8') as f:
    content = f.read()

# Replace the entire farmer_feedback function
replacement = '''def farmer_feedback():
    """View buyer feedback on the farmer's orders."""
    _require_farmer()

    search_category = request.args.get('category', 'delivery').strip().lower()
    
    # We only show DELIVERY and SERVICE here
    if search_category not in ['delivery', 'service']:
        search_category = 'delivery'

    cat_enum = FeedbackCategory.DELIVERY if search_category == 'delivery' else FeedbackCategory.SERVICE

    query = BuyerFeedback.query.filter_by(farmer_id=current_user.id, category=cat_enum)
    feedbacks = query.order_by(BuyerFeedback.created_at.desc()).all()

    avg_rating = 0
    rated_feedbacks = [fb for fb in feedbacks if fb.rating]
    if rated_feedbacks:
        avg_rating = sum(fb.rating for fb in rated_feedbacks) / len(rated_feedbacks)

    return render_template(
        'marketplace/farmer_feedback.html',
        feedbacks=feedbacks,
        current_category=search_category,
        avg_rating=round(avg_rating, 1) if avg_rating else 0,
        total_reviews=len(feedbacks)
    )
'''

content = re.sub(r'def farmer_feedback\(\).*?return render_template\(\s*\'marketplace/farmer_feedback\.html\',\s*.*?\)', replacement, content, flags=re.DOTALL)

with open(py_path, 'w', encoding='utf-8') as f:
    f.write(content)

print("Updated farmer_feedback")