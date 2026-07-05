from flask import Blueprint, render_template, redirect, url_for, abort
from flask_login import login_required, current_user
from app.models import UserRole, Conversation, Message, Notification

supplier_bp = Blueprint('supplier', __name__)


def _require_supplier():
    if not current_user.is_authenticated or current_user.role != UserRole.FEED_SUPPLIER:
        abort(403)


@supplier_bp.route('/dashboard')
@login_required
def dashboard():
    _require_supplier()
    uid = current_user.id

    convos = Conversation.query.filter(
        Conversation.participant_id == uid,
        Conversation.deleted_by_participant == False
    ).order_by(Conversation.id.desc()).all()

    total_convos = len(convos)
    unread_msgs = sum(c.unread_count(uid) for c in convos)
    unread_notifs = Notification.query.filter_by(user_id=uid, is_read=False).count()

    # Recent conversations (last 5)
    recent = []
    for c in convos[:5]:
        last = c.last_message()
        recent.append({
            'conv': c,
            'farmer': c.farmer,
            'last_msg': last,
            'unread': c.unread_count(uid),
        })

    return render_template(
        'supplier/supplier_dashboard.html',
        title='Feed Supplier Dashboard',
        total_convos=total_convos,
        unread_msgs=unread_msgs,
        unread_notifs=unread_notifs,
        recent=recent,
    )
