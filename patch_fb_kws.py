import re

py_path = 'c:/Users/Windows 10 Pro/Documents/YURI/poultryconnect-main/poultryconnect/app/routes/marketplace/marketplace.py'
with open(py_path, 'r', encoding='utf-8') as f:
    content = f.read()

# Fix 1: Search keyword
search_pattern1 = r"if search_keyword:\s+query = query\.filter\(BuyerFeedback\.feedback_text\.ilike\(f'%\{search_keyword\}%'\)\)"
replace_pattern1 = '''if search_keyword:
        from sqlalchemy import or_
        query = query.filter(
            or_(
                BuyerFeedback.feedback_text.ilike(f'%{search_keyword}%'),
                BuyerFeedback.ai_keywords.ilike(f'%"{search_keyword}"%')
            )
        )'''
content = re.sub(search_pattern1, replace_pattern1, content)

# Fix 2: Keyword counting
search_pattern2 = r"import json\s+keywords_map = \{\}\s+for fb in all_fbs:\s+if fb\.ai_keywords:\s+try:\s+kws = json\.loads\(fb\.ai_keywords\)\s+for k in kws:\s+k_lower = k\.lower\(\)\s+keywords_map\[k_lower\] = keywords_map\.get\(k_lower, 0\) \+ 1\s+except:\s+pass\s+# Sort keywords by frequency\s+keywords_map = dict\(sorted\(keywords_map\.items\(\), key=lambda item: item\[1\], reverse=True\)\[:5\]\)"
replace_pattern2 = '''import json
    keywords_map = {}
    for fb in all_fbs:
        if fb.ai_keywords:
            try:
                kws = json.loads(fb.ai_keywords)
                for k in kws:
                    k_lower = k.lower()
                    if k_lower not in keywords_map:
                        keywords_map[k_lower] = set()
                    keywords_map[k_lower].add(fb.order_id)
            except:
                pass
    
    # Convert sets to lengths for counting unique orders per keyword
    keywords_map_counts = {k: len(v) for k, v in keywords_map.items()}
    # Sort keywords by frequency
    keywords_map = dict(sorted(keywords_map_counts.items(), key=lambda item: item[1], reverse=True)[:5])'''
content = re.sub(search_pattern2, replace_pattern2, content)

with open(py_path, 'w', encoding='utf-8') as f:
    f.write(content)

print("Updated keywords logic")