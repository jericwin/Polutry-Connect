"""
Marketplace Blueprint Ã¢â‚¬â€ PoultryConnect 2.0
Handles:
  - Public product browsing           (GET /marketplace/)
  - Product detail                    (GET /marketplace/product/<id>)
  - Session-based shopping cart       (GET/POST /marketplace/cart/*)
  - Checkout & order placement        (GET/POST /marketplace/checkout)
  - Buyer order history               (GET /marketplace/orders)
  - Farmer product management         (GET/POST /marketplace/manage/*)
  - Farmer incoming orders            (GET/POST /marketplace/manage/orders/*)

Security practices:
  - Public browsing: no auth required for browse/detail
  - @login_required on cart, checkout, orders, and management routes
  - Role guard: buyer-only for cart/checkout/orders, farmer-only for manage
  - Ownership check: farmer can only edit/toggle their own products
  - Stock validation at checkout (prevents overselling)
  - Session cart re-validated against DB at checkout (price/availability)
  - Input sanitised via safe helpers (matching production.py patterns)
  - No raw SQL Ã¢â‚¬â€ all via SQLAlchemy ORM
"""

from flask import (
    Blueprint, render_template, redirect, url_for,
    flash, request, abort, session
)
from flask_login import login_required, current_user
from decimal import Decimal, InvalidOperation
from datetime import datetime
import json
import os
import warnings
warnings.filterwarnings('ignore', category=FutureWarning, module='google.generativeai')
import google.generativeai as genai

from sqlalchemy import func
from app import db
from app.models import (
    BuyerFeedback, FeedbackCategory, Product, Order, OrderItem, Farm, User, SalesRecord,
    ProductSize, ProductVariety, ProductUnit, OrderStatus, UserRole, Notification,
    ContentModeration, ModerationStatus, VerificationStatus
)
from werkzeug.utils import secure_filename
from app.utils.ai_moderation import moderate_image
from flask import current_app

marketplace_bp = Blueprint('marketplace', __name__)

@marketplace_bp.before_request
def check_farmer_verification():
    from flask import flash, redirect, url_for, request
    # Only restrict routes related to Farmer management
    if request.endpoint and request.endpoint.startswith('marketplace.manage'):
        if current_user.is_authenticated and current_user.role == UserRole.FARMER:
            if not current_user.verification or current_user.verification.status != VerificationStatus.APPROVED:
                flash('Your account is pending verification. Please wait for an administrator to approve your account before accessing farmer features.', 'warning')
                return redirect(url_for('dashboard.farmer'))

# Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬ helpers Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬

def _require_farmer():
    """Abort with 403 if the current user is not a farmer."""
    if current_user.role != UserRole.FARMER:
        abort(403)


def _require_buyer():
    """Abort with 403 if the current user is not a buyer."""
    if current_user.role != UserRole.BUYER:
        abort(403)


def _safe_int(val, default=0) -> int:
    try:
        return int(val)
    except (TypeError, ValueError):
        return default


def _safe_decimal(val, default=Decimal('0.00')) -> Decimal:
    try:
        return Decimal(str(val)).quantize(Decimal('0.01'))
    except (InvalidOperation, TypeError):
        return default


def _get_own_product_or_404(product_id: int) -> Product:
    """Return the product only if it belongs to current_user."""
    product = Product.query.get_or_404(product_id)
    if product.farmer_id != current_user.id:
        abort(403)
    return product

def _get_available_stock(product: Product) -> int:
    """Calculates stock available for purchase."""
    return max(0, product.stock)


def _get_cart():
    """Get current session cart. Returns dict {product_id_str: quantity}."""
    return session.get('cart', {})


def _save_cart(cart):
    """Persist cart to session."""
    session['cart'] = cart
    session.modified = True


def _get_cart_count():
    """Total number of items in the cart."""
    cart = _get_cart()
    return sum(cart.values())


# Ã¢â€¢ÂÃ¢â€¢ÂÃ¢â€¢ÂÃ¢â€¢ÂÃ¢â€¢ÂÃ¢â€¢ÂÃ¢â€¢ÂÃ¢â€¢ÂÃ¢â€¢ÂÃ¢â€¢ÂÃ¢â€¢ÂÃ¢â€¢ÂÃ¢â€¢ÂÃ¢â€¢ÂÃ¢â€¢ÂÃ¢â€¢ÂÃ¢â€¢ÂÃ¢â€¢ÂÃ¢â€¢ÂÃ¢â€¢ÂÃ¢â€¢ÂÃ¢â€¢ÂÃ¢â€¢ÂÃ¢â€¢ÂÃ¢â€¢ÂÃ¢â€¢ÂÃ¢â€¢ÂÃ¢â€¢ÂÃ¢â€¢ÂÃ¢â€¢ÂÃ¢â€¢ÂÃ¢â€¢ÂÃ¢â€¢ÂÃ¢â€¢ÂÃ¢â€¢ÂÃ¢â€¢ÂÃ¢â€¢ÂÃ¢â€¢ÂÃ¢â€¢ÂÃ¢â€¢ÂÃ¢â€¢ÂÃ¢â€¢ÂÃ¢â€¢ÂÃ¢â€¢ÂÃ¢â€¢ÂÃ¢â€¢ÂÃ¢â€¢ÂÃ¢â€¢ÂÃ¢â€¢ÂÃ¢â€¢ÂÃ¢â€¢ÂÃ¢â€¢ÂÃ¢â€¢ÂÃ¢â€¢ÂÃ¢â€¢ÂÃ¢â€¢ÂÃ¢â€¢ÂÃ¢â€¢ÂÃ¢â€¢ÂÃ¢â€¢ÂÃ¢â€¢ÂÃ¢â€¢ÂÃ¢â€¢ÂÃ¢â€¢ÂÃ¢â€¢ÂÃ¢â€¢ÂÃ¢â€¢ÂÃ¢â€¢ÂÃ¢â€¢ÂÃ¢â€¢ÂÃ¢â€¢ÂÃ¢â€¢ÂÃ¢â€¢ÂÃ¢â€¢ÂÃ¢â€¢ÂÃ¢â€¢Â
# PUBLIC BROWSING
# Ã¢â€¢ÂÃ¢â€¢ÂÃ¢â€¢ÂÃ¢â€¢ÂÃ¢â€¢ÂÃ¢â€¢ÂÃ¢â€¢ÂÃ¢â€¢ÂÃ¢â€¢ÂÃ¢â€¢ÂÃ¢â€¢ÂÃ¢â€¢ÂÃ¢â€¢ÂÃ¢â€¢ÂÃ¢â€¢ÂÃ¢â€¢ÂÃ¢â€¢ÂÃ¢â€¢ÂÃ¢â€¢ÂÃ¢â€¢ÂÃ¢â€¢ÂÃ¢â€¢ÂÃ¢â€¢ÂÃ¢â€¢ÂÃ¢â€¢ÂÃ¢â€¢ÂÃ¢â€¢ÂÃ¢â€¢ÂÃ¢â€¢ÂÃ¢â€¢ÂÃ¢â€¢ÂÃ¢â€¢ÂÃ¢â€¢ÂÃ¢â€¢ÂÃ¢â€¢ÂÃ¢â€¢ÂÃ¢â€¢ÂÃ¢â€¢ÂÃ¢â€¢ÂÃ¢â€¢ÂÃ¢â€¢ÂÃ¢â€¢ÂÃ¢â€¢ÂÃ¢â€¢ÂÃ¢â€¢ÂÃ¢â€¢ÂÃ¢â€¢ÂÃ¢â€¢ÂÃ¢â€¢ÂÃ¢â€¢ÂÃ¢â€¢ÂÃ¢â€¢ÂÃ¢â€¢ÂÃ¢â€¢ÂÃ¢â€¢ÂÃ¢â€¢ÂÃ¢â€¢ÂÃ¢â€¢ÂÃ¢â€¢ÂÃ¢â€¢ÂÃ¢â€¢ÂÃ¢â€¢ÂÃ¢â€¢ÂÃ¢â€¢ÂÃ¢â€¢ÂÃ¢â€¢ÂÃ¢â€¢ÂÃ¢â€¢ÂÃ¢â€¢ÂÃ¢â€¢ÂÃ¢â€¢ÂÃ¢â€¢ÂÃ¢â€¢ÂÃ¢â€¢ÂÃ¢â€¢ÂÃ¢â€¢Â

