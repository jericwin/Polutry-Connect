import sys

with open('app/routes/production/production.py', 'r', encoding='utf-8') as f:
    content = f.read()

# 1. Imports
content = content.replace(
    "from app.models import Farm, ProductionRecord, Expense, UserRole, ExpenseCategory, ExpenseFrequency, SalesRecord, ProductSize, ProductVariety",
    "from app.models import Farm, ProductionRecord, Expense, UserRole, ExpenseCategory, ExpenseFrequency, SalesRecord, ProductSize, ProductVariety, FlockHistory"
)

# 2. farm_add
farm_add_orig = """        farm = Farm(
            farmer_id=current_user.id,
            name=name,
            location=location or None,
            description=description or None,
            flock_size=flock_size,
            is_active=True,
        )
        db.session.add(farm)
        db.session.commit()"""
farm_add_new = """        farm = Farm(
            farmer_id=current_user.id,
            name=name,
            location=location or None,
            description=description or None,
            flock_size=flock_size,
            is_active=True,
        )
        db.session.add(farm)
        db.session.flush()
        if flock_size > 0:
            db.session.add(FlockHistory(
                farm_id=farm.id, user_id=current_user.id, date=date.today(),
                change_type='initial', quantity=flock_size, notes="Initial flock setup."
            ))
        db.session.commit()"""
content = content.replace(farm_add_orig, farm_add_new)

# 3. farm_edit
farm_edit_orig = """        farm.name        = name
        farm.location    = location or None
        farm.description = description or None
        farm.flock_size  = flock_size
        db.session.commit()"""
farm_edit_new = """        diff = flock_size - farm.flock_size
        if diff != 0:
            db.session.add(FlockHistory(
                farm_id=farm.id, user_id=current_user.id, date=date.today(),
                change_type='correction', quantity=diff, notes="Manual flock size update."
            ))

        farm.name        = name
        farm.location    = location or None
        farm.description = description or None
        farm.flock_size  = flock_size
        db.session.commit()"""
content = content.replace(farm_edit_orig, farm_edit_new)

# 4. log_add
log_add_orig = """        record = ProductionRecord(
            farm_id=farm_id,
            user_id=current_user.id,
            record_date=record_date,
            egg_count=egg_count,
            feed_kg=feed_kg,
            feed_cost=feed_cost,
            egg_price=egg_price,
            mortality=mortality,
            notes=notes or None,
            size=size,
            variety=variety,
        )
        db.session.add(record)
        try:
            db.session.commit()"""
log_add_new = """        record = ProductionRecord(
            farm_id=farm_id,
            user_id=current_user.id,
            record_date=record_date,
            egg_count=egg_count,
            feed_kg=feed_kg,
            feed_cost=feed_cost,
            egg_price=egg_price,
            mortality=mortality,
            notes=notes or None,
            size=size,
            variety=variety,
        )
        db.session.add(record)
        
        farm = Farm.query.get(farm_id)
        if mortality > 0 and farm:
            farm.flock_size = max(0, farm.flock_size - mortality)
            db.session.add(FlockHistory(
                farm_id=farm_id, user_id=current_user.id, date=record_date,
                change_type='mortality', quantity=-mortality, notes="Recorded in daily log."
            ))
            
        try:
            db.session.commit()"""
content = content.replace(log_add_orig, log_add_new)

# 5. log_edit
log_edit_orig = """        record.egg_count = egg_count
        record.feed_kg   = feed_kg
        record.feed_cost = feed_cost
        record.egg_price = egg_price
        record.mortality = mortality
        record.notes     = notes or None
        record.size      = size
        record.variety   = variety
        db.session.commit()"""
log_edit_new = """        old_mortality = record.mortality
        
        record.egg_count = egg_count
        record.feed_kg   = feed_kg
        record.feed_cost = feed_cost
        record.egg_price = egg_price
        record.mortality = mortality
        record.notes     = notes or None
        record.size      = size
        record.variety   = variety
        
        mortality_diff = mortality - old_mortality
        if mortality_diff != 0:
            farm = Farm.query.get(record.farm_id)
            if farm:
                farm.flock_size = max(0, farm.flock_size - mortality_diff)
                db.session.add(FlockHistory(
                    farm_id=farm.id, user_id=current_user.id, date=record.record_date,
                    change_type='mortality' if mortality_diff > 0 else 'correction',
                    quantity=-mortality_diff, notes=f"Adjusted mortality from {old_mortality} to {mortality}."
                ))
                
        db.session.commit()"""
content = content.replace(log_edit_orig, log_edit_new)

# 6. New Routes
new_routes = """
@production_bp.route('/farms/<int:farm_id>/history')
@login_required
def flock_history(farm_id: int):
    _require_farmer()
    farm = _get_own_farm_or_404(farm_id)
    history = FlockHistory.query.filter_by(farm_id=farm_id).order_by(FlockHistory.date.desc(), FlockHistory.created_at.desc()).all()
    return render_template('production/flock_history.html', title='Flock & Mortality History', farm=farm, history=history)

@production_bp.route('/farms/<int:farm_id>/adjust', methods=['POST'])
@login_required
def flock_adjust(farm_id: int):
    _require_farmer()
    farm = _get_own_farm_or_404(farm_id)
    
    adjustment_type = request.form.get('adjustment_type') # 'add' or 'remove'
    quantity_str = request.form.get('quantity', '0')
    notes = request.form.get('notes', '').strip()
    date_str = request.form.get('date', '')
    
    quantity = _safe_int(quantity_str)
    if quantity <= 0:
        flash('Quantity must be greater than zero.', 'error')
        return redirect(url_for('production.flock_history', farm_id=farm_id))
        
    adjust_date = _parse_date(date_str) or date.today()
    
    if adjustment_type == 'add':
        farm.flock_size += quantity
        change = 'added'
        qty = quantity
    elif adjustment_type == 'remove':
        farm.flock_size = max(0, farm.flock_size - quantity)
        change = 'removed'
        qty = -quantity
    else:
        flash('Invalid adjustment type.', 'error')
        return redirect(url_for('production.flock_history', farm_id=farm_id))
        
    db.session.add(FlockHistory(
        farm_id=farm.id, user_id=current_user.id, date=adjust_date,
        change_type=change, quantity=qty, notes=notes
    ))
    db.session.commit()
    flash('Flock size adjusted successfully.', 'success')
    return redirect(url_for('production.flock_history', farm_id=farm_id))
"""
content += new_routes

with open('app/routes/production/production.py', 'w', encoding='utf-8') as f:
    f.write(content)
