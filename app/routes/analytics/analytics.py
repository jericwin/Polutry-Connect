"""
Analytics Blueprint — PoultryConnect 2.0
Computes and presents the farmer's profitability analytics.

Features:
  - Monthly P&L overview  (revenue vs. expenses → profit / loss)
  - 6-month trend chart   (monthly revenue + expenses over time)
  - Expense breakdown     (by category, for the selected month)
  - 30-day production     (daily egg counts)
  - Price recommendation  (break-even + suggested price with configurable margin)
  - Month selector        (?year=YYYY&month=MM query params, validated)
  - Sales Report Export   (Excel and PDF)
  - Farm Health           (Mortality and Feed Efficiency)

Security:
  - @login_required on every route
  - Role guard: only FARMER
  - All DB queries are scoped to current_user's own farm IDs — no cross-user leakage
  - Query params (year, month) are strictly validated as integers in valid ranges
  - No raw SQL — all via SQLAlchemy ORM aggregation
"""

from flask import Blueprint, render_template, request, abort, redirect, url_for, send_file
from flask_login import login_required, current_user
from sqlalchemy import func, extract
from datetime import date, timedelta, datetime
from decimal import Decimal
from calendar import monthrange
import io
import openpyxl
from openpyxl.styles import Font, Alignment, PatternFill

from app import db
from app.models import Farm, ProductionRecord, Expense, SalesRecord, UserRole, ExpenseCategory, ExpenseFrequency, FeedRecord, MortalityRecord, VerificationStatus

analytics_bp = Blueprint('analytics', __name__)

@analytics_bp.before_request
def check_farmer_verification():
    from flask import flash, redirect, url_for
    if current_user.is_authenticated and current_user.role == UserRole.FARMER:
        if not current_user.verification or current_user.verification.status != VerificationStatus.APPROVED:
            flash('Your account is pending verification. Please wait for an administrator to approve your account before accessing analytics.', 'warning')
            return redirect(url_for('dashboard.farmer'))
            
        if not current_user.is_premium:
            flash('Your free trial has ended. Please upgrade to Pro to continue using advanced analytics.', 'error')
            return redirect(url_for('dashboard.subscription'))

# Target gross margin for the recommendation engine (20%)
RECOMMENDED_MARGIN = Decimal('0.20')


# ─── helpers ────────────────────────────────────────────────────────────────

def _require_farmer():
    if current_user.role != UserRole.FARMER:
        abort(403)


def _get_farm_ids() -> list[int]:
    farms = Farm.query.filter_by(
        farmer_id=current_user.id, is_active=True
    ).with_entities(Farm.id).all()
    return [f.id for f in farms]


def _validate_month_params(year_str, month_str):
    """
    Validate and return (year, month) ints from query params.
    Falls back to current month on invalid input.
    """
    today = date.today()
    try:
        year  = int(year_str)
        month = int(month_str)
        if not (2000 <= year <= 2100 and 1 <= month <= 12):
            raise ValueError
    except (TypeError, ValueError):
        year, month = today.year, today.month
    return year, month


def _month_bounds(year: int, month: int):
    """Return (first_day, last_day) date objects for the given month."""
    _, last_day = monthrange(year, month)
    return date(year, month, 1), date(year, month, last_day)

def _calculate_expenses(farm_ids, start_date, end_date):
    """Calculate total expenses considering frequency."""
    if not farm_ids: return 0.0
    expenses = Expense.query.filter(
        Expense.farm_id.in_(farm_ids),
        Expense.expense_date <= end_date,
        db.or_(Expense.end_date.is_(None), Expense.end_date >= start_date)
    ).all()
    
    total = 0.0
    days_in_period = (end_date - start_date).days + 1
    
    for exp in expenses:
        # Determine active period for this expense
        active_start = max(exp.expense_date, start_date)
        active_end = min(exp.end_date, end_date) if exp.end_date else end_date
        if active_start > active_end:
            continue
            
        active_days = (active_end - active_start).days + 1
        amount = float(exp.amount)
        
        if exp.frequency.value == 'one_time':
            if start_date <= exp.expense_date <= end_date:
                total += amount
        elif exp.frequency.value == 'daily':
            total += amount * active_days
        elif exp.frequency.value == 'weekly':
            total += amount * (active_days / 7.0)
        elif exp.frequency.value == 'monthly':
            # Simplified: full month amount if it overlaps
            total += amount * (active_days / 30.0)
            
    return total

