import os
from werkzeug.utils import secure_filename
from flask import Blueprint, render_template, redirect, url_for, flash, request
from flask_login import login_required, current_user
from app.models import UserRole, Farm, ProductionRecord, Expense, SalesRecord, ExpenseFrequency, VerificationStatus, FarmerVerification
from datetime import date, timedelta, datetime
from sqlalchemy import func
from app import db
from decimal import Decimal
from calendar import monthrange

dashboard_bp = Blueprint('dashboard', __name__)

def _calculate_expenses(farm_ids, start_date=None, end_date=None):
    """Calculate total expenses considering frequency and optional date bounds."""
    if not farm_ids: return 0.0
    
    query = Expense.query.filter(Expense.farm_id.in_(farm_ids))
    if end_date:
        query = query.filter(Expense.expense_date <= end_date)
    if start_date:
        query = query.filter(db.or_(Expense.end_date.is_(None), Expense.end_date >= start_date))
    expenses = query.all()
    
    total = 0.0
    
    # If all-time (no bounds), sum one_time expenses directly
    if not start_date or not end_date:
        for exp in expenses:
            total += float(exp.amount)
        return total

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

def _calculate_revenue(farm_ids, start_date=None, end_date=None):
    """Calculate revenue from SalesRecord with optional date bounds."""
    if not farm_ids: return 0.0
    query = db.session.query(func.sum(SalesRecord.total_revenue)).filter(
        SalesRecord.farm_id.in_(farm_ids)
    )
    if start_date:
        query = query.filter(SalesRecord.sale_date >= start_date)
    if end_date:
        query = query.filter(SalesRecord.sale_date <= end_date)
    result = query.scalar()
    return float(result or 0.0)


