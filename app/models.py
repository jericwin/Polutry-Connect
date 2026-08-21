"""
Database Models â€” PoultryConnect 2.0
Tables for v1 scope: Auth/Roles + Farmer Dashboard

Good practices applied:
- Primary keys (auto-increment INT)
- Indexes on FK columns and frequently filtered columns (date, role, email)
- Unique constraints on email and username
- Timestamps (created_at, updated_at) on every table
- Nullable=False on required fields
- Enum-style string constraints via db.CheckConstraint
- Relationships defined with backref for easy ORM access
"""

import enum
from datetime import datetime
from app import db, login
from flask import current_app
from flask_login import UserMixin
from werkzeug.security import generate_password_hash, check_password_hash
from itsdangerous import URLSafeTimedSerializer as Serializer

# â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
# ENUMS
# â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

class UserRole(str, enum.Enum):
    ADMIN          = 'admin'
    FARMER         = 'farmer'
    BUYER          = 'buyer'
    FEED_SUPPLIER  = 'feed_supplier'
    VETERINARIAN   = 'veterinarian'

class ExpenseCategory(str, enum.Enum):
    FEED       = 'feed'
    LABOR      = 'labor'
    UTILITIES  = 'utilities'
    MEDICINE   = 'medicine'
    OTHER      = 'other'

class ExpenseFrequency(str, enum.Enum):
    ONE_TIME = 'one_time'
    DAILY    = 'daily'
    WEEKLY   = 'weekly'
    MONTHLY  = 'monthly'

class ProductSize(str, enum.Enum):
    SMALL  = 'small'
    MEDIUM = 'medium'
    LARGE  = 'large'
    EXTRA_LARGE = 'extra_large'
    JUMBO = 'jumbo'

class ProductVariety(str, enum.Enum):
    BROWN = 'brown'
    WHITE = 'white'

class ProductUnit(str, enum.Enum):
    PIECE    = 'piece'
    TRAY     = 'tray'
    KILOGRAM = 'kilogram'
    HEAD     = 'head'

class OrderStatus(str, enum.Enum):
    PENDING    = 'pending'
    CONFIRMED  = 'confirmed'
    SHIPPED    = 'shipped'
    DELIVERED  = 'delivered'
    COMPLETED  = 'completed'
    CANCELLED  = 'cancelled'

class VerificationStatus(str, enum.Enum):
    PENDING  = 'pending'
    APPROVED = 'approved'
    REJECTED = 'rejected'

class ModerationStatus(str, enum.Enum):
    PENDING  = 'pending'
    APPROVED = 'approved'
    FLAGGED  = 'flagged'
    REJECTED = 'rejected'


# â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
# TABLE 1: users
# â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

class User(UserMixin, db.Model):
    """
    Central user table for all roles.
    Indexed: email, username, role â€” all are frequently queried.
    """
    __tablename__ = 'users'

    id            = db.Column(db.Integer, primary_key=True, autoincrement=True)
    username      = db.Column(db.String(64),  nullable=False, unique=True, index=True)
    email         = db.Column(db.String(120), nullable=False, unique=True, index=True)
    password_hash = db.Column(db.String(256), nullable=False)
    role          = db.Column(
                       db.Enum(UserRole, values_callable=lambda enum_cls: [e.value for e in enum_cls]),
                       nullable=False,
                       default=UserRole.FARMER,
                       index=True
                   )
    first_name    = db.Column(db.String(64))
    last_name     = db.Column(db.String(64))
    phone         = db.Column(db.String(20))
    address       = db.Column(db.String(200))
    landmark      = db.Column(db.String(255))
    is_active     = db.Column(db.Boolean, nullable=False, default=True)
    online_status = db.Column(db.Boolean, nullable=False, default=False)
    last_seen     = db.Column(db.DateTime, nullable=True)
    created_at    = db.Column(db.DateTime, nullable=False, default=datetime.utcnow)
    updated_at    = db.Column(db.DateTime, nullable=False, default=datetime.utcnow, onupdate=datetime.utcnow)

    # Relationships
    farms              = db.relationship('Farm', backref='owner', lazy='dynamic',
                                         foreign_keys='Farm.farmer_id')
    production_records = db.relationship('ProductionRecord', backref='recorded_by', lazy='dynamic',
                                          foreign_keys='ProductionRecord.user_id')
    expenses           = db.relationship('Expense', backref='recorded_by', lazy='dynamic',
                                          foreign_keys='Expense.user_id')

    def set_password(self, password: str):
        self.password_hash = generate_password_hash(password)

    def check_password(self, password: str) -> bool:
        return check_password_hash(self.password_hash, password)

    def get_reset_password_token(self):
        s = Serializer(current_app.config['SECRET_KEY'])
        return s.dumps({'user_id': self.id})

    @staticmethod
    def verify_reset_password_token(token, expires_in=3600):
        s = Serializer(current_app.config['SECRET_KEY'])
        try:
            user_id = s.loads(token, max_age=expires_in)['user_id']
        except:
            return None
        return User.query.get(user_id)

    @property
    def full_name(self) -> str:
        if self.first_name and self.last_name:
            return f'{self.first_name} {self.last_name}'
        return self.username

    def __repr__(self):
        return f'<User {self.username} [{self.role.value}]>'