def _calculate_expenses_by_category(farm_ids, start_date, end_date):
    if not farm_ids: return {}
    expenses = Expense.query.filter(
        Expense.farm_id.in_(farm_ids),
        Expense.expense_date <= end_date,
        db.or_(Expense.end_date.is_(None), Expense.end_date >= start_date)
    ).all()
    
    cat_totals = {}
    for exp in expenses:
        cat = exp.category.value.replace('_', ' ').title()
        
        active_start = max(exp.expense_date, start_date)
        active_end = min(exp.end_date, end_date) if exp.end_date else end_date
        if active_start > active_end:
            continue
            
        active_days = (active_end - active_start).days + 1
        amount = float(exp.amount)
        
        if cat not in cat_totals:
            cat_totals[cat] = 0.0
            
        if exp.frequency.value == 'one_time':
            if start_date <= exp.expense_date <= end_date:
                cat_totals[cat] += amount
        elif exp.frequency.value == 'daily':
            cat_totals[cat] += amount * active_days
        elif exp.frequency.value == 'weekly':
            cat_totals[cat] += amount * (active_days / 7.0)
        elif exp.frequency.value == 'monthly':
            cat_totals[cat] += amount * (active_days / 30.0)
            
    return cat_totals

def _calculate_revenue(farm_ids, start_date, end_date):
    """Calculate revenue from SalesRecord."""
    if not farm_ids: return 0.0
    result = db.session.query(func.sum(SalesRecord.total_revenue)).filter(
        SalesRecord.farm_id.in_(farm_ids),
        SalesRecord.sale_date >= start_date,
        SalesRecord.sale_date <= end_date,
    ).scalar()
    return float(result or 0.0)


# ─── main analytics view ────────────────────────────────────────────────────

