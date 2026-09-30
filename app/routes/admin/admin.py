"""
Admin Blueprint â€” PoultryConnect 2.0
Handles:
  - Admin Dashboard (stats overview)
  - Farmer Verification (list, approve, reject)
  - Content Moderation (list, approve, reject)
  - User Management

Security:
  - All routes protected by @login_required + _require_admin()
  - Role check done in backend; not just frontend hiding
"""

from flask import (
    Blueprint, render_template, redirect, url_for,
    flash, request, abort, jsonify
)
from flask_login import login_required, current_user
from werkzeug.security import generate_password_hash
from datetime import datetime

from app import db
from app.models import (
    User, UserRole, Farm, Product, Order,
    FarmerVerification, VerificationStatus, SubscriptionPlan
)

admin_bp = Blueprint('admin', __name__)


# â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
# GUARD HELPER
# â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

def _require_admin():
    """Abort 403 if current user is not an admin."""
    if not current_user.is_authenticated or current_user.role != UserRole.ADMIN:
        abort(403)


# â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
# DASHBOARD
# â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

from datetime import timedelta

@admin_bp.route('/')
@login_required
def index():
    _require_admin()

    # Date filtering
    date_filter = request.args.get('filter', 'all')
    now = datetime.utcnow()
    
    base_user_query = User.query
    base_prod_query = Product.query
    base_order_query = Order.query
    
    if date_filter == 'today':
        cutoff = now - timedelta(days=1)
    elif date_filter == 'week':
        cutoff = now - timedelta(days=7)
    elif date_filter == 'month':
        cutoff = now - timedelta(days=30)
    else:
        cutoff = None
        
    if cutoff:
        base_user_query = base_user_query.filter(User.created_at >= cutoff)
        base_prod_query = base_prod_query.filter(Product.created_at >= cutoff)
        base_order_query = base_order_query.filter(Order.created_at >= cutoff)

    total_users   = base_user_query.count()
    total_farmers = base_user_query.filter_by(role=UserRole.FARMER).count()
    total_buyers  = base_user_query.filter_by(role=UserRole.BUYER).count()
    total_products = base_prod_query.count()
    total_orders   = base_order_query.count()
    
    monthly_subs = User.query.filter_by(role=UserRole.FARMER, subscription_plan=SubscriptionPlan.MONTHLY).count()
    yearly_subs = User.query.filter_by(role=UserRole.FARMER, subscription_plan=SubscriptionPlan.YEARLY).count()
    total_revenue = (monthly_subs * 299) + (yearly_subs * 2990)

    # Farmer verification stats
    pending_verifications  = FarmerVerification.query.filter_by(status=VerificationStatus.PENDING).count()
    approved_verifications = FarmerVerification.query.filter_by(status=VerificationStatus.APPROVED).count()
    rejected_verifications = FarmerVerification.query.filter_by(status=VerificationStatus.REJECTED).count()
    # Farmers with NO verification record yet also count as pending
    unsubmitted_farmers = User.query.filter(
        User.role == UserRole.FARMER,
        ~User.id.in_(db.session.query(FarmerVerification.farmer_id))
    ).count()
    pending_verifications += unsubmitted_farmers

    # Recent activity
    recent_farmers = User.query.filter_by(role=UserRole.FARMER).order_by(User.created_at.desc()).limit(5).all()

    # Chart Data: Farmer Registrations (Last 30 Days)
    thirty_days_ago = datetime.utcnow() - timedelta(days=30)
    
    # We will do aggregation in Python for max compatibility
    recent_farmers_all = User.query.filter(User.role == UserRole.FARMER, User.created_at >= thirty_days_ago).all()
    reg_counts = {}
    for f in recent_farmers_all:
        date_str = f.created_at.strftime('%Y-%m-%d')
        reg_counts[date_str] = reg_counts.get(date_str, 0) + 1
        
    labels_30d = [(datetime.utcnow() - timedelta(days=i)).strftime('%Y-%m-%d') for i in range(29, -1, -1)]
    farmer_reg_data = [reg_counts.get(label, 0) for label in labels_30d]
    
    # Decision Insights Engine
    insights = []
    
    if pending_verifications > 0:
        insights.append({
            'type': 'warning',
            'title': f"{pending_verifications} Pending Farmer Verifications",
            'desc': "Review pending applications to prevent delays in farmer onboarding.",
            'action_text': "Review Applications",
            'action_url': url_for('admin.farmer_verification', status='pending')
        })
    if not insights:
        insights.append({
            'type': 'success',
            'title': "All Caught Up!",
            'desc': "There are no urgent actions required at this time.",
            'action_text': "View Dashboard",
            'action_url': "#"
        })

    return render_template(
        'admin/dashboard.html',
        title='Admin Dashboard',
        total_users=total_users,
        total_farmers=total_farmers,
        total_buyers=total_buyers,
        total_products=total_products,
        total_orders=total_orders,
        monthly_subs=monthly_subs,
        yearly_subs=yearly_subs,
        total_revenue=total_revenue,
        date_filter=date_filter,
        pending_verifications=pending_verifications,
        approved_verifications=approved_verifications,
        rejected_verifications=rejected_verifications,
        recent_farmers=recent_farmers,
        farmer_reg_labels=labels_30d,
        farmer_reg_data=farmer_reg_data,
        insights=insights,
        pending_verif_count=pending_verifications
    )