@login.user_loader
def load_user(user_id: int):
    return User.query.get(int(user_id))


# â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
# TABLE 2: farms
# â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

class Farm(db.Model):
    """
    A farmer can own multiple farms.
    Each farm is a distinct poultry operation.
    Indexed: farmer_id (FK) â€” always queried by owner.
    """
    __tablename__ = 'farms'

    id          = db.Column(db.Integer, primary_key=True, autoincrement=True)
    farmer_id   = db.Column(db.Integer, db.ForeignKey('users.id'), nullable=False, index=True)
    name        = db.Column(db.String(120), nullable=False)
    location    = db.Column(db.String(255))
    description = db.Column(db.Text)
    flock_size  = db.Column(db.Integer, default=0)        # total number of birds
    is_active   = db.Column(db.Boolean, nullable=False, default=True)
    created_at  = db.Column(db.DateTime, nullable=False, default=datetime.utcnow)
    updated_at  = db.Column(db.DateTime, nullable=False, default=datetime.utcnow, onupdate=datetime.utcnow)

    # Relationships
    production_records = db.relationship('ProductionRecord', backref='farm', lazy='dynamic',
                                          foreign_keys='ProductionRecord.farm_id')
    expenses           = db.relationship('Expense', backref='farm', lazy='dynamic',
                                          foreign_keys='Expense.farm_id')
    sales_records      = db.relationship('SalesRecord', backref='farm', lazy='dynamic',
                                          foreign_keys='SalesRecord.farm_id')

    @property
    def scale_label(self):
        if self.flock_size < 1000:
            return 'Small'
        elif self.flock_size < 10000:
            return 'Medium'
        else:
            return 'Large'

    @property
    def scale_class(self):
        if self.flock_size < 1000:
            return 'scale-small'
        elif self.flock_size < 10000:
            return 'scale-medium'
        else:
            return 'scale-large'

    @property
    def scale_icon(self):
        if self.flock_size < 1000:
            return '<svg xmlns="http://www.w3.org/2000/svg" width="1em" height="1em" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M12 22v-7l-2-2"></path><path d="M22 8.5C22 5.5 19 3 15.5 3S9 5.5 9 8.5c0 1.5.5 2.5 1 3.5-1.5 1-2.5 2.5-2.5 4 0 2 1.5 3.5 3.5 3.5.5 0 1 0 1.5-.5"></path><path d="M2 13.5C2 10.5 5 8 8.5 8s6.5 2.5 6.5 5.5c0 1.5-.5 2.5-1 3.5 1.5 1 2.5 2.5 2.5 4 0 2-1.5 3.5-3.5 3.5-.5 0-1 0-1.5-.5"></path></svg>'
        elif self.flock_size < 10000:
            return '<svg xmlns="http://www.w3.org/2000/svg" width="1em" height="1em" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="m3 9 9-7 9 7v11a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2z"/><polyline points="9 22 9 12 15 12 15 22"/></svg>'
        else:
            return '<svg xmlns="http://www.w3.org/2000/svg" width="1em" height="1em" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M2 20a2 2 0 0 0 2 2h16a2 2 0 0 0 2-2V8l-7 5V8l-7 5V4a2 2 0 0 0-2-2H4a2 2 0 0 0-2 2Z"/><path d="M17 18h1"/><path d="M12 18h1"/><path d="M7 18h1"/></svg>'

    def __repr__(self):
        return f'<Farm {self.name} (owner_id={self.farmer_id})>'