def _build_market_intelligence(recent_records, monthly_expenses, farm_count, today):
    """Build profit guidance and demand forecast with visualization data from real database records."""
    records = list(recent_records or [])
    eggs = [int(getattr(record, 'egg_count', 0) or 0) for record in records]
    prices = [float(record.egg_price) for record in records if getattr(record, 'egg_price', None)]
    feed_costs = [float(record.feed_cost) for record in records if getattr(record, 'feed_cost', None)]
    dates = [record.record_date for record in records if getattr(record, 'record_date', None)]

    avg_daily_eggs = round(sum(eggs) / len(eggs), 1) if eggs else 0
    avg_selling_price = round(sum(prices) / len(prices), 2) if prices else 7.5
    avg_feed_cost = round(sum(feed_costs) / len(feed_costs), 2) if feed_costs else 0.0
    base_cost_per_egg = round((avg_feed_cost / avg_daily_eggs) if avg_daily_eggs else 1.8, 2)

    # Build price trend chart data (last 7 days from records)
    price_trend_labels = [d.strftime('%a') for d in sorted(dates[-7:])]
    price_trend_data = sorted(prices[-7:]) if prices else []
    
    # Calculate profit margins
    margins = []
    for price in prices:
        margin = round(((price - base_cost_per_egg) / price * 100) if price > 0 else 0, 1)
        margins.append(margin)
    avg_margin = round(sum(margins) / len(margins), 1) if margins else 0

    seasonal_factors = {
        1: 0.95, 2: 0.93, 3: 0.97, 4: 1.02, 5: 1.06, 6: 1.11,
        7: 1.14, 8: 1.1, 9: 1.05, 10: 1.01, 11: 1.0, 12: 1.08,
    }
    season_factor = seasonal_factors.get(today.month, 1.0)
    demand_forecast = round(avg_daily_eggs * season_factor, 1)

    # Calculate base recommended price for Medium White (Base Cost + 20% margin)
    target_margin = 1.20
    medium_white_base = round(max(avg_selling_price * 1.06, base_cost_per_egg * target_margin, 7.2), 2)
    
    # Build pricing matrix based on multipliers
    size_multipliers = {
        'small': 0.90,
        'medium': 1.00,
        'large': 1.10,
        'extra_large': 1.20,
        'jumbo': 1.30
    }
    color_multiplier = {'white': 1.00, 'brown': 1.05}

    pricing_matrix = {}
    for size, s_mult in size_multipliers.items():
        pricing_matrix[size] = {}
        for color, c_mult in color_multiplier.items():
            pricing_matrix[size][color] = round(medium_white_base * s_mult * c_mult, 2)

    from app.models import Product, ProductUnit
    
    # In dashboard logic, we fallback to current_user if available, else first record user_id for test_logic script
    try:
        from flask_login import current_user
        u_id = current_user.id
    except:
        u_id = records[0].user_id if records else 1
    farmer_products = Product.query.filter_by(farmer_id=u_id, is_available=True).all()
    selling_prices = {}
    for p in farmer_products:
        if p.size and p.variety:
            # Convert to per-egg price if listed as a tray (30 pieces), but only if price > 30 
            # to handle cases where farmers enter the per-piece price while selecting TRAY.
            raw_price = float(p.price)
            if p.unit == ProductUnit.TRAY and raw_price > 30:
                price_per_egg = raw_price / 30
            else:
                price_per_egg = raw_price
                
            if p.size.value not in selling_prices:
                selling_prices[p.size.value] = {}
            selling_prices[p.size.value][p.variety.value] = round(price_per_egg, 2)

    recommended_price = pricing_matrix['medium']['white'] # Keep for backward compatibility or general reference
    projected_eggs = round(avg_daily_eggs * 7 * season_factor, 0)
    estimated_revenue = round(projected_eggs * recommended_price, 2)
    estimated_cost = round((projected_eggs * max(base_cost_per_egg, 1.5)) + (monthly_expenses / 4), 2)
    projected_profit = round(estimated_revenue - estimated_cost, 2)

    # Build forecast comparison data
    forecast_weeks = ['Week 1', 'Week 2', 'Week 3', 'Week 4']
    actual_data = [avg_daily_eggs * 7] * 4
    forecast_data = [round(avg_daily_eggs * 7 * season_factor * (1 + i*0.05), 0) for i in range(4)]

    if projected_profit > 0:
        sell_window = 'this week'
        guidance = 'Pricing slightly above the recent average can lift margin without slowing movement.'
    else:
        sell_window = 'within two days'
        guidance = 'Keep pricing competitive and move smaller batches quickly to protect cash flow.'

    if demand_forecast > avg_daily_eggs * 1.05:
        demand_signal = 'High demand expected'
        forecast_summary = 'Demand is trending up, so prepare for stronger order volume in the next week.'
        production_plan = 'Increase prep for the coming week and schedule pickups earlier in the cycle.'
        allocation = 'Reserve 60% of output for regular buyers and 40% for flexible channels.'
    elif demand_forecast < avg_daily_eggs * 0.95:
        demand_signal = 'Steady demand'
        forecast_summary = 'Demand is stable, so it is better to keep output measured and avoid overstock.'
        production_plan = 'Hold output steady and prioritize smaller, more frequent dispatches.'
        allocation = 'Keep 70% for direct buyers and 30% for quick-turnover sales.'
    else:
        demand_signal = 'Balanced demand'
        forecast_summary = 'The short-term outlook is balanced, so keep production steady and review again midweek.'
        production_plan = 'Maintain current output and adjust only if orders change.'
        allocation = 'Split volume evenly between dependable buyers and flexible channels.'

    buyer_leads = [
        {'name': 'Neighborhood groceries', 'note': 'Reliable weekly volumes for consistent supply', 'channel': 'Daily buyers'},
        {'name': 'School canteens', 'note': 'Good fit for medium-sized batches', 'channel': 'Institutional'},
        {'name': 'Restaurants', 'note': 'Higher value when supply stays fresh and regular', 'channel': 'Premium outlets'},
    ]

    return {
        'sell_window': sell_window,
        'guidance': guidance,
        'recommended_price': recommended_price,
        'pricing_matrix': pricing_matrix,
        'selling_prices': selling_prices,
        'projected_profit': projected_profit,
        'demand_forecast': demand_forecast,
        'demand_signal': demand_signal,
        'forecast_summary': forecast_summary,
        'production_plan': production_plan,
        'allocation': allocation,
        'buyer_leads': buyer_leads,
        'farm_count': farm_count,
        'price_trend_labels': price_trend_labels,
        'price_trend_data': price_trend_data,
        'avg_margin': avg_margin,
        'forecast_weeks': forecast_weeks,
        'actual_data': actual_data,
        'forecast_data': forecast_data,
        'base_cost_per_egg': base_cost_per_egg,
        'avg_selling_price': avg_selling_price,
    }