@marketplace_bp.route('/')
def index():
    """Browse all available farms Ã¢â‚¬â€ public, no login required."""
    search = request.args.get('q', '').strip()

    query = Farm.query.filter_by(is_active=True)
    if search:
        query = query.filter(
            db.or_(
                Farm.name.ilike(f'%{search}%'),
                Farm.location.ilike(f'%{search}%'),
                Farm.description.ilike(f'%{search}%'),
            )
        )

    farms = query.order_by(Farm.created_at.desc()).all()

    return render_template(
        'marketplace/browse.html',
        title='Marketplace',
        farms=farms,
        search=search,
        cart_count=_get_cart_count(),
    )

@marketplace_bp.route('/farm/<int:farm_id>')
def farm_profile(farm_id):
    """View a single farm's profile and their products Ã¢â‚¬â€ public."""
    farm = Farm.query.get_or_404(farm_id)
    if not farm.is_active:
        flash('This farm is no longer active.', 'error')
        return redirect(url_for('marketplace.index'))

    # Filters for products
    search = request.args.get('q', '').strip()
    size = request.args.get('size', '').strip()
    variety = request.args.get('variety', '').strip()
    sort_by = request.args.get('sort', 'newest')

    query = Product.query.filter_by(farm_id=farm.id, is_available=True).filter(Product.stock > 0)

    if search:
        query = query.filter(
            db.or_(
                Product.name.ilike(f'%{search}%'),
                Product.description.ilike(f'%{search}%'),
            )
        )

    valid_sizes = {e.value for e in ProductSize}
    if size and size in valid_sizes:
        query = query.filter(Product.size == ProductSize(size))
        
    valid_varieties = {e.value for e in ProductVariety}
    if variety and variety in valid_varieties:
        query = query.filter(Product.variety == ProductVariety(variety))

    # Sorting
    if sort_by == 'price_low':
        query = query.order_by(Product.price.asc())
    elif sort_by == 'price_high':
        query = query.order_by(Product.price.desc())
    else:  # newest
        query = query.order_by(Product.created_at.desc())

    products = query.all()

    return render_template(
        'marketplace/farm_profile.html',
        title=farm.name,
        farm=farm,
        products=products,
        search=search,
        size=size,
        variety=variety,
        sort_by=sort_by,
        sizes=ProductSize,
        varieties=ProductVariety,
        cart_count=_get_cart_count(),
    )


@marketplace_bp.route('/product/<int:product_id>')
def product_detail(product_id):
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
    )


# Ã¢â€¢ÂÃ¢â€¢ÂÃ¢â€¢ÂÃ¢â€¢ÂÃ¢â€¢ÂÃ¢â€¢ÂÃ¢â€¢ÂÃ¢â€¢ÂÃ¢â€¢ÂÃ¢â€¢ÂÃ¢â€¢ÂÃ¢â€¢ÂÃ¢â€¢ÂÃ¢â€¢ÂÃ¢â€¢ÂÃ¢â€¢ÂÃ¢â€¢ÂÃ¢â€¢ÂÃ¢â€¢ÂÃ¢â€¢ÂÃ¢â€¢ÂÃ¢â€¢ÂÃ¢â€¢ÂÃ¢â€¢ÂÃ¢â€¢ÂÃ¢â€¢ÂÃ¢â€¢ÂÃ¢â€¢ÂÃ¢â€¢ÂÃ¢â€¢ÂÃ¢â€¢ÂÃ¢â€¢ÂÃ¢â€¢ÂÃ¢â€¢ÂÃ¢â€¢ÂÃ¢â€¢ÂÃ¢â€¢ÂÃ¢â€¢ÂÃ¢â€¢ÂÃ¢â€¢ÂÃ¢â€¢ÂÃ¢â€¢ÂÃ¢â€¢ÂÃ¢â€¢ÂÃ¢â€¢ÂÃ¢â€¢ÂÃ¢â€¢ÂÃ¢â€¢ÂÃ¢â€¢ÂÃ¢â€¢ÂÃ¢â€¢ÂÃ¢â€¢ÂÃ¢â€¢ÂÃ¢â€¢ÂÃ¢â€¢ÂÃ¢â€¢ÂÃ¢â€¢ÂÃ¢â€¢ÂÃ¢â€¢ÂÃ¢â€¢ÂÃ¢â€¢ÂÃ¢â€¢ÂÃ¢â€¢ÂÃ¢â€¢ÂÃ¢â€¢ÂÃ¢â€¢ÂÃ¢â€¢ÂÃ¢â€¢ÂÃ¢â€¢ÂÃ¢â€¢ÂÃ¢â€¢ÂÃ¢â€¢ÂÃ¢â€¢ÂÃ¢â€¢ÂÃ¢â€¢ÂÃ¢â€¢Â
# SHOPPING CART (session-based)
# Ã¢â€¢ÂÃ¢â€¢ÂÃ¢â€¢ÂÃ¢â€¢ÂÃ¢â€¢ÂÃ¢â€¢ÂÃ¢â€¢ÂÃ¢â€¢ÂÃ¢â€¢ÂÃ¢â€¢ÂÃ¢â€¢ÂÃ¢â€¢ÂÃ¢â€¢ÂÃ¢â€¢ÂÃ¢â€¢ÂÃ¢â€¢ÂÃ¢â€¢ÂÃ¢â€¢ÂÃ¢â€¢ÂÃ¢â€¢ÂÃ¢â€¢ÂÃ¢â€¢ÂÃ¢â€¢ÂÃ¢â€¢ÂÃ¢â€¢ÂÃ¢â€¢ÂÃ¢â€¢ÂÃ¢â€¢ÂÃ¢â€¢ÂÃ¢â€¢ÂÃ¢â€¢ÂÃ¢â€¢ÂÃ¢â€¢ÂÃ¢â€¢ÂÃ¢â€¢ÂÃ¢â€¢ÂÃ¢â€¢ÂÃ¢â€¢ÂÃ¢â€¢ÂÃ¢â€¢ÂÃ¢â€¢ÂÃ¢â€¢ÂÃ¢â€¢ÂÃ¢â€¢ÂÃ¢â€¢ÂÃ¢â€¢ÂÃ¢â€¢ÂÃ¢â€¢ÂÃ¢â€¢ÂÃ¢â€¢ÂÃ¢â€¢ÂÃ¢â€¢ÂÃ¢â€¢ÂÃ¢â€¢ÂÃ¢â€¢ÂÃ¢â€¢ÂÃ¢â€¢ÂÃ¢â€¢ÂÃ¢â€¢ÂÃ¢â€¢ÂÃ¢â€¢ÂÃ¢â€¢ÂÃ¢â€¢ÂÃ¢â€¢ÂÃ¢â€¢ÂÃ¢â€¢ÂÃ¢â€¢ÂÃ¢â€¢ÂÃ¢â€¢ÂÃ¢â€¢ÂÃ¢â€¢ÂÃ¢â€¢ÂÃ¢â€¢ÂÃ¢â€¢ÂÃ¢â€¢ÂÃ¢â€¢Â

