from flask import Flask, current_app
from flask_cors import CORS
from flask_sqlalchemy import SQLAlchemy
from flask_migrate import Migrate
from flask_jwt_extended import JWTManager
from flask_bcrypt import Bcrypt
import stripe
from flask_mail import Mail


db = SQLAlchemy()
migrate = Migrate()
jwt = JWTManager()
bcrypt = Bcrypt()
mail = Mail()



def create_app(env="default"):
    app = Flask(__name__)

    # Charger la configuration en fonction de l'environnement
    from app.config import config
    app.config.from_object(config[env])
    

    #Configuration Stripe
    stripe.api_key = app.config["STRIPE_API_KEY"]
    stripe.public_key = app.config["STRIPE_PUBLIC_KEY"]

    

    # Initialiser les extensions
    db.init_app(app)
    migrate.init_app(app, db)
    jwt.init_app(app)
    bcrypt.init_app(app)
    mail.init_app(app)
    
    
    from app.models import RevokedToken

    @jwt.token_in_blocklist_loader
    def check_if_token_revoked(jwt_header, jwt_payload):
        return RevokedToken.is_token_revoked(jwt_payload["jti"])


    # Enregistrer les blueprints
    from app.routes import auth
    from app.routes import vehicles
    from app.routes import reservations
    from app.routes import payments
    from app.routes import geo
    from app.routes import reviews
    from app.routes import incidents
    from app.routes import support
    from app.routes import insurance
    from app.routes import home

    app.register_blueprint(auth)
    app.register_blueprint(vehicles)
    app.register_blueprint(reservations)
    app.register_blueprint(payments)
    app.register_blueprint(geo)
    app.register_blueprint(reviews)
    app.register_blueprint(incidents)
    app.register_blueprint(support)
    app.register_blueprint(insurance)
    app.register_blueprint(home)

    CORS(app)

    return app