# â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
# TABLE 3: production_records
# â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

class ProductionRecord(db.Model):
    """
    Daily production log per farm.
    Indexed: farm_id, record_date â€” core of farmer dashboard queries.
    """
    __tablename__ = 'production_records'

    id           = db.Column(db.Integer, primary_key=True, autoincrement=True)
    farm_id      = db.Column(db.Integer, db.ForeignKey('farms.id'), nullable=False, index=True)
    user_id      = db.Column(db.Integer, db.ForeignKey('users.id'), nullable=False, index=True)

    record_date  = db.Column(db.Date, nullable=False, index=True)   # the date the data is FOR
    egg_count    = db.Column(db.Integer, nullable=False, default=0)  # total eggs collected
    size         = db.Column(
                       db.Enum(ProductSize, values_callable=lambda enum_cls: [e.value for e in enum_cls]),
                       nullable=True
                   )
    variety      = db.Column(
                       db.Enum(ProductVariety, values_callable=lambda enum_cls: [e.value for e in enum_cls]),
                       nullable=True
                   )
    feed_kg      = db.Column(db.Numeric(8, 2), default=0.00)         # feed consumed in kg
    feed_cost    = db.Column(db.Numeric(10, 2), default=0.00)        # cost of feed that day (PHP)
    egg_price    = db.Column(db.Numeric(10, 2), nullable=True)       # selling price per egg (PHP); None = not recorded
    mortality    = db.Column(db.Integer, default=0)                   # birds that died
    notes        = db.Column(db.Text)

    created_at   = db.Column(db.DateTime, nullable=False, default=datetime.utcnow)
    updated_at   = db.Column(db.DateTime, nullable=False, default=datetime.utcnow, onupdate=datetime.utcnow)

    # Composite unique constraint: one record per farm per day per size per variety
    __table_args__ = (
        db.UniqueConstraint('farm_id', 'record_date', 'size', 'variety', name='uq_farm_record_date_size_variety'),
    )

    @property
    def revenue(self):
        """Daily revenue: egg_count Ã— egg_price. Returns 0 if price not set."""
        if self.egg_price:
            return float(self.egg_count) * float(self.egg_price)
        return 0.0

    def __repr__(self):
        return f'<ProductionRecord farm={self.farm_id} date={self.record_date} eggs={self.egg_count}>'


# â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
# TABLE 4: expenses
# â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

class Expense(db.Model):
    """
    Operational expense entries per farm.
    Categories: feed, labor, utilities, medicine, other.
    Indexed: farm_id, expense_date â€” for monthly profit/loss rollup queries.
    """
    __tablename__ = 'expenses'

    id           = db.Column(db.Integer, primary_key=True, autoincrement=True)
    farm_id      = db.Column(db.Integer, db.ForeignKey('farms.id'), nullable=False, index=True)
    user_id      = db.Column(db.Integer, db.ForeignKey('users.id'), nullable=False, index=True)

    expense_date = db.Column(db.Date, nullable=False, index=True)
    category     = db.Column(
                      db.Enum(ExpenseCategory, values_callable=lambda enum_cls: [e.value for e in enum_cls]),
                      nullable=False,
                      default=ExpenseCategory.OTHER,
                      index=True
                  )
    frequency    = db.Column(
                      db.Enum(ExpenseFrequency, values_callable=lambda enum_cls: [e.value for e in enum_cls]),
                      nullable=False,
                      default=ExpenseFrequency.ONE_TIME
                  )
    end_date     = db.Column(db.Date, nullable=True) # for recurring expenses
    amount       = db.Column(db.Numeric(10, 2), nullable=False)   # PHP
    description  = db.Column(db.String(255))

    created_at   = db.Column(db.DateTime, nullable=False, default=datetime.utcnow)
    updated_at   = db.Column(db.DateTime, nullable=False, default=datetime.utcnow, onupdate=datetime.utcnow)

    def __repr__(self):
        return f'<Expense farm={self.farm_id} {self.category.value} â‚±{self.amount} on {self.expense_date}>'


# â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
# TABLE 5: sales_records
# â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

