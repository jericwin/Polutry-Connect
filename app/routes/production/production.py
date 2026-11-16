"""
Production Blueprint — PoultryConnect 2.0
Handles:
  - Farm registration and management  (GET/POST /production/farms)
  - Daily production log              (GET/POST /production/log)
  - Expense log                       (GET/POST /production/expenses)

Security practices:
  - @login_required on every route
  - Role guard: only FARMER can access
  - Ownership check: farmer can only see/edit their own farms & records
  - farm_id from POST is always re-validated against current_user
  - Input sanitised and typed before DB write
  - IntegrityError (duplicate production date) caught gracefully
  - No raw SQL — all via SQLAlchemy ORM
"""

from flask import (
    Blueprint, render_template, redirect, url_for,
    flash, request, abort
)
from flask_login import login_required, current_user
from sqlalchemy.exc import IntegrityError
from datetime import date, datetime
from decimal import Decimal, InvalidOperation

from app import db
from app.models import Farm, ProductionRecord, Expense, UserRole, ExpenseCategory, ExpenseFrequency, SalesRecord, ProductSize, ProductVariety, FeedRecord, FlockHistory, Product, VerificationStatus, MortalityRecord

production_bp = Blueprint('production', __name__)

@production_bp.before_request
def check_farmer_verification():
    if current_user.is_authenticated and current_user.role == UserRole.FARMER:
        if not current_user.verification or current_user.verification.status != VerificationStatus.APPROVED:
            flash('Your account is pending verification. Please wait for an administrator to approve your account before accessing owner features.', 'warning')
            return redirect(url_for('dashboard.farmer'))


# ─── helpers ────────────────────────────────────────────────────────────────

def _require_farmer():
    """Abort with 403 if the current user is not a farmer."""
    if current_user.role != UserRole.FARMER:
        abort(403)

def _require_premium():
    """Redirect to subscription if not premium."""
    if not current_user.is_premium:
        flash('This feature is exclusive to Pro members. Upgrade your account to unlock it.', 'error')
        # We raise a custom exception or abort to handle redirect in a clean way if not returning.
        # But wait, flask abort(403) is easier, or we can just return a redirect.
        # A helper that returns a redirect means the caller has to check and return it.
        # So we can't just call _require_premium() without handling the return.
        # Let's just do it directly or use before_request.



def _get_own_farm_or_404(farm_id: int) -> Farm:
    """
    Return the farm only if it belongs to current_user.
    Raises 404 if not found, 403 if wrong owner.
    """
    farm = Farm.query.get_or_404(farm_id)
    if farm.farmer_id != current_user.id:
        abort(403)
    return farm


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


def _parse_date(val) -> date | None:
    """Parse ISO date string; return None on failure."""
    try:
        return datetime.strptime(val, '%Y-%m-%d').date()
    except (ValueError, TypeError):
        return None


def _get_my_farms():
    """Return all active farms for the current farmer."""
    return Farm.query.filter_by(
        farmer_id=current_user.id, is_active=True
    ).order_by(Farm.name).all()


# ════════════════════════════════════════════════════════════════════════════
# FARM MANAGEMENT
# ════════════════════════════════════════════════════════════════════════════

@production_bp.route('/farms')
@login_required
def farms():
    """List all farms belonging to this farmer."""
    _require_farmer()
    my_farms = Farm.query.filter_by(
        farmer_id=current_user.id
    ).order_by(Farm.created_at.desc()).all()
    return render_template(
        'production/farms.html',
        title='My Farms',
        farms=my_farms,
    )


@production_bp.route('/farms/add', methods=['GET', 'POST'])
@login_required
def farm_add():
    """Register a new farm."""
    _require_farmer()
    
    if not current_user.is_premium:
        current_farm_count = Farm.query.filter_by(farmer_id=current_user.id).count()
        if current_farm_count >= 1:
            flash('Free tier is limited to 1 farm. Please upgrade to Premium to add more farms.', 'error')
            return redirect(url_for('dashboard.subscription'))


    if request.method == 'POST':
        name        = request.form.get('name', '').strip()
        location    = request.form.get('location', '').strip()
        description = request.form.get('description', '').strip()
        flock_size  = _safe_int(request.form.get('flock_size'), default=0)

        errors = []
        if not name:
            errors.append('Farm name is required.')
        if len(name) > 120:
            errors.append('Farm name must be 120 characters or fewer.')
        if flock_size < 0:
            errors.append('Flock size cannot be negative.')

        if errors:
            for e in errors:
                flash(e, 'error')
            return render_template(
                'production/farm_form.html',
                title='Add Farm', action='add',
                form_data=request.form,
            )

        farm = Farm(
            farmer_id=current_user.id,
            name=name,
            location=location or None,
            description=description or None,
            flock_size=flock_size,
            is_active=True,
        )
        db.session.add(farm)
        db.session.commit()
        flash(f'Farm "{farm.name}" registered successfully.', 'success')
        return redirect(url_for('production.farms'))

    return render_template(
        'production/farm_form.html',
        title='Add Farm', action='add',
        form_data={},
    )


@production_bp.route('/farms/<int:farm_id>/edit', methods=['GET', 'POST'])
@login_required
def farm_edit(farm_id: int):
    """Edit an existing farm."""
    _require_farmer()
    farm = _get_own_farm_or_404(farm_id)

    if request.method == 'POST':
        name        = request.form.get('name', '').strip()
        location    = request.form.get('location', '').strip()
        description = request.form.get('description', '').strip()
        flock_size  = _safe_int(request.form.get('flock_size'), default=farm.flock_size)

        errors = []
        if not name:
            errors.append('Farm name is required.')
        if len(name) > 120:
            errors.append('Farm name must be 120 characters or fewer.')
        if flock_size < 0:
            errors.append('Flock size cannot be negative.')

        if errors:
            for e in errors:
                flash(e, 'error')
            return render_template(
                'production/farm_form.html',
                title='Edit Farm', action='edit',
                farm=farm, form_data=request.form,
            )

        farm.name        = name
        farm.location    = location or None
        farm.description = description or None
        farm.flock_size  = flock_size
        db.session.commit()
        flash(f'Farm "{farm.name}" updated.', 'success')
        return redirect(url_for('production.farms'))

    return render_template(
        'production/farm_form.html',
        title='Edit Farm', action='edit',
        farm=farm, form_data={},
    )