def _require_role(*roles):
    """Decorator-style helper — returns a redirect if current_user's role not in roles."""
    if current_user.role not in roles:
        flash('You do not have permission to access that page.', 'error')
        return redirect(url_for('index'))
    return None


@dashboard_bp.route('/')
@dashboard_bp.route('/index')
@login_required
def index():
    """Generic dashboard router — sends users to their role-specific dashboard."""
    if current_user.role == UserRole.FARMER:
        return redirect(url_for('dashboard.farmer'))
    elif current_user.role == UserRole.ADMIN:
        return redirect(url_for('admin.index'))
    elif current_user.role == UserRole.FEED_SUPPLIER:
        return redirect(url_for('supplier.dashboard'))
    elif current_user.role == UserRole.VETERINARIAN:
        return redirect(url_for('vet.dashboard'))
    else:
        return redirect(url_for('index'))


@dashboard_bp.route('/farmer')
@login_required
def farmer():
    """Farmer Dashboard — full farm overview with KPIs and activity."""
    guard = _require_role(UserRole.FARMER)
    if guard:
        return guard

    # Check Verification Status
    if not current_user.verification or current_user.verification.status != VerificationStatus.APPROVED:
        return render_template(
            'dashboard/farmer_verification_status.html',
            verification=current_user.verification
        )

    today = date.today()
    week_ago = today - timedelta(days=6)

    # Fetch farmer's farms
    farms = Farm.query.filter_by(farmer_id=current_user.id, is_active=True).all()
    all_farm_ids = [f.id for f in farms]

    selected_farm_id = request.args.get('farm_id', type=int, default=0)
    farm_ids = [selected_farm_id] if (selected_farm_id and selected_farm_id in all_farm_ids) else all_farm_ids

    # ── Month Filtering (Month selector or 'all') ────────────────────────────
    # Discover available record months from user's production & sales
    available_months_set = set()
    if all_farm_ids:
        prod_dates = ProductionRecord.query.with_entities(ProductionRecord.record_date).filter(
            ProductionRecord.farm_id.in_(all_farm_ids)
        ).all()
        for d in prod_dates:
            if d[0]: available_months_set.add(d[0].strftime('%Y-%m'))
            
        sales_dates = SalesRecord.query.with_entities(SalesRecord.sale_date).filter(
            SalesRecord.farm_id.in_(all_farm_ids)
        ).all()
        for d in sales_dates:
            if d[0]: available_months_set.add(d[0].strftime('%Y-%m'))

    # Always ensure current month is present
    available_months_set.add(today.strftime('%Y-%m'))
    available_months = sorted(list(available_months_set), reverse=True)

    # Default to current month if no filter specified, or respect 'all' / specific YYYY-MM
    selected_month = request.args.get('month', today.strftime('%Y-%m')).strip()
    
    is_all_time = (selected_month == 'all')
    period_start = None
    period_end = None
    period_label = 'All Time'

    if not is_all_time:
        try:
            parts = selected_month.split('-')
            y = int(parts[0])
            m = int(parts[1])
            _, last_day = monthrange(y, m)
            period_start = date(y, m, 1)
            period_end = date(y, m, last_day)
            period_label = period_start.strftime('%B %Y')
        except (ValueError, IndexError):
            # Fallback to current month
            selected_month = today.strftime('%Y-%m')
            period_start = today.replace(day=1)
            _, last_day = monthrange(today.year, today.month)
            period_end = date(today.year, today.month, last_day)
            period_label = period_start.strftime('%B %Y')

    # ── KPI: Total eggs (Filtered by selected month / all-time) ───────────────
    eggs_this_month = 0
    if farm_ids:
        query_eggs = ProductionRecord.query.with_entities(
            func.sum(ProductionRecord.egg_count)
        ).filter(ProductionRecord.farm_id.in_(farm_ids))
        if period_start and period_end:
            query_eggs = query_eggs.filter(
                ProductionRecord.record_date >= period_start,
                ProductionRecord.record_date <= period_end
            )
        eggs_this_month = query_eggs.scalar() or 0

    # ── KPI: Total expenses (Filtered) ───────────────────────────────────────
    expenses_this_month = _calculate_expenses(farm_ids, period_start, period_end)

    # ── KPI: Total Revenue & Profit (Filtered) ───────────────────────────────
    revenue_this_month = _calculate_revenue(farm_ids, period_start, period_end)
    profit_this_month = revenue_this_month - expenses_this_month

    # ── Chart: Daily egg production (Last 7 days or month daily trajectory) ──
    chart_labels = []
    chart_data = []
    
    if is_all_time:
        # For All-Time: show past 6 months aggregate
        for i in range(5, -1, -1):
            ref = today.replace(day=1)
            m = ref.month - i
            y = ref.year
            while m <= 0:
                m += 12
                y -= 1
            _, ld = monthrange(y, m)
            m_start = date(y, m, 1)
            m_end = date(y, m, ld)
            chart_labels.append(m_start.strftime('%b'))
            if farm_ids:
                m_eggs = ProductionRecord.query.with_entities(
                    func.sum(ProductionRecord.egg_count)
                ).filter(
                    ProductionRecord.farm_id.in_(farm_ids),
                    ProductionRecord.record_date >= m_start,
                    ProductionRecord.record_date <= m_end
                ).scalar() or 0
                chart_data.append(int(m_eggs))
            else:
                chart_data.append(0)
    else:
        # For Specific Month: show days of that month up to end/today
        end_day_num = period_end.day
        step = 1 if end_day_num <= 15 else 2
        for d in range(1, end_day_num + 1, step):
            day_dt = date(period_start.year, period_start.month, d)
            chart_labels.append(day_dt.strftime('%b %d'))
            if farm_ids:
                day_eggs = ProductionRecord.query.with_entities(
                    func.sum(ProductionRecord.egg_count)
                ).filter(
                    ProductionRecord.farm_id.in_(farm_ids),
                    ProductionRecord.record_date == day_dt,
                ).scalar() or 0
                chart_data.append(int(day_eggs))
            else:
                chart_data.append(0)

    # ── Recent production records (last 5) ───────────────────────────────────
    recent_records = []
    if farm_ids:
        rec_query = ProductionRecord.query.filter(ProductionRecord.farm_id.in_(farm_ids))
        if period_start and period_end:
            rec_query = rec_query.filter(
                ProductionRecord.record_date >= period_start,
                ProductionRecord.record_date <= period_end
            )
        recent_records = rec_query.order_by(ProductionRecord.record_date.desc()).limit(5).all()

    # Build farm lookup for display
    farm_map = {f.id: f.name for f in farms}
    market_intelligence = _build_market_intelligence(
        recent_records,
        expenses_this_month,
        len(farms),
        today,
    )

    # ── 6-month trend (revenue + expenses per month) ───────────────────────
    trend_labels   = []
    trend_revenue  = []
    trend_expenses = []

    for i in range(5, -1, -1):
        # Walk back i months from the reference
        ref = today.replace(day=1)
        m = ref.month - i
        y = ref.year
        while m <= 0:
            m += 12
            y -= 1
            
        _, last_day = monthrange(y, m)
        t_start = date(y, m, 1)
        t_end = date(y, m, last_day)
        
        label = date(y, m, 1).strftime('%b')
        trend_labels.append(label)

        rev = _calculate_revenue(farm_ids, t_start, t_end)
        exp = _calculate_expenses(farm_ids, t_start, t_end)

        trend_revenue.append(rev)
        trend_expenses.append(exp)

    return render_template(
        'dashboard/farmer_dashboard.html',
        title='Farmer Dashboard',
        farms=farms,
        farms_count=len(farms),
        eggs_this_month=eggs_this_month,
        expenses_this_month=expenses_this_month,
        chart_labels=chart_labels,
        chart_data=chart_data,
        recent_records=recent_records,
        farm_map=farm_map,
        market_intelligence=market_intelligence,
        revenue_this_month=revenue_this_month,
        profit_this_month=profit_this_month,
        trend_labels=trend_labels,
        trend_revenue=trend_revenue,
        trend_expenses=trend_expenses,
        today=today,
        selected_farm_id=selected_farm_id,
        selected_month=selected_month,
        period_label=period_label,
        available_months=available_months,
    )

