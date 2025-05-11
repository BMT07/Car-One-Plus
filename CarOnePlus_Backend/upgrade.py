from flask_migrate import upgrade
from app import create_app
from app import db

app = create_app()

with app.app_context():
    upgrade()
