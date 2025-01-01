from flask import Blueprint, request, jsonify
from flask_jwt_extended import jwt_required, get_jwt_identity
from app.models import Vehicle, VehicleImage, User, db

import os
from werkzeug.utils import secure_filename
from flask import current_app


bp = Blueprint("vehicles", __name__, url_prefix="/vehicles")

# 1. Afficher la liste des véhicules
@bp.route("/", methods=["GET"])
def list_vehicles():

    query = Vehicle.query

    # Filtre par localisation
    location = request.args.get("location")
    if location:
        query = query.filter(Vehicle.location.ilike(f"%{location}%"))

    # Filtre par prix minimum et maximum
    min_price = request.args.get("min_price", type=float)
    max_price = request.args.get("max_price", type=float)
    if min_price is not None:
        query = query.filter(Vehicle.price_per_day >= min_price)
    if max_price is not None:
        query = query.filter(Vehicle.price_per_day <= max_price)

    # Filtre par disponibilité
    available = request.args.get("available")
    if available is not None:
        # Convertir la chaîne en booléen
        is_available = available.lower() == "true"
        query = query.filter(Vehicle.available == is_available)

    # Récupérer les résultats
    vehicles = query.all()
    return jsonify([
        {
            "id": v.id,
            "title": v.title,
            "description": v.description,
            "price_per_day": v.price_per_day,
            "location": v.location,
            "available": v.available,
            "owner_id": v.owner_id
        } for v in vehicles
    ]), 200



# 2. Ajouter un véhicule (propriétaire authentifié)
@bp.route("/", methods=["POST"])
@jwt_required()
def create_vehicle():
    data = request.get_json()
    user_id = get_jwt_identity()

    # Validation des données
    if not all(k in data for k in ("title", "description", "price_per_day", "location")):
        return jsonify({"message": "Missing required fields"}), 400

    # Création du véhicule
    vehicle = Vehicle(
        owner_id=user_id,
        title=data["title"],
        description=data["description"],
        price_per_day=data["price_per_day"],
        location=data["location"],
        available=data.get("available", True)
    )
    db.session.add(vehicle)
    db.session.commit()

    return jsonify({"message": "Vehicle created successfully!", "id": vehicle.id}), 201

# 3. Modifier un véhicule (propriétaire uniquement)
@bp.route("/<int:vehicle_id>", methods=["PUT"])
@jwt_required()
def update_vehicle(vehicle_id):
    data = request.get_json()
    user_id = get_jwt_identity()

    vehicle = Vehicle.query.filter_by(id=vehicle_id, owner_id=user_id).first()
    if not vehicle:
        return jsonify({"message": "Vehicle not found or unauthorized"}), 404

    # Mise à jour des champs
    vehicle.title = data.get("title", vehicle.title)
    vehicle.description = data.get("description", vehicle.description)
    vehicle.price_per_day = data.get("price_per_day", vehicle.price_per_day)
    vehicle.location = data.get("location", vehicle.location)
    vehicle.available = data.get("available", vehicle.available)

    db.session.commit()
    return jsonify({"message": "Vehicle updated successfully!"}), 200

# 4. Supprimer un véhicule (propriétaire uniquement)
@bp.route("/<int:vehicle_id>", methods=["DELETE"])
@jwt_required()
def delete_vehicle(vehicle_id):
    user_id = get_jwt_identity()

    vehicle = Vehicle.query.filter_by(id=vehicle_id, owner_id=user_id).first()
    if not vehicle:
        return jsonify({"message": "Vehicle not found or unauthorized"}), 404

    db.session.delete(vehicle)
    db.session.commit()
    return jsonify({"message": "Vehicle deleted successfully!"}), 200


@bp.route("/my-vehicles", methods=["GET"])
@jwt_required()
def my_vehicles():
    user_id = get_jwt_identity()

    vehicles = Vehicle.query.filter_by(owner_id=user_id).all()
    return jsonify([
        {
            "id": v.id,
            "title": v.title,
            "description": v.description,
            "price_per_day": v.price_per_day,
            "location": v.location,
            "available": v.available
        } for v in vehicles
    ]), 200

@bp.route("/<int:vehicle_id>/upload-image", methods=["POST"])
@jwt_required()
def upload_image(vehicle_id):
    user_id = get_jwt_identity()

    # Vérifier si le véhicule appartient à l'utilisateur
    vehicle = Vehicle.query.filter_by(id=vehicle_id, owner_id=user_id).first()
    if not vehicle:
        return jsonify({"message": "Vehicle not found or unauthorized"}), 404

    # Vérifier si un fichier est présent dans la requête
    if "image" not in request.files:
        return jsonify({"message": "No file part"}), 400
    file = request.files["image"]

    # Vérifier si le fichier a un nom valide
    if file.filename == "":
        return jsonify({"message": "No selected file"}), 400

    # Vérifier l'extension du fichier
    if not allowed_file(file.filename):
        return jsonify({"message": "Invalid file type"}), 400

    # Enregistrer le fichier
    file_name = secure_filename(file.filename)
    file_path = os.path.join(current_app.config["UPLOAD_FOLDER"], file_name)
    file.save(file_path)

    # Ajouter l'image à la base de données
    vehicle_image = VehicleImage(vehicle_id=vehicle_id, file_name=file_name, file_path=file_path)
    db.session.add(vehicle_image)
    db.session.commit()

    return jsonify({"message": "Image uploaded successfully!", "file_name": file_name}), 201

def allowed_file(filename):
    return "." in filename and filename.rsplit(".", 1)[1].lower() in current_app.config["ALLOWED_EXTENSIONS"]

@bp.route("/<int:vehicle_id>/images", methods=["GET"])
def list_images(vehicle_id):
    vehicle = Vehicle.query.get(vehicle_id)
    if not vehicle:
        return jsonify({"message": "Vehicle not found"}), 404

    return jsonify([
        {
            "id": img.id,
            "file_name": img.file_name,
            "file_path": img.file_path,
            "uploaded_at": img.uploaded_at
        } for img in vehicle.images
    ]), 200