# â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
# FARMER VERIFICATION
# â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

@admin_bp.route('/farmers')
@login_required
def farmer_verification():
    _require_admin()

    status_filter = request.args.get('status', 'pending')

    # Get all farmers
    farmers_query = User.query.filter_by(role=UserRole.FARMER)

    if status_filter == 'pending':
        # Farmers with pending verification OR no verification record yet
        verified_farmer_ids = db.session.query(FarmerVerification.farmer_id).filter(
            FarmerVerification.status != VerificationStatus.PENDING
        ).all()
        verified_farmer_ids = [v[0] for v in verified_farmer_ids]
        farmers = farmers_query.filter(
            ~User.id.in_(verified_farmer_ids) if verified_farmer_ids else True
        ).order_by(User.created_at.desc()).all()

        # Also include those with explicit PENDING status
        explicit_pending_ids = db.session.query(FarmerVerification.farmer_id).filter_by(
            status=VerificationStatus.PENDING
        ).all()
        explicit_pending_ids = [v[0] for v in explicit_pending_ids]
        if explicit_pending_ids:
            extra = farmers_query.filter(User.id.in_(explicit_pending_ids)).all()
            existing_ids = {f.id for f in farmers}
            for f in extra:
                if f.id not in existing_ids:
                    farmers.append(f)

    elif status_filter == 'approved':
        approved_ids = db.session.query(FarmerVerification.farmer_id).filter_by(
            status=VerificationStatus.APPROVED
        ).all()
        approved_ids = [v[0] for v in approved_ids]
        farmers = farmers_query.filter(User.id.in_(approved_ids)).order_by(User.created_at.desc()).all() if approved_ids else []

    elif status_filter == 'rejected':
        rejected_ids = db.session.query(FarmerVerification.farmer_id).filter_by(
            status=VerificationStatus.REJECTED
        ).all()
        rejected_ids = [v[0] for v in rejected_ids]
        farmers = farmers_query.filter(User.id.in_(rejected_ids)).order_by(User.created_at.desc()).all() if rejected_ids else []

    else:
        farmers = farmers_query.order_by(User.created_at.desc()).all()

    # Stats
    total_pending = FarmerVerification.query.filter_by(status=VerificationStatus.PENDING).count()
    total_pending += User.query.filter(
        User.role == UserRole.FARMER,
        ~User.id.in_(db.session.query(FarmerVerification.farmer_id))
    ).count()

    return render_template(
        'admin/farmer_verification.html',
        title='Farmer Verification',
        farmers=farmers,
        status_filter=status_filter,
        total_pending=total_pending,
        total_approved=FarmerVerification.query.filter_by(status=VerificationStatus.APPROVED).count(),
        total_rejected=FarmerVerification.query.filter_by(status=VerificationStatus.REJECTED).count(),
    )


