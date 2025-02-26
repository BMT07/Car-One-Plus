import os
from dotenv import load_dotenv

load_dotenv()

class Config:
    SECRET_KEY = os.getenv("SECRET_KEY", "dev")
    SQLALCHEMY_DATABASE_URI = os.getenv(
        "DATABASE_URL", "postgresql://caroneuser:securepassword@localhost/caroneplus"
    )
    SQLALCHEMY_TRACK_MODIFICATIONS = False
    JWT_SECRET_KEY = os.getenv("JWT_SECRET_KEY", "jwt-secret")

    # Répertoire pour les images
    UPLOAD_FOLDER = os.path.join(os.getcwd(), "uploads")
    ALLOWED_EXTENSIONS = {"png", "jpg", "jpeg", "gif"}

    # Stripe
    STRIPE_API_KEY = os.getenv("STRIPE_API_KEY")
    STRIPE_PUBLIC_KEY = os.getenv("STRIPE_PUBLIC_KEY")
    STRIPE_WEBHOOK_SECRET = os.getenv("STRIPE_WEBHOOK_SECRET")

    # Google Maps API
    GOOGLE_MAPS_API_KEY = os.getenv("GOOGLE_MAPS_API_KEY")


    # Configuration Brevo SMTP
    MAIL_SERVER = "smtp-relay.brevo.com"
    MAIL_PORT = 587
    MAIL_USE_TLS = True
    MAIL_USERNAME = os.getenv("BREVO_USERNAME")  # Ton email Brevo
    MAIL_PASSWORD = os.getenv("BREVO_SMTP_KEY")  # Clé API SMTP de Brevo
    MAIL_DEFAULT_SENDER = os.getenv("BREVO_EMAIL")


    # Configuration du serveur SMTP
    # MAIL_SERVER = "smtp.gmail.com"  # Serveur SMTP (ex: Gmail)
    # MAIL_PORT = 587  # Port SMTP (TLS)
    # MAIL_USE_TLS = True  # Utilisation de TLS
    # MAIL_USE_SSL = False  # SSL désactivé
    # MAIL_USERNAME = os.getenv("EMAIL_USERNAME")  # Ton email
    # MAIL_PASSWORD = os.getenv("EMAIL_PASSWORD")  # Mot de passe ou App Password
    # MAIL_DEFAULT_SENDER = os.getenv("EMAIL_USERNAME")  # Expéditeur des emails
    # MAIL_LOCALHOST = "localhost"

    # URL du frontend pour les liens de confirmation
    FRONTEND_URL = "http://localhost:3000"



class DevelopmentConfig(Config):
    DEBUG = True
    ENV = "development"


class ProductionConfig(Config):
    DEBUG = False
    ENV = "production"


config = {
    "development": DevelopmentConfig,
    "production": ProductionConfig,
    "default": DevelopmentConfig
}