class SalesRecord(db.Model):
    """
    Log of actual eggs sold. Separated from ProductionRecord.
    Indexed: farm_id, sale_date
    """
    __tablename__ = 'sales_records'

    id             = db.Column(db.Integer, primary_key=True, autoincrement=True)
    farm_id        = db.Column(db.Integer, db.ForeignKey('farms.id'), nullable=False, index=True)
    user_id        = db.Column(db.Integer, db.ForeignKey('users.id'), nullable=False, index=True)

    sale_date      = db.Column(db.Date, nullable=False, index=True)
    quantity_sold  = db.Column(db.Integer, nullable=False)
    price_per_egg  = db.Column(db.Numeric(10, 2), nullable=False)
    total_revenue  = db.Column(db.Numeric(12, 2), nullable=False)
    buyer_name     = db.Column(db.String(255), nullable=True)
    notes          = db.Column(db.Text)

    created_at     = db.Column(db.DateTime, nullable=False, default=datetime.utcnow)
    updated_at     = db.Column(db.DateTime, nullable=False, default=datetime.utcnow, onupdate=datetime.utcnow)

    def __repr__(self):
        return f'<SalesRecord farm={self.farm_id} sold={self.quantity_sold} for â‚±{self.total_revenue}>'


# â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
# TABLE 5: products
# â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

class Product(db.Model):
    """
    Marketplace product listings created by farmers.
    Indexed: farmer_id, farm_id, category, is_available â€” all frequent query paths.
    """
    __tablename__ = 'products'

    id            = db.Column(db.Integer, primary_key=True, autoincrement=True)
    farmer_id     = db.Column(db.Integer, db.ForeignKey('users.id'), nullable=False, index=True)
    farm_id       = db.Column(db.Integer, db.ForeignKey('farms.id'), nullable=False, index=True)

    name          = db.Column(db.String(150), nullable=False)
    description   = db.Column(db.Text)
    size          = db.Column(
                       db.Enum(ProductSize, values_callable=lambda enum_cls: [e.value for e in enum_cls]),
                       nullable=False,
                       default=ProductSize.MEDIUM,
                       index=True
                   )
    variety       = db.Column(
                       db.Enum(ProductVariety, values_callable=lambda enum_cls: [e.value for e in enum_cls]),
                       nullable=False,
                       default=ProductVariety.BROWN,
                       index=True
                   )
    unit          = db.Column(
                       db.Enum(ProductUnit, values_callable=lambda enum_cls: [e.value for e in enum_cls]),
                       nullable=False,
                       default=ProductUnit.PIECE
                   )
    price             = db.Column(db.Numeric(10, 2), nullable=False)        # PHP per unit
    stock             = db.Column(db.Integer, nullable=False, default=0)
    location          = db.Column(db.String(255))                           # auto-filled from farm
    is_available      = db.Column(db.Boolean, nullable=False, default=True, index=True)
    image_url         = db.Column(db.String(500), nullable=True)            # product image
    moderation_status = db.Column(
                            db.Enum(ModerationStatus, values_callable=lambda e: [x.value for x in e]),
                            nullable=False,
                            default=ModerationStatus.PENDING
                        )  # content moderation state

    created_at    = db.Column(db.DateTime, nullable=False, default=datetime.utcnow)
    updated_at    = db.Column(db.DateTime, nullable=False, default=datetime.utcnow, onupdate=datetime.utcnow)

    # Relationships
    farmer        = db.relationship('User', backref=db.backref('products', lazy='dynamic'))
    farm          = db.relationship('Farm', backref=db.backref('products', lazy='dynamic'))
    order_items   = db.relationship('OrderItem', backref='product', lazy='dynamic')

    @property
    def stock_label(self):
        if self.stock <= 0:
            return 'out_of_stock'
        elif self.stock <= 10:
            return 'low_stock'
        return 'in_stock'

    @property
    def size_label(self):
        return self.size.value.title()

    @property
    def variety_label(self):
        return self.variety.value.title()

    @property
    def unit_label(self):
        return self.unit.value.replace('_', ' ')

    def __repr__(self):
        return f'<Product {self.name} â‚±{self.price}/{self.unit.value} (farmer={self.farmer_id})>'


# â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
# TABLE 6: orders
# â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

