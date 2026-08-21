from flask import Blueprint, render_template, redirect, url_for, flash, request
from flask_login import login_required, current_user
from app.models import UserRole, Farm, ProductionRecord, Expense, SalesRecord, ExpenseFrequency, VerificationStatus, FarmerVerification
from datetime import date, timedelta, datetime
from sqlalchemy import func
from app import db
from decimal import Decimal
from calendar import monthrange

dashboard_bp = Blueprint('dashboard', __name__)

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

def _calculate_revenue(farm_ids, start_date, end_date):
    """Calculate revenue from SalesRecord."""
    if not farm_ids: return 0.0
    result = db.session.query(func.sum(SalesRecord.total_revenue)).filter(
        SalesRecord.farm_id.in_(farm_ids),
        SalesRecord.sale_date >= start_date,
        SalesRecord.sale_date <= end_date,
    ).scalar()
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
    month_start = today.replace(day=1)
    week_ago = today - timedelta(days=6)

    # Fetch farmer's farms
    farms = Farm.query.filter_by(farmer_id=current_user.id, is_active=True).all()
    farm_ids = [f.id for f in farms]

    selected_farm_id = request.args.get('farm_id', type=int, default=0)
    if selected_farm_id and selected_farm_id in farm_ids:
        farm_ids = [selected_farm_id]

    # ── KPI: Total eggs this month ────────────────────────────────────────────
    eggs_this_month = 0
    if farm_ids:
        result = ProductionRecord.query.with_entities(
            func.sum(ProductionRecord.egg_count)
        ).filter(
            ProductionRecord.farm_id.in_(farm_ids),
            ProductionRecord.record_date >= month_start,
            ProductionRecord.record_date <= today,
        ).scalar()
        eggs_this_month = result or 0

    # ── KPI: Total expenses this month ───────────────────────────────────────
    expenses_this_month = _calculate_expenses(farm_ids, month_start, today)

    # ── Chart: 7-day daily egg production ────────────────────────────────────
    chart_labels = []
    chart_data = []
    for i in range(6, -1, -1):
        day = today - timedelta(days=i)
        chart_labels.append(day.strftime('%b %d'))
        if farm_ids:
            day_eggs = ProductionRecord.query.with_entities(
                func.sum(ProductionRecord.egg_count)
            ).filter(
                ProductionRecord.farm_id.in_(farm_ids),
                ProductionRecord.record_date == day,
            ).scalar()
            chart_data.append(int(day_eggs or 0))
        else:
            chart_data.append(0)

    # ── Recent production records (last 5) ───────────────────────────────────
    recent_records = []
    if farm_ids:
        recent_records = ProductionRecord.query.filter(
            ProductionRecord.farm_id.in_(farm_ids)
        ).order_by(ProductionRecord.record_date.desc()).limit(5).all()

    # Build farm lookup for display
    farm_map = {f.id: f.name for f in farms}
    market_intelligence = _build_market_intelligence(
        recent_records,
        expenses_this_month,
        len(farms),
        today,
    )

    # ── KPI: Total Revenue & Profit ──────────────────────────────────────────
    revenue_this_month = _calculate_revenue(farm_ids, month_start, today)
            
    profit_this_month = revenue_this_month - expenses_this_month

    # ── 6-month trend (revenue + expenses per month) ───────────────────────
    trend_labels   = []
    trend_revenue  = []
    trend_expenses = []

    for i in range(5, -1, -1):
        # Walk back i months from the selected month
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
    )

@dashboard_bp.route('/notifications', methods=['GET', 'POST'])
@login_required
def notifications():
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

