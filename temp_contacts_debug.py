from app import create_app
from app.models import User, UserRole

app = create_app()
with app.app_context():
    print('APP CONTEXT OK')
    users = User.query.all()
    print('ALL USERS', len(users))
    for u in users:
        print('USER', u.id, u.username, u.role, u.is_active, u.full_name)
    farmer = User.query.filter_by(role=UserRole.FARMER.value).first()
    print('FIRST FARMER', farmer)
    if farmer:
        allowed = [UserRole.FEED_SUPPLIER.value, UserRole.VETERINARIAN.value]
        contacts = User.query.filter(User.id != farmer.id, User.role.in_(allowed), User.is_active == True).all()
        print('FARMER CONTACTS', len(contacts))
        for c in contacts:
            print('CONTACT', c.id, c.username, c.role, c.is_active, c.full_name)
