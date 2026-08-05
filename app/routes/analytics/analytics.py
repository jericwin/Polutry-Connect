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
from app.models import Farm, ProductionRecord, Expense, SalesRecord, UserRole, ExpenseCategory, ExpenseFrequency

analytics_bp = Blueprint('analytics', __name__)

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
    farm_ids = _get_farm_ids()

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

    prev_link = url_for('analytics.index', year=prev_month_date.year, month=prev_month_date.month)
    next_link = url_for('analytics.index', year=next_month_date.year, month=next_month_date.month)
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
        result = db.session.query(
            func.sum(ProductionRecord.egg_count),
            func.sum(ProductionRecord.feed_kg),
            func.sum(ProductionRecord.mortality)
        ).filter(
            ProductionRecord.farm_id.in_(farm_ids),
            ProductionRecord.record_date >= month_start,
            ProductionRecord.record_date <= month_end,
        ).first()
        
        monthly_eggs = int(result[0] or 0) if result else 0
        monthly_feed_kg = float(result[1] or 0.0) if result else 0.0
        monthly_mortality = int(result[2] or 0) if result else 0

    # Calculate Feed Efficiency (grams of feed per egg)
    feed_efficiency = 0
    if monthly_eggs > 0 and monthly_feed_kg > 0:
        feed_efficiency = round((monthly_feed_kg * 1000) / monthly_eggs, 1)

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

    return render_template(
        'analytics/analytics.html',
        title='Analytics',

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

        farms=farms,
        today=today,
    )


@analytics_bp.route('/report/sales')
@login_required
def sales_report():
    """Generate Excel or PDF-printable HTML report for Sales."""
    _require_farmer()
    farm_ids = _get_farm_ids()
    if not farm_ids:
        flash('You have no registered farms.', 'error')
        return redirect(url_for('analytics.index'))

    start_date_str = request.args.get('start_date')
    end_date_str = request.args.get('end_date')
    format_type = request.args.get('format', 'pdf')
    
    query = SalesRecord.query.filter(SalesRecord.farm_id.in_(farm_ids))
    
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
            
    sales = query.order_by(SalesRecord.sale_date.desc()).all()
    
    total_qty = sum(s.quantity_sold for s in sales)
    total_rev = sum(s.total_revenue for s in sales)
    
    if format_type == 'excel':
        wb = openpyxl.Workbook()
        ws = wb.active
        ws.title = "Sales Report"
        
        header_fill = PatternFill(start_color="0D631B", end_color="0D631B", fill_type="solid")
        header_font = Font(color="FFFFFF", bold=True)
        
        headers = ["Date", "Farm", "Buyer", "Egg Type / Notes", "Quantity (Eggs)", "Price per Egg (PHP)", "Total Revenue (PHP)"]
        ws.append(headers)
        
        for col_num, cell in enumerate(ws[1], 1):
            cell.fill = header_fill
            cell.font = header_font
            cell.alignment = Alignment(horizontal="center")
            ws.column_dimensions[openpyxl.utils.get_column_letter(col_num)].width = 20
            
        for s in sales:
            ws.append([
                s.sale_date.strftime('%Y-%m-%d'),
                s.farm.name,
                s.buyer_name or 'Walk-in / Unknown',
                s.notes or '',
                s.quantity_sold,
                float(s.price_per_egg),
                float(s.total_revenue)
            ])
            
        ws.append([])
        ws.append(["TOTALS", "", "", "", total_qty, "", float(total_rev)])
        totals_row = ws.max_row
        for col_num in range(1, 8):
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