@analytics_bp.route('/')
@login_required
def index():
    _require_farmer()
    farms = Farm.query.filter_by(farmer_id=current_user.id, is_active=True).all()
    farm_ids = [f.id for f in farms]
    
    selected_farm_id = request.args.get('farm_id', type=int, default=0)
    if selected_farm_id and selected_farm_id in farm_ids:
        farm_ids = [selected_farm_id]

    # ── month selector ────────────────────────────────────────────────────
    today    = date.today()
    year, month = _validate_month_params(
        request.args.get('year'),
        request.args.get('month'),
    )
    month_start, month_end = _month_bounds(year, month)

    # Build prev / next month links
    prev_month_date = date(year, month, 1) - timedelta(days=1)
    next_month_date = date(year, month, 28) + timedelta(days=4)
    next_month_date = next_month_date.replace(day=1)

    prev_link = url_for('analytics.index', year=prev_month_date.year, month=prev_month_date.month, farm_id=selected_farm_id)
    next_link = url_for('analytics.index', year=next_month_date.year, month=next_month_date.month, farm_id=selected_farm_id)
    is_current_month = (year == today.year and month == today.month)

    # ── monthly revenue (from SalesRecord) ────────────────────────────────
    monthly_revenue = _calculate_revenue(farm_ids, month_start, month_end)

    # ── monthly expenses total ────────────────────────────────────────────
    monthly_expenses = _calculate_expenses(farm_ids, month_start, month_end)

    monthly_profit = monthly_revenue - monthly_expenses

    # ── expense breakdown by category ─────────────────────────────────────
    expense_by_category = []
    if farm_ids:
        cat_totals = _calculate_expenses_by_category(farm_ids, month_start, month_end)
        expense_by_category = [{'label': cat, 'amount': amt} for cat, amt in cat_totals.items()]
    category_labels = [r['label'] for r in expense_by_category]
    category_data   = [r['amount'] for r in expense_by_category]

    # ── monthly egg totals + feed totals ───────────────────────────────────
    monthly_eggs = 0
    monthly_feed_kg = 0.0
    monthly_mortality = 0
    
    if farm_ids:
        # Get eggs
        result_eggs = db.session.query(
            func.sum(ProductionRecord.egg_count)
        ).filter(
            ProductionRecord.farm_id.in_(farm_ids),
            ProductionRecord.record_date >= month_start,
            ProductionRecord.record_date <= month_end,
        ).first()
        monthly_eggs = int(result_eggs[0] or 0) if result_eggs else 0
        
        # Get feed
        result_feed = db.session.query(
            func.sum(FeedRecord.feed_consumed_kg)
        ).filter(
            FeedRecord.farm_id.in_(farm_ids),
            FeedRecord.record_date >= month_start,
            FeedRecord.record_date <= month_end,
        ).first()
        monthly_feed_kg = float(result_feed[0] or 0.0) if result_feed else 0.0
        
        # Get mortality
        result_mortality = db.session.query(
            func.sum(MortalityRecord.quantity_died)
        ).filter(
            MortalityRecord.farm_id.in_(farm_ids),
            MortalityRecord.record_date >= month_start,
            MortalityRecord.record_date <= month_end,
        ).first()
        monthly_mortality = int(result_mortality[0] or 0) if result_mortality else 0

    # Calculate Feed Efficiency (grams of feed per egg)
    feed_efficiency = 0
    if monthly_eggs > 0 and monthly_feed_kg > 0:
        feed_efficiency = round((monthly_feed_kg * 1000) / monthly_eggs, 1)

    # ── Source Data Records (for data drill-down & auditability) ────────────
    source_sales = []
    source_expenses = []
    source_production = []
    source_feed = []
    source_mortality = []

    if farm_ids:
        # 1. Sales Records (Revenue source)
        raw_sales = SalesRecord.query.filter(
            SalesRecord.farm_id.in_(farm_ids),
            SalesRecord.sale_date >= month_start,
            SalesRecord.sale_date <= month_end
        ).order_by(SalesRecord.sale_date.desc()).all()
        for s in raw_sales:
            f_name = s.farm.name if hasattr(s, 'farm') and s.farm else 'Farm'
            source_sales.append({
                'date': s.sale_date.strftime('%b %d, %Y'),
                'farm': f_name,
                'buyer': s.buyer_name or 'Walk-in / Direct Buyer',
                'quantity': s.quantity_sold,
                'price_per_egg': float(s.price_per_egg),
                'total_revenue': float(s.total_revenue),
                'notes': s.notes or ''
            })

        # 2. Expenses Records (Expense source with allocated amount)
        raw_expenses = Expense.query.filter(
            Expense.farm_id.in_(farm_ids),
            Expense.expense_date <= month_end,
            db.or_(Expense.end_date.is_(None), Expense.end_date >= month_start)
        ).order_by(Expense.expense_date.desc()).all()
        for e in raw_expenses:
            active_start = max(e.expense_date, month_start)
            active_end = min(e.end_date, month_end) if e.end_date else month_end
            if active_start > active_end:
                continue
            active_days = (active_end - active_start).days + 1
            amt = float(e.amount)
            allocated = 0.0
            freq_str = e.frequency.value if hasattr(e.frequency, 'value') else str(e.frequency)
            if freq_str == 'one_time':
                if month_start <= e.expense_date <= month_end:
                    allocated = amt
            elif freq_str == 'daily':
                allocated = amt * active_days
            elif freq_str == 'weekly':
                allocated = amt * (active_days / 7.0)
            elif freq_str == 'monthly':
                allocated = amt * (active_days / 30.0)

            f_name = e.farm.name if hasattr(e, 'farm') and e.farm else 'Farm'
            cat_name = e.category.value.replace('_', ' ').title() if hasattr(e.category, 'value') else str(e.category)
            source_expenses.append({
                'date': e.expense_date.strftime('%b %d, %Y'),
                'farm': f_name,
                'category': cat_name,
                'frequency': freq_str.replace('_', ' ').title(),
                'base_amount': amt,
                'allocated_amount': round(allocated, 2),
                'description': e.description or 'No description'
            })

        # 3. Production Records (Egg collection source)
        raw_prod = ProductionRecord.query.filter(
            ProductionRecord.farm_id.in_(farm_ids),
            ProductionRecord.record_date >= month_start,
            ProductionRecord.record_date <= month_end
        ).order_by(ProductionRecord.record_date.desc()).all()
        for p in raw_prod:
            f_name = p.farm.name if hasattr(p, 'farm') and p.farm else 'Farm'
            s_val = p.size.value.title() if p.size else 'Standard'
            v_val = p.variety.value.title() if p.variety else 'Egg'
            source_production.append({
                'date': p.record_date.strftime('%b %d, %Y'),
                'farm': f_name,
                'egg_count': p.egg_count,
                'size': s_val,
                'variety': v_val,
                'notes': p.notes or ''
            })

        # 4. Feed Records
        raw_feed = FeedRecord.query.filter(
            FeedRecord.farm_id.in_(farm_ids),
            FeedRecord.record_date >= month_start,
            FeedRecord.record_date <= month_end
        ).order_by(FeedRecord.record_date.desc()).all()
        for fd in raw_feed:
            f_name = fd.farm.name if hasattr(fd, 'farm') and fd.farm else 'Farm'
            source_feed.append({
                'date': fd.record_date.strftime('%b %d, %Y'),
                'farm': f_name,
                'feed_type': fd.feed_type or 'Standard Feed',
                'consumed_kg': float(fd.feed_consumed_kg or 0),
                'cost': float(fd.feed_cost or 0),
                'notes': fd.notes or ''
            })

        # 5. Mortality Records
        raw_mort = MortalityRecord.query.filter(
            MortalityRecord.farm_id.in_(farm_ids),
            MortalityRecord.record_date >= month_start,
            MortalityRecord.record_date <= month_end
        ).order_by(MortalityRecord.record_date.desc()).all()
        for m in raw_mort:
            f_name = m.farm.name if hasattr(m, 'farm') and m.farm else 'Farm'
            source_mortality.append({
                'date': m.record_date.strftime('%b %d, %Y'),
                'farm': f_name,
                'quantity_died': m.quantity_died,
                'reason': m.reason or 'Unspecified',
                'notes': m.notes or ''
            })


    # ── price recommendation ───────────────────────────────────────────────
    breakeven_price    = None
    recommended_price  = None
    current_avg_price  = None

    if monthly_eggs > 0 and monthly_expenses > 0:
        breakeven_price   = Decimal(str(monthly_expenses)) / Decimal(str(monthly_eggs))
        medium_white_base = breakeven_price * (1 + RECOMMENDED_MARGIN)
        
        # Build pricing matrix based on multipliers
        size_multipliers = {
            'small': Decimal('0.90'),
            'medium': Decimal('1.00'),
            'large': Decimal('1.10'),
            'extra_large': Decimal('1.20'),
            'jumbo': Decimal('1.30')
        }
        color_multiplier = {'white': Decimal('1.00'), 'brown': Decimal('1.05')}

        pricing_matrix = {}
        for size, s_mult in size_multipliers.items():
            pricing_matrix[size] = {}
            for color, c_mult in color_multiplier.items():
                pricing_matrix[size][color] = round(medium_white_base * s_mult * c_mult, 2)

        recommended_price = pricing_matrix['medium']['white']

    # Fetch farmer's current selling prices from their active marketplace listings
    from app.models import Product, ProductUnit
    farmer_products = Product.query.filter_by(farmer_id=current_user.id, is_available=True).all()
    selling_prices = {}
    for p in farmer_products:
        if p.size and p.variety:
            raw_price = float(p.price)
            if p.unit == ProductUnit.TRAY and raw_price > 30:
                price_per_egg = raw_price / 30
            else:
                price_per_egg = raw_price
                
            if p.size.value not in selling_prices:
                selling_prices[p.size.value] = {}
            selling_prices[p.size.value][p.variety.value] = round(price_per_egg, 2)

    if monthly_eggs > 0:
        result = db.session.query(
            func.sum(SalesRecord.quantity_sold * SalesRecord.price_per_egg),
            func.sum(SalesRecord.quantity_sold)
        ).filter(
            SalesRecord.farm_id.in_(farm_ids),
            SalesRecord.sale_date >= month_start,
            SalesRecord.sale_date <= month_end,
        ).first()
        if result and result[0] and result[1] and result[1] > 0:
            current_avg_price = Decimal(str(result[0])) / Decimal(str(result[1]))

    # ── 6-month trend (revenue + expenses per month) ───────────────────────
    trend_labels   = []
    trend_revenue  = []
    trend_expenses = []

    for i in range(5, -1, -1):
        ref = date(year, month, 1)
        m = ref.month - i
        y = ref.year
        while m <= 0:
            m += 12
            y -= 1
        t_start, t_end = _month_bounds(y, m)
        label = date(y, m, 1).strftime('%b %Y')
        trend_labels.append(label)

        rev = _calculate_revenue(farm_ids, t_start, t_end)
        exp = _calculate_expenses(farm_ids, t_start, t_end)

        trend_revenue.append(float(rev))
        trend_expenses.append(float(exp))

    # ── 30-day daily egg production chart ─────────────────────────────────
    prod_labels = []
    prod_data   = []
    for i in range(29, -1, -1):
        day = today - timedelta(days=i)
        prod_labels.append(day.strftime('%b %d'))
        if farm_ids:
            result = db.session.query(func.sum(ProductionRecord.egg_count)).filter(
                ProductionRecord.farm_id.in_(farm_ids),
                ProductionRecord.record_date == day,
            ).scalar()
            prod_data.append(int(result or 0))
        else:
            prod_data.append(0)

    # ── farms quick summary ────────────────────────────────────────────────
    farms = Farm.query.filter_by(farmer_id=current_user.id, is_active=True).all()

    # ── daily sales report ───────────────────────────────────────────────
    daily_sales = []
    if farm_ids:
        daily_res = db.session.query(
            SalesRecord.sale_date,
            func.sum(SalesRecord.total_revenue)
        ).filter(
            SalesRecord.farm_id.in_(farm_ids),
            SalesRecord.sale_date >= month_start,
            SalesRecord.sale_date <= month_end
        ).group_by(SalesRecord.sale_date).order_by(SalesRecord.sale_date).all()
        daily_sales = [{'date': r[0].strftime('%b %d'), 'revenue': float(r[1])} for r in daily_res]

    daily_sales_labels = [s['date'] for s in daily_sales]
    daily_sales_data = [s['revenue'] for s in daily_sales]

    # ── sales and profit by egg size ─────────────────────────────────────
    from app.models import Order, OrderItem, Product, OrderStatus, ProductSize
    sales_by_size = {}
    size_profit_stats = []
    weekly_labels = []
    size_weekly_datasets = []

    # Prepare weeks for the current month view (e.g. Week 1, Week 2, ...)
    curr = month_start
    weeks = []
    week_idx = 1
    while curr <= month_end:
        w_end = min(curr + timedelta(days=6), month_end)
        label = f"W{week_idx} ({curr.strftime('%b %d')}-{w_end.strftime('%d')})"
        weeks.append((curr, w_end, label))
        weekly_labels.append(label)
        curr = w_end + timedelta(days=1)
        week_idx += 1

    # Cost per egg for this month (total expenses / total eggs produced)
    cost_per_egg_month = float(breakeven_price or 0.0) if breakeven_price else 0.0

    if farm_ids:
        # Match orders by payment_date or created_at within month
        order_date_col = func.coalesce(func.date(Order.payment_date), func.date(Order.created_at))
        delivered_items = db.session.query(
            Product.size,
            order_date_col,
            OrderItem.quantity,
            OrderItem.unit_price,
            Product.unit
        ).join(OrderItem, OrderItem.product_id == Product.id) \
         .join(Order, Order.id == OrderItem.order_id) \
         .filter(
            Product.farm_id.in_(farm_ids),
            Order.status == OrderStatus.DELIVERED,
            order_date_col >= month_start,
            order_date_col <= month_end
        ).all()

        # Group data per size
        # Standard sizes in display order
        all_sizes_enum = [ProductSize.SMALL, ProductSize.MEDIUM, ProductSize.LARGE, ProductSize.EXTRA_LARGE, ProductSize.JUMBO]
        size_dict = {
            s.value: {
                'size_key': s.value,
                'size_name': s.value.replace('_', ' ').title(),
                'trays_sold': 0,
                'eggs_sold': 0,
                'revenue': 0.0,
                'cost': 0.0,
                'profit': 0.0,
                'margin': 0.0,
                'weekly_sales': [0.0] * len(weeks)
            } for s in all_sizes_enum
        }

        for p_size, dt_val, qty, unit_price, p_unit in delivered_items:
            if not p_size:
                continue
            s_key = p_size.value
            if s_key not in size_dict:
                size_dict[s_key] = {
                    'size_key': s_key,
                    'size_name': s_key.replace('_', ' ').title(),
                    'trays_sold': 0,
                    'eggs_sold': 0,
                    'revenue': 0.0,
                    'cost': 0.0,
                    'profit': 0.0,
                    'margin': 0.0,
                    'weekly_sales': [0.0] * len(weeks)
                }

            line_rev = float(qty * unit_price)
            # 1 tray = 30 eggs; if piece unit, qty = eggs
            eggs_count = qty * 30 if getattr(p_unit, 'value', str(p_unit)) == 'tray' or unit_price > 25 else qty
            line_cost = eggs_count * cost_per_egg_month

            size_dict[s_key]['trays_sold'] += (qty if getattr(p_unit, 'value', str(p_unit)) == 'tray' or unit_price > 25 else round(qty / 30, 1))
            size_dict[s_key]['eggs_sold'] += eggs_count
            size_dict[s_key]['revenue'] += line_rev
            size_dict[s_key]['cost'] += line_cost
            size_dict[s_key]['profit'] += (line_rev - line_cost)

            # Assign to week
            item_date = dt_val if isinstance(dt_val, date) else datetime.strptime(str(dt_val)[:10], '%Y-%m-%d').date()
            for w_i, (w_s, w_e, _) in enumerate(weeks):
                if w_s <= item_date <= w_e:
                    size_dict[s_key]['weekly_sales'][w_i] += line_rev

        # Calculate margins & format
        palette = {
            'small': {'color': '#16a34a', 'bg': 'rgba(22, 163, 74, 0.1)'},
            'medium': {'color': '#2563eb', 'bg': 'rgba(37, 99, 235, 0.1)'},
            'large': {'color': '#d97706', 'bg': 'rgba(217, 119, 6, 0.1)'},
            'extra_large': {'color': '#9333ea', 'bg': 'rgba(147, 51, 234, 0.1)'},
            'jumbo': {'color': '#dc2626', 'bg': 'rgba(220, 38, 38, 0.1)'}
        }

        for s_key, s_data in size_dict.items():
            if s_data['revenue'] > 0:
                s_data['margin'] = round((s_data['profit'] / s_data['revenue']) * 100, 1)
            else:
                s_data['margin'] = 0.0
            s_data['color'] = palette.get(s_key, {}).get('color', '#64748b')
            s_data['bg'] = palette.get(s_key, {}).get('bg', 'rgba(100, 116, 139, 0.1)')
            size_profit_stats.append(s_data)
            sales_by_size[s_data['size_name']] = s_data['trays_sold']

        # Prepare chart datasets for weekly sales per size
        for s_data in size_profit_stats:
            size_weekly_datasets.append({
                'label': s_data['size_name'],
                'data': [round(v, 2) for v in s_data['weekly_sales']],
                'borderColor': s_data['color'],
                'backgroundColor': s_data['bg'],
                'borderWidth': 2.5,
                'tension': 0.3,
                'fill': False,
                'pointRadius': 4,
                'pointHoverRadius': 6,
            })

    size_labels = [s['size_name'] for s in size_profit_stats if s['trays_sold'] > 0]
    size_data = [s['trays_sold'] for s in size_profit_stats if s['trays_sold'] > 0]

    # ══════════════════════════════════════════════════════════════════════
    # DECISION SUPPORT & FORECASTING
    # ══════════════════════════════════════════════════════════════════════

    # ── A. 30-Day Production Forecast (Weighted Moving Average) ───────────
    # Fetch last 90 days of daily egg production
    forecast_eggs_next30 = 0
    forecast_revenue_next30 = 0.0
    forecast_confidence = 'low'  # 'low' | 'medium' | 'high'
    wma_history = []   # (date, egg_count) pairs

    if farm_ids:
        ninety_days_ago = today - timedelta(days=89)
        raw_prod = db.session.query(
            ProductionRecord.record_date,
            func.sum(ProductionRecord.egg_count)
        ).filter(
            ProductionRecord.farm_id.in_(farm_ids),
            ProductionRecord.record_date >= ninety_days_ago,
            ProductionRecord.record_date <= today,
        ).group_by(ProductionRecord.record_date).order_by(ProductionRecord.record_date).all()

        wma_history = [(r[0], int(r[1])) for r in raw_prod]

    if len(wma_history) >= 7:
        # Weighted Moving Average: more recent days carry heavier weight
        # Window = min(30, available days)
        window = min(30, len(wma_history))
        recent = [v for _, v in wma_history[-window:]]
        weights = list(range(1, window + 1))   # [1, 2, 3, …, window]
        wma_daily = sum(r * w for r, w in zip(recent, weights)) / sum(weights)
        forecast_eggs_next30 = int(round(wma_daily * 30))

        if current_avg_price:
            forecast_revenue_next30 = round(float(current_avg_price) * forecast_eggs_next30, 2)
        elif recommended_price:
            forecast_revenue_next30 = round(float(recommended_price) * forecast_eggs_next30, 2)

        # Confidence based on data coverage
        if len(wma_history) >= 60:
            forecast_confidence = 'high'
        elif len(wma_history) >= 21:
            forecast_confidence = 'medium'
        else:
            forecast_confidence = 'low'

    # ── B. Feed Cost Trend ─────────────────────────────────────────────────
    prev_month_date   = date(year, month, 1) - timedelta(days=1)
    prev_m_start, prev_m_end = _month_bounds(prev_month_date.year, prev_month_date.month)

    prev_feed_cost = 0.0
    this_feed_cost = 0.0
    feed_cost_change_pct = 0.0
    feed_cost_alert = None   # None | 'rising' | 'stable' | 'falling'
    feed_cost_per_egg = 0.0

    if farm_ids:
        r_prev = db.session.query(func.sum(FeedRecord.feed_cost)).filter(
            FeedRecord.farm_id.in_(farm_ids),
            FeedRecord.record_date >= prev_m_start,
            FeedRecord.record_date <= prev_m_end,
        ).scalar()
        prev_feed_cost = float(r_prev or 0.0)

        r_this = db.session.query(func.sum(FeedRecord.feed_cost)).filter(
            FeedRecord.farm_id.in_(farm_ids),
            FeedRecord.record_date >= month_start,
            FeedRecord.record_date <= month_end,
        ).scalar()
        this_feed_cost = float(r_this or 0.0)

    if prev_feed_cost > 0:
        feed_cost_change_pct = round(((this_feed_cost - prev_feed_cost) / prev_feed_cost) * 100, 1)
        if feed_cost_change_pct > 10:
            feed_cost_alert = 'rising'
        elif feed_cost_change_pct < -5:
            feed_cost_alert = 'falling'
        else:
            feed_cost_alert = 'stable'

    if monthly_eggs > 0 and this_feed_cost > 0:
        feed_cost_per_egg = round(this_feed_cost / monthly_eggs, 4)

    # ── C. Mortality Risk Signal ───────────────────────────────────────────
    total_flock = sum(f.flock_size for f in farms) if farms else 0
    mortality_rate_pct = 0.0
    mortality_signal = 'normal'    # 'normal' | 'elevated' | 'high'

    if total_flock > 0 and monthly_mortality > 0:
        mortality_rate_pct = round((monthly_mortality / total_flock) * 100, 2)
        if mortality_rate_pct > 2.0:
            mortality_signal = 'high'
        elif mortality_rate_pct >= 0.5:
            mortality_signal = 'elevated'

    # ── D. Sales Trend Direction ───────────────────────────────────────────
    prev_revenue = _calculate_revenue(farm_ids, prev_m_start, prev_m_end)
    sales_trend_pct = 0.0
    sales_trend_dir = 'flat'   # 'up' | 'down' | 'flat'

    if prev_revenue > 0:
        sales_trend_pct = round(((monthly_revenue - float(prev_revenue)) / float(prev_revenue)) * 100, 1)
        if sales_trend_pct > 2:
            sales_trend_dir = 'up'
        elif sales_trend_pct < -2:
            sales_trend_dir = 'down'

    # ── Farm classification summary & performance ────────────────────────
    farm_classifications = []
    for f in farms:
        f_rev = _calculate_revenue([f.id], month_start, month_end)
        f_exp = _calculate_expenses([f.id], month_start, month_end)
        f_profit = f_rev - f_exp
        
        result_eggs = db.session.query(func.sum(ProductionRecord.egg_count)).filter(
            ProductionRecord.farm_id == f.id,
            ProductionRecord.record_date >= month_start,
            ProductionRecord.record_date <= month_end,
        ).first()
        f_eggs = int(result_eggs[0] or 0) if result_eggs else 0

        farm_classifications.append({
            'name': f.name,
            'flock_size': f.flock_size,
            'scale_label': f.scale_label,
            'scale_class': f.scale_class,
            'scale_icon': f.scale_icon,
            'revenue': f_rev,
            'expenses': f_exp,
            'profit': f_profit,
            'eggs': f_eggs,
        })
        
    # Sort by profit descending so best performing farm is first
    farm_classifications.sort(key=lambda x: x['profit'], reverse=True)

    return render_template(
        'analytics/analytics.html',
        title='Analytics',
        farms=farms,
        selected_farm_id=selected_farm_id,

        year=year, month=month,
        month_label=date(year, month, 1).strftime('%B %Y'),
        prev_link=prev_link,
        next_link=next_link,
        is_current_month=is_current_month,

        monthly_revenue=monthly_revenue,
        monthly_expenses=monthly_expenses,
        monthly_profit=monthly_profit,
        monthly_eggs=monthly_eggs,
        
        monthly_feed_kg=monthly_feed_kg,
        monthly_mortality=monthly_mortality,
        feed_efficiency=feed_efficiency,

        breakeven_price=breakeven_price,
        recommended_price=recommended_price,
        pricing_matrix=pricing_matrix if 'pricing_matrix' in locals() else None,
        selling_prices=selling_prices,
        current_avg_price=current_avg_price,
        margin_pct=int(RECOMMENDED_MARGIN * 100),

        trend_labels=trend_labels,
        trend_revenue=trend_revenue,
        trend_expenses=trend_expenses,
        prod_labels=prod_labels,
        prod_data=prod_data,
        category_labels=category_labels,
        category_data=category_data,

        daily_sales_labels=daily_sales_labels,
        daily_sales_data=daily_sales_data,
        size_labels=size_labels,
        size_data=size_data,
        size_profit_stats=size_profit_stats,
        weekly_labels=weekly_labels,
        size_weekly_datasets=size_weekly_datasets,
        cost_per_egg_month=cost_per_egg_month,

        today=today,

        # ── Decision Support ──────────────────────────────────────────────
        forecast_eggs_next30=forecast_eggs_next30,
        forecast_revenue_next30=forecast_revenue_next30,
        forecast_confidence=forecast_confidence,

        feed_cost_change_pct=feed_cost_change_pct,
        feed_cost_alert=feed_cost_alert,
        feed_cost_per_egg=feed_cost_per_egg,
        this_feed_cost=this_feed_cost,

        mortality_rate_pct=mortality_rate_pct,
        mortality_signal=mortality_signal,
        total_flock=total_flock,

        sales_trend_pct=sales_trend_pct,
        sales_trend_dir=sales_trend_dir,
        prev_revenue=float(prev_revenue),

        farm_classifications=farm_classifications,

        source_sales=source_sales,
        source_expenses=source_expenses,
        source_production=source_production,
        source_feed=source_feed,
        source_mortality=source_mortality,
    )



