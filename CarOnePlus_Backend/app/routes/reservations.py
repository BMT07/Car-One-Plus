from flask import Blueprint, request, jsonify
from flask_jwt_extended import jwt_required, get_jwt_identity
from app.models import Reservation, Vehicle, VehicleImage, User, db

bp = Blueprint("reservations", __name__, url_prefix="/reservations")

@bp.route("/", methods=["POST"])
@jwt_required()
def create_reservation():
    user_id = get_jwt_identity()
    data = request.get_json()

    # Vérifier les champs requis
    if not data.get("vehicle_id") or not data.get("start_date") or not data.get("end_date"):
        return jsonify({"message": "Vehicle ID, start date, and end date are required"}), 400

    # Récupérer le véhicule
    vehicle = Vehicle.query.get(data["vehicle_id"])
    if not vehicle:
        return jsonify({"message": "Vehicle not found"}), 404

    # Vérifier la disponibilité
    existing_reservations = Reservation.query.filter(
        Reservation.vehicle_id == vehicle.id,
        Reservation.status.in_(["pending", "confirmed", "in_progress"]),
        Reservation.start_date <= data["end_date"],
        Reservation.end_date >= data["start_date"]
    ).all()
    if existing_reservations:
        return jsonify({"message": "Vehicle is not available for the selected dates"}), 400

    # Créer la réservation
    reservation = Reservation(
        user_id=user_id,
        vehicle_id=vehicle.id,
        start_date=data["start_date"],
        end_date=data["end_date"],
        status="pending"
    )
    db.session.add(reservation)
    db.session.commit()

    return jsonify({
        "message": "Reservation created successfully",
        "reservation": {
            "id": reservation.id,
            "vehicle_id": reservation.vehicle_id,
            "start_date": reservation.start_date,
            "end_date": reservation.end_date,
            "status": reservation.status
        }
    }), 201


@bp.route("/", methods=["GET"])
@jwt_required()
def get_reservations():
    user_id = get_jwt_identity()

    reservations = Reservation.query.filter_by(user_id=user_id).all()
    return jsonify([
        {
            "id": r.id,
            "vehicle_id": r.vehicle_id,
            "start_date": r.start_date,
            "end_date": r.end_date,
            "status": r.status
        } for r in reservations
    ]), 200


@bp.route("/<int:reservation_id>/status", methods=["PATCH"])
@jwt_required()
def update_reservation_status(reservation_id):
    user_id = get_jwt_identity()
    print(f"Debug: Authenticated User ID: {user_id}")  # Étape 1 : Vérifier l'utilisateur authentifié

    data = request.get_json()
    print(f"Debug: Received Data - {data}")  # Étape 2 : Vérifier les données reçues

    # Vérifier si le statut est fourni
    if not data.get("status"):
        print("Debug: Missing status in request.")
        return jsonify({"message": "Status is required"}), 400

    # Vérifier que le statut est valide
    valid_statuses = ["confirmed", "in_progress", "completed", "cancelled"]
    if data["status"] not in valid_statuses:
        print(f"Debug: Invalid status '{data['status']}' provided.")
        return jsonify({"message": f"Invalid status. Valid statuses are: {valid_statuses}"}), 400

    # Récupérer la réservation
    reservation = Reservation.query.get(reservation_id)
    if not reservation:
        print(f"Debug: Reservation ID {reservation_id} not found.")
        return jsonify({"message": "Reservation not found"}), 404

    print(f"Debug: Reservation Details - {reservation}")  # Étape 3 : Vérifier la réservation

    # Récupérer le véhicule
    vehicle = Vehicle.query.get(reservation.vehicle_id)
    if not vehicle:
        print(f"Debug: Vehicle ID {reservation.vehicle_id} not found.")
        return jsonify({"message": "Vehicle not found"}), 404

    print(f"Debug: Vehicle Details - ID: {vehicle.id}, Owner ID: {vehicle.owner_id}")  # Étape 4 : Vérifier le véhicule

    # Vérifier si l'utilisateur est le propriétaire du véhicule
    if int(vehicle.owner_id) != int(user_id):
        print(f"Debug: Owner mismatch - Authenticated User ID: {user_id}, Vehicle Owner ID: {vehicle.owner_id}")
        return jsonify({"message": "Unauthorized to modify this reservation"}), 403

    # Modifier le statut de la réservation
    reservation.status = data["status"]
    db.session.commit()

    print(f"Debug: Reservation status updated to {data['status']}")  # Étape 5 : Vérifier la mise à jour

    return jsonify({
        "message": "Reservation status updated successfully",
        "reservation": {
            "id": reservation.id,
            "vehicle_id": reservation.vehicle_id,
            "start_date": reservation.start_date,
            "end_date": reservation.end_date,
            "status": reservation.status
        }
    }), 200


@bp.route("/owner", methods=["GET"])
@jwt_required()
def get_reservations_for_owner():
    user_id = get_jwt_identity()

    # Récupérer les véhicules appartenant au propriétaire
    vehicles = Vehicle.query.filter_by(owner_id=user_id).all()
    vehicle_ids = [v.id for v in vehicles]

    # Récupérer les réservations associées à ces véhicules
    reservations = Reservation.query.filter(Reservation.vehicle_id.in_(vehicle_ids)).all()

    return jsonify([
        {
            "id": r.id,
            "vehicle_id": r.vehicle_id,
            "vehicle_title": Vehicle.query.get(r.vehicle_id).title,
            "start_date": r.start_date,
            "end_date": r.end_date,
            "status": r.status,
            "user_id": r.user_id
        } for r in reservations
    ]), 200