@admin_bp.route('/farmers/<int:farmer_id>/approve', methods=['POST'])
@login_required
def approve_farmer(farmer_id):
    _require_admin()
    farmer = User.query.get_or_404(farmer_id)
    if farmer.role != UserRole.FARMER:
        abort(400)

    verification = FarmerVerification.query.filter_by(farmer_id=farmer_id).first()
    if not verification:
        verification = FarmerVerification(farmer_id=farmer_id)
        db.session.add(verification)

    verification.status = VerificationStatus.APPROVED
    verification.reviewed_by_id = current_user.id
    verification.reviewed_at = datetime.utcnow()
    verification.rejection_reason = None
    db.session.commit()

    flash(f'Farmer {farmer.full_name} has been approved and verified.', 'success')
    return redirect(url_for('admin.farmer_verification', status='pending'))


@admin_bp.route('/farmers/<int:farmer_id>/reject', methods=['POST'])
@login_required
def reject_farmer(farmer_id):
    _require_admin()
    farmer = User.query.get_or_404(farmer_id)
    if farmer.role != UserRole.FARMER:
        abort(400)

    reason = request.form.get('reason', '').strip()
    if not reason:
        flash('A rejection reason is required.', 'error')
        return redirect(url_for('admin.farmer_verification', status='pending'))

    verification = FarmerVerification.query.filter_by(farmer_id=farmer_id).first()
    if not verification:
        verification = FarmerVerification(farmer_id=farmer_id)
        db.session.add(verification)

    verification.status = VerificationStatus.REJECTED
    verification.reviewed_by_id = current_user.id
    verification.reviewed_at = datetime.utcnow()
    verification.rejection_reason = reason
    db.session.commit()

    flash(f'Farmer {farmer.full_name} has been rejected.', 'warning')
    return redirect(url_for('admin.farmer_verification', status='pending'))


# â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
# USER MANAGEMENT
# â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

@admin_bp.route('/users')
@login_required
def users():
    _require_admin()

    role_filter = request.args.get('role', '')
    search = request.args.get('q', '').strip()

    query = User.query

    if role_filter:
        try:
            query = query.filter_by(role=UserRole(role_filter))
        except ValueError:
            pass

    if search:
        query = query.filter(
            db.or_(
                User.username.ilike(f'%{search}%'),
                User.email.ilike(f'%{search}%'),
                User.first_name.ilike(f'%{search}%'),
                User.last_name.ilike(f'%{search}%'),
            )
        )

    users_list = query.order_by(User.created_at.desc()).all()

    return render_template(
        'admin/users.html',
        title='User Management',
        users_list=users_list,
        role_filter=role_filter,
        search=search,
        total=query.count(),
    )


@admin_bp.route('/users/<int:user_id>/toggle-active', methods=['POST'])
@login_required
def toggle_user_active(user_id):
    _require_admin()
    user = User.query.get_or_404(user_id)
    if user.id == current_user.id:
        flash('You cannot deactivate your own account.', 'error')
        return redirect(url_for('admin.users'))
    user.is_active = not user.is_active
    db.session.commit()
    status = 'activated' if user.is_active else 'deactivated'
    flash(f'User {user.full_name} has been {status}.', 'success')
    return redirect(url_for('admin.users'))