@production_bp.route('/farms/<int:farm_id>/deactivate', methods=['POST'])
@login_required
def farm_deactivate(farm_id: int):
    """Soft-delete: mark farm as inactive."""
    _require_farmer()
    farm = _get_own_farm_or_404(farm_id)
    farm.is_active = False
    db.session.commit()
    flash(f'Farm "{farm.name}" has been deactivated.', 'success')
    return redirect(url_for('production.farms'))


# ════════════════════════════════════════════════════════════════════════════
# PRODUCTION LOG
# ════════════════════════════════════════════════════════════════════════════

@production_bp.route('/log')
@login_required
def log():
    """View all production records for this farmer."""
    _require_farmer()
    farms = _get_my_farms()
    farm_ids = [f.id for f in farms]
    farm_map = {f.id: f.name for f in farms}

    # Filter by farm if ?farm_id= provided
    selected_farm_id = _safe_int(request.args.get('farm_id'), default=0)
    query = ProductionRecord.query.filter(
        ProductionRecord.farm_id.in_(farm_ids)
    )
    if selected_farm_id and selected_farm_id in farm_ids:
        query = query.filter(ProductionRecord.farm_id == selected_farm_id)

    # Date range filters
    start_date_str = request.args.get('start_date')
    end_date_str = request.args.get('end_date')
    if start_date_str:
        try:
            query = query.filter(ProductionRecord.record_date >= datetime.strptime(start_date_str, '%Y-%m-%d').date())
        except ValueError:
            pass
    if end_date_str:
        try:
            query = query.filter(ProductionRecord.record_date <= datetime.strptime(end_date_str, '%Y-%m-%d').date())
        except ValueError:
            pass

    selected_variety = request.args.get('variety', '')
    selected_size = request.args.get('size', '')
    if selected_variety in {v for v, _ in EGG_VARIETIES}:
        query = query.filter(ProductionRecord.variety == ProductVariety(selected_variety))
    else:
        selected_variety = ''
    if selected_size in {s for s, _ in EGG_SIZES}:
        query = query.filter(ProductionRecord.size == ProductSize(selected_size))
    else:
        selected_size = ''

    records = query.order_by(ProductionRecord.record_date.desc(),
                             ProductionRecord.farm_id, ProductionRecord.id).limit(300).all()

    # Group by day: totals for brown / white and per size
    from collections import OrderedDict
    days = OrderedDict()
    for rec in records:
        d = days.setdefault(rec.record_date, {
            'date': rec.record_date, 'records': [], 'total': 0, 'brown': 0, 'white': 0,
            'sizes': OrderedDict((k, 0) for k, _ in EGG_SIZES), 'value': 0.0,
        })
        d['records'].append(rec)
        d['total'] += rec.egg_count or 0
        if rec.variety:
            d[rec.variety.value] += rec.egg_count or 0
        if rec.size:
            d['sizes'][rec.size.value] += rec.egg_count or 0
        d['value'] += rec.revenue
    day_groups = list(days.values())[:45]

    summary = {
        'total': sum(d['total'] for d in day_groups),
        'brown': sum(d['brown'] for d in day_groups),
        'white': sum(d['white'] for d in day_groups),
        'days': len(day_groups),
    }

    return render_template(
        'production/log.html',
        title='Production Log',
        farms=farms,
        farm_map=farm_map,
        records=records,
        day_groups=day_groups,
        summary=summary,
        sizes=EGG_SIZES,
        varieties=EGG_VARIETIES,
        selected_variety=selected_variety,
        selected_size=selected_size,
        selected_farm_id=selected_farm_id,
        start_date_str=start_date_str,
        end_date_str=end_date_str,
        today=date.today(),
    )


EGG_SIZES = [
    ('small', 'Small'), ('medium', 'Medium'), ('large', 'Large'),
    ('extra_large', 'Extra Large'), ('jumbo', 'Jumbo'),
]
EGG_VARIETIES = [('brown', 'Brown'), ('white', 'White')]
RECOMMENDED_EGG_PRICES = {
    'brown': {'small': 6.00, 'medium': 7.00, 'large': 8.00, 'extra_large': 9.00, 'jumbo': 10.00},
    'white': {'small': 5.50, 'medium': 6.50, 'large': 7.50, 'extra_large': 8.50, 'jumbo': 9.50},
}


def _last_prices(farm_ids):
    """Most recent selling price used per variety/size (falls back to recommended)."""
    prices = {v: dict(sizes) for v, sizes in RECOMMENDED_EGG_PRICES.items()}
    if not farm_ids:
        return prices
    recent = ProductionRecord.query.filter(
        ProductionRecord.farm_id.in_(farm_ids),
        ProductionRecord.egg_price.isnot(None),
    ).order_by(ProductionRecord.record_date.desc()).limit(200).all()
    seen = set()
    for r in recent:
        if not (r.variety and r.size):
            continue
        key = (r.variety.value, r.size.value)
        if key in seen:
            continue
        seen.add(key)
        prices.setdefault(key[0], {})[key[1]] = float(r.egg_price)
    return prices


