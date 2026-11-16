"""
seed_revision.py — PoultryConnect data reset (panel revision, Nov 2026)

* Deletes ALL existing data and accounts.
* Creates the admin, the 4 owners from the revision list, and 3 sample buyers.
* Generates realistic small-farm data for Oct 1 – Nov 16, 2026 only:
  production by size/variety, feed (several feed types per day), flock history
  (original flock, additions, mortality), expenses, on-site sales and online orders.
* Every farm ends each month with a profit (no net loss).

Run:  python seed_revision.py
Works on SQLite, XAMPP MySQL, and TiDB (whatever DATABASE_URL / config points to).
"""
import math
import random
from datetime import date, datetime, timedelta
from decimal import Decimal

from app import create_app, db
from app.models import (
    User, UserRole, SubscriptionPlan, Farm, FarmerVerification, VerificationStatus,
    ProductionRecord, ProductSize, ProductVariety, ProductUnit, Product, ModerationStatus,
    FeedRecord, FlockHistory, MortalityRecord, Expense, ExpenseCategory, ExpenseFrequency,
    SalesRecord, Order, OrderItem, OrderStatus, Notification,
)

random.seed(20261116)

START = date(2026, 10, 1)
END = date(2026, 11, 16)
PASSWORDS = {}

# ── People ────────────────────────────────────────────────────────────────
ADMIN = dict(username='admin', email='admin@poultryconnect.com', first='System', last='Administrator',
             phone='09170000001', password='Admin#2026')

OWNERS = [
    dict(username='ardonn', email='ardonn.sales@poultryconnect.com', first='Ardonn', last='Sales',
         phone='09171230001', password='Ardonn#2026',
         farm='Ardonn Farm', location='Brgy. Macasipac, Sta. Maria, Laguna',
         flock={'brown': 300}, desc='Small family layer farm raising brown-egg layers.'),
    dict(username='benito', email='benito.valmonte@poultryconnect.com', first='Benito', last='Valmonte',
         phone='09171230002', password='Benito#2026',
         farm='Benito Farm', location='Brgy. Iniyapan, Sta. Maria, Laguna',
         flock={'brown': 800, 'white': 400}, desc='Two-house layer farm producing brown and white eggs.'),
    dict(username='jane', email='jane.ison@poultryconnect.com', first='Jane', last='Ison',
         phone='09171230003', password='Jane#2026',
         farm='Coco-A-Vanilla Farm', location='Brgy. Bubucal, Sta. Maria, Laguna',
         flock={'white': 350}, desc='Backyard layer farm known for clean white eggs.'),
    dict(username='digna', email='digna.fernandez@poultryconnect.com', first='Digna', last='Fernandez',
         phone='09171230004', password='Digna#2026',
         farm="Ising's Farm", location='Brgy. Balian, Pangil, Laguna',
         flock={'brown': 300}, desc='Family-run layer farm supplying fresh brown eggs to nearby stores.'),
]

BUYERS = [
    dict(username='liza', email='liza.manalo@poultryconnect.com', first='Liza', last='Manalo',
         phone='09181110001', password='Buyer#2026', address='Brgy. Poblacion, Sta. Maria, Laguna'),
    dict(username='ramon', email='ramon.dizon@poultryconnect.com', first='Ramon', last='Dizon',
         phone='09181110002', password='Buyer#2026', address='Brgy. Coralan, Sta. Maria, Laguna'),
    dict(username='carla', email='carla.bautista@poultryconnect.com', first='Carla', last='Bautista',
         phone='09181110003', password='Buyer#2026', address='Brgy. Mabato, Famy, Laguna'),
]

WALK_IN = ['Walk-in Buyer', "Aling Nena's Sari-sari Store", 'Kuya Jun Carinderia', 'Barangay Bakery',
           "Tess' Mini Mart", 'Walk-in Buyer', 'Mang Pido (reseller)']

