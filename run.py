from app import create_app, db
from app.models import User, Farm, ProductionRecord, Expense, Product, Order, OrderItem

app = create_app()

with app.app_context():
    db.create_all()

@app.shell_context_processor
def make_shell_context():
    return {
        'db': db,
        'User': User,
        'Farm': Farm,
        'ProductionRecord': ProductionRecord,
        'Expense': Expense,
        'Product': Product,
        'Order': Order,
        'OrderItem': OrderItem,
    }

@app.cli.command("create-admin")
def create_admin():
    """Create a default admin user."""
    import os
    from app.models import UserRole
    
    email = os.environ.get('ADMIN_EMAIL', 'admin@poultryconnect.com')
    password = os.environ.get('ADMIN_PASSWORD', 'admin123')
    
    existing = User.query.filter_by(email=email).first()
    if existing:
        print(f"Admin user {email} already exists.")
        return
        
    admin = User(
        username='admin',
        email=email,
        role=UserRole.ADMIN,
        first_name='System',
        last_name='Administrator',
        is_active=True
    )
    admin.set_password(password)
    db.session.add(admin)
    db.session.commit()
    print(f"Admin user {email} created successfully.")

if __name__ == '__main__':
    app.run(debug=True)