@marketplace_bp.route('/cart')
@login_required
def cart():
    """View shopping cart."""
    _require_buyer()
    cart_data = _get_cart()
    cart_items = []
    total = Decimal('0.00')

    for pid_str, qty in cart_data.items():
        product = Product.query.get(int(pid_str))
        if product and product.is_available:
            subtotal = product.price * qty
            total += subtotal
            cart_items.append({
                'product': product,
                'quantity': qty,
                'subtotal': float(subtotal),
            })

    return render_template(
        'marketplace/cart.html',
        title='Shopping Cart',
        cart_items=cart_items,
        cart_total=float(total),
        cart_count=len(cart_items),
    )


@marketplace_bp.route('/cart/add', methods=['POST'])
@login_required
def cart_add():
    """Add a product to cart."""
    _require_buyer()
    product_id = _safe_int(request.form.get('product_id'))
    quantity   = _safe_int(request.form.get('quantity', 1), default=1)

    if quantity < 1:
        if request.headers.get('X-Requested-With') == 'XMLHttpRequest' or request.is_json:
            return {'status': 'error', 'message': 'Invalid quantity.'}
        flash('Invalid quantity.', 'error')
        return redirect(request.referrer or url_for('marketplace.index'))

    product = Product.query.get(product_id)
    if not product or not product.is_available:
        if request.headers.get('X-Requested-With') == 'XMLHttpRequest' or request.is_json:
            return {'status': 'error', 'message': 'Product not available.'}
        flash('Product not available.', 'error')
        return redirect(url_for('marketplace.index'))

    available_stock = _get_available_stock(product)
    
    if quantity > available_stock:
        if request.headers.get('X-Requested-With') == 'XMLHttpRequest' or request.is_json:
            return {'status': 'error', 'message': f'Only {available_stock} available in stock.'}
        flash(f'Only {available_stock} available in stock.', 'error')
        return redirect(url_for('marketplace.product_detail', product_id=product_id))

    cart = _get_cart()
    pid_str = str(product_id)
    current_qty = cart.get(pid_str, 0)
    new_qty = current_qty + quantity

    if new_qty > available_stock:
        if request.headers.get('X-Requested-With') == 'XMLHttpRequest' or request.is_json:
            return {'status': 'error', 'message': f'Cannot add more. Only {available_stock} available (you have {current_qty} in cart).'}
        flash(f'Cannot add more. Only {available_stock} available (you have {current_qty} in cart).', 'error')
        return redirect(url_for('marketplace.product_detail', product_id=product_id))

    cart[pid_str] = new_qty
    _save_cart(cart)
    
    if request.headers.get('X-Requested-With') == 'XMLHttpRequest' or request.is_json:
        return {'status': 'success', 'message': f'"{product.name}" added to cart.', 'cart_count': _get_cart_count()}
        
    flash(f'"{product.name}" added to cart.', 'success')
    return redirect(request.referrer or url_for('marketplace.index'))


@marketplace_bp.route('/cart/update', methods=['POST'])
@login_required
def cart_update():
    """Update quantity for a cart item."""
    _require_buyer()
    product_id = _safe_int(request.form.get('product_id'))
    quantity   = _safe_int(request.form.get('quantity', 1), default=1)

    cart = _get_cart()
    pid_str = str(product_id)

    if pid_str not in cart:
        if request.headers.get('X-Requested-With') == 'XMLHttpRequest' or request.is_json:
            return {'status': 'error', 'message': 'Item not in cart.', 'cart_count': _get_cart_count()}
        flash('Item not in cart.', 'error')
        return redirect(url_for('marketplace.cart'))

    if quantity < 1:
        # Remove from cart
        del cart[pid_str]
        _save_cart(cart)
        if request.headers.get('X-Requested-With') == 'XMLHttpRequest' or request.is_json:
            return {'status': 'success', 'message': 'Item removed from cart.', 'cart_count': _get_cart_count()}
        flash('Item removed from cart.', 'success')
        return redirect(url_for('marketplace.cart'))

    product = Product.query.get(product_id)
    if product:
        available_stock = _get_available_stock(product)
        if quantity > available_stock:
            if request.headers.get('X-Requested-With') == 'XMLHttpRequest' or request.is_json:
                return {'status': 'error', 'message': f'Only {available_stock} available.', 'cart_count': _get_cart_count()}
            flash(f'Only {available_stock} available.', 'error')
            return redirect(url_for('marketplace.cart'))

    cart[pid_str] = quantity
    _save_cart(cart)
    if request.headers.get('X-Requested-With') == 'XMLHttpRequest' or request.is_json:
        return {'status': 'success', 'message': 'Cart updated.', 'cart_count': _get_cart_count()}
    flash('Cart updated.', 'success')
    return redirect(url_for('marketplace.cart'))


@marketplace_bp.route('/cart/remove', methods=['POST'])
@login_required
def cart_remove():
    """Remove an item from cart."""
    _require_buyer()
    product_id = str(_safe_int(request.form.get('product_id')))

    cart = _get_cart()
    if product_id in cart:
        del cart[product_id]
        _save_cart(cart)
        flash('Item removed from cart.', 'success')

    return redirect(url_for('marketplace.cart'))