@production_bp.route('/log/add', methods=['GET', 'POST'])
@login_required
def log_add():
    """Log a day's egg collection for ALL sizes and both varieties at once."""
    _require_farmer()
    farms = _get_my_farms()

    if not farms:
        flash('You need to register a farm before logging production data.', 'error')
        return redirect(url_for('production.farm_add'))

    farm_ids = [f.id for f in farms]
    ctx = dict(
        title='Log Production', action='add', farms=farms,
        sizes=EGG_SIZES, varieties=EGG_VARIETIES,
        last_prices=_last_prices(farm_ids), today=date.today(),
    )

    if request.method == 'POST':
        farm_id     = _safe_int(request.form.get('farm_id'))
        record_date = _parse_date(request.form.get('record_date'))
        notes       = request.form.get('notes', '').strip()

        errors = []
        if farm_id not in farm_ids:
            errors.append('Invalid farm selected.')
        if not record_date:
            errors.append('A valid date is required.')
        elif record_date > date.today():
            errors.append('Production date cannot be in the future.')

        entries = []
        for v_key, v_label in EGG_VARIETIES:
            for s_key, s_label in EGG_SIZES:
                count_raw = (request.form.get(f'count_{v_key}_{s_key}') or '').strip()
                if not count_raw:
                    continue
                count = _safe_int(count_raw, default=-1)
                if count < 0:
                    errors.append(f'{s_label} {v_label}: egg count must be a whole number of 0 or more.')
                    continue
                if count == 0:
                    continue
                price_raw = (request.form.get(f'price_{v_key}_{s_key}') or '').strip()
                price = _safe_decimal(price_raw) if price_raw else None
                if price is not None and price < 0:
                    errors.append(f'{s_label} {v_label}: price cannot be negative.')
                    continue
                entries.append((v_key, s_key, count, price))

        if not errors and not entries:
            errors.append('Enter the number of eggs collected for at least one size.')

        if errors:
            for e in errors:
                flash(e, 'error')
            return render_template('production/log_form.html', form_data=request.form, **ctx)

        saved, updated = 0, 0
        for v_key, s_key, count, price in entries:
            existing = ProductionRecord.query.filter_by(
                farm_id=farm_id, record_date=record_date,
                size=ProductSize(s_key), variety=ProductVariety(v_key),
            ).first()
            if existing:
                existing.egg_count = count
                if price is not None:
                    existing.egg_price = price
                if notes:
                    existing.notes = notes
                updated += 1
            else:
                db.session.add(ProductionRecord(
                    farm_id=farm_id, user_id=current_user.id, record_date=record_date,
                    egg_count=count, size=ProductSize(s_key), variety=ProductVariety(v_key),
                    egg_price=price, feed_kg=Decimal('0.00'), feed_cost=Decimal('0.00'),
                    mortality=0, notes=notes or None,
                ))
                saved += 1
        try:
            db.session.commit()
        except IntegrityError:
            db.session.rollback()
            flash('Could not save — a record for one of those sizes already exists for that date.', 'error')
            return render_template('production/log_form.html', form_data=request.form, **ctx)

        total = sum(e[2] for e in entries)
        msg = f'Saved {total:,} eggs across {len(entries)} size/variety entr{"y" if len(entries) == 1 else "ies"}.'
        if updated:
            msg += f' ({updated} existing entr{"y" if updated == 1 else "ies"} for that date updated.)'
        flash(msg, 'success')
        return redirect(url_for('production.log'))

    return render_template(
        'production/log_form.html',
        form_data={'record_date': date.today().isoformat(),
                   'farm_id': str(farms[0].id) if len(farms) == 1 else ''},
        **ctx,
    )


@production_bp.route('/log/<int:record_id>/edit', methods=['GET', 'POST'])
@login_required
def log_edit(record_id: int):
    """Edit an existing production record."""
    _require_farmer()
    record = ProductionRecord.query.get_or_404(record_id)

    # Ownership check via farm
    farm = _get_own_farm_or_404(record.farm_id)
    farms = _get_my_farms()

    if request.method == 'POST':
        egg_count = _safe_int(request.form.get('egg_count'), default=record.egg_count)
        feed_kg   = _safe_decimal(request.form.get('feed_kg'))
        feed_cost = _safe_decimal(request.form.get('feed_cost'))
        egg_price_raw = request.form.get('egg_price', '').strip()
        egg_price = _safe_decimal(egg_price_raw) if egg_price_raw else None
        mortality = _safe_int(request.form.get('mortality'), default=record.mortality)
        notes     = request.form.get('notes', '').strip()

        size_str    = request.form.get('size', '').strip()
        variety_str = request.form.get('variety', '').strip()
        size        = ProductSize(size_str) if size_str in {e.value for e in ProductSize} else None
        variety     = ProductVariety(variety_str) if variety_str in {e.value for e in ProductVariety} else None

        errors = []
        if egg_count < 0:
            errors.append('Egg count cannot be negative.')
        if feed_kg < 0:
            errors.append('Feed consumption cannot be negative.')
        if feed_cost < 0:
            errors.append('Feed cost cannot be negative.')
        if mortality < 0:
            errors.append('Mortality count cannot be negative.')

        if errors:
            for e in errors:
                flash(e, 'error')
            return render_template(
                'production/log_form.html',
                title='Edit Record', action='edit',
                farms=farms, record=record, form_data=request.form,
                today=date.today(),
            )

        record.egg_count = egg_count
        record.feed_kg   = feed_kg
        record.feed_cost = feed_cost
        record.egg_price = egg_price
        record.mortality = mortality
        record.notes     = notes or None
        record.size      = size
        record.variety   = variety
        try:
            db.session.commit()
        except IntegrityError:
            db.session.rollback()
            flash('Another record already exists for that size and variety on this date. Edit that one instead.', 'error')
            return redirect(url_for('production.log_edit', record_id=record.id))
        flash('Production record updated.', 'success')
        return redirect(url_for('production.log'))

    return render_template(
        'production/log_form.html',
        title='Edit Record', action='edit',
        farms=farms, record=record, form_data={},
        farm_map={f.id: f.name for f in farms},
        today=date.today(),
    )


@production_bp.route('/log/<int:record_id>/delete', methods=['POST'])
@login_required
def log_delete(record_id: int):
    """Delete a production record."""
    _require_farmer()
    record = ProductionRecord.query.get_or_404(record_id)
    _get_own_farm_or_404(record.farm_id)  # ownership check

    db.session.delete(record)
    db.session.commit()
    flash('Production record deleted.', 'success')
    return redirect(url_for('production.log'))


# ════════════════════════════════════════════════════════════════════════════
# TRANSACTIONS LOG
# ════════════════════════════════════════════════════════════════════════════

