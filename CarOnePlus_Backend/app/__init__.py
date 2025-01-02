from flask import Flask
from flask_sqlalchemy import SQLAlchemy
from flask_migrate import Migrate
from flask_jwt_extended import JWTManager
from flask_bcrypt import Bcrypt

db = SQLAlchemy()
migrate = Migrate()
jwt = JWTManager()
bcrypt = Bcrypt()


def create_app():
    app = Flask(__name__)

    # Charger la configuration
    app.config.from_object('app.config.Config')

    # Initialiser les extensions
    db.init_app(app)
    migrate.init_app(app, db)
    jwt.init_app(app)
    bcrypt.init_app(app)

    # Enregistrer les blueprints
    from app.routes import auth
    from app.routes import vehicles
    from app.routes import reservations
    app.register_blueprint(auth)
    app.register_blueprint(vehicles)
    app.register_blueprint(reservations)

    return app