@dashboard_bp.route('/notifications', methods=['GET', 'POST'])
@login_required
def notifications():
    if current_user.role == UserRole.FARMER and not current_user.is_premium:
        from flask import flash, redirect, url_for
        flash('Notifications are a Premium feature. Please upgrade your subscription to view them.', 'error')
        return redirect(url_for('dashboard.subscription'))
    from app.models import Notification
    from app import db
    
    if current_user.role != UserRole.FARMER:
        flash('Only farmers have access to this page.', 'error')
        return redirect(url_for('dashboard.index'))
        
    if request.method == 'POST':
        # Mark all as read
        current_user.notifications.filter_by(is_read=False, notif_type='order').update({'is_read': True})
        db.session.commit()
        flash('All notifications marked as read.', 'success')
        return redirect(url_for('dashboard.notifications'))
        
    # Mark viewed notifications as read when visited? The user might want to click them individually.
    
    notifs = current_user.notifications.filter_by(notif_type='order').order_by(Notification.created_at.desc()).all()
    
    # Check if a specific notification is clicked
    mark_read = request.args.get('read', type=int)
    if mark_read:
        notif = Notification.query.get(mark_read)
        if notif and notif.user_id == current_user.id:
            notif.is_read = True
            db.session.commit()
            if notif.link_url:
                return redirect(notif.link_url)
                
    return render_template('dashboard/notifications.html', title='Notifications', notifications=notifs)