@analytics_bp.route('/report/sales')
@login_required
def sales_report():
    """Generate Excel or PDF-printable HTML report for Sales."""
    _require_farmer()
    farms = Farm.query.filter_by(farmer_id=current_user.id, is_active=True).all()
    farm_ids = [f.id for f in farms]
    if not farm_ids:
        flash('You have no registered farms.', 'error')
        return redirect(url_for('analytics.index'))

    start_date_str = request.args.get('start_date')
    end_date_str = request.args.get('end_date')
    selected_farm_id = request.args.get('farm_id')
    selected_type = request.args.get('type')
    format_type = request.args.get('format', 'pdf')
    
    query = SalesRecord.query.filter_by(user_id=current_user.id)
    
    if selected_farm_id:
        try:
            fid = int(selected_farm_id)
            if fid in farm_ids:
                query = query.filter(SalesRecord.farm_id == fid)
        except ValueError:
            pass
            
    start_date = None
    end_date = None
    
    if start_date_str:
        try:
            start_date = datetime.strptime(start_date_str, '%Y-%m-%d').date()
            query = query.filter(SalesRecord.sale_date >= start_date)
        except ValueError:
            pass
            
    if end_date_str:
        try:
            end_date = datetime.strptime(end_date_str, '%Y-%m-%d').date()
            query = query.filter(SalesRecord.sale_date <= end_date)
        except ValueError:
            pass
            
    sales = query.order_by(SalesRecord.sale_date.desc(), SalesRecord.created_at.desc()).all()
    
    # Filter by type (Online/On-site)
    if selected_type == 'online':
        sales = [s for s in sales if s.notes and '(Order #' in s.notes]
    elif selected_type == 'onsite':
        sales = [s for s in sales if not s.notes or '(Order #' not in s.notes]
        
    total_qty = sum(s.quantity_sold for s in sales)
    total_rev = sum(s.total_revenue for s in sales)
    
    if format_type == 'excel':
        wb = openpyxl.Workbook()
        ws = wb.active
        ws.title = "Sales Report"
        
        header_fill = PatternFill(start_color="0D631B", end_color="0D631B", fill_type="solid")
        header_font = Font(color="FFFFFF", bold=True)
        
        headers = ["Date", "Type", "Farm", "Buyer", "Egg Type / Notes", "Quantity (Eggs)", "Price per Egg (PHP)", "Total Revenue (PHP)"]
        ws.append(headers)
        
        for col_num, cell in enumerate(ws[1], 1):
            cell.fill = header_fill
            cell.font = header_font
            cell.alignment = Alignment(horizontal="center")
            ws.column_dimensions[openpyxl.utils.get_column_letter(col_num)].width = 20
            
        for s in sales:
            is_online = s.notes and '(Order #' in s.notes
            ws.append([
                s.sale_date.strftime('%Y-%m-%d'),
                "Online" if is_online else "On-site",
                s.farm.name,
                s.buyer_name or 'Walk-in / Unknown',
                s.notes or '',
                s.quantity_sold,
                float(s.price_per_egg),
                float(s.total_revenue)
            ])
            
        ws.append([])
        ws.append(["TOTALS", "", "", "", "", total_qty, "", float(total_rev)])
        totals_row = ws.max_row
        for col_num in range(1, 9):
            ws.cell(row=totals_row, column=col_num).font = Font(bold=True)
            
        mem = io.BytesIO()
        wb.save(mem)
        mem.seek(0)
        
        filename = f"PoultryConnect_Sales_{datetime.now().strftime('%Y%m%d')}.xlsx"
        return send_file(
            mem,
            mimetype='application/vnd.openxmlformats-officedocument.spreadsheetml.sheet',
            as_attachment=True,
            download_name=filename
        )
        
    else:
        return render_template(
            'analytics/sales_report_pdf.html',
            sales=sales,
            start_date=start_date,
            end_date=end_date,
            total_qty=total_qty,
            total_rev=total_rev,
            today=datetime.now()
        )