class Order(db.Model):
    """
    Purchase orders placed by buyers.
    Indexed: buyer_id, status â€” dashboard queries.
    """
    __tablename__ = 'orders'

    id               = db.Column(db.Integer, primary_key=True, autoincrement=True)
    buyer_id         = db.Column(db.Integer, db.ForeignKey('users.id'), nullable=False, index=True)

    total_amount     = db.Column(db.Numeric(12, 2), nullable=False, default=0)
    status           = db.Column(
                          db.Enum(OrderStatus, values_callable=lambda enum_cls: [e.value for e in enum_cls]),
                          nullable=False,
                          default=OrderStatus.PENDING,
                          index=True
                      )
    delivery_address = db.Column(db.String(500), nullable=False)
    contact_phone    = db.Column(db.String(30), nullable=False)
    payment_method   = db.Column(db.String(50), nullable=False, default='COD')
    payment_date     = db.Column(db.DateTime, nullable=True)
    notes            = db.Column(db.Text)
    
    rating             = db.Column(db.Integer, nullable=True)
    feedback_text      = db.Column(db.Text, nullable=True)
    
    # AI Classification
    feedback_category  = db.Column(db.String(100), nullable=True)
    feedback_issue     = db.Column(db.String(100), nullable=True)
    feedback_sentiment = db.Column(db.String(20), nullable=True)
    feedback_keywords  = db.Column(db.String(500), nullable=True)

    created_at       = db.Column(db.DateTime, nullable=False, default=datetime.utcnow)
    updated_at       = db.Column(db.DateTime, nullable=False, default=datetime.utcnow, onupdate=datetime.utcnow)

    # Relationships
    buyer            = db.relationship('User', backref=db.backref('orders', lazy='dynamic'))
    items            = db.relationship('OrderItem', backref='order', lazy='joined',
                                        cascade='all, delete-orphan')

    @property
    def status_label(self):
        return self.status.value.replace('_', ' ').title()

    @property
    def item_count(self):
        return len(self.items)

    def __repr__(self):
        return f'<Order #{self.id} buyer={self.buyer_id} â‚±{self.total_amount} [{self.status.value}]>'


# â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
# TABLE 7: order_items
# â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

class OrderItem(db.Model):
    """
    Line items within an order.
    Captures a snapshot of the unit price at order time so it never changes retroactively.
    """
    __tablename__ = 'order_items'

    id           = db.Column(db.Integer, primary_key=True, autoincrement=True)
    order_id     = db.Column(db.Integer, db.ForeignKey('orders.id'), nullable=False, index=True)
    product_id   = db.Column(db.Integer, db.ForeignKey('products.id'), nullable=False, index=True)
    quantity     = db.Column(db.Integer, nullable=False, default=1)
    unit_price   = db.Column(db.Numeric(10, 2), nullable=False)   # price snapshot at order time

    @property
    def subtotal(self):
        return float(self.quantity) * float(self.unit_price)

    def __repr__(self):
        return f'<OrderItem order={self.order_id} product={self.product_id} qty={self.quantity}>'


# â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
# TABLE 8: conversations
# â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

class Conversation(db.Model):
    """
    A conversation thread between a farmer and a buyer.
    Each pair can only have one active conversation (enforced by unique constraint).
    """
    __tablename__ = 'conversations'

    id               = db.Column(db.Integer, primary_key=True, autoincrement=True)
    farmer_id        = db.Column(db.Integer, db.ForeignKey('users.id'), nullable=False, index=True)
    participant_id   = db.Column(db.Integer, db.ForeignKey('users.id'), nullable=False, index=True)
    participant_role = db.Column(db.String(32), nullable=False)   # 'buyer'
    # Soft-delete flags per side
    deleted_by_farmer      = db.Column(db.Boolean, default=False)
    deleted_by_participant = db.Column(db.Boolean, default=False)
    created_at       = db.Column(db.DateTime, nullable=False, default=datetime.utcnow)

    farmer      = db.relationship('User', foreign_keys=[farmer_id],
                                  backref=db.backref('farmer_conversations', lazy='dynamic'))
    participant = db.relationship('User', foreign_keys=[participant_id],
                                  backref=db.backref('participant_conversations', lazy='dynamic'))
    messages    = db.relationship('Message', backref='conversation', lazy='dynamic',
                                  cascade='all, delete-orphan')

    __table_args__ = (
        db.UniqueConstraint('farmer_id', 'participant_id', name='uq_convo_pair'),
    )

    def other_user(self, current_user_id):
        """Return the other participant from this user's perspective."""
        if self.farmer_id == current_user_id:
            return self.participant
        return self.farmer

    def last_message(self):
        return self.messages.order_by(Message.sent_at.desc()).first()

    def unread_count(self, viewer_id):
        """Count messages NOT sent by viewer that are unseen."""
        return self.messages.filter(
            Message.sender_id != viewer_id,
            Message.is_seen == False
        ).count()

    def __repr__(self):
        return f'<Conversation #{self.id} farmer={self.farmer_id} <-> {self.participant_id}>'