# Ã¢â€¢ÂÃ¢â€¢ÂÃ¢â€¢ÂÃ¢â€¢ÂÃ¢â€¢ÂÃ¢â€¢ÂÃ¢â€¢ÂÃ¢â€¢ÂÃ¢â€¢ÂÃ¢â€¢ÂÃ¢â€¢ÂÃ¢â€¢ÂÃ¢â€¢ÂÃ¢â€¢ÂÃ¢â€¢ÂÃ¢â€¢ÂÃ¢â€¢ÂÃ¢â€¢ÂÃ¢â€¢ÂÃ¢â€¢ÂÃ¢â€¢ÂÃ¢â€¢ÂÃ¢â€¢ÂÃ¢â€¢ÂÃ¢â€¢ÂÃ¢â€¢ÂÃ¢â€¢ÂÃ¢â€¢ÂÃ¢â€¢ÂÃ¢â€¢ÂÃ¢â€¢ÂÃ¢â€¢ÂÃ¢â€¢ÂÃ¢â€¢ÂÃ¢â€¢ÂÃ¢â€¢ÂÃ¢â€¢ÂÃ¢â€¢ÂÃ¢â€¢ÂÃ¢â€¢ÂÃ¢â€¢ÂÃ¢â€¢ÂÃ¢â€¢ÂÃ¢â€¢ÂÃ¢â€¢ÂÃ¢â€¢ÂÃ¢â€¢ÂÃ¢â€¢ÂÃ¢â€¢ÂÃ¢â€¢ÂÃ¢â€¢ÂÃ¢â€¢ÂÃ¢â€¢ÂÃ¢â€¢ÂÃ¢â€¢ÂÃ¢â€¢ÂÃ¢â€¢ÂÃ¢â€¢ÂÃ¢â€¢ÂÃ¢â€¢ÂÃ¢â€¢ÂÃ¢â€¢ÂÃ¢â€¢ÂÃ¢â€¢ÂÃ¢â€¢ÂÃ¢â€¢ÂÃ¢â€¢ÂÃ¢â€¢ÂÃ¢â€¢ÂÃ¢â€¢ÂÃ¢â€¢ÂÃ¢â€¢ÂÃ¢â€¢ÂÃ¢â€¢ÂÃ¢â€¢ÂÃ¢â€¢Â
# CHECKOUT & ORDER PLACEMENT
# Ã¢â€¢ÂÃ¢â€¢ÂÃ¢â€¢ÂÃ¢â€¢ÂÃ¢â€¢ÂÃ¢â€¢ÂÃ¢â€¢ÂÃ¢â€¢ÂÃ¢â€¢ÂÃ¢â€¢ÂÃ¢â€¢ÂÃ¢â€¢ÂÃ¢â€¢ÂÃ¢â€¢ÂÃ¢â€¢ÂÃ¢â€¢ÂÃ¢â€¢ÂÃ¢â€¢ÂÃ¢â€¢ÂÃ¢â€¢ÂÃ¢â€¢ÂÃ¢â€¢ÂÃ¢â€¢ÂÃ¢â€¢ÂÃ¢â€¢ÂÃ¢â€¢ÂÃ¢â€¢ÂÃ¢â€¢ÂÃ¢â€¢ÂÃ¢â€¢ÂÃ¢â€¢ÂÃ¢â€¢ÂÃ¢â€¢ÂÃ¢â€¢ÂÃ¢â€¢ÂÃ¢â€¢ÂÃ¢â€¢ÂÃ¢â€¢ÂÃ¢â€¢ÂÃ¢â€¢ÂÃ¢â€¢ÂÃ¢â€¢ÂÃ¢â€¢ÂÃ¢â€¢ÂÃ¢â€¢ÂÃ¢â€¢ÂÃ¢â€¢ÂÃ¢â€¢ÂÃ¢â€¢ÂÃ¢â€¢ÂÃ¢â€¢ÂÃ¢â€¢ÂÃ¢â€¢ÂÃ¢â€¢ÂÃ¢â€¢ÂÃ¢â€¢ÂÃ¢â€¢ÂÃ¢â€¢ÂÃ¢â€¢ÂÃ¢â€¢ÂÃ¢â€¢ÂÃ¢â€¢ÂÃ¢â€¢ÂÃ¢â€¢ÂÃ¢â€¢ÂÃ¢â€¢ÂÃ¢â€¢ÂÃ¢â€¢ÂÃ¢â€¢ÂÃ¢â€¢ÂÃ¢â€¢ÂÃ¢â€¢ÂÃ¢â€¢ÂÃ¢â€¢ÂÃ¢â€¢ÂÃ¢â€¢Â

@marketplace_bp.route('/checkout', methods=['GET', 'POST'])
@login_required
def checkout():
    """Checkout: review cart and place order."""
    _require_buyer()
    cart_data = _get_cart()

    if not cart_data:
        flash('Your cart is empty.', 'error')
        return redirect(url_for('marketplace.index'))

    # Re-validate every cart item against database
    cart_items = []
    total = Decimal('0.00')
    errors = []

    for pid_str, qty in cart_data.items():
        product = Product.query.get(int(pid_str))
        if not product or not product.is_available:
            errors.append(f'"{pid_str}" is no longer available.')
            continue
        available_stock = _get_available_stock(product)
        if qty > available_stock:
            errors.append(f'"{product.name}" only has {available_stock} available (you requested {qty}).')
            cart_data[pid_str] = available_stock
            qty = available_stock
        if qty <= 0:
            continue

        subtotal = product.price * qty
        total += subtotal
        cart_items.append({
            'product': product,
            'quantity': qty,
            'subtotal': float(subtotal),
        })

    if errors:
        for e in errors:
            flash(e, 'error')
        _save_cart(cart_data)

    if not cart_items:
        flash('No valid items in your cart.', 'error')
        return redirect(url_for('marketplace.index'))

    if request.method == 'POST':
        delivery_address = request.form.get('delivery_address', '').strip()
        contact_phone    = request.form.get('contact_phone', '').strip()
        notes            = request.form.get('notes', '').strip()

        form_errors = []
        if not delivery_address:
            form_errors.append('Delivery address is required.')
        if len(delivery_address) > 500:
            form_errors.append('Delivery address is too long (max 500 characters).')
        if not contact_phone:
            form_errors.append('Contact phone is required.')
        if len(contact_phone) > 30:
            form_errors.append('Contact phone is too long.')

        if form_errors:
            for e in form_errors:
                flash(e, 'error')
            return render_template(
                'marketplace/checkout.html',
                title='Checkout',
                cart_items=cart_items,
                cart_total=float(total),
                form_data=request.form,
                cart_count=_get_cart_count(),
            )

        # Create order
        order = Order(
            buyer_id=current_user.id,
            total_amount=total,
            status=OrderStatus.PENDING,
            payment_method='COD',
            delivery_address=delivery_address,
            contact_phone=contact_phone,
            notes=notes or None,
        )
        db.session.add(order)
        db.session.flush()  # get order.id

        # Create order items and decrement stock
        farmer_ids = set()
        for item in cart_items:
            product = item['product']
            qty = item['quantity']

            # Final stock check
            available_stock = _get_available_stock(product)
            if available_stock < qty:
                db.session.rollback()
                flash(f'"{product.name}" stock changed. Please review your cart.', 'error')
                return redirect(url_for('marketplace.cart'))

            order_item = OrderItem(
                order_id=order.id,
                product_id=product.id,
                quantity=qty,
                unit_price=product.price,
            )
            db.session.add(order_item)
            # Deduct stock immediately upon pending order
            product.stock -= qty
            farmer_ids.add(product.farmer_id)

        # Notify farmers of new order
        for fid in farmer_ids:
            notif = Notification(
                user_id=fid,
                title="New Order Received!",
                body=f"You have a new order #{order.id} from {current_user.first_name} {current_user.last_name}.",
                notif_type='order',
                link_url=url_for('marketplace.farmer_orders') + f"#farmerOrder-{order.id}"
            )
            db.session.add(notif)

        db.session.commit()

        # Clear cart
        session.pop('cart', None)
        session.modified = True

        flash(f'Order #{order.id} placed successfully! Payment: Cash on Delivery.', 'success')
        return redirect(url_for('marketplace.order_detail', order_id=order.id))

    return render_template(
        'marketplace/checkout.html',
        title='Checkout',
        cart_items=cart_items,
        cart_total=float(total),
        form_data={'delivery_address': f"{getattr(current_user, 'landmark', '') or ''}, {getattr(current_user, 'address', '') or ''}".strip(', ') if getattr(current_user, 'address', '') else ''},
        cart_count=_get_cart_count(),
    )


