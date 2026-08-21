import re

py_path = 'c:/Users/Windows 10 Pro/Documents/YURI/poultryconnect-main/poultryconnect/app/routes/marketplace/marketplace.py'
with open(py_path, 'r', encoding='utf-8') as f:
    content = f.read()

# Add BuyerFeedback, FeedbackCategory to imports if not there
if 'BuyerFeedback' not in content:
    content = content.replace('from app.models import', 'from app.models import BuyerFeedback, FeedbackCategory,')

# Patch product_detail
detail_replacement = '''def product_detail(product_id):
    """View a single product detail AAA?sAA,A? public."""
    product = Product.query.get_or_404(product_id)
    if not product.is_available:
        flash('This product is no longer available.', 'error')
        return redirect(url_for('marketplace.index'))

    # Get related products of the same size/variety
    related = Product.query.filter(
        Product.id != product.id,
        Product.size == product.size,
        Product.is_available == True,
        Product.stock > 0,
    ).order_by(db.func.random()).limit(4).all()

    # Get product feedbacks
    feedbacks = BuyerFeedback.query.filter_by(
        product_id=product.id,
        category=FeedbackCategory.PRODUCT
    ).order_by(BuyerFeedback.created_at.desc()).all()

    avg_rating = 0
    rated_feedbacks = [fb for fb in feedbacks if fb.rating]
    if rated_feedbacks:
        avg_rating = sum(fb.rating for fb in rated_feedbacks) / len(rated_feedbacks)

    return render_template(
        'marketplace/product_detail.html',
        title=product.name,
        product=product,
        related=related,
        feedbacks=feedbacks,
        avg_rating=round(avg_rating, 1) if avg_rating else None,
        cart_count=_get_cart_count(),
    )'''

content = re.sub(r'def product_detail\(product_id\):.*?cart_count=_get_cart_count\(\),\n\s*\)', detail_replacement, content, flags=re.DOTALL)

with open(py_path, 'w', encoding='utf-8') as f:
    f.write(content)

print("Updated product_detail")