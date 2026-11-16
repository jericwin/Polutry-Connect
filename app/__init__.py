from flask import Flask
from flask_sqlalchemy import SQLAlchemy
from flask_migrate import Migrate
from flask_login import LoginManager
from flask_mail import Mail
from config import Config

db = SQLAlchemy()
migrate = Migrate()
login = LoginManager()
login.login_view = 'auth.login'
login.login_message = 'Please log in to access this page.'
mail = Mail()

def create_app(config_class=Config):
    app = Flask(__name__)
    app.config.from_object(config_class)

    db.init_app(app)
    migrate.init_app(app, db)
    login.init_app(app)
    mail.init_app(app)

    # Register Blueprints
    from app.routes.auth.auth import auth_bp
    from app.routes.dashboard.dashboard import dashboard_bp
    from app.routes.production.production import production_bp
    from app.routes.analytics.analytics import analytics_bp
    from app.routes.marketplace.marketplace import marketplace_bp
    from app.routes.community.community import community_bp
    from app.routes.admin.admin import admin_bp
    from app.routes.messaging.messaging import messaging_bp
    from app.routes.supplier.supplier import supplier_bp
    from app.routes.vet.vet import vet_bp
    from app.routes.dashboard.buyer import buyer_bp

    app.register_blueprint(auth_bp, url_prefix='/auth')
    app.register_blueprint(dashboard_bp, url_prefix='/dashboard')
    app.register_blueprint(production_bp, url_prefix='/production')
    app.register_blueprint(analytics_bp, url_prefix='/analytics')
    app.register_blueprint(marketplace_bp, url_prefix='/marketplace')
    app.register_blueprint(community_bp, url_prefix='/community')
    app.register_blueprint(admin_bp, url_prefix='/admin')
    app.register_blueprint(messaging_bp, url_prefix='/messaging')
    app.register_blueprint(supplier_bp, url_prefix='/supplier')
    app.register_blueprint(vet_bp, url_prefix='/vet')
    app.register_blueprint(buyer_bp, url_prefix='/buyer')

    # Main index / Landing page route
    @app.route('/')
    def index():
        from flask import render_template
        from app.models import Farm
        # Fetch latest active farms for landing preview
        try:
            preview_farms = Farm.query.filter_by(
                is_active=True
            ).order_by(
                Farm.created_at.desc()
            ).limit(6).all()
        except Exception as e:
            app.logger.warning(f"Error loading preview farms: {e}")
            preview_farms = []

        return render_template(
            'landing.html',
            title='PoultryConnect — Smart Farming, Better Living',
            preview_farms=preview_farms,
        )

    # Uploaded files (stored in DB) ─────────────────────────────
    from app.utils.storage import media_url
    app.jinja_env.filters['media_url'] = media_url

    @app.route('/media/<int:file_id>')
    def media(file_id):
        from flask import Response, abort
        from flask_login import current_user
        from app.models import StoredFile, UserRole
        rec = db.session.get(StoredFile, file_id)
        if rec is None:
            abort(404)
        if rec.is_private:
            if not current_user.is_authenticated:
                abort(403)
            if current_user.id != rec.owner_id and current_user.role != UserRole.ADMIN:
                abort(403)
        resp = Response(rec.data, mimetype=rec.mimetype)
        resp.headers['Content-Disposition'] = f'inline; filename="{rec.filename}"'
        resp.headers['Cache-Control'] = ('private' if rec.is_private else 'public') + ', max-age=31536000, immutable'
        return resp

    with app.app_context():
        try:
            from app import models  # Ensure all models are registered
            db.create_all()
        except Exception as e:
            app.logger.warning(f"Auto db.create_all() warning: {e}")
        try:
            _ensure_columns()
        except Exception as e:
            app.logger.warning(f"Auto column migration warning: {e}")

    return app


# Columns added after the first release. db.create_all() never alters existing
# tables, so add any that are missing (works on SQLite, XAMPP MySQL and TiDB).
_NEW_COLUMNS = {
    'orders': [
        ('estimated_days', 'INTEGER'),
        ('fulfillment_note', 'VARCHAR(255)'),
        ('confirmed_at', 'DATETIME'),
        ('shipped_at', 'DATETIME'),
    ],
}


def _ensure_columns():
    from sqlalchemy import inspect, text
    insp = inspect(db.engine)
    tables = set(insp.get_table_names())
    with db.engine.begin() as conn:
        for table, cols in _NEW_COLUMNS.items():
            if table not in tables:
                continue
            existing = {c['name'] for c in insp.get_columns(table)}
            for name, ddl in cols:
                if name not in existing:
                    conn.execute(text(f'ALTER TABLE {table} ADD COLUMN {name} {ddl} NULL'))


from app import models