# Ã¢â€¢ÂÃ¢â€¢ÂÃ¢â€¢ÂÃ¢â€¢ÂÃ¢â€¢ÂÃ¢â€¢ÂÃ¢â€¢ÂÃ¢â€¢ÂÃ¢â€¢ÂÃ¢â€¢ÂÃ¢â€¢ÂÃ¢â€¢ÂÃ¢â€¢ÂÃ¢â€¢ÂÃ¢â€¢ÂÃ¢â€¢ÂÃ¢â€¢ÂÃ¢â€¢ÂÃ¢â€¢ÂÃ¢â€¢ÂÃ¢â€¢ÂÃ¢â€¢ÂÃ¢â€¢ÂÃ¢â€¢ÂÃ¢â€¢ÂÃ¢â€¢ÂÃ¢â€¢ÂÃ¢â€¢ÂÃ¢â€¢ÂÃ¢â€¢ÂÃ¢â€¢ÂÃ¢â€¢ÂÃ¢â€¢ÂÃ¢â€¢ÂÃ¢â€¢ÂÃ¢â€¢ÂÃ¢â€¢ÂÃ¢â€¢ÂÃ¢â€¢ÂÃ¢â€¢ÂÃ¢â€¢ÂÃ¢â€¢ÂÃ¢â€¢ÂÃ¢â€¢ÂÃ¢â€¢ÂÃ¢â€¢ÂÃ¢â€¢ÂÃ¢â€¢ÂÃ¢â€¢ÂÃ¢â€¢ÂÃ¢â€¢ÂÃ¢â€¢ÂÃ¢â€¢ÂÃ¢â€¢ÂÃ¢â€¢ÂÃ¢â€¢ÂÃ¢â€¢ÂÃ¢â€¢ÂÃ¢â€¢ÂÃ¢â€¢ÂÃ¢â€¢ÂÃ¢â€¢ÂÃ¢â€¢ÂÃ¢â€¢ÂÃ¢â€¢ÂÃ¢â€¢ÂÃ¢â€¢ÂÃ¢â€¢ÂÃ¢â€¢ÂÃ¢â€¢ÂÃ¢â€¢ÂÃ¢â€¢ÂÃ¢â€¢ÂÃ¢â€¢ÂÃ¢â€¢ÂÃ¢â€¢Â
# BUYER ORDER HISTORY
# Ã¢â€¢ÂÃ¢â€¢ÂÃ¢â€¢ÂÃ¢â€¢ÂÃ¢â€¢ÂÃ¢â€¢ÂÃ¢â€¢ÂÃ¢â€¢ÂÃ¢â€¢ÂÃ¢â€¢ÂÃ¢â€¢ÂÃ¢â€¢ÂÃ¢â€¢ÂÃ¢â€¢ÂÃ¢â€¢ÂÃ¢â€¢ÂÃ¢â€¢ÂÃ¢â€¢ÂÃ¢â€¢ÂÃ¢â€¢ÂÃ¢â€¢ÂÃ¢â€¢ÂÃ¢â€¢ÂÃ¢â€¢ÂÃ¢â€¢ÂÃ¢â€¢ÂÃ¢â€¢ÂÃ¢â€¢ÂÃ¢â€¢ÂÃ¢â€¢ÂÃ¢â€¢ÂÃ¢â€¢ÂÃ¢â€¢ÂÃ¢â€¢ÂÃ¢â€¢ÂÃ¢â€¢ÂÃ¢â€¢ÂÃ¢â€¢ÂÃ¢â€¢ÂÃ¢â€¢ÂÃ¢â€¢ÂÃ¢â€¢ÂÃ¢â€¢ÂÃ¢â€¢ÂÃ¢â€¢ÂÃ¢â€¢ÂÃ¢â€¢ÂÃ¢â€¢ÂÃ¢â€¢ÂÃ¢â€¢ÂÃ¢â€¢ÂÃ¢â€¢ÂÃ¢â€¢ÂÃ¢â€¢ÂÃ¢â€¢ÂÃ¢â€¢ÂÃ¢â€¢ÂÃ¢â€¢ÂÃ¢â€¢ÂÃ¢â€¢ÂÃ¢â€¢ÂÃ¢â€¢ÂÃ¢â€¢ÂÃ¢â€¢ÂÃ¢â€¢ÂÃ¢â€¢ÂÃ¢â€¢ÂÃ¢â€¢ÂÃ¢â€¢ÂÃ¢â€¢ÂÃ¢â€¢ÂÃ¢â€¢ÂÃ¢â€¢ÂÃ¢â€¢ÂÃ¢â€¢ÂÃ¢â€¢Â

@marketplace_bp.route('/orders')
@login_required
def orders():
    """View buyer's order history."""
    _require_buyer()
    
    status_filter = request.args.get('status', 'all')
    query = Order.query.filter_by(buyer_id=current_user.id)
    
    if status_filter != 'all':
        query = query.filter_by(status=status_filter)
        
    buyer_orders = query.order_by(Order.created_at.desc()).all()

    return render_template(
        'marketplace/orders.html',
        title='My Orders',
        orders=buyer_orders,
        cart_count=_get_cart_count(),
        status_filter=status_filter
    )