# â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
# TABLE 9: messages
# â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

class Message(db.Model):
    """
    Individual chat messages within a conversation.
    """
    __tablename__ = 'messages'

    id              = db.Column(db.Integer, primary_key=True, autoincrement=True)
    conversation_id = db.Column(db.Integer, db.ForeignKey('conversations.id'), nullable=False, index=True)
    sender_id       = db.Column(db.Integer, db.ForeignKey('users.id'), nullable=False, index=True)
    receiver_id     = db.Column(db.Integer, db.ForeignKey('users.id'), nullable=False, index=True)
    body            = db.Column(db.Text, nullable=False)
    sent_at         = db.Column(db.DateTime, nullable=False, default=datetime.utcnow, index=True)
    delivered_at    = db.Column(db.DateTime, nullable=True)
    seen_at         = db.Column(db.DateTime, nullable=True)
    is_seen         = db.Column(db.Boolean, nullable=False, default=False, index=True)

    sender   = db.relationship('User', foreign_keys=[sender_id],
                               backref=db.backref('sent_messages', lazy='dynamic'))
    receiver = db.relationship('User', foreign_keys=[receiver_id],
                               backref=db.backref('received_messages', lazy='dynamic'))

    def to_dict(self, current_user_id):
        return {
            'id': self.id,
            'body': self.body,
            'sender_id': self.sender_id,
            'is_mine': self.sender_id == current_user_id,
            'sent_at': self.sent_at.strftime('%H:%M') if self.sent_at else '',
            'sent_at_full': self.sent_at.strftime('%b %d, %H:%M') if self.sent_at else '',
            'is_seen': self.is_seen,
            'seen_at': self.seen_at.strftime('%H:%M') if self.seen_at else None,
        }

    def __repr__(self):
        return f'<Message #{self.id} conv={self.conversation_id} from={self.sender_id}>'


# â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
# TABLE 10: notifications
# â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

class Notification(db.Model):
    """
    In-app notification entries per user (new message, seen, etc.)
    """
    __tablename__ = 'notifications'

    id         = db.Column(db.Integer, primary_key=True, autoincrement=True)
    user_id    = db.Column(db.Integer, db.ForeignKey('users.id'), nullable=False, index=True)
    title      = db.Column(db.String(120), nullable=False)
    body       = db.Column(db.String(255), nullable=False)
    notif_type = db.Column(db.String(32), nullable=False, default='message')  # 'message', 'seen'
    is_read    = db.Column(db.Boolean, nullable=False, default=False, index=True)
    link_url   = db.Column(db.String(255))
    created_at = db.Column(db.DateTime, nullable=False, default=datetime.utcnow)

    user = db.relationship('User', foreign_keys=[user_id],
                           backref=db.backref('notifications', lazy='dynamic'))

    def to_dict(self):
        return {
            'id': self.id,
            'title': self.title,
            'body': self.body,
            'type': self.notif_type,
            'is_read': self.is_read,
            'link_url': self.link_url,
            'created_at': self.created_at.strftime('%b %d, %H:%M'),
        }

    def __repr__(self):
        return f'<Notification #{self.id} user={self.user_id} [{self.notif_type}]>'


# â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
# TABLE 11: flock_history
# â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

