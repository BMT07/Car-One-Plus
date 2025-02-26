from flask import Blueprint, request, jsonify
from flask_jwt_extended import jwt_required, get_jwt_identity
from app.models import Incident, User, Reservation, db

bp = Blueprint("incidents", __name__, url_prefix="/incidents")

@bp.route("/report", methods=["POST"])
@jwt_required()
def report_incident():
    user_id = get_jwt_identity()
    data = request.get_json()
    reservation_id = data.get("reservation_id")
    description = data.get("description")

    if not reservation_id or not description:
        return jsonify({"error": "Reservation ID and description are required"}), 400

    # Vérifier si la réservation existe et appartient à l'utilisateur
    reservation = Reservation.query.filter_by(id=reservation_id, user_id=user_id).first()
    if not reservation:
        return jsonify({"error": "Reservation not found or not authorized"}), 404

    # Créer un nouvel incident
    incident = Incident(
        reservation_id=reservation_id,
        user_id=user_id,
        description=description
    )
    db.session.add(incident)
    db.session.commit()

    return jsonify({"message": "Incident reported successfully", "incident_id": incident.id}), 201

@bp.route("/", methods=["GET"])
@jwt_required()
def list_incidents():
    user_id = get_jwt_identity()
    incidents = Incident.query.filter_by(user_id=user_id).all()

    results = [
        {
            "id": i.id,
            "reservation_id": i.reservation_id,
            "description": i.description,
            "status": i.status,
            "created_at": i.created_at
        }
        for i in incidents
    ]
    return jsonify(results), 200