@production_bp.route('/transactions')
@login_required
def transactions():
    """Unified view of all sales (both online and on-site)."""
    _require_farmer()
    farms = _get_my_farms()
    farm_ids = [f.id for f in farms]
    farm_map = {f.id: f.name for f in farms}

    selected_farm_id = _safe_int(request.args.get('farm_id'), default=0)
    selected_type = request.args.get('type', '')
    start_date_str = request.args.get('start_date')
    end_date_str = request.args.get('end_date')

    query = SalesRecord.query.filter_by(user_id=current_user.id)

    if selected_farm_id and selected_farm_id in farm_ids:
        query = query.filter(SalesRecord.farm_id == selected_farm_id)

    if start_date_str:
        try:
            query = query.filter(SalesRecord.sale_date >= datetime.strptime(start_date_str, '%Y-%m-%d').date())
        except ValueError:
            pass
    if end_date_str:
        try:
            query = query.filter(SalesRecord.sale_date <= datetime.strptime(end_date_str, '%Y-%m-%d').date())
        except ValueError:
            pass
            
    sales = query.order_by(SalesRecord.sale_date.desc(), SalesRecord.created_at.desc()).all()
    
    # Filter by type (Online/On-site) in python since it relies on 'notes' content
    if selected_type == 'online':
        sales = [s for s in sales if s.notes and '(Order #' in s.notes]
    elif selected_type == 'onsite':
        sales = [s for s in sales if not s.notes or '(Order #' not in s.notes]

    # ── Period grouping (daily / weekly / monthly) ──
    from collections import OrderedDict
    from datetime import timedelta
    period = request.args.get('period', 'daily')
    if period not in ('daily', 'weekly', 'monthly'):
        period = 'daily'

    def period_key(d):
        if period == 'weekly':
            start = d - timedelta(days=d.weekday())
            return start, f"Week of {start.strftime('%b %d')} – {(start + timedelta(days=6)).strftime('%b %d, %Y')}"
        if period == 'monthly':
            start = d.replace(day=1)
            return start, start.strftime('%B %Y')
        return d, d.strftime('%A, %b %d, %Y')

    groups = OrderedDict()
    for sale in sales:
        key, label = period_key(sale.sale_date)
        g = groups.setdefault(key, {'label': label, 'sales': [], 'online': 0.0, 'onsite': 0.0,
                                    'online_count': 0, 'onsite_count': 0, 'total': 0.0})
        g['sales'].append(sale)
        amt = float(sale.total_revenue or 0)
        if sale.sale_type == 'Online':
            g['online'] += amt
            g['online_count'] += 1
        else:
            g['onsite'] += amt
            g['onsite_count'] += 1
        g['total'] += amt
    period_groups = list(groups.values())
    grand = {
        'online': sum(g['online'] for g in period_groups),
        'onsite': sum(g['onsite'] for g in period_groups),
        'total': sum(g['total'] for g in period_groups),
        'count': len(sales),
    }

    # Quick cards: today / this week / this month, split online vs on-site (ignores the type filter)
    all_sales = SalesRecord.query.filter_by(user_id=current_user.id)
    if selected_farm_id and selected_farm_id in farm_ids:
        all_sales = all_sales.filter(SalesRecord.farm_id == selected_farm_id)
    today_d = date.today()
    week_start = today_d - timedelta(days=today_d.weekday())
    month_start = today_d.replace(day=1)
    recent = all_sales.filter(SalesRecord.sale_date >= min(week_start, month_start)).all()

    def bucket(since):
        on = sum(float(x.total_revenue or 0) for x in recent if x.sale_date >= since and x.sale_type == 'Online')
        off = sum(float(x.total_revenue or 0) for x in recent if x.sale_date >= since and x.sale_type != 'Online')
        return {'online': on, 'onsite': off, 'total': on + off}

    quick = {'daily': bucket(today_d), 'weekly': bucket(week_start), 'monthly': bucket(month_start)}

    return render_template(
        'production/transactions.html',
        title='Transactions Log',
        sales=sales,
        period=period,
        period_groups=period_groups,
        grand=grand,
        quick=quick,
        farms=farms,
        selected_farm_id=selected_farm_id,
        selected_type=selected_type,
        start_date_str=start_date_str,
        end_date_str=end_date_str,
    )


# ════════════════════════════════════════════════════════════════════════════
# EXPENSE LOG
# ════════════════════════════════════════════════════════════════════════════

@production_bp.route('/expenses')
@login_required
def expenses():
    """View all expense records for this farmer."""
    _require_farmer()
    farms = _get_my_farms()
    farm_ids = [f.id for f in farms]
    farm_map = {f.id: f.name for f in farms}

    selected_farm_id = _safe_int(request.args.get('farm_id'), default=0)
    query = Expense.query.filter(Expense.farm_id.in_(farm_ids))
    if selected_farm_id and selected_farm_id in farm_ids:
        query = query.filter(Expense.farm_id == selected_farm_id)

    start_date_str = request.args.get('start_date')
    end_date_str = request.args.get('end_date')
    if start_date_str:
        try:
            query = query.filter(Expense.expense_date >= datetime.strptime(start_date_str, '%Y-%m-%d').date())
        except ValueError:
            pass
    if end_date_str:
        try:
            query = query.filter(Expense.expense_date <= datetime.strptime(end_date_str, '%Y-%m-%d').date())
        except ValueError:
            pass

    expense_records = query.order_by(Expense.expense_date.desc()).limit(60).all()

    return render_template(
        'production/expenses.html',
        title='Expense Log',
        farms=farms,
        farm_map=farm_map,
        expenses=expense_records,
        selected_farm_id=selected_farm_id,
        start_date_str=start_date_str,
        end_date_str=end_date_str,
        categories=ExpenseCategory,
        today=date.today(),
        ExpenseFrequency=ExpenseFrequency,
    )


