from flask import Blueprint, request, jsonify, current_app, url_for,  send_from_directory
from flask_jwt_extended import create_access_token, jwt_required, get_jwt_identity, get_jwt
from werkzeug.utils import secure_filename
from app.models import User, UserImage, db, RevokedToken, PasswordResetCode
import os
from flask_mail import Message
from itsdangerous import URLSafeTimedSerializer
from app import mail
import random
from datetime import timedelta


bp = Blueprint("auth", __name__, url_prefix="/auth")


revoked_tokens = set()

reset_tokens = {}

UPLOAD_FOLDER = "static/users_photos/"
ALLOWED_EXTENSIONS = {"png", "jpg", "jpeg"}

# Vérifier l'extension du fichier
def allowed_file(filename):
    return "." in filename and filename.rsplit(".", 1)[1].lower() in ALLOWED_EXTENSIONS


# Initialiser le générateur de token
def get_serializer():
    serializer = URLSafeTimedSerializer(current_app.config["SECRET_KEY"])
    return serializer


@bp.route("/activate/<token>", methods=["GET"])
def activate_account(token):
    serializer = get_serializer()
    try:
        # ✅ Vérifier le token
        email = serializer.loads(token, salt="email-confirmation", max_age=3600)  # Expire après 1h
    except:
        return jsonify({"message": "Invalid or expired token"}), 400

    # ✅ Trouver l'utilisateur et activer son compte
    user = User.query.filter_by(email=email).first()

    if not user:
        return jsonify({"message": "User not found"}), 404

    if user.is_active:
        return jsonify({"message": "Account already activated"}), 200

    user.is_active = True
    db.session.commit()

    return jsonify({"message": "Account activated successfully! You can now log in."}), 200


def send_activation_email(email, activation_link):
    msg = Message(
        subject="Activate Your Account",
        sender=current_app.config["MAIL_DEFAULT_SENDER"],
        recipients=[email],
        body=f"Hello,\n\nClick the link below to activate your account:\n{activation_link}\n\nIf you did not request this, please ignore this email."
    )
    mail.send(msg)


# Route pour l'inscription
@bp.route("/register", methods=["POST"])
def register():
    data = request.get_json()

    if not data.get("email") or not data.get("password"):
        return jsonify({"message": "Email and password are required"}), 400

    if User.query.filter_by(email=data["email"]).first():
        return jsonify({"message": "User already exists"}), 409
    
    if User.query.filter_by(telephone=data.get("telephone")).first():
        return jsonify({"message": "Phone number already exists"}), 409

    role = data.get("role", "locateur")  # Par défaut, "renter" si non spécifié

    if role not in ["proprietaire", "locateur"]:
        return jsonify({"message": "Invalid role. Must be 'proprietaire' or 'locateur'."}), 400

    new_user = User(
        email=data["email"],
        prenom=data.get("prenom"),
        nom=data.get("nom"),
        telephone=data.get("telephone"),
        role=role,  # On enregistre le rôle choisi
        is_active=False,  # ✅ L'utilisateur n'est PAS activé à l'inscription
    )
    new_user.set_password(data["password"])
    db.session.add(new_user)
    db.session.commit()

    serializer = get_serializer()

    # ✅ Générer un token d'activation
    token = serializer.dumps(new_user.email, salt="email-confirmation")

    # ✅ Construire l'URL d'activation
    activation_link = url_for("auth.activate_account", token=token, _external=True)

    # ✅ Envoyer l'email
    send_activation_email(new_user.email, activation_link)


    return jsonify({"message": "User registered successfully!", "role": role}), 201