@marketplace_bp.route('/orders/<int:order_id>')
@login_required
def order_detail(order_id):
    """View a specific order (buyer only, owns the order)."""
    _require_buyer()
    order = Order.query.get_or_404(order_id)
    if order.buyer_id != current_user.id:
        abort(403)

    return render_template(
        'marketplace/order_detail.html',
        title=f'Order #{order.id}',
        order=order,
        cart_count=_get_cart_count(),
    )


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
        category=FeedbackCategory.WEBSITE, rating=rating_website, feedback_text=comment_website
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
        category=FeedbackCategory.PRODUCT, rating=rating_product, feedback_text=comment_product
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
        category=FeedbackCategory.DELIVERY, rating=rating_delivery, feedback_text=comment_delivery
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

@marketplace_bp.route('/manage')
@login_required
def manage():
    """Farmer's product management dashboard."""
    _require_farmer()
    farms = Farm.query.filter_by(farmer_id=current_user.id, is_active=True).all()
    farm_ids = [f.id for f in farms]
    
    selected_farm_id = request.args.get('farm_id', type=int, default=0)
    query = Product.query.filter_by(farmer_id=current_user.id)
    
    if selected_farm_id and selected_farm_id in farm_ids:
        query = query.filter_by(farm_id=selected_farm_id)
        
    start_date_str = request.args.get('start_date', '')
    end_date_str = request.args.get('end_date', '')
    
    if start_date_str:
        try:
            start_date = datetime.strptime(start_date_str, '%Y-%m-%d').date()
            query = query.filter(db.func.date(Product.created_at) >= start_date)
        except ValueError:
            pass
            
    if end_date_str:
        try:
            end_date = datetime.strptime(end_date_str, '%Y-%m-%d').date()
            query = query.filter(db.func.date(Product.created_at) <= end_date)
        except ValueError:
            pass
            
    products = query.order_by(Product.created_at.desc()).all()

    return render_template(
        'marketplace/manage.html',
        title='My Products',
        products=products,
        farms=farms,
        selected_farm_id=selected_farm_id,
        start_date_str=start_date_str if 'start_date_str' in locals() else '',
        end_date_str=end_date_str if 'end_date_str' in locals() else ''
    )


@marketplace_bp.route('/manage/add', methods=['GET', 'POST'])
@login_required
def manage_add():
    """Add a new product listing."""
    _require_farmer()
    farms = Farm.query.filter_by(
        farmer_id=current_user.id, is_active=True
    ).order_by(Farm.name).all()

    if not farms:
        flash('You need to register a farm before listing products.', 'error')
        return redirect(url_for('production.farm_add'))

    if request.method == 'POST':
        farm_id     = _safe_int(request.form.get('farm_id'))
        name        = request.form.get('name', '').strip()
        description = request.form.get('description', '').strip()
        size_str = request.form.get('size', '').strip()
        variety_str = request.form.get('variety', '').strip()
        unit_str     = request.form.get('unit', '').strip()
        price       = _safe_decimal(request.form.get('price'))
        stock       = _safe_int(request.form.get('stock'), default=0)

        errors = []
        farm_ids = [f.id for f in farms]

        if farm_id not in farm_ids:
            errors.append('Invalid farm selected.')
        if not name:
            errors.append('Product name is required.')
        if len(name) > 150:
            errors.append('Product name must be 150 characters or fewer.')
        if size_str not in {e.value for e in ProductSize}:
            errors.append('Please select a valid size.')
        if variety_str not in {e.value for e in ProductVariety}:
            errors.append('Please select a valid variety.')
        if unit_str not in {e.value for e in ProductUnit}:
            errors.append('Please select a valid unit.')
        if price <= 0:
            errors.append('Price must be greater than zero.')
        if stock < 0:
            errors.append('Stock cannot be negative.')

        if errors:
            for e in errors:
                flash(e, 'error')
            return render_template(
                'marketplace/product_form.html',
                title='Add Product', action='add',
                farms=farms, form_data=request.form,
                sizes=ProductSize, varieties=ProductVariety, units=ProductUnit,
            )

        farm = Farm.query.get(farm_id)
        product = Product(
            farmer_id=current_user.id,
            farm_id=farm_id,
            name=name,
            description=description or None,
            size=ProductSize(size_str),
            variety=ProductVariety(variety_str),
            unit=ProductUnit(unit_str),
            price=price,
            stock=stock,
            location=farm.location if farm else None,
            is_available=True,
        )

        image_file = request.files.get('image')
        if image_file and image_file.filename:
            filename = secure_filename(image_file.filename)
            timestamp = datetime.utcnow().strftime('%Y%m%d%H%M%S')
            new_filename = f"{current_user.id}_{timestamp}_{filename}"
            
            upload_dir = os.path.join(current_app.root_path, 'static', 'uploads')
            os.makedirs(upload_dir, exist_ok=True)
            
            file_path = os.path.join(upload_dir, new_filename)
            image_file.save(file_path)
            
            image_url = url_for('static', filename=f'uploads/{new_filename}')
            product.image_url = image_url
            
            # AI Moderation
            is_safe, flag_reason, ai_result_json = moderate_image(file_path)
            
            if is_safe:
                product.moderation_status = ModerationStatus.APPROVED
            else:
                product.moderation_status = ModerationStatus.FLAGGED
                product.is_available = False # Hide until admin approves
                
            db.session.add(product)
            db.session.flush() # Get product ID for moderation record
            
            mod_record = ContentModeration(
                product_id=product.id,
                uploader_id=current_user.id,
                image_url=image_url,
                status=product.moderation_status,
                ai_result=ai_result_json,
                ai_flag_reason=flag_reason,
                ai_safe=is_safe
            )
            db.session.add(mod_record)
            
            if not is_safe:
                flash(f'"{product.name}" was flagged by our automated moderation system for: {flag_reason}. It is pending admin review.', 'warning')
            else:
                flash(f'"{product.name}" listed on the marketplace.', 'success')
        else:
            db.session.add(product)
            flash(f'"{product.name}" listed on the marketplace.', 'success')
            
        db.session.commit()
        return redirect(url_for('marketplace.manage'))

    return render_template(
        'marketplace/product_form.html',
        title='Add Product', action='add',
        farms=farms, form_data={},
        sizes=ProductSize, varieties=ProductVariety, units=ProductUnit,
    )