@production_bp.route('/expenses/add', methods=['GET', 'POST'])
@login_required
def expense_add():
    """Log a new expense."""
    _require_farmer()
    farms = _get_my_farms()

    if not farms:
        flash('You need to register a farm before logging expenses.', 'error')
        return redirect(url_for('production.farm_add'))

    if request.method == 'POST':
        farm_id      = _safe_int(request.form.get('farm_id'))
        expense_date = _parse_date(request.form.get('expense_date'))
        category_str = request.form.get('category', '').strip().lower()
        amount       = _safe_decimal(request.form.get('amount'))
        description  = request.form.get('description', '').strip()

        errors = []
        farm_ids = [f.id for f in farms]
        valid_categories = {e.value for e in ExpenseCategory}

        if farm_id not in farm_ids:
            errors.append('Invalid farm selected.')
        if not expense_date:
            errors.append('A valid date is required.')
        elif expense_date > date.today():
            errors.append('Expense date cannot be in the future.')
        if category_str not in valid_categories:
            errors.append('Please select a valid expense category.')
        if amount <= 0:
            errors.append('Amount must be greater than zero.')

        if errors:
            for e in errors:
                flash(e, 'error')
            return render_template(
                'production/expense_form.html',
                title='Log Expense', action='add',
                farms=farms, form_data=request.form,
                categories=ExpenseCategory, today=date.today(),
            )

        frequency_str = request.form.get('frequency', 'one_time').strip().lower()
        valid_frequencies = {e.value for e in ExpenseFrequency}
        if frequency_str not in valid_frequencies:
            frequency_str = 'one_time'

        expense = Expense(
            farm_id=farm_id,
            user_id=current_user.id,
            expense_date=expense_date,
            category=ExpenseCategory(category_str),
            frequency=ExpenseFrequency(frequency_str),
            amount=amount,
            description=description or None,
        )
        db.session.add(expense)
        db.session.commit()
        flash('Expense recorded.', 'success')
        return redirect(url_for('production.expenses'))

    return render_template(
        'production/expense_form.html',
        title='Log Expense', action='add',
        farms=farms, form_data={'expense_date': date.today().isoformat()},
        categories=ExpenseCategory, today=date.today(),
        ExpenseFrequency=ExpenseFrequency,
    )


@production_bp.route('/expenses/<int:expense_id>/edit', methods=['GET', 'POST'])
@login_required
def expense_edit(expense_id: int):
    """Edit an existing expense."""
    _require_farmer()
    expense = Expense.query.get_or_404(expense_id)
    _get_own_farm_or_404(expense.farm_id)  # ownership
    farms = _get_my_farms()
    valid_categories = {e.value for e in ExpenseCategory}

    if request.method == 'POST':
        category_str = request.form.get('category', '').strip().lower()
        frequency_str = request.form.get('frequency', 'one_time').strip().lower()
        amount       = _safe_decimal(request.form.get('amount'))
        description  = request.form.get('description', '').strip()

        errors = []
        valid_frequencies = {e.value for e in ExpenseFrequency}
        if category_str not in valid_categories:
            errors.append('Please select a valid expense category.')
        if frequency_str not in valid_frequencies:
            frequency_str = 'one_time'
        if amount <= 0:
            errors.append('Amount must be greater than zero.')

        if errors:
            for e in errors:
                flash(e, 'error')
            return render_template(
                'production/expense_form.html',
                title='Edit Expense', action='edit',
                farms=farms, expense=expense, form_data=request.form,
                categories=ExpenseCategory, today=date.today(),
                ExpenseFrequency=ExpenseFrequency,
            )

        expense.category    = ExpenseCategory(category_str)
        expense.frequency   = ExpenseFrequency(frequency_str)
        expense.amount      = amount
        expense.description = description or None
        db.session.commit()
        flash('Expense updated.', 'success')
        return redirect(url_for('production.expenses'))

    return render_template(
        'production/expense_form.html',
        title='Edit Expense', action='edit',
        farms=farms, expense=expense, form_data={},
        farm_map={f.id: f.name for f in farms},
        categories=ExpenseCategory, today=date.today(),
        ExpenseFrequency=ExpenseFrequency,
    )


@production_bp.route('/expenses/<int:expense_id>/delete', methods=['POST'])
@login_required
def expense_delete(expense_id: int):
    """Delete an expense record."""
    _require_farmer()
    expense = Expense.query.get_or_404(expense_id)
    _get_own_farm_or_404(expense.farm_id)  # ownership

    db.session.delete(expense)
    db.session.commit()
    flash('Expense deleted.', 'success')
    return redirect(url_for('production.expenses'))


# ════════════════════════════════════════════════════════════════════════════
# Quick-log from Dashboard (POST from dashboard widget)
# ════════════════════════════════════════════════════════════════════════════

@production_bp.route('/quick-log', methods=['POST'])
@login_required
def quick_log():
    """
    Receives the quick-log form submitted from the farmer dashboard widget.
    Redirects back to dashboard with a flash message.
    """
    _require_farmer()
    farms = _get_my_farms()
    farm_ids = [f.id for f in farms]

    farm_id     = _safe_int(request.form.get('farm_id'))
    record_date = _parse_date(request.form.get('record_date'))
    egg_count   = _safe_int(request.form.get('egg_count'), default=0)
    feed_kg     = _safe_decimal(request.form.get('feed_kg'))
    mortality   = _safe_int(request.form.get('mortality'), default=0)

    # Basic validation
    if farm_id not in farm_ids:
        flash('Invalid farm selected.', 'error')
        return redirect(url_for('dashboard.farmer'))
    if not record_date or record_date > date.today():
        flash('Invalid production date.', 'error')
        return redirect(url_for('dashboard.farmer'))
    if egg_count < 0 or mortality < 0 or feed_kg < 0:
        flash('Values cannot be negative.', 'error')
        return redirect(url_for('dashboard.farmer'))

    record = ProductionRecord(
        farm_id=farm_id,
        user_id=current_user.id,
        record_date=record_date,
        egg_count=egg_count,
        feed_kg=feed_kg,
        feed_cost=Decimal('0.00'),
        mortality=mortality,
    )
    db.session.add(record)
    try:
        db.session.commit()
        flash('Daily log saved successfully.', 'success')
    except IntegrityError:
        db.session.rollback()
        flash(
            'A record for that farm on that date already exists. '
            'Visit the Production Log to edit it.',
            'error'
        )
    return redirect(url_for('dashboard.farmer'))

# ════════════════════════════════════════════════════════════════════════════
# SALES LOG
# ════════════════════════════════════════════════════════════════════════════

