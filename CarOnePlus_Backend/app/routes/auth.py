from flask import Blueprint, jsonify
from app.models import User

bp = Blueprint("auth", __name__, url_prefix="/auth")

@bp.route("/test-db", methods=["GET"])
def test_db():
    user = User.query.first()
    if user:
        return jsonify({"message": "Database connected!", "user": user.email})
    else:
        return jsonify({"message": "Database connected! No users found."})