class FlockHistory(db.Model):
    """
    Log of flock size changes (additions, deaths, sales, corrections).
    """
    __tablename__ = 'flock_history'

    id          = db.Column(db.Integer, primary_key=True, autoincrement=True)
    farm_id     = db.Column(db.Integer, db.ForeignKey('farms.id'), nullable=False, index=True)
    user_id     = db.Column(db.Integer, db.ForeignKey('users.id'), nullable=False, index=True)
    date        = db.Column(db.Date, nullable=False, index=True)
    change_type = db.Column(db.String(50), nullable=False) # 'initial', 'correction', 'added', 'removed', 'died'
    quantity    = db.Column(db.Integer, nullable=False)
    notes       = db.Column(db.Text)
    created_at  = db.Column(db.DateTime, nullable=False, default=datetime.utcnow)
    
    farm = db.relationship('Farm', backref=db.backref('flock_history', lazy='dynamic'))

    def __repr__(self):
        return f'<FlockHistory farm={self.farm_id} {self.change_type} {self.quantity}>'


# â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
# TABLE 12: feed_records
# â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

class FeedRecord(db.Model):
    """
    Log of daily feed consumption per farm.
    """
    __tablename__ = 'feed_records'

    id               = db.Column(db.Integer, primary_key=True, autoincrement=True)
    farm_id          = db.Column(db.Integer, db.ForeignKey('farms.id'), nullable=False, index=True)
    user_id          = db.Column(db.Integer, db.ForeignKey('users.id'), nullable=False, index=True)
    record_date      = db.Column(db.Date, nullable=False, index=True)
    feed_type        = db.Column(db.String(100), nullable=False)
    feed_consumed_kg = db.Column(db.Numeric(8, 2), default=0.00)
    feed_cost        = db.Column(db.Numeric(10, 2), default=0.00)
    notes            = db.Column(db.Text)
    created_at       = db.Column(db.DateTime, nullable=False, default=datetime.utcnow)
    updated_at       = db.Column(db.DateTime, nullable=False, default=datetime.utcnow, onupdate=datetime.utcnow)

    farm = db.relationship('Farm', backref=db.backref('feed_records', lazy='dynamic'))

    def __repr__(self):
        return f'<FeedRecord farm={self.farm_id} {self.feed_consumed_kg}kg>'


# â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
# TABLE 13: mortality_records
# â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

class MortalityRecord(db.Model):
    """
    Log of bird mortality per farm.
    """
    __tablename__ = 'mortality_records'

    id            = db.Column(db.Integer, primary_key=True, autoincrement=True)
    farm_id       = db.Column(db.Integer, db.ForeignKey('farms.id'), nullable=False, index=True)
    user_id       = db.Column(db.Integer, db.ForeignKey('users.id'), nullable=False, index=True)
    record_date   = db.Column(db.Date, nullable=False, index=True)
    quantity_died = db.Column(db.Integer, nullable=False, default=0)
    reason        = db.Column(db.String(255), nullable=False)
    notes         = db.Column(db.Text)
    created_at    = db.Column(db.DateTime, nullable=False, default=datetime.utcnow)
    updated_at    = db.Column(db.DateTime, nullable=False, default=datetime.utcnow, onupdate=datetime.utcnow)

    farm = db.relationship('Farm', backref=db.backref('mortality_records', lazy='dynamic'))

    def __repr__(self):
        return f'<MortalityRecord farm={self.farm_id} died={self.quantity_died}>'


# ─────────────────────────────────────────────────────────────
# TABLE 14: farmer_verifications
# ─────────────────────────────────────────────────────────────

class FarmerVerification(db.Model):
    """
    Tracks admin verification status for each farmer.
    One record per farmer (upserted on resubmit).
    """
    __tablename__ = 'farmer_verifications'

    id               = db.Column(db.Integer, primary_key=True, autoincrement=True)
    farmer_id        = db.Column(db.Integer, db.ForeignKey('users.id'), nullable=False, unique=True, index=True)
    status           = db.Column(
                           db.Enum(VerificationStatus, values_callable=lambda e: [x.value for x in e]),
                           nullable=False,
                           default=VerificationStatus.PENDING,
                           index=True
                       )
    rejection_reason = db.Column(db.Text, nullable=True)
    reviewed_by_id   = db.Column(db.Integer, db.ForeignKey('users.id'), nullable=True)
    reviewed_at      = db.Column(db.DateTime, nullable=True)
    notes            = db.Column(db.Text, nullable=True)   # admin notes
    created_at       = db.Column(db.DateTime, nullable=False, default=datetime.utcnow)
    updated_at       = db.Column(db.DateTime, nullable=False, default=datetime.utcnow, onupdate=datetime.utcnow)

    # Relationships
    farmer      = db.relationship('User', foreign_keys=[farmer_id], backref=db.backref('verification', uselist=False))
    reviewed_by = db.relationship('User', foreign_keys=[reviewed_by_id])

    def __repr__(self):
        return f'<FarmerVerification farmer={self.farmer_id} status={self.status.value}>'


