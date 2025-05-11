from flask import Blueprint

bp = Blueprint("home", __name__)  # pas de url_prefix ici

@bp.route("/")
def index():
    return "Bienvenue sur CarOnePlus 🚗"
