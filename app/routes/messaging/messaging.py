from flask import (Blueprint, render_template, redirect, url_for,
                   flash, request, jsonify, abort)
from flask_login import login_required, current_user
from datetime import datetime
from sqlalchemy import func
import enum
from app import db
from app.models import User, UserRole, Conversation, Message, Notification, Farm

messaging_bp = Blueprint('messaging', __name__)


def _get_conv_or_404(conv_id):
    """Return conversation if current user is a participant, else 404."""
    conv = Conversation.query.get_or_404(conv_id)
    uid = current_user.id
    if conv.farmer_id != uid and conv.participant_id != uid:
        abort(403)
    return conv


def _create_notif(user_id, title, body, link_url=None, notif_type='message'):
    """Helper to insert a notification row."""
    notif = Notification(
        user_id=user_id,
        title=title,
        body=body,
        notif_type=notif_type,
        link_url=link_url,
    )
    db.session.add(notif)


def _role_value(role):
    """Normalize enum or string role values for comparisons."""
    if isinstance(role, enum.Enum):
        return role.value
    return role


def _get_matching_contacts(role, uid, q=''):
    """Return matching contacts for the current role and optional query."""
    current_role = _role_value(role)
    if current_role == UserRole.FARMER.value:
        allowed_roles = [UserRole.FEED_SUPPLIER.value, UserRole.VETERINARIAN.value]
    elif current_role in [UserRole.FEED_SUPPLIER.value, UserRole.VETERINARIAN.value]:
        allowed_roles = [UserRole.FARMER.value]
    else:
        return []

    query = User.query.filter(
        User.id != uid,
        User.role.in_(allowed_roles),
        User.is_active == True,
    )
    if q:
        query = query.filter(
            (User.first_name.ilike(f'%{q}%')) |
            (User.last_name.ilike(f'%{q}%')) |
            (User.username.ilike(f'%{q}%'))
        )
    return query.order_by(User.first_name, User.last_name, User.username).limit(50).all()


def _get_conversation_data(uid, role):
    """Return ordered conversation summaries for the current user."""
    if role == UserRole.FARMER:
        convos = Conversation.query.outerjoin(Message).filter(
            Conversation.farmer_id == uid,
            Conversation.deleted_by_farmer == False
        ).group_by(Conversation.id).order_by(
            func.coalesce(func.max(Message.sent_at), Conversation.created_at).desc()
        ).all()
    else:
        convos = Conversation.query.outerjoin(Message).filter(
            Conversation.participant_id == uid,
            Conversation.deleted_by_participant == False
        ).group_by(Conversation.id).order_by(
            func.coalesce(func.max(Message.sent_at), Conversation.created_at).desc()
        ).all()

    conv_data = []
    for c in convos:
        last = c.last_message()
        other = c.other_user(uid)
        conv_data.append({
            'conv': c,
            'other': other,
            'last_msg': last,
            'unread': c.unread_count(uid),
        })
    return conv_data


# ────────────────────────────────────────────────────────────────
# Main messenger page
# ────────────────────────────────────────────────────────────────

@messaging_bp.route('/')
@login_required
def index():
    """Messenger landing — shows all conversations for the current user."""
    uid = current_user.id
    role = current_user.role
    conv_data = _get_conversation_data(uid, role)

    # Pre-open conversation if ?open=<id>
    open_conv_id = request.args.get('open', type=int)
    open_conv = None
    open_messages = []
    if open_conv_id:
        try:
            open_conv = _get_conv_or_404(open_conv_id)
            open_messages = open_conv.messages.order_by(Message.sent_at.asc()).all()
            # Mark seen
            _mark_seen(open_conv, uid)
        except Exception:
            pass

    return render_template(
        'messaging/messenger.html',
        title='Messages',
        conv_data=conv_data,
        open_conv=open_conv,
        open_messages=open_messages,
        open_other=(open_conv.other_user(uid) if open_conv else None),
        modal_contacts=[{
            'id': u.id,
            'name': u.full_name,
            'role': u.role.value.replace('_', ' ').title(),
            'online': u.online_status,
            'initials': (u.first_name[0] + u.last_name[0]).upper() if u.first_name and u.last_name else u.username[:2].upper(),
        } for u in _get_matching_contacts(role, uid)],
        # For supplier/vet show farms so they can message farmers directly
        farm_contacts=([] if role == UserRole.FARMER else [
            {
                'farm_id': f.id,
                'farm_name': f.name,
                'farmer_id': f.farmer_id,
                'farmer_name': f.owner.full_name,
            } for f in Farm.query.filter_by(is_active=True).order_by(Farm.name).all()
        ])
    )


