from flask import Blueprint, request, jsonify
from flask_jwt_extended import create_access_token, jwt_required, get_jwt_identity
from app.models import User, db

bp = Blueprint("auth", __name__, url_prefix="/auth")

# Route pour l'inscription
@bp.route("/register", methods=["POST"])
def register():
    data = request.get_json()

    # Validation des champs requis
    if not data.get("email") or not data.get("password"):
        return jsonify({"message": "Email and password are required"}), 400

    # Vérification si l'utilisateur existe déjà
    if User.query.filter_by(email=data["email"]).first():
        return jsonify({"message": "User already exists"}), 409

    # Création de l'utilisateur
    new_user = User(email=data["email"])
    new_user.set_password(data["password"])  # Hachage du mot de passe
    db.session.add(new_user)
    db.session.commit()

    return jsonify({"message": "User registered successfully!"}), 201


# Route pour la connexion
@bp.route("/login", methods=["POST"])
def login():
    data = request.get_json()

    # Validation des champs requis
    if not data.get("email") or not data.get("password"):
        return jsonify({"message": "Email and password are required"}), 400

    # Recherche de l'utilisateur
    user = User.query.filter_by(email=data["email"]).first()
    if not user or not user.check_password(data["password"]):
        return jsonify({"message": "Invalid email or password"}), 401

    # Création du token JWT
    access_token = create_access_token(identity=str(user.id))
    return jsonify({"access_token": access_token, "message": "Login successful"}), 200


@bp.route("/profile", methods=["GET"])
@jwt_required()
def profile():
    user_id = get_jwt_identity()  # Récupérer l'identité depuis le JWT
    user = User.query.get(user_id)
    if not user:
        return jsonify({"message": "User not found"}), 404

    return jsonify({
        "email": user.email,
        "created_at": user.created_at
    }), 200



@bp.route("/test-db", methods=["GET"])
def test_db():
    user = User.query.first()
    if user:
        return jsonify({"message": "Database connected!", "user": user.email})
    else:
        return jsonify({"message": "Database connected! No users found."})
