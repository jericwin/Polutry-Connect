from app import create_app, db
from app.models import User
from app.email import send_password_reset_email

app = create_app()

with app.test_request_context():
    user = User.query.first()
    if user:
        print(f"Found user: {user.email}")
        send_password_reset_email(user)
        print("Email sent to thread.")
    else:
        print("No users found in database.")