@messaging_bp.route('/conversations')
@login_required
def conversations():
    """Return conversation summaries for the sidebar and live sync polling."""
    uid = current_user.id
    role = current_user.role
    conv_data = _get_conversation_data(uid, role)
    return jsonify([{
        'conversation_id': item['conv'].id,
        'name': item['other'].full_name if item['other'] else '',
        'role': item['other'].role.value if item['other'] else '',
        'role_label': item['other'].role.value.replace('_', ' ').title() if item['other'] else '',
        'avatar_initials': ((item['other'].first_name[0] + item['other'].last_name[0]).upper() if item['other'] and item['other'].first_name and item['other'].last_name else (item['other'].username[:2].upper() if item['other'] else '')),
        'online': bool(item['other'].online_status) if item['other'] else False,
        'preview': item['last_msg'].body if item['last_msg'] else 'Start the conversation',
        'preview_is_mine': bool(item['last_msg'] and item['last_msg'].sender_id == uid),
        'last_sent_at': item['last_msg'].sent_at.strftime('%H:%M') if item['last_msg'] and item['last_msg'].sent_at else '',
        'unread_count': item['unread'],
        'open_url': url_for('messaging.index', open=item['conv'].id, _external=False),
    } for item in conv_data])


@messaging_bp.route('/start_from_farm', methods=['POST'])
@login_required
def start_from_farm():
    """Allow supplier/vet to start a conversation by selecting a farm's owner."""
    if current_user.role not in [UserRole.FEED_SUPPLIER, UserRole.VETERINARIAN]:
        abort(403)
    farm_id = request.form.get('farm_id', type=int)
    if not farm_id:
        flash('Invalid farm selection.', 'error')
        return redirect(url_for('messaging.index'))

    farm = Farm.query.get_or_404(farm_id)
    farmer_id = farm.farmer_id
    # Ensure the farm owner is actually a farmer (safety)
    owner = User.query.get(farmer_id)
    if not owner or owner.role != UserRole.FARMER:
        flash('Selected farm owner is not a farmer.', 'error')
        return redirect(url_for('messaging.index'))

    # Find or create conversation where farmer is the farm owner and participant is current_user
    conv = Conversation.query.filter_by(farmer_id=farmer_id, participant_id=current_user.id).first()
    if not conv:
        conv = Conversation(
            farmer_id=farmer_id,
            participant_id=current_user.id,
            participant_role=current_user.role.value,
        )
        db.session.add(conv)
        db.session.commit()
        _create_notif(
            farmer_id,
            'New Conversation',
            f'{current_user.full_name} started a conversation with you.',
            link_url=url_for('messaging.index', open=conv.id, _external=False),
        )
        db.session.commit()
    else:
        conv.deleted_by_participant = False
        db.session.commit()

    return redirect(url_for('messaging.index', open=conv.id))


# ────────────────────────────────────────────────────────────────
# JSON: contacts (farmers only)
# ────────────────────────────────────────────────────────────────

@messaging_bp.route('/contacts')
@login_required
def contacts():
    """Return the matching contact list for the current role."""
    current_role = _role_value(current_user.role)
    if current_role == UserRole.FARMER.value:
        allowed_roles = [UserRole.FEED_SUPPLIER.value, UserRole.VETERINARIAN.value]
    elif current_role in [UserRole.FEED_SUPPLIER.value, UserRole.VETERINARIAN.value]:
        allowed_roles = [UserRole.FARMER.value]
    else:
        return jsonify([])

    q = request.args.get('q', '').strip()
    query = User.query.filter(
        User.id != current_user.id,
        User.role.in_(allowed_roles),
        User.is_active == True,
    )
    if q:
        query = query.filter(
            (User.first_name.ilike(f'%{q}%')) |
            (User.last_name.ilike(f'%{q}%')) |
            (User.username.ilike(f'%{q}%'))
        )
    users = query.order_by(User.first_name, User.last_name, User.username).limit(50).all()
    return jsonify([{
        'id': u.id,
        'name': u.full_name,
        'role': u.role.value.replace('_', ' ').title(),
        'online': u.online_status,
        'initials': (u.first_name[0] + u.last_name[0]).upper() if u.first_name and u.last_name else u.username[:2].upper(),
    } for u in users])


