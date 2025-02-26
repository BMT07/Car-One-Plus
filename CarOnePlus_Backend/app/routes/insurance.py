from flask import Blueprint, request, jsonify
from flask_jwt_extended import jwt_required, get_jwt_identity
from app.models import Insurance, Reservation, db

bp = Blueprint("insurance", __name__, url_prefix="/insurance")

@bp.route("/select", methods=["POST"])
@jwt_required()
def select_insurance():
    user_id = get_jwt_identity()
    data = request.get_json()
    reservation_id = data.get("reservation_id")
    insurance_type = data.get("type")
    cost = data.get("cost")

    if not reservation_id or not insurance_type or not cost:
        return jsonify({"error": "Reservation ID, type, and cost are required"}), 400

    # Vérifier la réservation
    reservation = Reservation.query.filter_by(id=reservation_id, user_id=user_id).first()
    if not reservation:
        return jsonify({"error": "Reservation not found or not authorized"}), 404

    # Ajouter l'assurance
    insurance = Insurance(
        reservation_id=reservation_id,
        type=insurance_type,
        cost=cost
    )
    db.session.add(insurance)
    db.session.commit()

    return jsonify({"message": "Insurance selected successfully", "insurance_id": insurance.id}), 201
