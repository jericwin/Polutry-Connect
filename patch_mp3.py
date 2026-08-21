import re

py_path = 'c:/Users/Windows 10 Pro/Documents/YURI/poultryconnect-main/poultryconnect/app/routes/marketplace/marketplace.py'
with open(py_path, 'r', encoding='utf-8') as f:
    content = f.read()

replacement = '''def farmer_feedback():
    """View buyer feedback on the farmer's orders."""
    _require_farmer()

    search_category = request.args.get('category', '').strip().lower()
    search_sentiment = request.args.get('sentiment', '').strip().lower()
    search_keyword = request.args.get('q', '').strip().lower()
    rating_filter = request.args.get('rating', '').strip()

    # Base query for feedbacks for this farmer (exclude PRODUCT if you want, or show all)
    query = BuyerFeedback.query.filter_by(farmer_id=current_user.id)
    
    # Exclude product feedback? The requirement before was delivery and service only.
    # But since they want the old UI back, maybe we just show all feedbacks linked to this farmer.
    
    if search_category:
        try:
            cat_enum = FeedbackCategory(search_category)
            query = query.filter(BuyerFeedback.category == cat_enum)
        except ValueError:
            pass
            
    if search_sentiment:
        query = query.filter(func.lower(BuyerFeedback.ai_sentiment) == search_sentiment)
        
    if search_keyword:
        query = query.filter(BuyerFeedback.feedback_text.ilike(f'%{search_keyword}%'))
        
    if rating_filter:
        try:
            r = int(rating_filter)
            query = query.filter(BuyerFeedback.rating == r)
        except ValueError:
            pass

    feedbacks = query.order_by(BuyerFeedback.created_at.desc()).all()

    # Get unique sentiments and categories for filters
    all_fbs = BuyerFeedback.query.filter_by(farmer_id=current_user.id).all()
    
    unique_categories = list(set([fb.category.value for fb in all_fbs if fb.category]))
    unique_sentiments = list(set([fb.ai_sentiment for fb in all_fbs if fb.ai_sentiment]))
    
    import json
    keywords_map = {}
    for fb in all_fbs:
        if fb.ai_keywords:
            try:
                kws = json.loads(fb.ai_keywords)
                for k in kws:
                    k_lower = k.lower()
                    keywords_map[k_lower] = keywords_map.get(k_lower, 0) + 1
            except:
                pass
    
    # Sort keywords by frequency
    keywords_map = dict(sorted(keywords_map.items(), key=lambda item: item[1], reverse=True)[:10])

    avg_rating = 0
    rated_feedbacks = [fb for fb in feedbacks if fb.rating]
    if rated_feedbacks:
        avg_rating = sum(fb.rating for fb in rated_feedbacks) / len(rated_feedbacks)

    return render_template(
        'marketplace/farmer_feedback.html',
        feedbacks=feedbacks,
        current_category=search_category,
        avg_rating=round(avg_rating, 1) if avg_rating else 0,
        total_reviews=len(feedbacks),
        unique_categories=unique_categories,
        unique_sentiments=unique_sentiments,
        keywords_map=keywords_map
    )
'''

content = re.sub(r'def farmer_feedback\(\).*?total_reviews=len\(feedbacks\)\n    \)', replacement, content, flags=re.DOTALL)

with open(py_path, 'w', encoding='utf-8') as f:
    f.write(content)

print("Updated farmer_feedback route")