@production_bp.route('/sales/add', methods=['POST'])
@login_required
def sales_add():
    """Log a sale quickly from dashboard."""
    _require_farmer()
    farms = _get_my_farms()
    farm_ids = [f.id for f in farms]

    farm_id        = _safe_int(request.form.get('farm_id'))
    sale_date      = _parse_date(request.form.get('sale_date'))
    quantity_sold  = _safe_int(request.form.get('quantity_sold'))
    price_per_egg  = _safe_decimal(request.form.get('price_per_egg'))
    buyer_name     = request.form.get('buyer_name', '').strip()
    notes          = request.form.get('notes', '').strip()

    if farm_id not in farm_ids:
        flash('Invalid farm selected.', 'error')
        return redirect(url_for('dashboard.farmer'))
    if not sale_date or sale_date > date.today():
        flash('Invalid sale date.', 'error')
        return redirect(url_for('dashboard.farmer'))
    if quantity_sold <= 0 or price_per_egg <= 0:
        flash('Quantity and price must be greater than zero.', 'error')
        return redirect(url_for('dashboard.farmer'))

    total_revenue = Decimal(quantity_sold) * price_per_egg

    sale = SalesRecord(
        farm_id=farm_id,
        user_id=current_user.id,
        sale_date=sale_date,
        quantity_sold=quantity_sold,
        price_per_egg=price_per_egg,
        total_revenue=total_revenue,
        buyer_name=buyer_name or None,
        notes=notes or None,
    )
    db.session.add(sale)
    db.session.commit()
    flash('Sale logged successfully.', 'success')
    return redirect(url_for('dashboard.farmer'))

@production_bp.route('/sales/onsite/add', methods=['GET', 'POST'])
@login_required
def onsite_sales_add():
    """Log an on-site sale, deducting product stock and creating a SalesRecord."""
    _require_farmer()
    farms = _get_my_farms()
    farm_ids = [f.id for f in farms]

    if not farms:
        flash('You need to register a farm before logging sales.', 'error')
        return redirect(url_for('production.farm_add'))

    products = Product.query.filter(Product.farm_id.in_(farm_ids), Product.is_available==True, Product.stock > 0).all()

    if request.method == 'POST':
        product_id     = _safe_int(request.form.get('product_id'))
        sale_date      = _parse_date(request.form.get('sale_date'))
        quantity_sold  = _safe_int(request.form.get('quantity_sold'))
        price_input    = _safe_decimal(request.form.get('price_per_egg'))
        buyer_name     = request.form.get('buyer_name', '').strip()
        notes          = request.form.get('notes', '').strip()

        errors = []
        product = Product.query.get(product_id)
        if not product or product.farm_id not in farm_ids:
            errors.append('Invalid product selected.')
        if not sale_date or sale_date > date.today():
            errors.append('Invalid sale date.')
        if quantity_sold <= 0:
            errors.append('Quantity must be greater than zero.')
        elif product and quantity_sold > product.stock:
            errors.append(f'Not enough stock. Only {product.stock} available for {product.name}.')

        price_per_egg = price_input if (price_input and price_input > 0) else (product.price if product else Decimal(0))
        if price_per_egg <= 0:
            errors.append('Amount per pcs/tray must be greater than zero.')

        if errors:
            for e in errors:
                flash(e, 'error')
            return render_template(
                'production/onsite_sale_form.html',
                title='Log On-site Sale',
                farms=farms,
                products=products,
                form_data=request.form,
                today=date.today(),
            )

        total_revenue = Decimal(quantity_sold) * price_per_egg
        product.stock -= quantity_sold

        unit_str = product.unit.value.title() if hasattr(product.unit, 'value') else str(product.unit).title()
        size_str = product.size.value.title() if hasattr(product.size, 'value') else str(product.size).title()
        detail_note = f"Product: {product.name} | Size: {size_str} | Unit: {unit_str}"
        full_notes = f"{detail_note}. {notes}" if notes else detail_note

        sale = SalesRecord(
            farm_id=product.farm_id,
            user_id=current_user.id,
            sale_date=sale_date,
            quantity_sold=quantity_sold,
            price_per_egg=price_per_egg,
            total_revenue=total_revenue,
            buyer_name=buyer_name or None,
            notes=full_notes,
        )
        db.session.add(sale)
        db.session.commit()
        flash('On-site sale logged successfully. Stock deducted.', 'success')
        return redirect(url_for('production.transactions'))

    return render_template(
        'production/onsite_sale_form.html',
        title='Log On-site Sale',
        farms=farms,
        products=products,
        form_data={'sale_date': date.today().isoformat()},
        today=date.today(),
    )

# ════════════════════════════════════════════════════════════════════════════
# FEED LOG
# ════════════════════════════════════════════════════════════════════════════

@production_bp.route('/feed')
@login_required
def feed():
    """View all feed records."""
    _require_farmer()
    if not current_user.is_premium:
        flash('Tracking feed consumption is a Pro feature. Upgrade your account to unlock this tool.', 'error')
        return redirect(url_for('dashboard.subscription'))
    farms = _get_my_farms()
    farm_ids = [f.id for f in farms]
    farm_map = {f.id: f.name for f in farms}

    selected_farm_id = _safe_int(request.args.get('farm_id'), default=0)
    query = FeedRecord.query.filter(FeedRecord.farm_id.in_(farm_ids))
    if selected_farm_id and selected_farm_id in farm_ids:
        query = query.filter(FeedRecord.farm_id == selected_farm_id)

    start_date_str = request.args.get('start_date')
    end_date_str = request.args.get('end_date')
    if start_date_str:
        try:
            query = query.filter(FeedRecord.record_date >= datetime.strptime(start_date_str, '%Y-%m-%d').date())
        except ValueError:
            pass
    if end_date_str:
        try:
            query = query.filter(FeedRecord.record_date <= datetime.strptime(end_date_str, '%Y-%m-%d').date())
        except ValueError:
            pass

    records = query.order_by(FeedRecord.record_date.desc(), FeedRecord.id).limit(200).all()

    from collections import OrderedDict
    days = OrderedDict()
    for rec in records:
        d = days.setdefault(rec.record_date, {'date': rec.record_date, 'records': [], 'kg': 0.0, 'cost': 0.0})
        d['records'].append(rec)
        d['kg'] += float(rec.feed_consumed_kg or 0)
        d['cost'] += float(rec.feed_cost or 0)
    feed_types = sorted({r.feed_type for r in FeedRecord.query.filter(FeedRecord.farm_id.in_(farm_ids)).all()} |
                        {'Layer Mash', 'Grower Mash', 'Starter Mash', 'Layer Pellets'})

    return render_template(
        'production/feed_log.html',
        day_groups=list(days.values()),
        feed_types=feed_types,
        farms=farms,
        farm_map=farm_map,
        records=records,
        selected_farm_id=selected_farm_id,
        start_date_str=start_date_str,
        end_date_str=end_date_str,
        today=date.today(),
    )

