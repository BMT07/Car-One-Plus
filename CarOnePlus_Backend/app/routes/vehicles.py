from flask import Blueprint, request, jsonify, url_for, send_from_directory
from flask_jwt_extended import jwt_required, get_jwt_identity
from app.models import Vehicle, VehicleImage, User, db

import os
from werkzeug.utils import secure_filename
from flask import current_app
import logging



bp = Blueprint("vehicles", __name__, url_prefix="/vehicles")

# Configuration du logging
logging.basicConfig(level=logging.DEBUG, format='%(asctime)s - %(levelname)s - %(message)s')
logger = logging.getLogger(__name__)

def get_upload_folder():
    path = os.path.join(current_app.root_path, "static", "uploads", "vehicles")
    return path


def serialize_vehicle(vehicle):
    """Transforme un objet Vehicle en dictionnaire JSON."""
    return {
        "id": vehicle.id,
        "owner_id": vehicle.owner_id,
        "title": vehicle.title,
        "description": vehicle.description,
        "price_per_day": vehicle.price_per_day,
        "localisation": vehicle.localisation,
        "puissance": vehicle.puissance,
        "type_de_carburant": vehicle.type_de_carburant,
        "type_de_vehicule": vehicle.type_de_vehicule,
        "vitesse": vehicle.vitesse,
        "transmission": vehicle.transmission,
        "nbreSieges": vehicle.nbreSieges,
        "lat": vehicle.lat,
        "lng": vehicle.lng,
        "available": vehicle.available,
        "created_at": vehicle.created_at,
        "images": [
            url_for("vehicles.get_vehicle_image", filename=image.file_name, _external=True)
            for image in vehicle.images
        ],
    }



@bp.route("/list", methods=["GET"])
def list_vehicles():
    """Liste paginée des véhicules avec filtres par localisation, prix et disponibilité."""
    try:
        query = Vehicle.query

        # Filtre par localisation
        localisation = request.args.get("localisation")
        if localisation:
            query = query.filter(Vehicle.localisation.ilike(f"%{localisation}%"))

        # Filtre par prix minimum et maximum
        min_price = request.args.get("min_price", type=float)
        max_price = request.args.get("max_price", type=float)
        if min_price is not None:
            query = query.filter(Vehicle.price_per_day >= min_price)
        if max_price is not None:
            query = query.filter(Vehicle.price_per_day <= max_price)
        
        # Filtre par type de véhicule
        vehicle_type = request.args.get("type_de_vehicule")
        if vehicle_type:
            query = query.filter(Vehicle.type_de_vehicule == vehicle_type)

        #Filtre par disponibilité - par défaut, ne montrer que les véhicules disponibles
        available = request.args.get("available", default="true")
        is_available = available.lower() in ["true", "1", "yes"]
        query = query.filter(Vehicle.available == is_available)

        # Pagination
        limit = request.args.get("limit", default=10, type=int)
        offset = request.args.get("offset", default=0, type=int)

        # Nombre total de véhicules après filtrage
        total_count = query.count()

        # Appliquer la pagination
        vehicles = query.offset(offset).limit(limit).all()

        return jsonify({
            "total": total_count,
            "limit": limit,
            "offset": offset,
            "vehicles": [serialize_vehicle(vehicle) for vehicle in vehicles],
        }), 200
    except Exception as e:
        return jsonify({"error": str(e)}), 500


# 2. Ajouter un véhicule (propriétaire authentifié)
@bp.route("/add", methods=["POST"])
@jwt_required()
def create_vehicle():
    data = request.get_json()
    user_id = get_jwt_identity()

    # Validation des données
    # if not all(k in data for k in ("title", "description", "price_per_day", "localisation", "puissance", "type_de_carburant", "type_de_vehicule")):
    #     return jsonify({"message": "Missing required fields"}), 400
    print(data)
    print(user_id)
    # Création du véhicule
    vehicle = Vehicle(
        owner_id=user_id,
        title=data["title"],
        description=data["description"],
        price_per_day=data["price_per_day"],
        localisation=data["localisation"],
        puissance=data["puissance"],
        type_de_carburant=data["type_de_carburant"],
        type_de_vehicule=data["type_de_vehicule"],
        vitesse = data["vitesse"],
        transmission = data["transmission"],
        nbreSieges = data["nbreSieges"],
        available=data.get("available", True)
    )
    db.session.add(vehicle)
    db.session.commit()

    return jsonify({"message": "Vehicle created successfully!", "id": vehicle.id}), 201

# 3. Modifier un véhicule (propriétaire uniquement)
@bp.route("update/<int:vehicle_id>", methods=["PUT"])
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
    vehicle.localisation = data.get("localisation", vehicle.localisation)
    vehicle.puissance = data.get("puissance", vehicle.puissance)
    vehicle.vitesse = data.get("vitesse", vehicle.vitesse)
    vehicle.transmission = data.get("transmission", vehicle.transmission)
    vehicle.type_de_carburant = data.get("type_de_carburant", vehicle.type_de_carburant)
    vehicle.type_de_vehicule = data.get("type_de_vehicule", vehicle.type_de_vehicule)
    vehicle.nbreSieges = data.get("nbreSieges", vehicle.nbreSieges)
    vehicle.available = data.get("available", vehicle.available)

    db.session.commit()
    return jsonify({"message": "Vehicle updated successfully!"}), 200