@analytics_bp.route('/report/expenses')
@login_required
def expenses_report():
    """Generate Excel or PDF-printable HTML report for Expenses."""
    from app.models import Expense
    _require_farmer()
    farms = Farm.query.filter_by(farmer_id=current_user.id, is_active=True).all()
    farm_ids = [f.id for f in farms]
    if not farm_ids:
        flash('You have no registered farms.', 'error')
        return redirect(url_for('analytics.index'))

    start_date_str = request.args.get('start_date')
    end_date_str = request.args.get('end_date')
    selected_farm_id = request.args.get('farm_id')
    format_type = request.args.get('format', 'pdf')
    
    query = Expense.query.filter(Expense.farm_id.in_(farm_ids))
    
    if selected_farm_id:
        try:
            fid = int(selected_farm_id)
            if fid in farm_ids:
                query = query.filter(Expense.farm_id == fid)
        except ValueError:
            pass
            
    start_date = None
    end_date = None
    
    if start_date_str:
        try:
            start_date = datetime.strptime(start_date_str, '%Y-%m-%d').date()
            query = query.filter(Expense.expense_date >= start_date)
        except ValueError:
            pass
            
    if end_date_str:
        try:
            end_date = datetime.strptime(end_date_str, '%Y-%m-%d').date()
            query = query.filter(Expense.expense_date <= end_date)
        except ValueError:
            pass
            
    expenses = query.order_by(Expense.expense_date.desc(), Expense.created_at.desc()).all()
    
    total_amount = sum(e.amount for e in expenses)
    
    if format_type == 'excel':
        import openpyxl
        from openpyxl.styles import Font, PatternFill, Alignment
        import io
        
        wb = openpyxl.Workbook()
        ws = wb.active
        ws.title = "Expenses Report"
        
        header_fill = PatternFill(start_color="B91C1C", end_color="B91C1C", fill_type="solid")
        header_font = Font(color="FFFFFF", bold=True)
        
        headers = ["Date", "Farm", "Category", "Description", "Frequency", "Amount (PHP)"]
        ws.append(headers)
        
        for col_num, cell in enumerate(ws[1], 1):
            cell.fill = header_fill
            cell.font = header_font
            cell.alignment = Alignment(horizontal="center")
            ws.column_dimensions[openpyxl.utils.get_column_letter(col_num)].width = 20
            
        for e in expenses:
            ws.append([
                e.expense_date.strftime('%Y-%m-%d'),
                e.farm.name,
                e.category.value if e.category else '',
                e.description or '',
                e.frequency.value if e.frequency else '',
                float(e.amount)
            ])
            
        ws.append([])
        ws.append(["TOTAL", "", "", "", "", float(total_amount)])
        totals_row = ws.max_row
        for col_num in range(1, 7):
            ws.cell(row=totals_row, column=col_num).font = Font(bold=True)
            
        mem = io.BytesIO()
        wb.save(mem)
        mem.seek(0)
        
        return send_file(
            mem,
            as_attachment=True,
            download_name=f"Expenses_Report_{datetime.utcnow().strftime('%Y%m%d')}.xlsx",
            mimetype='application/vnd.openxmlformats-officedocument.spreadsheetml.sheet'
        )

    # Otherwise render HTML for printing to PDF
    return render_template(
        'analytics/expenses_report_pdf.html',
        expenses=expenses,
        total_amount=total_amount,
        start_date=start_date,
        end_date=end_date,
        today=datetime.now()
    )
