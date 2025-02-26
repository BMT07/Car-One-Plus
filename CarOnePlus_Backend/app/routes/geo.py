from flask import Blueprint, request, jsonify, current_app
import requests
from app.models import Vehicle, db

bp = Blueprint("geo", __name__, url_prefix="/geo")

# Route : Convertir une adresse en coordonnées géographiques
@bp.route("/geocode", methods=["POST"])
def geocode():
    data = request.get_json()
    address = data.get("address")
    vehicle_id = data.get("vehicle_id")

    if not address or not vehicle_id:
        return jsonify({"error": "Address and vehicle_id are required"}), 400

    api_key = current_app.config["GOOGLE_MAPS_API_KEY"]
    url = f"https://maps.googleapis.com/maps/api/geocode/json?address={address}&key={api_key}"

    response = requests.get(url)
    if response.status_code != 200:
        return jsonify({"error": "Failed to fetch geocode data"}), response.status_code

    data = response.json()
    if data["status"] != "OK":
        return jsonify({"error": data["status"]}), 400

    location = data["results"][0]["geometry"]["location"]

    # Mettre à jour les coordonnées du véhicule
    vehicle = Vehicle.query.get(vehicle_id)
    if not vehicle:
        return jsonify({"error": "Vehicle not found"}), 404

    vehicle.lat = location["lat"]
    vehicle.lng = location["lng"]
    db.session.commit()

    return jsonify({
        "message": "Coordinates updated successfully",
        "vehicle_id": vehicle_id,
        "lat": vehicle.lat,
        "lng": vehicle.lng
    }), 200

# Route : Trouver des véhicules proches
@bp.route("/nearby", methods=["GET"])
def nearby():
    lat = request.args.get("lat", type=float)
    lng = request.args.get("lng", type=float)
    radius = request.args.get("radius", default=5, type=int)  # Rayon en kilomètres

    if not lat or not lng:
        return jsonify({"error": "Latitude and longitude are required"}), 400

    # Filtrer les véhicules dans le rayon spécifié
    query = db.session.query(Vehicle).filter(
        Vehicle.lat.isnot(None),
        Vehicle.lng.isnot(None)
    ).filter(
        db.func.pow(Vehicle.lat - lat, 2) + db.func.pow(Vehicle.lng - lng, 2) <= db.func.pow(radius / 111, 2)
    )

    vehicles = query.all()
    results = [
        {
            "id": v.id,
            "title": v.title,
            "description": v.description,
            "price_per_day": v.price_per_day,
            "available": v.available,
            "lat": v.lat,
            "lng": v.lng
        }
        for v in vehicles
    ]

    return jsonify(results), 200