# 4. Supprimer un véhicule (propriétaire uniquement)
@bp.route("delete/<int:vehicle_id>", methods=["DELETE"])
@jwt_required()
def delete_vehicle(vehicle_id):
    user_id = get_jwt_identity()

    vehicle = Vehicle.query.filter_by(id=vehicle_id, owner_id=user_id).first()
    if not vehicle:
        return jsonify({"message": "Vehicle not found or unauthorized"}), 404

    db.session.delete(vehicle)
    db.session.commit()
    return jsonify({"message": "Vehicle deleted successfully!"}), 200


@bp.route("/my_vehicles", methods=["GET"])
@jwt_required()
def my_vehicles():
    try:
        user_id = get_jwt_identity()

        # user = User.query.get(user_id)
        # if not user:
        #     return jsonify({"message": "user not found"})

        vehicles = Vehicle.query.filter_by(owner_id=user_id).all()

        return jsonify({
            "vehicles": [serialize_vehicle(vehicle) for vehicle in vehicles],
        }), 200
    except Exception as e:
        return jsonify({"error": str(e)}), 500




# afficher d'un vehicule par son ID
@bp.route("/<int:vehicle_id>", methods=["GET"])
def list_images(vehicle_id):
    vehicle = Vehicle.query.get(vehicle_id)
    if not vehicle:
        return jsonify({"message": "Vehicle not found"}), 404

    return jsonify(
        {
          "vehicle": serialize_vehicle(vehicle)
        } 
    ), 200


@bp.route('/images/<filename>')
def get_vehicle_image(filename):
    UPLOAD_FOLDER = get_upload_folder()
    """Retourne une image de véhicule à partir de son nom de fichier."""
    return send_from_directory(os.path.join(os.getcwd(), UPLOAD_FOLDER), filename)


MAX_FILE_SIZE = 16 * 1024 * 1024  # 5 Mo
ALLOWED_EXTENSIONS = {"png", "jpg", "jpeg", "gif"}

def allowed_file(filename):
    return '.' in filename and filename.rsplit('.', 1)[1].lower() in ALLOWED_EXTENSIONS

@bp.route("/upload_image", methods=["POST"])
@jwt_required()
def upload_vehicle_image():
    """Upload une image pour un véhicule donné."""
    user_id = get_jwt_identity()
    logger.debug(f"User ID: {user_id}")  # Débogage

    vehicle_id = int(request.form.get("vehicle_id"))
    logger.debug(f"Vehicle ID: {vehicle_id}")  # Débogage

    if not vehicle_id:
        logger.warning("Vehicle ID is missing")  # Débogage
        return jsonify({"message": "Vehicle ID is required"}), 400

    vehicle = Vehicle.query.filter_by(id=vehicle_id, owner_id=user_id).first()
    if not vehicle:
        logger.warning("Vehicle not found or unauthorized")  # Débogage
        return jsonify({"message": "Vehicle not found or unauthorized"}), 404

    if "file" not in request.files:
        logger.warning("No file uploaded")  # Débogage
        return jsonify({"message": "No file uploaded"}), 400

    file = request.files["file"]
    logger.debug(f"File received: {file.filename}")  # Débogage

    if file.filename == "":
        logger.warning("No file selected")  # Débogage
        return jsonify({"message": "No file selected"}), 400

    if file and allowed_file(file.filename):
        logger.debug("File is allowed")  # Débogage

        file.seek(0, os.SEEK_END)  # Aller à la fin du fichier pour mesurer la taille
        file_size = file.tell()  # Obtenir la taille sans lire le fichier
        file.seek(0)  # Remettre le curseur au début après vérification
        logger.debug(f"File size: {file_size} bytes")  # Débogage

        if file_size > MAX_FILE_SIZE:
            logger.warning("File is too large")  # Débogage
            return jsonify({"message": "File is too large (max 16MB)"}), 400

        filename = secure_filename(file.filename)
        logger.debug(f"Secure filename: {filename}")  # Débogage

        UPLOAD_FOLDER = get_upload_folder()
        logger.debug(f"Upload folder: {UPLOAD_FOLDER}")  # Débogage

        if not os.path.exists(UPLOAD_FOLDER):
            logger.info("Creating upload folder")  # Débogage
            os.makedirs(UPLOAD_FOLDER)

        file_path = os.path.join(UPLOAD_FOLDER, filename)
        logger.debug(f"Saving file to: {file_path}")  # Débogage
        file.save(file_path)

        # Enregistrer l'image dans la base de données
        vehicle_image = VehicleImage(vehicle_id=vehicle.id, file_name=filename, file_path=file_path)
        db.session.add(vehicle_image)
        db.session.commit()
        logger.info("Image saved to database")  # Débogage

        image_url = url_for("vehicles.get_vehicle_image", filename=filename, _external=True)
        logger.debug(f"Image URL: {image_url}")  # Débogage
        return jsonify({"message": "Image uploaded successfully", "file_path": image_url}), 200

    logger.warning("Invalid file type")  # Débogage
    return jsonify({"message": "Invalid file type"}), 400


@bp.route("/available_vehicles", methods=["GET"])
def get_available_vehicles():
    """Récupère la liste paginée des véhicules disponibles avec leurs images."""
    try:
        # Paramètres de pagination
        limit = request.args.get("limit", default=10, type=int)
        offset = request.args.get("offset", default=0, type=int)

        # Filtrer les véhicules disponibles
        query = Vehicle.query.filter_by(available=True)

        # Compter le nombre total de véhicules disponibles
        total_count = query.count()

        # Appliquer la pagination
        vehicles = query.offset(offset).limit(limit).all()

        return jsonify({
            "total": total_count,
            "limit": limit,
            "offset": offset,
            "vehicles": [serialize_vehicle(vehicle) for vehicle in vehicles],
        }), 200
    except Exception as e:
        return jsonify({"error": str(e)}), 500