@dashboard_bp.route('/subscription')
@login_required
def subscription():
    if current_user.role != UserRole.FARMER:
        return redirect(url_for('main.index'))
    return render_template('dashboard/subscription.html', title='Subscription', today=datetime.utcnow())

@dashboard_bp.route('/subscribe/<plan>', methods=['POST'])
@login_required
def subscribe_plan(plan):
    if current_user.role != UserRole.FARMER:
        return redirect(url_for('main.index'))
    
    from app.models import SubscriptionPlan
    
    if plan == 'monthly':
        current_user.subscription_plan = SubscriptionPlan.MONTHLY
        current_user.subscription_end = datetime.utcnow() + timedelta(days=30)
        flash('Successfully subscribed to Pro Monthly!', 'success')
    elif plan == 'yearly':
        current_user.subscription_plan = SubscriptionPlan.YEARLY
        current_user.subscription_end = datetime.utcnow() + timedelta(days=365)
        flash('Successfully subscribed to Pro Yearly!', 'success')
    else:
        flash('Invalid plan selected.', 'error')
        
    db.session.commit()
    return redirect(url_for('dashboard.subscription'))


ALLOWED_VERIFICATION_EXTENSIONS = {'png', 'jpg', 'jpeg', 'webp', 'pdf'}

def _allowed_verification_file(filename):
    return '.' in filename and filename.rsplit('.', 1)[1].lower() in ALLOWED_VERIFICATION_EXTENSIONS

