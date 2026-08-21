import re

py_path = 'c:/Users/Windows 10 Pro/Documents/YURI/poultryconnect-main/poultryconnect/app/routes/marketplace/marketplace.py'
with open(py_path, 'r', encoding='utf-8') as f:
    content = f.read()

# Replace the part that prepares eedbacks to also create eedbacks_grouped
search_pattern = r'feedbacks = query\.order_by\(BuyerFeedback\.created_at\.desc\(\)\)\.all\(\).*?# Get unique sentiments'

replace_pattern = '''feedbacks = query.order_by(BuyerFeedback.created_at.desc()).all()
    
    from collections import OrderedDict
    grouped = OrderedDict()
    for fb in feedbacks:
        if fb.order_id not in grouped:
            grouped[fb.order_id] = {
                'order_id': fb.order_id,
                'buyer': fb.buyer,
                'created_at': fb.created_at,
                'website': None,
                'product': None,
                'delivery': None
            }
        cat = fb.category.value if fb.category else None
        if cat == 'website':
            grouped[fb.order_id]['website'] = fb
        elif cat == 'product':
            grouped[fb.order_id]['product'] = fb
        elif cat == 'delivery':
            grouped[fb.order_id]['delivery'] = fb
            
    feedbacks_grouped = list(grouped.values())

    # Get unique sentiments'''

content = re.sub(search_pattern, replace_pattern, content, flags=re.DOTALL)

# Now inject feedbacks_grouped into render_template
content = re.sub(r'return render_template\(\'marketplace/farmer_feedback\.html\',.*?feedbacks=feedbacks,', 
                 'return render_template(\'marketplace/farmer_feedback.html\', feedbacks_grouped=feedbacks_grouped, feedbacks=feedbacks,', content, flags=re.DOTALL)

with open(py_path, 'w', encoding='utf-8') as f:
    f.write(content)

print("Updated backend route")