# ────────────────────────────────────────────────────────────────
# Start conversation (farmer → supplier or vet)
# ────────────────────────────────────────────────────────────────

@messaging_bp.route('/start', methods=['GET', 'POST'])
@login_required
def start():
    participant_id = request.values.get('participant_id', type=int)
    if not participant_id:
        flash('Invalid contact.', 'error')
        if request.headers.get('X-Requested-With') == 'XMLHttpRequest':
            return jsonify({'ok': False, 'error': 'Invalid contact.'}), 400
        return redirect(url_for('messaging.index'))

    participant = User.query.get_or_404(participant_id)
    current_role = _role_value(current_user.role)
    participant_role_value = _role_value(participant.role)

    if current_role == UserRole.FARMER.value:
        if participant_role_value not in [UserRole.FEED_SUPPLIER.value, UserRole.VETERINARIAN.value]:
            flash('You can only start conversations with Feed Suppliers or Veterinarians.', 'error')
            if request.headers.get('X-Requested-With') == 'XMLHttpRequest':
                return jsonify({'ok': False, 'error': 'You can only start conversations with Feed Suppliers or Veterinarians.'}), 400
            return redirect(url_for('messaging.index'))
        farmer_id = current_user.id
        participant_user_id = participant.id
        participant_role = participant_role_value
        conv = Conversation.query.filter_by(
            farmer_id=farmer_id,
            participant_id=participant_user_id
        ).first()
    elif current_role in [UserRole.FEED_SUPPLIER.value, UserRole.VETERINARIAN.value]:
        if participant_role_value != UserRole.FARMER.value:
            flash('You can only start conversations with Farmers.', 'error')
            if request.headers.get('X-Requested-With') == 'XMLHttpRequest':
                return jsonify({'ok': False, 'error': 'You can only start conversations with Farmers.'}), 400
            return redirect(url_for('messaging.index'))
        farmer_id = participant.id
        participant_user_id = current_user.id
        participant_role = current_role
        conv = Conversation.query.filter_by(
            farmer_id=farmer_id,
            participant_id=participant_user_id
        ).first()
    else:
        abort(403)

    if not conv:
        conv = Conversation(
            farmer_id=farmer_id,
            participant_id=participant_user_id,
            participant_role=participant_role,
        )
        db.session.add(conv)
        db.session.commit()
        _create_notif(
            participant_user_id,
            'New Conversation',
            f'{current_user.full_name} started a conversation with you.',
            link_url=url_for('messaging.index', open=conv.id, _external=False),
        )
        db.session.commit()
    else:
        if current_user.role == UserRole.FARMER:
            conv.deleted_by_farmer = False
        else:
            conv.deleted_by_participant = False
        db.session.commit()

    if request.headers.get('X-Requested-With') == 'XMLHttpRequest':
        return jsonify({'ok': True, 'conversation_id': conv.id, 'redirect_url': url_for('messaging.index', open=conv.id)})

    return redirect(url_for('messaging.index', open=conv.id))


# ────────────────────────────────────────────────────────────────
# JSON: messages in a conversation
# ────────────────────────────────────────────────────────────────

@messaging_bp.route('/conversation/<int:conv_id>/messages')
@login_required
def get_messages(conv_id):
    conv = _get_conv_or_404(conv_id)
    uid = current_user.id
    _mark_seen(conv, uid)
    msgs = conv.messages.order_by(Message.sent_at.asc()).all()
    return jsonify([m.to_dict(uid) for m in msgs])


# ────────────────────────────────────────────────────────────────
# Send a message
# ────────────────────────────────────────────────────────────────