@dashboard_bp.route('/farmer/submit-verification', methods=['POST'])
@login_required
def submit_verification():
    if current_user.role != UserRole.FARMER:
        return redirect(url_for('main.index'))

    # Form fields
    farm_name = request.form.get('farm_name', '').strip()
    farm_location = request.form.get('farm_location', '').strip()
    initial_flock_str = request.form.get('initial_flock_size', '').strip()
    id_type = request.form.get('id_type', '').strip()
    id_number = request.form.get('id_number', '').strip()
    permit_type = request.form.get('permit_type', '').strip()

    try:
        initial_flock_size = int(initial_flock_str) if initial_flock_str else 0
    except ValueError:
        initial_flock_size = 0

    if not farm_name or not farm_location or not id_type or not id_number or not permit_type:
        flash('Please complete all required fields and submit appropriate documents.', 'error')
        return redirect(url_for('dashboard.farmer'))

    verification = FarmerVerification.query.filter_by(farmer_id=current_user.id).first()
    if not verification:
        verification = FarmerVerification(farmer_id=current_user.id)
        db.session.add(verification)

    upload_dir = os.path.join('app', 'static', 'uploads', 'verifications')
    os.makedirs(upload_dir, exist_ok=True)

    # File uploads
    id_file = request.files.get('id_document')
    permit_file = request.files.get('permit_document')
    farm_file = request.files.get('farm_photo')

    timestamp = int(datetime.utcnow().timestamp())

    if id_file and id_file.filename and _allowed_verification_file(id_file.filename):
        ext = id_file.filename.rsplit('.', 1)[1].lower()
        id_filename = f'id_{current_user.id}_{timestamp}.{ext}'
        id_file.save(os.path.join(upload_dir, id_filename))
        verification.id_document_url = f'uploads/verifications/{id_filename}'
    elif not verification.id_document_url:
        flash('Valid Government ID document is required.', 'error')
        return redirect(url_for('dashboard.farmer'))

    if permit_file and permit_file.filename and _allowed_verification_file(permit_file.filename):
        ext = permit_file.filename.rsplit('.', 1)[1].lower()
        permit_filename = f'permit_{current_user.id}_{timestamp}.{ext}'
        permit_file.save(os.path.join(upload_dir, permit_filename))
        verification.permit_document_url = f'uploads/verifications/{permit_filename}'
    elif not verification.permit_document_url:
        flash('Farm permit / Barangay clearance document is required.', 'error')
        return redirect(url_for('dashboard.farmer'))

    if farm_file and farm_file.filename and _allowed_verification_file(farm_file.filename):
        ext = farm_file.filename.rsplit('.', 1)[1].lower()
        farm_filename = f'farm_{current_user.id}_{timestamp}.{ext}'
        farm_file.save(os.path.join(upload_dir, farm_filename))
        verification.farm_photo_url = f'uploads/verifications/{farm_filename}'

    verification.farm_name = farm_name
    verification.farm_location = farm_location
    verification.initial_flock_size = initial_flock_size
    verification.id_type = id_type
    verification.id_number = id_number
    verification.permit_type = permit_type
    verification.status = VerificationStatus.PENDING
    verification.rejection_reason = None
    verification.updated_at = datetime.utcnow()

    # Also automatically ensure user has their initial farm created or updated
    farm = Farm.query.filter_by(farmer_id=current_user.id).first()
    if not farm:
        farm = Farm(
            farmer_id=current_user.id,
            name=farm_name,
            location=farm_location,
            flock_size=initial_flock_size if initial_flock_size > 0 else 0,
            is_active=True
        )
        db.session.add(farm)
    else:
        farm.name = farm_name
        farm.location = farm_location
        if initial_flock_size > 0 and (not farm.flock_size or farm.flock_size == 0):
            farm.flock_size = initial_flock_size

    db.session.commit()
    flash('Requirements submitted successfully! Your application is now under review by an administrator.', 'success')
    return redirect(url_for('dashboard.farmer'))


@dashboard_bp.route('/resubmit-verification', methods=['GET', 'POST'])
@login_required
def resubmit_verification():
    # Helper to allow GET or redirect to dashboard.farmer
    return redirect(url_for('dashboard.farmer'))