@marketplace_bp.route('/manage/<int:product_id>/edit', methods=['GET', 'POST'])
@login_required
def manage_edit(product_id):
    """Edit an existing product listing."""
    _require_farmer()
    product = _get_own_product_or_404(product_id)
    farms = Farm.query.filter_by(
        farmer_id=current_user.id, is_active=True
    ).order_by(Farm.name).all()

    if request.method == 'POST':
        name        = request.form.get('name', '').strip()
        description = request.form.get('description', '').strip()
        size_str = request.form.get('size', '').strip()
        variety_str = request.form.get('variety', '').strip()
        unit_str     = request.form.get('unit', '').strip()
        price       = _safe_decimal(request.form.get('price'))
        stock       = _safe_int(request.form.get('stock'), default=product.stock)

        errors = []
        if not name:
            errors.append('Product name is required.')
        if len(name) > 150:
            errors.append('Product name must be 150 characters or fewer.')
        if size_str not in {e.value for e in ProductSize}:
            errors.append('Please select a valid size.')
        if variety_str not in {e.value for e in ProductVariety}:
            errors.append('Please select a valid variety.')
        if unit_str not in {e.value for e in ProductUnit}:
            errors.append('Please select a valid unit.')
        if price <= 0:
            errors.append('Price must be greater than zero.')
        if stock < 0:
            errors.append('Stock cannot be negative.')

        if errors:
            for e in errors:
                flash(e, 'error')
            return render_template(
                'marketplace/product_form.html',
                title='Edit Product', action='edit',
                farms=farms, product=product, form_data=request.form,
                sizes=ProductSize, varieties=ProductVariety, units=ProductUnit,
            )

        product.name        = name
        product.description = description or None
        product.size        = ProductSize(size_str)
        product.variety     = ProductVariety(variety_str)
        product.unit        = ProductUnit(unit_str)
        product.price       = price
        product.stock       = stock
        db.session.commit()
        flash(f'"{product.name}" updated.', 'success')
        return redirect(url_for('marketplace.manage'))

    return render_template(
        'marketplace/product_form.html',
        title='Edit Product', action='edit',
        farms=farms, product=product, form_data={},
        sizes=ProductSize, varieties=ProductVariety, units=ProductUnit,
    )


@marketplace_bp.route('/manage/<int:product_id>/toggle', methods=['POST'])
@login_required
def manage_toggle(product_id):
    """Toggle product availability on/off."""
    _require_farmer()
    product = _get_own_product_or_404(product_id)
    product.is_available = not product.is_available
    db.session.commit()
    state = 'listed' if product.is_available else 'unlisted'
    flash(f'"{product.name}" is now {state}.', 'success')
    return redirect(url_for('marketplace.manage'))


# Ã¢â€¢ÂÃ¢â€¢ÂÃ¢â€¢ÂÃ¢â€¢ÂÃ¢â€¢ÂÃ¢â€¢ÂÃ¢â€¢ÂÃ¢â€¢ÂÃ¢â€¢ÂÃ¢â€¢ÂÃ¢â€¢ÂÃ¢â€¢ÂÃ¢â€¢ÂÃ¢â€¢ÂÃ¢â€¢ÂÃ¢â€¢ÂÃ¢â€¢ÂÃ¢â€¢ÂÃ¢â€¢ÂÃ¢â€¢ÂÃ¢â€¢ÂÃ¢â€¢ÂÃ¢â€¢ÂÃ¢â€¢ÂÃ¢â€¢ÂÃ¢â€¢ÂÃ¢â€¢ÂÃ¢â€¢ÂÃ¢â€¢ÂÃ¢â€¢ÂÃ¢â€¢ÂÃ¢â€¢ÂÃ¢â€¢ÂÃ¢â€¢ÂÃ¢â€¢ÂÃ¢â€¢ÂÃ¢â€¢ÂÃ¢â€¢ÂÃ¢â€¢ÂÃ¢â€¢ÂÃ¢â€¢ÂÃ¢â€¢ÂÃ¢â€¢ÂÃ¢â€¢ÂÃ¢â€¢ÂÃ¢â€¢ÂÃ¢â€¢ÂÃ¢â€¢ÂÃ¢â€¢ÂÃ¢â€¢ÂÃ¢â€¢ÂÃ¢â€¢ÂÃ¢â€¢ÂÃ¢â€¢ÂÃ¢â€¢ÂÃ¢â€¢ÂÃ¢â€¢ÂÃ¢â€¢ÂÃ¢â€¢ÂÃ¢â€¢ÂÃ¢â€¢ÂÃ¢â€¢ÂÃ¢â€¢ÂÃ¢â€¢ÂÃ¢â€¢ÂÃ¢â€¢ÂÃ¢â€¢ÂÃ¢â€¢ÂÃ¢â€¢ÂÃ¢â€¢ÂÃ¢â€¢ÂÃ¢â€¢ÂÃ¢â€¢ÂÃ¢â€¢ÂÃ¢â€¢ÂÃ¢â€¢Â
# FARMER ORDER MANAGEMENT
# Ã¢â€¢ÂÃ¢â€¢ÂÃ¢â€¢ÂÃ¢â€¢ÂÃ¢â€¢ÂÃ¢â€¢ÂÃ¢â€¢ÂÃ¢â€¢ÂÃ¢â€¢ÂÃ¢â€¢ÂÃ¢â€¢ÂÃ¢â€¢ÂÃ¢â€¢ÂÃ¢â€¢ÂÃ¢â€¢ÂÃ¢â€¢ÂÃ¢â€¢ÂÃ¢â€¢ÂÃ¢â€¢ÂÃ¢â€¢ÂÃ¢â€¢ÂÃ¢â€¢ÂÃ¢â€¢ÂÃ¢â€¢ÂÃ¢â€¢ÂÃ¢â€¢ÂÃ¢â€¢ÂÃ¢â€¢ÂÃ¢â€¢ÂÃ¢â€¢ÂÃ¢â€¢ÂÃ¢â€¢ÂÃ¢â€¢ÂÃ¢â€¢ÂÃ¢â€¢ÂÃ¢â€¢ÂÃ¢â€¢ÂÃ¢â€¢ÂÃ¢â€¢ÂÃ¢â€¢ÂÃ¢â€¢ÂÃ¢â€¢ÂÃ¢â€¢ÂÃ¢â€¢ÂÃ¢â€¢ÂÃ¢â€¢ÂÃ¢â€¢ÂÃ¢â€¢ÂÃ¢â€¢ÂÃ¢â€¢ÂÃ¢â€¢ÂÃ¢â€¢ÂÃ¢â€¢ÂÃ¢â€¢ÂÃ¢â€¢ÂÃ¢â€¢ÂÃ¢â€¢ÂÃ¢â€¢ÂÃ¢â€¢ÂÃ¢â€¢ÂÃ¢â€¢ÂÃ¢â€¢ÂÃ¢â€¢ÂÃ¢â€¢ÂÃ¢â€¢ÂÃ¢â€¢ÂÃ¢â€¢ÂÃ¢â€¢ÂÃ¢â€¢ÂÃ¢â€¢ÂÃ¢â€¢ÂÃ¢â€¢ÂÃ¢â€¢ÂÃ¢â€¢ÂÃ¢â€¢ÂÃ¢â€¢Â