@messaging_bp.route('/conversation/<int:conv_id>/send', methods=['POST'])
@login_required
def send_message(conv_id):
    conv = _get_conv_or_404(conv_id)
    uid = current_user.id
    body = (request.form.get('body') or request.json.get('body', '') if request.is_json else request.form.get('body', '')).strip()
    if not body:
        return jsonify({'error': 'empty'}), 400

    # Determine receiver
    receiver_id = conv.participant_id if conv.farmer_id == uid else conv.farmer_id

    msg = Message(
        conversation_id=conv_id,
        sender_id=uid,
        receiver_id=receiver_id,
        body=body,
        delivered_at=datetime.utcnow(),
    )
    db.session.add(msg)

    # Un-soft-delete for receiver
    if conv.farmer_id == uid:
        conv.deleted_by_participant = False
    else:
        conv.deleted_by_farmer = False

    # Update sender online status
    current_user.online_status = True
    current_user.last_seen = datetime.utcnow()

    db.session.flush()

    # Create notification for receiver
    _create_notif(
        receiver_id,
        f'New message from {current_user.full_name}',
        body[:80] + ('…' if len(body) > 80 else ''),
        link_url=url_for('messaging.index', open=conv_id, _external=False),
    )
    db.session.commit()

    return jsonify(msg.to_dict(uid))


# ────────────────────────────────────────────────────────────────
# Mark messages as seen
# ────────────────────────────────────────────────────────────────

def _mark_seen(conv, viewer_id):
    now = datetime.utcnow()
    updated = conv.messages.filter(
        Message.sender_id != viewer_id,
        Message.is_seen == False
    ).all()
    senders = set()
    for m in updated:
        m.is_seen = True
        m.seen_at = now
        senders.add(m.sender_id)

    if updated:
        db.session.flush()
        for sender_id in senders:
            if sender_id == viewer_id:
                continue
            sender = User.query.get(sender_id)
            if sender:
                _create_notif(
                    sender_id,
                    f'Message read by {conv.other_user(sender_id).full_name}',
                    f'{conv.other_user(sender_id).full_name} has seen your latest message.',
                    link_url=url_for('messaging.index', open=conv.id, _external=False),
                    notif_type='seen'
                )
        db.session.commit()


@messaging_bp.route('/conversation/<int:conv_id>/seen', methods=['POST'])
@login_required
def mark_seen(conv_id):
    conv = _get_conv_or_404(conv_id)
    _mark_seen(conv, current_user.id)
    return jsonify({'ok': True})


# ────────────────────────────────────────────────────────────────
# Polling endpoint — returns new messages since last_id
# ────────────────────────────────────────────────────────────────

@messaging_bp.route('/conversation/<int:conv_id>/poll')
@login_required
def poll(conv_id):
    conv = _get_conv_or_404(conv_id)
    uid = current_user.id
    last_id = request.args.get('last_id', 0, type=int)
    msgs = conv.messages.filter(Message.id > last_id).order_by(Message.sent_at.asc()).all()
    if msgs:
        _mark_seen(conv, uid)
    return jsonify([m.to_dict(uid) for m in msgs])


# ────────────────────────────────────────────────────────────────
# Delete conversation (soft delete on current user's side)
# ────────────────────────────────────────────────────────────────

@messaging_bp.route('/conversation/<int:conv_id>/delete', methods=['POST'])
@login_required
def delete_conversation(conv_id):
    conv = _get_conv_or_404(conv_id)
    if conv.farmer_id == current_user.id:
        conv.deleted_by_farmer = True
    else:
        conv.deleted_by_participant = True
    db.session.commit()
    flash('Conversation removed.', 'success')
    return redirect(url_for('messaging.index'))


# ────────────────────────────────────────────────────────────────
# Notifications API
# ────────────────────────────────────────────────────────────────

@messaging_bp.route('/notifications')
@login_required
def notifications():
    notifs = (Notification.query
              .filter_by(user_id=current_user.id)
              .order_by(Notification.created_at.desc())
              .limit(20).all())
    unread_count = Notification.query.filter_by(
        user_id=current_user.id, is_read=False).count()
    return jsonify({
        'unread_count': unread_count,
        'notifications': [n.to_dict() for n in notifs],
    })


@messaging_bp.route('/notifications/read', methods=['POST'])
@login_required
def mark_notifs_read():
    Notification.query.filter_by(user_id=current_user.id, is_read=False).update({'is_read': True})
    db.session.commit()
    return jsonify({'ok': True})


# ────────────────────────────────────────────────────────────────
# Online heartbeat
# ────────────────────────────────────────────────────────────────

@messaging_bp.route('/heartbeat', methods=['POST'])
@login_required
def heartbeat():
    current_user.online_status = True
    current_user.last_seen = datetime.utcnow()
    db.session.commit()
    return jsonify({'ok': True})