@production_bp.route('/feed/add', methods=['POST'])
@login_required
def feed_add():
    """Add a feed record."""
    _require_farmer()
    if not current_user.is_premium:
        flash('Tracking feed consumption is a Pro feature. Upgrade your account to unlock this tool.', 'error')
        return redirect(url_for('dashboard.subscription'))
    farms = _get_my_farms()
    farm_ids = [f.id for f in farms]

    farm_id = _safe_int(request.form.get('farm_id'))
    record_date = _parse_date(request.form.get('record_date'))
    notes = request.form.get('notes', '').strip()

    if farm_id not in farm_ids:
        flash('Invalid farm selected.', 'error')
        return redirect(url_for('production.feed'))
    if not record_date or record_date > date.today():
        flash('A valid date (not in the future) is required.', 'error')
        return redirect(url_for('production.feed'))

    # One row per feed type — the form can send several (feed_type[] / feed_consumed_kg[] / feed_cost[])
    types = request.form.getlist('feed_type')
    kgs = request.form.getlist('feed_consumed_kg')
    costs = request.form.getlist('feed_cost')
    rows = []
    for i, ftype in enumerate(types):
        ftype = (ftype or '').strip()[:100]
        kg = _safe_decimal(kgs[i] if i < len(kgs) else None)
        cost = _safe_decimal(costs[i] if i < len(costs) else None)
        if not ftype and kg == 0 and cost == 0:
            continue  # empty row
        if not ftype:
            flash(f'Row {i + 1}: please enter the feed type.', 'error')
            return redirect(url_for('production.feed'))
        if kg <= 0:
            flash(f'{ftype}: amount consumed must be greater than 0 kg.', 'error')
            return redirect(url_for('production.feed'))
        if cost < 0:
            flash(f'{ftype}: cost cannot be negative.', 'error')
            return redirect(url_for('production.feed'))
        rows.append((ftype, kg, cost))

    if not rows:
        flash('Add at least one feed type with the amount consumed.', 'error')
        return redirect(url_for('production.feed'))

    for ftype, kg, cost in rows:
        db.session.add(FeedRecord(
            farm_id=farm_id,
            user_id=current_user.id,
            record_date=record_date,
            feed_type=ftype,
            feed_consumed_kg=kg,
            feed_cost=cost,
            notes=notes or None,
        ))
    db.session.commit()
    total_kg = sum(r[1] for r in rows)
    total_cost = sum(r[2] for r in rows)
    flash(f'Saved {len(rows)} feed type{"s" if len(rows) != 1 else ""}: {total_kg:,.1f} kg, ₱{total_cost:,.2f} total.', 'success')
    return redirect(url_for('production.feed', farm_id=farm_id))


@production_bp.route('/feed/<int:record_id>/delete', methods=['POST'])
@login_required
def feed_delete(record_id: int):
    """Delete a feed record."""
    _require_farmer()
    rec = FeedRecord.query.get_or_404(record_id)
    _get_own_farm_or_404(rec.farm_id)
    db.session.delete(rec)
    db.session.commit()
    flash('Feed record deleted.', 'success')
    return redirect(url_for('production.feed'))

# ════════════════════════════════════════════════════════════════════════════
# MORTALITY LOG (FLOCK HISTORY)
# ════════════════════════════════════════════════════════════════════════════

@production_bp.route('/mortality')
@login_required
def mortality():
    """View all flock history/mortality records."""
    _require_farmer()
    if not current_user.is_premium:
        flash('Mortality tracking is a Pro feature. Upgrade your account to unlock this tool.', 'error')
        return redirect(url_for('dashboard.subscription'))
    farms = _get_my_farms()
    farm_ids = [f.id for f in farms]
    farm_map = {f.id: f.name for f in farms}

    _ensure_initial_flock(farms)

    selected_farm_id = _safe_int(request.args.get('farm_id'), default=0)
    query = FlockHistory.query.filter(FlockHistory.farm_id.in_(farm_ids))
    if selected_farm_id and selected_farm_id in farm_ids:
        query = query.filter(FlockHistory.farm_id == selected_farm_id)

    start_date_str = request.args.get('start_date')
    end_date_str = request.args.get('end_date')
    if start_date_str:
        try:
            query = query.filter(FlockHistory.date >= datetime.strptime(start_date_str, '%Y-%m-%d').date())
        except ValueError:
            pass
    if end_date_str:
        try:
            query = query.filter(FlockHistory.date <= datetime.strptime(end_date_str, '%Y-%m-%d').date())
        except ValueError:
            pass

    records = query.order_by(FlockHistory.date.desc(), FlockHistory.id.desc()).limit(200).all()

    # Precompute running flock size for each record per farm
    # Chronological cumulative sum of quantity per farm
    all_farm_history = FlockHistory.query.filter(FlockHistory.farm_id.in_(farm_ids))\
        .order_by(FlockHistory.farm_id, FlockHistory.date.asc(), FlockHistory.id.asc()).all()
    running_flock_map = {}
    farm_running = {}
    for entry in all_farm_history:
        farm_running[entry.farm_id] = farm_running.get(entry.farm_id, 0) + entry.quantity
        running_flock_map[entry.id] = farm_running[entry.farm_id]

    # Current flock sizes for modal/card
    farm_flock_map = {f.id: f.flock_size for f in farms}
    total_current_flock = sum(f.flock_size for f in farms)

    # Summary: original flock, birds added, birds died (per selection)
    scope = [h for h in all_farm_history if not selected_farm_id or h.farm_id == selected_farm_id]
    initial_entries = [h for h in scope if h.change_type == 'initial']
    flock_summary = {
        'original': sum(h.quantity for h in initial_entries),
        'original_date': min((h.date for h in initial_entries), default=None),
        'added': sum(h.quantity for h in scope if h.quantity > 0 and h.change_type != 'initial'),
        'died': -sum(h.quantity for h in scope if h.quantity < 0),
    }
    flock_summary['current'] = flock_summary['original'] + flock_summary['added'] - flock_summary['died']
    flock_summary['mortality_rate'] = round(flock_summary['died'] * 100.0 / flock_summary['original'], 2) \
        if flock_summary['original'] else 0

    return render_template(
        'production/mortality_log.html',
        farms=farms,
        farm_map=farm_map,
        farm_flock_map=farm_flock_map,
        total_current_flock=total_current_flock,
        running_flock_map=running_flock_map,
        flock_summary=flock_summary,
        records=records,
        selected_farm_id=selected_farm_id,
        start_date_str=start_date_str,
        end_date_str=end_date_str,
        today=date.today(),
    )