# 🌐 Route pour demander la réinitialisation du mot de passe
@bp.route("/request-reset", methods=["POST"])
def request_reset():
    data = request.get_json()
    email = data.get("email")

    if not email:
        return jsonify({"message": "Email is required"}), 400

    user = User.query.filter_by(email=email).first()
    if not user:
        return jsonify({"message": "No account associated with this email."}), 404

    # 🔐 Génération d'un code à 6 chiffres
    verification_code = str(random.randint(100000, 999999))

    # 🔄 Stockage du code dans la base de données
    reset_entry = PasswordResetCode.query.filter_by(user_id=user.id).first()
    if reset_entry:
        reset_entry.code = verification_code  # Met à jour le code existant
    else:
        reset_entry = PasswordResetCode(user_id=user.id, code=verification_code)
        db.session.add(reset_entry)

    db.session.commit()

    # 📧 Envoi de l'email
    msg = Message(
        subject="Password Reset Verification Code",
        sender=current_app.config["MAIL_DEFAULT_SENDER"],
        recipients=[email],
        body=f"Hello,\n\nHere is your password reset code: {verification_code}\n\nIf you did not request this, please ignore this email."
    )
    
    try:
        mail.send(msg)
    except Exception as e:
        current_app.logger.error(f"Failed to send reset email: {str(e)}")
        return jsonify({"message": "Failed to send reset email."}), 500

    return jsonify({"message": "Verification code sent to your email."}), 200


# 🔐 Route pour vérifier le code de réinitialisation
@bp.route("/verify-reset-code", methods=["POST"])
def verify_reset_code():
    data = request.get_json()
    code = data.get("code")

    if not code:
        return jsonify({"message": "Verification code is required"}), 400

    reset_entry = PasswordResetCode.query.filter_by(code=code).first()
    if not reset_entry:
        return jsonify({"message": "Invalid verification code"}), 400

    user = User.query.filter_by(id=reset_entry.user_id).first()

    return jsonify({
        "message": "Code verified successfully", 
        "user_id": user.id
        }), 200


# 🔑 Route pour réinitialiser le mot de passe
@bp.route("/reset-password", methods=["POST"])
def reset_password():
    data = request.get_json()
    user_id = data.get("user_id")
    new_password = data.get("new_password")
    confirm_password = data.get("confirm_password")

    if not new_password or not confirm_password:
        return jsonify({"message": "Both password fields are required."}), 400

    if new_password != confirm_password:
        return jsonify({"message": "Passwords do not match."}), 400

    user = User.query.get(user_id)
    if not user:
        return jsonify({"message": "User not found."}), 404

    user.set_password(new_password)
    db.session.commit()

    return jsonify({"message": "Password has been reset successfully."}), 200



### ✅ Retourner plus d'infos lors de la connexion
@bp.route("/login", methods=["POST"])
def login():
    data = request.get_json()

    if not data.get("email") or not data.get("password"):
        return jsonify({"message": "Email and password are required"}), 400

    user = User.query.filter_by(email=data["email"]).first()

    if not user or not user.check_password(data["password"]):
        return jsonify({"message": "Invalid email or password"}), 401

    if not user.is_active:  # ✅ Vérifier si l'utilisateur est activé
        return jsonify({"message": "Please activate your account via email."}), 403

    access_token = create_access_token(identity=str(user.id), expires_delta=timedelta(hours=24))
    
    return jsonify({
        "access_token": access_token,
        "user": {
            "id": user.id,
            "email": user.email,
            "prenom": user.prenom,
            "nom": user.nom,
            "telephone": user.telephone,
            "role": user.role,
        },
        "message": "Login successful"
    }), 200


# ✅ 1. Amélioration de /profile (ajouter URL de photo)
@bp.route("/profile", methods=["GET"])
@jwt_required()
def profile():
    user_id = get_jwt_identity()
    user = User.query.get(user_id)

    if not user:
        return jsonify({"message": "User not found"}), 404

    # Obtenir la dernière photo si disponible
    user_image = UserImage.query.filter_by(user_id=user.id).order_by(UserImage.id.desc()).first()
    photo_url = url_for('auth.get_image', filename=user_image.file_name, _external=True) if user_image else None

    return jsonify({
        "email": user.email,
        "prenom": user.prenom,
        "nom": user.nom,
        "telephone": user.telephone,
        "role": user.role,
        "photo_url": photo_url,  # ✅ Ajout de l'URL de photo
        "created_at": user.created_at
    }), 200


@bp.route('/images/<filename>')
def get_image(filename):
    return send_from_directory(os.path.join(os.getcwd(), UPLOAD_FOLDER), filename)

### ✅ Upload d'image de profil
MAX_FILE_SIZE = 5 * 1024 * 1024  # 5 Mo