@admin_bp.route('/users/add', methods=['POST'])
@login_required
def add_user():
    _require_admin()
    
    first_name = request.form.get('first_name', '').strip()
    last_name = request.form.get('last_name', '').strip()
    email = request.form.get('email', '').strip()
    username = request.form.get('username', '').strip()
    phone = request.form.get('phone', '').strip()
    role_val = request.form.get('role', 'farmer')
    password = request.form.get('password', '')

    if not all([first_name, last_name, email, username, password]):
        flash('Please fill in all required fields.', 'error')
        return redirect(url_for('admin.users'))

    if User.query.filter_by(email=email).first():
        flash('Email already registered.', 'error')
        return redirect(url_for('admin.users'))
        
    if User.query.filter_by(username=username).first():
        flash('Username already registered.', 'error')
        return redirect(url_for('admin.users'))

    try:
        role = UserRole(role_val)
    except ValueError:
        role = UserRole.FARMER

    new_user = User(
        first_name=first_name,
        last_name=last_name,
        email=email,
        username=username,
        phone=phone,
        role=role,
        password_hash=generate_password_hash(password)
    )
    db.session.add(new_user)
    db.session.flush()

    if role == UserRole.FARMER:
        # Initialize verification state
        verification = FarmerVerification(
            farmer_id=new_user.id,
            status=VerificationStatus.PENDING
        )
        db.session.add(verification)

    db.session.commit()
    flash(f'Account created successfully for {new_user.full_name}.', 'success')
    return redirect(url_for('admin.users'))


@admin_bp.route('/users/<int:user_id>/edit', methods=['POST'])
@login_required
def edit_user(user_id):
    _require_admin()
    user = User.query.get_or_404(user_id)
    
    user.first_name = request.form.get('first_name', user.first_name).strip()
    user.last_name = request.form.get('last_name', user.last_name).strip()
    user.phone = request.form.get('phone', user.phone).strip()
    
    # Handle optional role update
    role_val = request.form.get('role')
    if role_val and user.id != current_user.id:
        try:
            new_role = UserRole(role_val)
            user.role = new_role
            if new_role == UserRole.FARMER:
                verif = FarmerVerification.query.filter_by(farmer_id=user.id).first()
                if not verif:
                    db.session.add(FarmerVerification(farmer_id=user.id, status=VerificationStatus.PENDING))
        except ValueError:
            pass

    # Handle password reset if provided
    new_password = request.form.get('password')
    if new_password:
        user.password_hash = generate_password_hash(new_password)
        flash('Password successfully updated.', 'success')

    db.session.commit()
    flash(f'Account details updated for {user.full_name}.', 'success')
    return redirect(url_for('admin.users'))

@admin_bp.route('/subscribers')
@login_required
def subscribers():
    _require_admin()
    farmers = User.query.filter_by(role=UserRole.FARMER).order_by(User.created_at.desc()).all()
    return render_template('admin/subscribers.html', farmers=farmers, today=datetime.utcnow())

@admin_bp.route('/subscribers/<int:user_id>/end-trial', methods=['POST'])
@login_required
def end_trial(user_id):
    _require_admin()
    farmer = User.query.get_or_404(user_id)
    if farmer.role != UserRole.FARMER:
        flash('Can only end trials for farmers.', 'error')
        return redirect(url_for('admin.subscribers'))
        
    farmer.trial_end = datetime.utcnow()
    db.session.commit()
    flash(f"Ended 7-day free trial for {farmer.full_name}.", 'success')
    return redirect(url_for('admin.subscribers'))

@admin_bp.route('/subscribers/<int:user_id>/end-subscription', methods=['POST'])
@login_required
def end_subscription(user_id):
    _require_admin()
    farmer = User.query.get_or_404(user_id)
    if farmer.role != UserRole.FARMER:
        flash('Can only end subscriptions for farmers.', 'error')
        return redirect(url_for('admin.subscribers'))
        
    farmer.subscription_plan = SubscriptionPlan.FREE
    farmer.subscription_end = None
    db.session.commit()
    flash(f"Ended subscription for {farmer.full_name}.", 'success')
    return redirect(url_for('admin.subscribers'))