def _ensure_initial_flock(farms):
    """Every farm needs an 'initial' FlockHistory row so the original flock size and date are visible."""
    changed = False
    for farm in farms:
        has_initial = FlockHistory.query.filter_by(farm_id=farm.id, change_type='initial').first()
        if has_initial:
            continue
        net = db.session.query(db.func.coalesce(db.func.sum(FlockHistory.quantity), 0)) \
            .filter(FlockHistory.farm_id == farm.id).scalar() or 0
        original = max(0, (farm.flock_size or 0) - int(net))
        first = FlockHistory.query.filter_by(farm_id=farm.id).order_by(FlockHistory.date.asc()).first()
        start = farm.created_at.date() if farm.created_at else date.today()
        if first and first.date < start:
            start = first.date
        db.session.add(FlockHistory(farm_id=farm.id, user_id=farm.farmer_id, date=start,
                                    change_type='initial', quantity=original,
                                    notes='Original flock size when the farm was registered.'))
        changed = True
    if changed:
        db.session.commit()


@production_bp.route('/flock/add', methods=['POST'])
@login_required
def flock_add():
    """Record new birds added to a farm (e.g. a new batch of pullets)."""
    _require_farmer()
    if not current_user.is_premium:
        flash('Flock tracking is a Pro feature. Upgrade your account to unlock this tool.', 'error')
        return redirect(url_for('dashboard.subscription'))
    farms = _get_my_farms()
    farm_ids = [f.id for f in farms]

    farm_id = _safe_int(request.form.get('farm_id'))
    record_date = _parse_date(request.form.get('date'))
    quantity = _safe_int(request.form.get('quantity'))
    notes = request.form.get('notes', '').strip()

    if farm_id not in farm_ids:
        flash('Invalid farm selected.', 'error')
        return redirect(url_for('production.mortality'))
    if not record_date or record_date > date.today():
        flash('A valid date (not in the future) is required.', 'error')
        return redirect(url_for('production.mortality'))
    if quantity <= 0:
        flash('Number of birds added must be greater than zero.', 'error')
        return redirect(url_for('production.mortality'))

    farm = db.session.get(Farm, farm_id)
    _ensure_initial_flock([farm])
    db.session.add(FlockHistory(farm_id=farm_id, user_id=current_user.id, date=record_date,
                                change_type='added', quantity=quantity, notes=notes or None))
    farm.flock_size = (farm.flock_size or 0) + quantity
    db.session.commit()
    flash(f'Added {quantity:,} birds. New flock size is {farm.flock_size:,}.', 'success')
    return redirect(url_for('production.mortality', farm_id=farm_id))


@production_bp.route('/mortality/add', methods=['POST'])
@login_required
def mortality_add():
    """Add a flock history record."""
    _require_farmer()
    if not current_user.is_premium:
        flash('Mortality tracking is a Pro feature. Upgrade your account to unlock this tool.', 'error')
        return redirect(url_for('dashboard.subscription'))
    farms = _get_my_farms()
    farm_ids = [f.id for f in farms]

    farm_id = _safe_int(request.form.get('farm_id'))
    record_date = _parse_date(request.form.get('date'))
    change_type = request.form.get('change_type', '').strip() or 'mortality'
    quantity = _safe_int(request.form.get('quantity'))
    notes = request.form.get('notes', '').strip()

    if farm_id not in farm_ids:
        flash('Invalid farm selected.', 'error')
        return redirect(url_for('production.mortality'))
    if not record_date:
        flash('A valid date is required.', 'error')
        return redirect(url_for('production.mortality'))
    if quantity <= 0:
        flash('Birds died count must be greater than zero.', 'error')
        return redirect(url_for('production.mortality'))

    target_farm = db.session.get(Farm, farm_id)
    if not target_farm:
        flash('Selected farm not found.', 'error')
        return redirect(url_for('production.mortality'))
    _ensure_initial_flock([target_farm])

    # Store negative quantity in FlockHistory for mortality/reduction
    # Deduct from current flock size of the farm
    record = FlockHistory(
        farm_id=farm_id,
        user_id=current_user.id,
        date=record_date,
        change_type=change_type,
        quantity=-quantity,
        notes=notes or None
    )
    target_farm.flock_size = max(0, (target_farm.flock_size or 0) - quantity)

    # Also keep the MortalityRecord table in sync (used by Analytics)
    db.session.add(MortalityRecord(
        farm_id=farm_id, user_id=current_user.id, record_date=record_date,
        quantity_died=quantity, reason=change_type[:255], notes=notes or None,
    ))
    db.session.add(record)
    db.session.commit()
    flash(f'Mortality logged: {quantity} birds recorded. New flock size is {target_farm.flock_size:,}.', 'success')
    return redirect(url_for('production.mortality', farm_id=farm_id))
