from flask import Blueprint, request, jsonify
from flask_jwt_extended import jwt_required, get_jwt_identity
from app.models import Reservation, Vehicle, VehicleImage, User, db
from datetime import datetime
from dateutil import parser  # Ajoute cette librairie pour gérer plusieurs formats

bp = Blueprint("reservations", __name__, url_prefix="/reservations")

@bp.route("/", methods=["POST"])
@jwt_required()
def create_reservation():
    user_id = get_jwt_identity()
    data = request.get_json()

    # Vérifier les champs requis
    if not data.get("vehicle_id") or not data.get("start_date") or not data.get("end_date"):
        return jsonify({"message": "Vehicle ID, start date, and end date are required"}), 400

    # Vérification et conversion des dates
    # try:
    #     start_date = datetime.strptime(data["start_date"], "%Y-%m-%d")
    #     end_date = datetime.strptime(data["end_date"], "%Y-%m-%d")
    # except ValueError:
    #     return jsonify({"message": "Invalid date format. Use YYYY-MM-DD"}), 400

    try:
     start_date = parser.isoparse(data["start_date"]).date()  # Convertir ISO 8601 en date
     end_date = parser.isoparse(data["end_date"]).date()
    except ValueError:
        return jsonify({"message": "Invalid date format. Use ISO 8601 or YYYY-MM-DD"}), 400

    # Vérifier que start_date < end_date
    if start_date >= end_date:
        return jsonify({"message": "Start date must be before end date"}), 400

    # Vérifier si le véhicule existe
    vehicle = Vehicle.query.filter_by(id=data["vehicle_id"]).first()
    if not vehicle:
        return jsonify({"message": "Vehicle not found"}), 404

    # Récupérer toutes les réservations existantes pour ce véhicule
    existing_reservations = Reservation.query.filter(
        Reservation.vehicle_id == vehicle.id,
        Reservation.start_date <= end_date,
        Reservation.end_date >= start_date
    ).all()

    for reservation in existing_reservations:
        if reservation.status == "CONFIRMER":
            return jsonify({"message": "Vehicle is already booked for the selected dates"}), 400
        elif reservation.status == "EN ATTENTE":
            # Vérifier si les dates se chevauchent
            if not (end_date < reservation.start_date or start_date > reservation.end_date):
                return jsonify({"message": "A pending reservation already exists for these dates"}), 400

    # Si tout est bon, créer la réservation
    new_reservation = Reservation(
        user_id=user_id,
        vehicle_id=vehicle.id,
        start_date=start_date,
        end_date=end_date,
        status="EN ATTENTE"
    )
    db.session.add(new_reservation)
    db.session.commit()

    return jsonify({
        "message": "Reservation created successfully",
        "reservation": {
            "id": new_reservation.id,
            "vehicle_id": new_reservation.vehicle_id,
            "start_date": new_reservation.start_date.strftime("%Y-%m-%d"),
            "end_date": new_reservation.end_date.strftime("%Y-%m-%d"),
            "status": new_reservation.status
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
            "start_date": r.start_date.strftime("%Y-%m-%d"),
            "end_date": r.end_date.strftime("%Y-%m-%d"),
            "status": r.status
        } for r in reservations
    ]), 200


@bp.route("/<int:reservation_id>/status", methods=["PATCH"])
@jwt_required()
def update_reservation_status(reservation_id):
    user_id = get_jwt_identity()
    data = request.get_json()

    # Vérifier si le statut est fourni
    if not data.get("status"):
        return jsonify({"message": "Status is required"}), 400

    # Vérifier que le statut est valide
    valid_statuses = ["EN ATTENTE", "CONFIRMER"]
    if data["status"] not in valid_statuses:
        return jsonify({"message": f"Invalid status. Valid statuses are: {valid_statuses}"}), 400

    # Récupérer la réservation
    reservation = Reservation.query.get(reservation_id)
    if not reservation:
        return jsonify({"message": "Reservation not found"}), 404

    # Récupérer le véhicule
    vehicle = Vehicle.query.get(reservation.vehicle_id)
    if not vehicle:
        return jsonify({"message": "Vehicle not found"}), 404

    # Vérifier si l'utilisateur est le propriétaire du véhicule
    if int(vehicle.owner_id) != int(user_id):
        return jsonify({"message": "Unauthorized to modify this reservation"}), 403

    # Modifier le statut de la réservation
    reservation.status = data["status"]
    db.session.commit()

    return jsonify({
        "message": "Reservation status updated successfully",
        "reservation": {
            "id": reservation.id,
            "vehicle_id": reservation.vehicle_id,
            "start_date": reservation.start_date.strftime("%Y-%m-%d"),
            "end_date": reservation.end_date.strftime("%Y-%m-%d"),
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
            "start_date": r.start_date.strftime("%Y-%m-%d"),
            "end_date": r.end_date.strftime("%Y-%m-%d"),
            "status": r.status,
            "user_id": r.user_id
        } for r in reservations
    ]), 200