# ─────────────────────────────────────────────────────────────
# TABLE 15: content_moderations
# ─────────────────────────────────────────────────────────────

class ContentModeration(db.Model):
    """
    Tracks AI + admin moderation for uploaded images/content.
    """
    __tablename__ = 'content_moderations'

    id             = db.Column(db.Integer, primary_key=True, autoincrement=True)
    product_id     = db.Column(db.Integer, db.ForeignKey('products.id'), nullable=True, index=True)
    uploader_id    = db.Column(db.Integer, db.ForeignKey('users.id'), nullable=False, index=True)
    image_url      = db.Column(db.String(500), nullable=False)
    status         = db.Column(
                         db.Enum(ModerationStatus, values_callable=lambda e: [x.value for x in e]),
                         nullable=False,
                         default=ModerationStatus.PENDING,
                         index=True
                     )
    ai_result      = db.Column(db.Text, nullable=True)     # JSON: full AI response
    ai_flag_reason = db.Column(db.Text, nullable=True)     # Human-readable AI flag reason
    ai_safe        = db.Column(db.Boolean, nullable=True)  # True = AI cleared it
    admin_action   = db.Column(db.Text, nullable=True)     # Admin decision note
    reviewed_by_id = db.Column(db.Integer, db.ForeignKey('users.id'), nullable=True)
    reviewed_at    = db.Column(db.DateTime, nullable=True)
    created_at     = db.Column(db.DateTime, nullable=False, default=datetime.utcnow)

    # Relationships
    product     = db.relationship('Product', backref=db.backref('moderation_records', lazy='dynamic'))
    uploader    = db.relationship('User', foreign_keys=[uploader_id])
    reviewed_by = db.relationship('User', foreign_keys=[reviewed_by_id])

    def __repr__(self):
        return f'<ContentModeration product={self.product_id} status={self.status.value}>'

# ─────────────────────────────────────────
# TABLE: buyer_feedback
# ─────────────────────────────────────────

class FeedbackCategory(str, enum.Enum):
    PRODUCT = 'product'
    DELIVERY = 'delivery'
    WEBSITE = 'website'

class BuyerFeedback(db.Model):
    __tablename__ = 'buyer_feedback'

    id = db.Column(db.Integer, primary_key=True, autoincrement=True)
    buyer_id = db.Column(db.Integer, db.ForeignKey('users.id'), nullable=False, index=True)
    order_id = db.Column(db.Integer, db.ForeignKey('orders.id'), nullable=True, index=True)
    product_id = db.Column(db.Integer, db.ForeignKey('products.id'), nullable=True, index=True)
    farmer_id = db.Column(db.Integer, db.ForeignKey('users.id'), nullable=True, index=True)

    
    category = db.Column(
        db.Enum(FeedbackCategory, values_callable=lambda enum_cls: [e.value for e in enum_cls]),
        nullable=False
    )
    rating = db.Column(db.Integer, nullable=True)
    feedback_text = db.Column(db.Text, nullable=False)
    
    # AI Classification
    ai_issue = db.Column(db.String(100), nullable=True)
    ai_sentiment = db.Column(db.String(20), nullable=True)
    ai_keywords = db.Column(db.String(500), nullable=True)

    created_at = db.Column(db.DateTime, nullable=False, default=datetime.utcnow)
    updated_at = db.Column(db.DateTime, nullable=False, default=datetime.utcnow, onupdate=datetime.utcnow)

    buyer = db.relationship('User', foreign_keys=[buyer_id], backref=db.backref('submitted_feedback', lazy='dynamic'))
    farmer = db.relationship('User', foreign_keys=[farmer_id], backref=db.backref('received_feedback', lazy='dynamic'))
    order = db.relationship('Order', backref=db.backref('buyer_feedback', lazy='dynamic'))
    product = db.relationship('Product', backref=db.backref('buyer_feedback', lazy='dynamic'))
