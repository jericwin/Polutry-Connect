import os
import json
from flask import Blueprint, render_template, redirect, url_for, flash, request, abort
from flask_login import login_required, current_user
from app.models import UserRole, Order, BuyerFeedback, FeedbackCategory, Product, OrderItem
from app import db
from app.utils.feedback_analysis import analyze_feedback
from datetime import datetime

buyer_bp = Blueprint('buyer', __name__)

def _require_buyer():
    if not current_user.is_authenticated or current_user.role != UserRole.BUYER:
        abort(403)

@buyer_bp.route('/feedback', methods=['GET', 'POST'])
@login_required
def feedback():
    _require_buyer()

    if request.method == 'POST':
        category_str = request.form.get('category', '').lower()
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
        )

        # Local NLP analysis for issue, sentiment, keywords
        analysis = analyze_feedback(
            feedback_text,
            category=category,
            rating=rating if 1 <= rating <= 5 else None
        )
        new_feedback.ai_issue = str(analysis.get("issue", ""))[:100]
        new_feedback.ai_sentiment = str(analysis.get("sentiment", ""))[:20]
        kws = analysis.get("keywords", [])
        if isinstance(kws, list):
            new_feedback.ai_keywords = json.dumps(kws)[:500]

        db.session.add(new_feedback)
        db.session.commit()
        flash("Thank you for your feedback!", "success")
        return redirect(url_for('buyer.feedback'))

    # GET Request
    status_filter = request.args.get('category', 'all')
    
    query = BuyerFeedback.query.filter_by(buyer_id=current_user.id)
    
    if status_filter != 'all':
        try:
            cat_enum = FeedbackCategory(status_filter)
            query = query.filter_by(category=cat_enum)
        except ValueError:
            pass

    feedbacks = query.order_by(BuyerFeedback.created_at.desc()).all()
    
    # Get recent completed orders for the dropdown
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
    )