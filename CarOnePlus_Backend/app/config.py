
import os
from dotenv import load_dotenv

uri = os.getenv("DATABASE_URL")
if uri and uri.startswith("postgres://"):
    os.environ["DATABASE_URL"] = uri.replace("postgres://", "postgresql://", 1)

class Config:
    # Clés de sécurité
    SECRET_KEY = os.environ.get("SECRET_KEY", "fallback_dev_secret")
    JWT_SECRET_KEY = os.environ.get("JWT_SECRET_KEY", "fallback_jwt_secret")

    # Base de données
    SQLALCHEMY_DATABASE_URI = os.environ.get("DATABASE_URL", "sqlite:///fallback.db")
    SQLALCHEMY_TRACK_MODIFICATIONS = False

    # Répertoire pour les images
    UPLOAD_FOLDER = os.path.join(os.getcwd(), "uploads")
    ALLOWED_EXTENSIONS = {"png", "jpg", "jpeg", "gif"}

    # Stripe
    STRIPE_API_KEY = os.environ.get("STRIPE_API_KEY")
    STRIPE_PUBLIC_KEY = os.environ.get("STRIPE_PUBLIC_KEY")
    STRIPE_WEBHOOK_SECRET = os.environ.get("STRIPE_WEBHOOK_SECRET")


    # Email SMTP (Brevo)
    MAIL_SERVER = "smtp-relay.brevo.com"
    MAIL_PORT = 587
    MAIL_USE_TLS = True
    MAIL_USERNAME = os.environ.get("BREVO_USERNAME")
    MAIL_PASSWORD = os.environ.get("BREVO_SMTP_KEY")
    MAIL_DEFAULT_SENDER = os.environ.get("BREVO_EMAIL")



class DevelopmentConfig(Config):
    DEBUG = True
    ENV = "development"


class ProductionConfig(Config):
    DEBUG = False
    ENV = "production"


# Choix dynamique en fonction d'une variable HEROKU_ENV (par défaut dev)
config = {
    "development": DevelopmentConfig,
    "production": ProductionConfig,
    "default": ProductionConfig if os.environ.get("HEROKU_ENV") == "production" else DevelopmentConfig
}



#--------------------Configuration pour le local-------------------------

# import os
# from dotenv import load_dotenv

# load_dotenv()

# class Config:
#     SECRET_KEY = os.getenv("SECRET_KEY", "dev")
#     SQLALCHEMY_DATABASE_URI = os.getenv(
#         "DATABASE_URL", "postgresql://caroneuser:securepassword@localhost/caroneplus"
#     )
#     SQLALCHEMY_TRACK_MODIFICATIONS = False
#     JWT_SECRET_KEY = os.getenv("JWT_SECRET_KEY", "jwt-secret")

#     # Répertoire pour les images
#     UPLOAD_FOLDER = os.path.join(os.getcwd(), "uploads")
#     ALLOWED_EXTENSIONS = {"png", "jpg", "jpeg", "gif"}

#     # Stripe
#     STRIPE_API_KEY = os.getenv("STRIPE_API_KEY")
#     STRIPE_PUBLIC_KEY = os.getenv("STRIPE_PUBLIC_KEY")
#     STRIPE_WEBHOOK_SECRET = os.getenv("STRIPE_WEBHOOK_SECRET")

#     # Google Maps API
#     GOOGLE_MAPS_API_KEY = os.getenv("GOOGLE_MAPS_API_KEY")


#     # Configuration Brevo SMTP
#     MAIL_SERVER = "smtp-relay.brevo.com"
#     MAIL_PORT = 587
#     MAIL_USE_TLS = True
#     MAIL_USERNAME = os.getenv("BREVO_USERNAME")  # Ton email Brevo
#     MAIL_PASSWORD = os.getenv("BREVO_SMTP_KEY")  # Clé API SMTP de Brevo
#     MAIL_DEFAULT_SENDER = os.getenv("BREVO_EMAIL")


#     # URL du frontend pour les liens de confirmation
#     FRONTEND_URL = "http://localhost:3000"



# class DevelopmentConfig(Config):
#     DEBUG = True
#     ENV = "development"


# class ProductionConfig(Config):
#     DEBUG = False
#     ENV = "production"


# config = {
#     "development": DevelopmentConfig,
#     "production": ProductionConfig,
#     "default": DevelopmentConfig
# }