# ── Egg economics (Laguna farm-gate, late 2026) ───────────────────────────
SIZES = ['small', 'medium', 'large', 'extra_large', 'jumbo']
SIZE_SHARE = {'small': 0.10, 'medium': 0.30, 'large': 0.35, 'extra_large': 0.18, 'jumbo': 0.07}
TRAY_PRICE = {  # per tray of 30
    'brown': {'small': 195, 'medium': 225, 'large': 250, 'extra_large': 270, 'jumbo': 290},
    'white': {'small': 185, 'medium': 215, 'large': 240, 'extra_large': 260, 'jumbo': 280},
}
SIZE_LABEL = {'small': 'Small', 'medium': 'Medium', 'large': 'Large', 'extra_large': 'Extra Large', 'jumbo': 'Jumbo'}
LAYER_MASH_PER_KG = Decimal('32.00')   # ₱1,600 / 50 kg bag
GROWER_MASH_PER_KG = Decimal('31.00')
SHELL_GRIT_PER_KG = Decimal('25.00')


def d2(x):
    return Decimal(str(round(float(x), 2)))


def daterange(a, b):
    d = a
    while d <= b:
        yield d
        d += timedelta(days=1)


def wipe():
    """Delete every row from every table (children first)."""
    print('Clearing all existing data and accounts...')
    for table in reversed(db.metadata.sorted_tables):
        db.session.execute(table.delete())
    db.session.commit()


def make_user(p, role, created):
    u = User(username=p['username'], email=p['email'], role=role,
             first_name=p['first'], last_name=p['last'], phone=p['phone'],
             address=p.get('address') or p.get('location'), is_active=True,
             created_at=created, updated_at=created)
    u.set_password(p['password'])
    if role == UserRole.FARMER:
        u.subscription_plan = SubscriptionPlan.YEARLY
        u.subscription_end = datetime(2027, 10, 1)
        u.trial_end = created + timedelta(days=7)
    PASSWORDS[p['email']] = (p['username'], p['password'], role.value)
    db.session.add(u)
    return u


