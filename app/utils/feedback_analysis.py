"""
Feedback Analysis Engine — PoultryConnect 2.0
Lightweight, local NLP and sentiment analysis for customer feedback.
Does not require external Generative AI or API keys.
"""

import re
import json

# Comprehensive English & Tagalog sentiment lexicons
POSITIVE_WORDS = {
    'fresh', 'good', 'great', 'excellent', 'fast', 'quick', 'prompt', 'best', 
    'clean', 'healthy', 'tasty', 'delicious', 'polite', 'recommended', 'affordable', 
    'satisfied', 'happy', 'love', 'nice', 'smooth', 'superb', 'wonderful', 
    'mura', 'mabilis', 'maayos', 'sariwa', 'masarap', 'maganda', 'salamat', 
    'legit', 'mabait', 'sulit', 'ayos', 'husay'
}

NEGATIVE_WORDS = {
    'bad', 'slow', 'late', 'delayed', 'broken', 'cracked', 'rotten', 'spoiled', 
    'damaged', 'poor', 'smelly', 'foul', 'disappointed', 'missing', 'terrible', 
    'horrible', 'worst', 'stale', 'dirty', 'unhappy', 'complaint',
    'kulang', 'basag', 'bulok', 'mabagal', 'sira', 'tagal', 'pangit', 
    'mahal', 'bastos', 'hassle', 'amoy', 'luma'
}

STOP_WORDS = {
    'the', 'and', 'for', 'that', 'this', 'with', 'from', 'have', 'were', 
    'they', 'what', 'your', 'when', 'will', 'been', 'there', 'their', 
    'would', 'about', 'some', 'them', 'then', 'very', 'just', 'more', 
    'ang', 'mga', 'para', 'pero', 'dahil', 'kung', 'nito', 'niyan', 
    'siya', 'kami', 'kayo', 'sila', 'namin', 'ninyo', 'nila', 'nang', 
    'yung', 'iyon', 'dito', 'doon', 'lahat', 'wala', 'meron', 'kasi'
}

# Domain issue patterns (regex pattern, issue name)
ISSUE_PATTERNS = [
    (r'\b(late|delay|delayed|tagal|mabagal|wait|traffic)\b', 'Delayed Delivery'),
    (r'\b(fast|quick|mabilis|prompt|early|speedy)\b', 'Fast Delivery'),
    (r'\b(broken|crack|cracked|basag|damage|damaged|sira|leak|crushed)\b', 'Damaged / Broken Product'),
    (r'\b(rotten|bulok|spoil|spoiled|smell|smelly|foul|amoy|luma|stale)\b', 'Product Quality / Freshness'),
    (r'\b(fresh|sariwa|clean|healthy|masarap|tasty|quality)\b', 'Fresh Produce Quality'),
    (r'\b(missing|kulang|wrong|incorrect|mali|incomplete)\b', 'Order Accuracy Issue'),
    (r'\b(package|packaging|box|balot|bubble|carton|wrap)\b', 'Packaging Condition'),
    (r'\b(bait|mabait|friendly|helpful|accommodating|polite|bastos|service)\b', 'Customer Service'),
    (r'\b(price|affordable|mura|expensive|mahal|sulit|cost)\b', 'Pricing & Value'),
    (r'\b(app|website|order|checkout|payment|bayad|system|online)\b', 'Platform & Ordering'),
]


def analyze_feedback(text: str, category=None, rating: int = None) -> dict:
    """
    Analyzes feedback text and returns a dictionary containing:
      - 'issue': A concise domain issue/observation string
      - 'sentiment': 'Positive', 'Negative', or 'Neutral'
      - 'keywords': A list of 2 to 5 relevant keyword strings
    """
    cleaned_text = (text or '').strip()
    words = [re.sub(r'[^a-zA-Z0-9]', '', w.lower()) for w in cleaned_text.split()]
    words = [w for w in words if len(w) > 2]

    # 1. Sentiment Analysis
    pos_matches = [w for w in words if w in POSITIVE_WORDS]
    neg_matches = [w for w in words if w in NEGATIVE_WORDS]
    
    if rating is not None and 1 <= rating <= 5:
        if rating >= 4:
            sentiment = "Positive"
        elif rating <= 2:
            sentiment = "Negative"
        else:
            if len(pos_matches) > len(neg_matches):
                sentiment = "Positive"
            elif len(neg_matches) > len(pos_matches):
                sentiment = "Negative"
            else:
                sentiment = "Neutral"
    else:
        if len(pos_matches) > len(neg_matches):
            sentiment = "Positive"
        elif len(neg_matches) > len(pos_matches):
            sentiment = "Negative"
        else:
            sentiment = "Neutral"

    # 2. Issue Detection
    detected_issue = None
    lower_text = cleaned_text.lower()
    for pattern, label in ISSUE_PATTERNS:
        if re.search(pattern, lower_text):
            detected_issue = label
            break

    # Fallback issue based on category if no specific pattern matched
    if not detected_issue:
        cat_str = str(category.value if hasattr(category, 'value') else category or '').lower()
        if 'delivery' in cat_str:
            detected_issue = "Delivery Service"
        elif 'product' in cat_str:
            detected_issue = "Product Quality"
        elif 'website' in cat_str:
            detected_issue = "Platform Feedback"
        else:
            detected_issue = "General Feedback"

    # 3. Keywords Extraction
    # Prioritize sentiment words and domain words, then other significant words
    candidate_keywords = []
    seen = set()

    for w in words:
        if w not in STOP_WORDS and len(w) >= 4 and w not in seen:
            candidate_keywords.append(w)
            seen.add(w)

    keywords = candidate_keywords[:5]
    if not keywords and words:
        keywords = list(dict.fromkeys(words))[:3]

    return {
        "issue": detected_issue,
        "sentiment": sentiment,
        "keywords": keywords
    }