@marketplace_bp.route('/manage/orders')
@login_required
def farmer_orders():
    """View orders that contain the farmer's products."""
    _require_farmer()

    farms = Farm.query.filter_by(farmer_id=current_user.id, is_active=True).all()
    farm_ids = [f.id for f in farms]
    selected_farm_id = request.args.get('farm_id', type=int, default=0)

    my_product_query = Product.query.filter_by(farmer_id=current_user.id)
    if selected_farm_id and selected_farm_id in farm_ids:
        my_product_query = my_product_query.filter_by(farm_id=selected_farm_id)
        
    my_product_ids = [p.id for p in my_product_query.all()]
    
    current_status = request.args.get('status', 'all')

    if not my_product_ids:
        orders_list = []
    else:
        order_ids = db.session.query(OrderItem.order_id).filter(
            OrderItem.product_id.in_(my_product_ids)
        ).distinct().all()
        order_ids = [oid[0] for oid in order_ids]
        
        query = Order.query.filter(Order.id.in_(order_ids))
        
        if current_status != 'all':
            valid_statuses = {e.value for e in OrderStatus}
            if current_status in valid_statuses:
                query = query.filter(Order.status == current_status)
                
        start_date_str = request.args.get('start_date', '')
        end_date_str = request.args.get('end_date', '')
        
        if start_date_str:
            try:
                start_date = datetime.strptime(start_date_str, '%Y-%m-%d').date()
                query = query.filter(db.func.date(Order.created_at) >= start_date)
            except ValueError:
                pass
                
        if end_date_str:
            try:
                end_date = datetime.strptime(end_date_str, '%Y-%m-%d').date()
                query = query.filter(db.func.date(Order.created_at) <= end_date)
            except ValueError:
                pass
                
        orders_list = query.order_by(Order.created_at.desc()).all()

    return render_template(
        'marketplace/farmer_orders.html',
        title='Incoming Orders',
        orders=orders_list,
        my_product_ids=my_product_ids,
        current_status=current_status,
        farms=farms,
        selected_farm_id=selected_farm_id,
        start_date_str=start_date_str if 'start_date_str' in locals() else '',
        end_date_str=end_date_str if 'end_date_str' in locals() else ''
    )


@marketplace_bp.route('/manage/feedback')
@login_required
def farmer_feedback():
    """View buyer feedback on the farmer's orders."""
    _require_farmer()

    search_category = request.args.get('category', '').strip().lower()
    search_sentiment = request.args.get('sentiment', '').strip().lower()
    search_keyword = request.args.get('q', '').strip().lower()
    rating_filter = request.args.get('rating', '').strip()

    # Base query for feedbacks for this farmer (exclude PRODUCT if you want, or show all)
    from app.models import Order, OrderItem, Product
    order_ids = db.session.query(Order.id).join(OrderItem).join(Product).filter(Product.farmer_id == current_user.id).subquery()
    query = BuyerFeedback.query.filter(BuyerFeedback.order_id.in_(order_ids))
    
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
        from sqlalchemy import or_
        query = query.filter(
            or_(
                BuyerFeedback.feedback_text.ilike(f'%{search_keyword}%'),
                BuyerFeedback.ai_keywords.ilike(f'%"{search_keyword}"%')
            )
        )
        
    if rating_filter:
        try:
            r = int(rating_filter)
            query = query.filter(BuyerFeedback.rating == r)
        except ValueError:
            pass

    feedbacks = query.order_by(BuyerFeedback.created_at.desc()).all()
    
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

    # Get unique sentiments and categories for filters
    all_fbs = BuyerFeedback.query.filter(BuyerFeedback.order_id.in_(order_ids)).all()
    
    unique_categories = [c.value for c in FeedbackCategory]
    unique_sentiments = list(set([fb.ai_sentiment for fb in all_fbs if fb.ai_sentiment]))
    
    import json
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
    keywords_map = dict(sorted(keywords_map_counts.items(), key=lambda item: item[1], reverse=True)[:5])

    avg_rating = 0
    rated_feedbacks = [fb for fb in feedbacks if fb.rating]
    if rated_feedbacks:
        avg_rating = sum(fb.rating for fb in rated_feedbacks) / len(rated_feedbacks)

    return render_template(
        'marketplace/farmer_feedback.html',
        feedbacks_grouped=feedbacks_grouped,
        feedbacks=feedbacks,
        current_category=search_category,
        avg_rating=round(avg_rating, 1) if avg_rating else 0,
        total_reviews=len(feedbacks),
        unique_categories=unique_categories,
        unique_sentiments=unique_sentiments,
        keywords_map=keywords_map
    )



@marketplace_bp.route('/manage/orders/<int:order_id>/status', methods=['POST'])
@login_required
def update_order_status(order_id):
    """Update order status (farmer action)."""
    _require_farmer()
    order = Order.query.get_or_404(order_id)

    # Verify this farmer has products in this order
    my_product_ids = [p.id for p in Product.query.filter_by(farmer_id=current_user.id).all()]
    order_product_ids = [item.product_id for item in order.items]
    if not any(pid in my_product_ids for pid in order_product_ids):
        abort(403)

    new_status = request.form.get('status', '').strip()
    valid_statuses = {e.value for e in OrderStatus}
    if new_status not in valid_statuses:
        flash('Invalid order status.', 'error')
        return redirect(url_for('marketplace.farmer_orders'))

    # Prevent backwards transitions (simple validation)
    status_order = ['pending', 'confirmed', 'shipped', 'delivered']
    old_idx = status_order.index(order.status.value) if order.status.value in status_order else -1
    new_idx = status_order.index(new_status) if new_status in status_order else -1

    if new_status == 'cancelled' and order.status.value == 'delivered':
        flash('Cannot cancel a delivered order.', 'error')
        return redirect(url_for('marketplace.farmer_orders'))

    # Since stock is deducted on checkout, we only need to restore it if the order is cancelled.
    old_status = order.status.value
    if new_status == 'cancelled' and old_status != 'cancelled':
        for item in order.items:
            if item.product_id in my_product_ids:
                item.product.stock += item.quantity

    # Generate SalesRecord when order is DELIVERED for the first time
    if new_status == 'delivered' and old_status != 'delivered':
        order.payment_date = datetime.utcnow()
        for item in order.items:
            if item.product_id in my_product_ids:
                sales_record = SalesRecord(
                    farm_id=item.product.farm_id,
                    user_id=current_user.id,
                    sale_date=datetime.utcnow().date(),
                    quantity_sold=item.quantity,
                    price_per_egg=item.unit_price,
                    total_revenue=item.subtotal,
                    buyer_name=order.buyer.full_name,
                    notes=f"{item.product.name} (Order #{order.id})"
                )
                db.session.add(sales_record)

    # Cancel order logic: SalesRecord should be removed if moving from delivered to cancelled.
    if new_status == 'cancelled' and old_status == 'delivered':
        for item in order.items:
            if item.product_id in my_product_ids:
                # Find matching auto-generated SalesRecord and delete it
                rec = SalesRecord.query.filter_by(
                    farm_id=item.product.farm_id,
                    user_id=current_user.id,
                    notes=f"{item.product.name} (Order #{order.id})"
                ).first()
                if rec:
                    db.session.delete(rec)

    order.status = OrderStatus(new_status)
    db.session.commit()
    flash(f'Order #{order.id} status updated to {order.status_label}. Inventory adjusted.', 'success')
    return redirect(url_for('marketplace.farmer_orders'))