def main():
    app = create_app()
    with app.app_context():
        db.create_all()
        wipe()

        created = datetime(2026, 10, 1, 8, 0)
        admin = make_user(ADMIN, UserRole.ADMIN, created - timedelta(days=3))
        buyers = [make_user(b, UserRole.BUYER, created + timedelta(days=i)) for i, b in enumerate(BUYERS)]
        db.session.commit()

        summary = []
        all_products = []
        for o in OWNERS:
            owner = make_user(o, UserRole.FARMER, created)
            db.session.flush()
            total_flock = sum(o['flock'].values())
            farm = Farm(farmer_id=owner.id, name=o['farm'], location=o['location'], description=o['desc'],
                        flock_size=total_flock, is_active=True, created_at=created, updated_at=created)
            db.session.add(farm)
            db.session.flush()
            db.session.add(FarmerVerification(
                farmer_id=owner.id, status=VerificationStatus.APPROVED, farm_name=o['farm'],
                farm_location=o['location'], initial_flock_size=total_flock,
                id_type='PhilSys National ID', id_number=f'PSN-{4000 + owner.id:04d}-{random.randint(1000, 9999)}',
                permit_type='Barangay Clearance for Poultry / Business',
                id_document_url='uploads/verifications/sample_philsys_id.png',
                permit_document_url='uploads/verifications/sample_barangay_permit.png',
                farm_photo_url='uploads/verifications/sample_poultry_farm.png',
                reviewed_by_id=admin.id, reviewed_at=created + timedelta(hours=5),
                created_at=created, updated_at=created + timedelta(hours=5)))

            # Products (sold per tray of 30) — real egg photos
            products = {}
            for variety in o['flock']:
                for size in SIZES:
                    p = Product(
                        farmer_id=owner.id, farm_id=farm.id,
                        name=f"{o['farm']} {variety.title()} Eggs ({SIZE_LABEL[size]})",
                        description=f"Fresh {variety} eggs, {SIZE_LABEL[size].lower()} size, collected daily at {o['farm']}. 30 eggs per tray.",
                        size=ProductSize(size), variety=ProductVariety(variety), unit=ProductUnit.TRAY,
                        price=Decimal(TRAY_PRICE[variety][size]), stock=0, location=o['location'],
                        is_available=True, moderation_status=ModerationStatus.APPROVED,
                        image_url=f'/static/img/eggs/{variety}-eggs.jpg',
                        created_at=created, updated_at=created)
                    db.session.add(p)
                    products[(variety, size)] = p
            db.session.flush()
            all_products.extend(products.values())

            # Flock: original + events
            flock = dict(o['flock'])
            db.session.add(FlockHistory(farm_id=farm.id, user_id=owner.id, date=START, change_type='initial',
                                        quantity=total_flock, notes='Original flock size when the farm was registered.'))
            added_events = {}
            if o['username'] == 'benito':
                added_events[date(2026, 10, 20)] = ('brown', 50, 'New batch of ready-to-lay pullets (18 weeks).')
            if o['username'] == 'jane':
                added_events[date(2026, 11, 3)] = ('white', 20, 'Replacement layers bought from nearby hatchery.')
            pullets_until = date(2026, 11, 3)  # new pullets eat grower mash ~2 weeks

            inventory = {k: 0 for k in products}  # eggs on hand
            week_feed_cost = Decimal('0')
            revenue = {'10': 0.0, '11': 0.0}
            expense_total = {'10': 0.0, '11': 0.0}
            pending_online = []

            def add_expense(day, cat, amount, desc):
                db.session.add(Expense(farm_id=farm.id, user_id=owner.id, expense_date=day, category=cat,
                                       frequency=ExpenseFrequency.ONE_TIME, amount=d2(amount), description=desc,
                                       created_at=datetime.combine(day, datetime.min.time()) + timedelta(hours=17)))
                expense_total[f'{day.month}'] += float(amount)

            for day in daterange(START, END):
                stamp = datetime.combine(day, datetime.min.time()) + timedelta(hours=7)

                # ── flock changes ──
                if day in added_events:
                    v, qty, note = added_events[day]
                    flock[v] += qty
                    db.session.add(FlockHistory(farm_id=farm.id, user_id=owner.id, date=day, change_type='added',
                                                quantity=qty, notes=note))
                    add_expense(day, ExpenseCategory.OTHER, qty * 290, f'Purchase of {qty} ready-to-lay pullets')
                for v in list(flock):
                    # ~2% of the flock over the period, a bird here and there
                    if random.random() < flock[v] * 0.00045:
                        died = 1 if random.random() < 0.85 else 2
                        reason = random.choice(['Heat stress', 'Sudden death', 'Respiratory illness', 'Egg-bound', 'Injury'])
                        flock[v] -= died
                        db.session.add(FlockHistory(farm_id=farm.id, user_id=owner.id, date=day, change_type=reason,
                                                    quantity=-died, notes=f'{v.title()} layer house'))
                        db.session.add(MortalityRecord(farm_id=farm.id, user_id=owner.id, record_date=day,
                                                       quantity_died=died, reason=reason, notes=f'{v.title()} layer house'))

                # ── production by variety & size ──
                for v, hens in flock.items():
                    rate = random.uniform(0.82, 0.90)
                    eggs = int(hens * rate)
                    remaining = eggs
                    for i, size in enumerate(SIZES):
                        n = remaining if i == len(SIZES) - 1 else int(round(eggs * SIZE_SHARE[size] * random.uniform(0.9, 1.1)))
                        n = max(0, min(n, remaining))
                        remaining -= n
                        if n == 0:
                            continue
                        price_per_egg = d2(TRAY_PRICE[v][size] / 30)
                        db.session.add(ProductionRecord(
                            farm_id=farm.id, user_id=owner.id, record_date=day, egg_count=n,
                            size=ProductSize(size), variety=ProductVariety(v), egg_price=price_per_egg,
                            feed_kg=Decimal('0'), feed_cost=Decimal('0'), mortality=0,
                            created_at=stamp, updated_at=stamp))
                        inventory[(v, size)] += n

                # ── feed: several feed types per day ──
                layers = sum(flock.values())
                pullets = 0
                if o['username'] == 'benito' and date(2026, 10, 20) <= day < pullets_until:
                    pullets = 50
                mash_kg = d2((layers - pullets) * random.uniform(0.110, 0.118))
                feeds = [('Layer Mash', mash_kg, mash_kg * LAYER_MASH_PER_KG)]
                if pullets:
                    g = d2(pullets * 0.09)
                    feeds.append(('Grower / Pre-layer Mash', g, g * GROWER_MASH_PER_KG))
                if day.weekday() in (0, 3):  # shell grit twice a week for strong shells
                    sg = d2(max(1.0, layers * 0.004))
                    feeds.append(('Shell Grit (calcium)', sg, sg * SHELL_GRIT_PER_KG))
                for ftype, kg, cost in feeds:
                    db.session.add(FeedRecord(farm_id=farm.id, user_id=owner.id, record_date=day, feed_type=ftype,
                                              feed_consumed_kg=kg, feed_cost=d2(cost),
                                              created_at=stamp + timedelta(hours=1)))
                    week_feed_cost += d2(cost)

                # weekly feed purchase (Saturday or last day) — logged as an expense
                if day.weekday() == 5 or day == END:
                    bags = math.ceil(float(week_feed_cost) / 1600)
                    add_expense(day, ExpenseCategory.FEED, week_feed_cost,
                                f'Feed purchase for the week (~{bags} bags layer mash + supplements)')
                    week_feed_cost = Decimal('0')

                # ── other expenses ──
                if day.day == 5:
                    elec = {'ardonn': 780, 'benito': 2350, 'jane': 820, 'digna': 760}[o['username']]
                    add_expense(day, ExpenseCategory.UTILITIES, elec * random.uniform(0.95, 1.08), 'Electricity and water bill')
                if day.day == 8:
                    med = {'ardonn': 520, 'benito': 1650, 'jane': 560, 'digna': 480}[o['username']]
                    add_expense(day, ExpenseCategory.MEDICINE, med, 'Vitamins, electrolytes and dewormer')
                if day.day in (15, 30):
                    wage = {'ardonn': 2000, 'benito': 5400, 'jane': 2000, 'digna': 1800}[o['username']]
                    add_expense(day, ExpenseCategory.LABOR, wage, 'Helper wages (half month)')
                if day.day == 2:
                    trays_cost = {'ardonn': 360, 'benito': 1250, 'jane': 400, 'digna': 360}[o['username']]
                    add_expense(day, ExpenseCategory.OTHER, trays_cost, 'Egg trays and packaging')

                # ── selling: online orders + on-site sales ──
                # Online orders (a few per week)
                if random.random() < (0.45 if o['username'] == 'benito' else 0.28):
                    buyer = random.choice(buyers)
                    choices = [k for k in inventory if inventory[k] >= 60]
                    if choices:
                        key = random.choice(choices)
                        qty = random.randint(1, min(4, inventory[key] // 30))
                        prod = products[key]
                        inventory[key] -= qty * 30
                        order_time = datetime.combine(day, datetime.min.time()) + timedelta(hours=random.randint(8, 19), minutes=random.randint(0, 59))
                        order = Order(buyer_id=buyer.id, total_amount=prod.price * qty, status=OrderStatus.PENDING,
                                      delivery_address=BUYERS[buyers.index(buyer)]['address'], contact_phone=buyer.phone,
                                      payment_method='COD', created_at=order_time, updated_at=order_time)
                        db.session.add(order)
                        db.session.flush()
                        db.session.add(OrderItem(order_id=order.id, product_id=prod.id, quantity=qty, unit_price=prod.price))
                        pending_online.append((order, prod, qty, day))

                # On-site: sell full trays every 2 days, keep ~1 tray per size as stock
                if day.toordinal() % 2 == 0 or day == END:
                    for key, eggs in inventory.items():
                        trays = eggs // 30 - (1 if day == END else 0)
                        if trays <= 0:
                            continue
                        prod = products[key]
                        sell = trays if day != END else max(0, trays - random.randint(1, 3))
                        if sell <= 0:
                            continue
                        inventory[key] -= sell * 30
                        total = prod.price * sell
                        v, size = key
                        db.session.add(SalesRecord(
                            farm_id=farm.id, user_id=owner.id, sale_date=day, quantity_sold=sell,
                            price_per_egg=prod.price, total_revenue=total, buyer_name=random.choice(WALK_IN),
                            notes=f'Product: {prod.name} | Size: {SIZE_LABEL[size]} | Unit: Tray',
                            created_at=datetime.combine(day, datetime.min.time()) + timedelta(hours=15)))
                        revenue[f'{day.month}'] += float(total)

            # ── settle online orders ──
            for order, prod, qty, day in pending_online:
                age = (END - day).days
                confirmed_at = datetime.combine(day, datetime.min.time()) + timedelta(hours=20)
                if age >= 4:
                    order.status = OrderStatus.DELIVERED if age < 10 or random.random() < 0.4 else OrderStatus.COMPLETED
                    order.estimated_days = 2
                    order.fulfillment_note = 'Ready to be delivered'
                    order.confirmed_at = confirmed_at
                    order.shipped_at = confirmed_at + timedelta(days=1)
                    delivered_day = day + timedelta(days=2)
                    order.payment_date = datetime.combine(delivered_day, datetime.min.time()) + timedelta(hours=11)
                    order.updated_at = order.payment_date
                    db.session.add(SalesRecord(
                        farm_id=farm.id, user_id=owner.id, sale_date=delivered_day, quantity_sold=qty,
                        price_per_egg=prod.price, total_revenue=prod.price * qty,
                        buyer_name=order.buyer.full_name, notes=f'{prod.name} (Order #{order.id})',
                        created_at=order.payment_date))
                    revenue[f'{delivered_day.month}'] += float(prod.price * qty)
                elif age >= 2:
                    order.status = OrderStatus.SHIPPED
                    order.estimated_days = 2
                    order.fulfillment_note = 'Out for delivery'
                    order.confirmed_at = confirmed_at
                    order.shipped_at = confirmed_at + timedelta(days=1)
                elif age >= 1:
                    order.status = OrderStatus.CONFIRMED
                    order.estimated_days = random.choice([1, 2, 3])
                    order.fulfillment_note = random.choice(['Preparing your eggs', 'Ready for pick-up at the farm'])
                    order.confirmed_at = confirmed_at
                # age 0 → stays pending

            # remaining inventory becomes marketplace stock (trays)
            for key, prod in products.items():
                prod.stock = max(2, inventory[key] // 30 + random.randint(3, 12))

            farm.flock_size = sum(flock.values())
            db.session.commit()
            summary.append((o, farm, revenue, expense_total, farm.flock_size))

        # Welcome notifications
        for u in User.query.all():
            db.session.add(Notification(user_id=u.id, title='Welcome to PoultryConnect',
                                        body='Your account is ready. Explore the dashboard to get started.',
                                        notif_type='system', is_read=True,
                                        created_at=datetime(2026, 10, 1, 9, 0)))
        db.session.commit()

        print('\n================ PROFIT CHECK (must be > 0) ================')
        ok = True
        for o, farm, rev, exp, flock_now in summary:
            for m, name in (('10', 'Oct'), ('11', 'Nov 1-16')):
                profit = rev[m] - exp[m]
                ok &= profit > 0
                print(f"{farm.name:<22} {name:<9} revenue ₱{rev[m]:>11,.2f}  expenses ₱{exp[m]:>11,.2f}  profit ₱{profit:>10,.2f}")
            print(f"{'':<22} flock now {flock_now}")
        print('ALL PROFITABLE' if ok else 'WARNING: a farm has a net loss!')

        print('\n================ ACCOUNTS ================')
        for email, (uname, pw, role) in PASSWORDS.items():
            print(f'{role:<8} {uname:<8} {email:<38} {pw}')


if __name__ == '__main__':
    main()