@bp.route("/upload-photo", methods=["POST"])
@jwt_required()
def upload_photo():
    user_id = get_jwt_identity()
    user = User.query.get(user_id)

    if not user:
        return jsonify({"message": "User not found"}), 404

    if "file" not in request.files:
        return jsonify({"message": "No file uploaded"}), 400

    file = request.files["file"]

    if file.filename == "":
        return jsonify({"message": "No file selected"}), 400

    if file and allowed_file(file.filename):
        if len(file.read()) > MAX_FILE_SIZE:  # Vérifie la taille du fichier
            return jsonify({"message": "File is too large (max 5MB)"}), 400
        file.seek(0)  # Revenir au début du fichier après lecture

        filename = secure_filename(file.filename)
        
        # Vérifier et créer le dossier si nécessaire
        if not os.path.exists(UPLOAD_FOLDER):
            os.makedirs(UPLOAD_FOLDER)

        file_path = os.path.join(UPLOAD_FOLDER, filename)
        file.save(file_path)

        user_image = UserImage(user_id=user.id, file_name=filename, file_path=file_path)
        db.session.add(user_image)
        db.session.commit()

        photo_url = url_for('auth.get_image', filename=user_image.file_name, _external=True)
        return jsonify({"message": "Photo uploaded successfully", "file_path": photo_url}), 200

    return jsonify({"message": "Invalid file type"}), 400



### ✅ Modification de profil
@bp.route("/update", methods=["PUT"])
@jwt_required()
def update_profile():
    user_id = get_jwt_identity()
    user = User.query.get(user_id)
    
    if not user:
        return jsonify({"message": "User not found"}), 404

    data = request.get_json()
    
    updated = False  # Vérifie si au moins une donnée a été changée
    
    if "email" in data and data["email"] != user.email:
        user.email = data["email"]
        updated = True
    if "prenom" in data and data["prenom"] != user.prenom:
        user.prenom = data["prenom"]
        updated = True
    if "nom" in data and data["nom"] != user.nom:
        user.nom = data["nom"]
        updated = True
    if "telephone" in data and data["telephone"] != user.telephone:
        user.telephone = data["telephone"]
        updated = True
    if "password" in data:
        user.set_password(data["password"])
        updated = True

    if updated:
        db.session.commit()
        return jsonify({"message": "Profile updated successfully"}), 200
    else:
        return jsonify({"message": "No changes made"}), 200



# @bp.route("/reset-password", methods=["POST"])
# def reset_password():
#     data = request.get_json()
#     email = data.get("email")
#     reset_code = data.get("code")
#     new_password = data.get("new_password")

#     if email not in reset_tokens or reset_tokens[email] != reset_code:
#         return jsonify({"message": "Invalid reset code"}), 400

#     user = User.query.filter_by(email=email).first()
#     if not user:
#         return jsonify({"message": "User not found"}), 404

#     user.set_password(new_password)
#     db.session.commit()

#     del reset_tokens[email]  # Supprime le code utilisé

#     return jsonify({"message": "Password successfully reset"}), 200


@bp.route("/logout", methods=["POST"])
@jwt_required()
def logout():
    jti = get_jwt()["jti"]  # ID du token
    db.session.add(RevokedToken(jti=jti))
    db.session.commit()
    return jsonify({"message": "Déconnexion réussie !"}), 200


### ✅ Suppression de compte
@bp.route("/delete", methods=["DELETE"])
@jwt_required()
def delete_account():
    user_id = get_jwt_identity()
    user = User.query.get(user_id)

    if not user:
        return jsonify({"message": "User not found"}), 404

    # Supprimer toutes les images associées à l'utilisateur
    user_images = UserImage.query.filter_by(user_id=user.id).all()
    for img in user_images:
        if os.path.exists(img.file_path):
            os.remove(img.file_path)
        db.session.delete(img)

    db.session.delete(user)
    db.session.commit()
    return jsonify({"message": "User deleted successfully"}), 204  # Code 204 pour dire "No Content"



@bp.route("/test-db", methods=["GET"])
def test_db():
    user = User.query.first()
    if user:
        return jsonify({"message": "Database connected!", "user": user.email})
    else:
        return jsonify({"message": "Database connected! No users found."})
